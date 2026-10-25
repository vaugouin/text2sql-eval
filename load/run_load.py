"""Launcher for the T2S load bench (LOAD-TESTING-004 / -005, Nestor topics/load-testing.md).

Runs from the PC, and only from the PC: the bench must not measure the VPS CPU.
It mirrors the evaluator's pre-flight (`text2sql-eval.sh`), which can read the VPS
state directly because it runs there. The bench cannot, so this launcher reaches
the VPS over SSH (paramiko, like `voice-agent/doc/logs-download/sync_vps_docker.py`)
and does, in one command, what the evaluator does in one place:

  1. work out what the run will do from the scenario and the env, and print a recap;
  2. probe the target API (`GET /`) for reachability, version and `bktrees_ready`;
  3. check on the VPS that every scheduled task is off, that nothing competes, and
     that swap/disk still have room, plus the forbidden time windows (00:00, 06:00-07:30);
  4. ask to confirm, then launch Locust locally as a subprocess.

Why SSH and not the restricted `vps-agent` gate: that gate only runs `.sql` files, so
it cannot read `off.sh` state or run `docker ps`. This launcher uses the full SSH key,
which is encrypted, so run it in your own terminal (it may prompt for the passphrase),
exactly as the sync script and the evaluator hand-off already do.

Usage (from C:\\Users\\vaugo\\Code\\text2sql-eval):

    uv run --no-project --with paramiko python load/run_load.py A
    uv run --no-project --with paramiko python load/run_load.py A --warmup
    uv run --no-project --with paramiko python load/run_load.py E --shape endurance
    uv run --no-project --with paramiko python load/run_load.py B            # refused without --allow-cold

The launcher shells out to `uv run --no-project --with locust locust ...`, so Locust
itself lives in its own ephemeral environment; this process only needs paramiko.
"""

import argparse
import getpass
import json
import os
import socket
import subprocess
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent          # the text2sql-eval clone
LOCUSTFILE = Path(__file__).resolve().parent / "locustfile.py"
RESULTS = Path(__file__).resolve().parent / "results"

# Scenario letter -> the Locust user classes it drives. ProbeUser is always added.
SCENARIOS = {
    "A": ["ApiWarmUser"],
    "B": ["ApiColdUser"],
    "C": ["ApiDetailUser"],
    "D": ["VoiceToolUser"],
    "E": ["TmdbSearchUser", "TmdbPageUser"],
}
API_CLASSES = {"ProbeUser", "ApiWarmUser", "ApiColdUser", "ApiDetailUser"}
# Scheduled tasks that must keep running during a shot, so never flagged as "armed".
SCHEDULED_KEEP = {"chromadb-ensure", "docker-cleanup"}


# --- env files (same shape as the evaluator and the sync script) --------------------------------

def read_env_file(path):
    values = {}
    if path and Path(path).is_file():
        for line in Path(path).read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                values[key.strip()] = value.strip().strip('"').strip("'")
    return values


# --- the question bank, counted the same way locustfile.load_questions picks it -----------------

def count_questions(flag, lang):
    n = 0
    for path in sorted((ROOT / "data" / "evaluation").glob("*.json")):
        try:
            item = json.loads(path.read_text(encoding="utf-8"))
        except (ValueError, OSError):
            continue
        if item.get("deleted") or not item.get(flag):
            continue
        for one in (("en", "fr") if lang == "both" else (lang,)):
            if (item.get(f"question_{one}") or "").strip():
                n += 1
    return n


# --- the API probe (GET /), from the PC, exactly what the bench will hit -------------------------

def probe_api(base, key):
    import urllib.error
    import urllib.request
    req = urllib.request.Request(base.rstrip("/") + "/", headers={"X-API-Key": key or ""})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            body = json.loads(resp.read().decode("utf-8"))
            return {"status": resp.status, "api_version": body.get("api_version", "absent"),
                    "bktrees_ready": body.get("bktrees_ready", "absent")}
    except urllib.error.HTTPError as e:
        return {"status": e.code, "api_version": "?", "bktrees_ready": "?"}
    except (urllib.error.URLError, socket.timeout, ValueError) as e:
        return {"status": f"unreachable ({type(e).__name__})", "api_version": "?", "bktrees_ready": "?"}


# --- the VPS state, over SSH ---------------------------------------------------------------------

# A read-only snapshot. The off.sh scan reproduces the one in text2sql-eval.sh: a task is OFF
# when its folder holds the flag file CRON_OFF its off.sh writes (or still a <name>-off.sh left
# by the old renaming off.sh, before 2026-10-25), ARMED otherwise. The scripts of the folder
# that read CRON_OFF give the container names. Run through `bash -s` whatever the login shell.
# $ROOT defaults to ~/docker.
REMOTE_SNAPSHOT = r"""
ROOT="${DOCKER_ROOT:-$HOME/docker}"
echo "VPS_TIME=$(date '+%H:%M')"
echo "VPS_WHEN=$(date '+%Y-%m-%d %H:%M:%S %Z')"
armed=""; off=""; names=""
for o in "$ROOT"/*/off.sh; do
  [ -f "$o" ] || continue
  d=$(dirname "$o"); repo=$(basename "$d")
  case " %KEEP% " in *" $repo "*) continue ;; esac
  for l in $(grep -l CRON_OFF "$d"/*.sh 2>/dev/null) "$d"/*-off.sh; do
    case "$(basename "$l")" in on.sh|off.sh|"*-off.sh") ;; *) names="$names $(basename "$l" .sh | sed 's/-off$//')" ;; esac
  done
  names="$names $repo"
  if [ -f "$d/CRON_OFF" ] || ls "$d"/*-off.sh >/dev/null 2>&1; then off="$off $repo"; else armed="$armed $repo"; fi
done
echo "ARMED=$armed"
echo "OFF=$off"
pat=$(echo $names | tr ' ' '\n' | grep -v '^$' | sort -u | paste -sd'|' -)
comp=""
[ -n "$pat" ] && comp=$(docker ps --format '{{.Names}}' | grep -E "^($pat)" | tr '\n' ' ' || true)
echo "COMPETING=$comp"
echo "SWAP=$(free -m | awk '/Swap:/{print $3\"/\"$2}')"
echo "MEM=$(free -m | awk '/Mem:/{print $3\"/\"$2}')"
echo "DISK=$(df -Pm / | awk 'NR==2{print $4\" free / \"$2}')"
"""


def vps_connect(cfg):
    import paramiko
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    host = cfg.get("VPS_HOST")
    if not host:
        raise SystemExit("No VPS_HOST: point --vps-env at the .env that holds VPS_HOST/VPS_USER/VPS_KEY_FILE "
                         "(default: voice-agent/doc/logs-download/.env).")
    kwargs = dict(hostname=host, port=int(cfg.get("VPS_PORT", 22)),
                  username=cfg.get("VPS_USER", "root"), timeout=20,
                  allow_agent=True, look_for_keys=True)
    key_file = cfg.get("VPS_KEY_FILE")
    if key_file:
        kwargs["key_filename"] = os.path.expanduser(key_file)
        passphrase = cfg.get("VPS_KEY_PASSPHRASE") or os.environ.get("VPS_KEY_PASSPHRASE")
        if passphrase:
            kwargs["passphrase"] = passphrase
    try:
        client.connect(**kwargs)
    except paramiko.PasswordRequiredException:
        kwargs["passphrase"] = getpass.getpass(f"Passphrase for {key_file}: ")
        client.connect(**kwargs)
    return client


def vps_snapshot(cfg, docker_root):
    client = vps_connect(cfg)
    try:
        script = REMOTE_SNAPSHOT.replace("%KEEP%", " ".join(sorted(SCHEDULED_KEEP)))
        if docker_root:
            script = f'DOCKER_ROOT="{docker_root}"\n' + script
        stdin, stdout, stderr = client.exec_command("bash -s")
        stdin.write(script)
        stdin.channel.shutdown_write()
        out = stdout.read().decode("utf-8", "replace")
        err = stderr.read().decode("utf-8", "replace").strip()
    finally:
        client.close()
    state = {}
    for line in out.splitlines():
        if "=" in line:
            k, v = line.split("=", 1)
            state[k.strip()] = v.strip()
    if err:
        state.setdefault("_stderr", err)
    return state


# --- git freshness of this clone (mirrors the evaluator) ----------------------------------------

def git_line():
    try:
        subprocess.run(["git", "-C", str(ROOT), "fetch", "-q", "origin"],
                       capture_output=True, timeout=30)
        behind = subprocess.run(["git", "-C", str(ROOT), "rev-list", "--count", "HEAD..origin/main"],
                                 capture_output=True, text=True).stdout.strip()
        dirty = subprocess.run(["git", "-C", str(ROOT), "status", "--porcelain", "--untracked-files=no"],
                               capture_output=True, text=True).stdout.strip()
        head = subprocess.run(["git", "-C", str(ROOT), "log", "-1", "--format=%h %cs"],
                              capture_output=True, text=True).stdout.strip()
        if behind and behind != "0":
            return ("warn", f"clone is {behind} commit(s) behind origin/main: git pull --ff-only first.")
        if dirty:
            return ("warn", f"clone carries uncommitted edits: {dirty.replace(chr(10), ' ')}")
        return ("ok", f"clone up to date ({head}).")
    except Exception as e:                                           # noqa: BLE001 - informational only
        return ("warn", f"git check skipped ({type(e).__name__}).")


# --- main ----------------------------------------------------------------------------------------

def main():
    p = argparse.ArgumentParser(description="Pre-flight and launch the T2S load bench.")
    p.add_argument("scenario", help="A, B, C, D or E (see topics/load-testing.md), or 'classes' with --classes")
    p.add_argument("--classes", help="explicit Locust user classes, space-separated, instead of a scenario letter")
    p.add_argument("--with-chat", action="store_true", help="scenario D: add VoiceChatUser (one OpenAI turn per request)")
    p.add_argument("--warmup", action="store_true", help="scenario A at 1 user for 10 min, to warm the cache once")
    p.add_argument("--lang", default=None, help="en, fr or both (default: LOAD_LANG or en)")
    p.add_argument("--shape", choices=["steps", "endurance"], default=None)
    p.add_argument("--steps", default=None, help="users per step, e.g. 1,2,4")
    p.add_argument("--step-seconds", default=None)
    p.add_argument("--endurance-minutes", default=None)
    p.add_argument("--users", default=None, help="endurance: simultaneous users")
    p.add_argument("--question-limit", default=None)
    p.add_argument("--csv", default=None, help="results prefix (default: results/<date>-<scenario>)")
    p.add_argument("--allow-cold", action="store_true", help="scenario B: confirm the paid cold run")
    p.add_argument("--vps-env", default=None, help="path to the .env with VPS_HOST/VPS_USER/VPS_KEY_FILE")
    p.add_argument("--docker-root", default=None, help="VPS docker root (default: ~/docker)")
    p.add_argument("--no-vps", action="store_true", help="skip the SSH state check (recap and API probe only)")
    p.add_argument("--force", action="store_true", help="launch inside a forbidden time window anyway")
    p.add_argument("--yes", action="store_true", help="skip the confirmation prompt")
    p.add_argument("locust_args", nargs="*", help="extra args passed through to locust (after --)")
    args = p.parse_args()

    # --- resolve env: process env wins over text2sql-eval/.env, VPS config from its own .env ------
    env = {**read_env_file(ROOT / ".env"), **os.environ}
    default_vps_env = Path(os.path.expanduser("~/Code/voice-agent/doc/logs-download/.env"))
    vps_cfg = {**read_env_file(args.vps_env or default_vps_env), **os.environ}

    scenario = args.scenario.upper()
    if args.classes:
        classes = args.classes.split()
        scenario = "custom"
    elif scenario in SCENARIOS:
        classes = list(SCENARIOS[scenario])
        if scenario == "D" and args.with_chat:
            classes.append("VoiceChatUser")
    else:
        raise SystemExit(f"Unknown scenario {args.scenario!r}: use A, B, C, D, E or --classes.")
    user_classes = ["ProbeUser"] + classes

    # --- build the env the Locust subprocess will read -------------------------------------------
    lang = args.lang or env.get("LOAD_LANG", "en")
    shape = args.shape or env.get("LOAD_SHAPE", "steps")
    sub = dict(os.environ)
    sub["LOAD_LANG"] = lang
    sub["LOAD_SHAPE"] = shape
    if args.warmup:
        sub["LOAD_STEPS"], sub["LOAD_STEP_SECONDS"], shape = "1", "600", "steps"
        sub["LOAD_SHAPE"] = "steps"
    if args.steps:
        sub["LOAD_STEPS"] = args.steps
    if args.step_seconds:
        sub["LOAD_STEP_SECONDS"] = args.step_seconds
    if args.endurance_minutes:
        sub["LOAD_ENDURANCE_MINUTES"] = args.endurance_minutes
    if args.users:
        sub["LOAD_USERS"] = args.users
    if args.question_limit:
        sub["LOAD_QUESTION_LIMIT"] = args.question_limit
    if "B" in [scenario] or "ApiColdUser" in classes:
        if not args.allow_cold and env.get("LOAD_ALLOW_COLD") != "yes":
            print("Scenario B calls the whole pipeline with the cache off: every question is paid for,")
            print("roughly 8 to 50 USD per 1,000 questions. Announce the budget, then add --allow-cold.")
            return 2
        sub["LOAD_ALLOW_COLD"] = "yes"

    api_base = env.get("LOAD_API_BASE") or \
        f"{env.get('TEXT2SQL_API_URL', 'http://www.vaugouin.com').rstrip('/')}:{env.get('API_PORT_GREEN', '8187')}"
    site_base = env.get("LOAD_SITE_BASE", "https://www.vaugouin.com")
    api_key = env.get("LOAD_API_KEY") or env.get("TEXT2SQL_API_KEY")
    question_flag = "is_eval" if "ApiColdUser" in classes else "is_showcase"
    q_count = count_questions(question_flag, lang)
    q_limit = int(sub.get("LOAD_QUESTION_LIMIT", env.get("LOAD_QUESTION_LIMIT", "30")))
    steps = sub.get("LOAD_STEPS", env.get("LOAD_STEPS", "1,2,4"))
    step_seconds = sub.get("LOAD_STEP_SECONDS", env.get("LOAD_STEP_SECONDS", "300"))
    cache = "off both ways (paid)" if "ApiColdUser" in classes else "on"

    csv_prefix = args.csv or str(RESULTS / f"{datetime.now():%Y%m%d}-{scenario}{'-warmup' if args.warmup else ''}")

    # --- probe the API and the VPS ---------------------------------------------------------------
    api = probe_api(api_base, api_key)
    vps = None if args.no_vps else None
    vps_error = None
    if not args.no_vps:
        try:
            vps = vps_snapshot(vps_cfg, args.docker_root)
        except Exception as e:                                       # noqa: BLE001 - reported in recap
            vps_error = f"{type(e).__name__}: {e}"

    # --- recap -----------------------------------------------------------------------------------
    version = (ROOT / "VERSION").read_text().strip() if (ROOT / "VERSION").is_file() else "?"
    print()
    print("================ T2S load bench: pre-flight ================")
    print(f"Date        : {datetime.now():%Y-%m-%d %H:%M:%S}")
    print(f"Bench       : text2sql-eval {version}, load/locustfile.py")
    print(f"Scenario    : {scenario}  ({', '.join(user_classes)})")
    print(f"API target  : {api_base}   HTTP {api['status']}")
    print(f"              answers api_version={api['api_version']}, bktrees_ready={api['bktrees_ready']}")
    if any(c in API_CLASSES for c in user_classes) is False:
        print("Site target : " + site_base)
    else:
        print(f"Site target : {site_base} (used by D and E scenarios)")
    if shape == "endurance":
        minutes = sub.get("LOAD_ENDURANCE_MINUTES", env.get("LOAD_ENDURANCE_MINUTES", "45"))
        users = sub.get("LOAD_USERS", env.get("LOAD_USERS", "2"))
        print(f"Shape       : endurance, {users} users for {minutes} min, plus the probe")
    else:
        print(f"Shape       : steps {steps} users, {step_seconds} s each, plus the probe")
    print(f"Cache       : {cache}")
    print(f"Questions   : bank has {q_count} {question_flag} ({lang}); the run samples {q_limit} (seed "
          f"{sub.get('LOAD_SEED', env.get('LOAD_SEED', '42'))})")
    print(f"Results     : {csv_prefix}_steps.csv  (+ Locust CSV/HTML)")
    print(f"API key     : {'set' if api_key else 'MISSING (set LOAD_API_KEY or TEXT2SQL_API_KEY)'}")
    print()
    print("Both halves of a session (same rule as an evaluation campaign):")
    print("  before : on the VPS  bash ~/docker/off-all.sh   (+ docker stop any crawler still up)")
    print("           then start  ~/docker/tools/watch-load.sh  in its own terminal (LOAD-TESTING-005)")
    print("  after  : on the VPS  bash ~/docker/on-all.sh   (re-enables only what off-all.sh switched off)")

    # --- checks ----------------------------------------------------------------------------------
    warnings = 0

    def warn(msg):
        nonlocal warnings
        warnings += 1
        print(f"  ! {msg}")

    print()
    print("Checks:")
    if not api_key:
        warn("no API key: the probe and the API scenarios cannot authenticate.")
    if isinstance(api["status"], int) and api["status"] != 200:
        warn(f"the API answered HTTP {api['status']}, not 200: it may be down or warming up.")
    elif not isinstance(api["status"], int):
        warn(f"the API is {api['status']}: check the colour in service and the URL.")
    if api["bktrees_ready"] == "false" or api["bktrees_ready"] is False:
        warn("bktrees_ready is false: the API is still warming up, early latencies will be inflated. Wait.")

    level, msg = git_line()
    (warn if level == "warn" else print)(f"  - {msg}" if level == "ok" else msg)

    if args.no_vps:
        print("  - VPS state check skipped (--no-vps).")
    elif vps_error:
        warn(f"could not reach the VPS to check process state: {vps_error}")
        warn("verify by hand on the VPS, or rerun without --no-vps once SSH works.")
    elif vps:
        if vps.get("_stderr"):
            warn(f"VPS snapshot reported: {vps['_stderr']}")
        armed = vps.get("ARMED", "").split()
        if armed:
            warn("scheduled tasks still ARMED, cron can start them mid-shot: " + " ".join(armed))
            print("    switch them off first:  bash ~/docker/off-all.sh")
        else:
            print("  - every scheduled task under ~/docker is switched off.")
        if vps.get("OFF"):
            print("  - already off:" + vps["OFF"])
        comp = vps.get("COMPETING", "").split()
        if comp:
            warn("containers running now (off.sh will not stop them; embedding-update changes the answers): "
                 + " ".join(comp))
            print("    docker stop them and wait, or pick another window.")
        else:
            print("  - no competing container running.")
        print(f"  - VPS now {vps.get('VPS_WHEN', '?')}; swap {vps.get('SWAP', '?')} MB, "
              f"mem {vps.get('MEM', '?')} MB, disk {vps.get('DISK', '?')} MB.")
        # Forbidden windows: 00:00 (docker-cleanup) and 06:00-07:30 (CSV exports off-all.sh misses).
        t = vps.get("VPS_TIME", "")
        forbidden = False
        try:
            hh, mm = (int(x) for x in t.split(":"))
            minutes_of_day = hh * 60 + mm
            forbidden = (hh == 0 and mm == 0) or (6 * 60 <= minutes_of_day <= 7 * 60 + 30)
        except ValueError:
            pass
        if forbidden:
            if args.force:
                warn(f"VPS time {t} is in a forbidden window (00:00 or 06:00-07:30); --force set, continuing.")
            else:
                warn(f"VPS time {t} is in a forbidden window (00:00 or 06:00-07:30): CSV exports / cleanup "
                     "run then. Wait, or pass --force.")
                print("==========================================================")
                print("Aborted on a forbidden time window. Nothing launched.")
                return 1
    if warnings == 0:
        print("  - no warning.")
    print("==========================================================")
    print()

    # --- confirm ---------------------------------------------------------------------------------
    if not api_key:
        print("Refusing to launch without an API key.")
        return 2
    if not args.yes:
        if not sys.stdin.isatty():
            print("No terminal to confirm on and --yes not set: aborted, nothing launched.")
            return 1
        answer = input(f"Type 'yes' to launch this shot ({warnings} warning(s) above), anything else aborts: ")
        if answer.strip() != "yes":
            print("Aborted. Nothing was launched.")
            return 1

    # --- launch Locust locally -------------------------------------------------------------------
    RESULTS.mkdir(parents=True, exist_ok=True)
    cmd = ["uv", "run", "--no-project", "--with", "locust", "locust",
           "-f", str(LOCUSTFILE), "--headless", "--only-summary",
           *user_classes, "--csv", csv_prefix, "--html", f"{csv_prefix}.html",
           *args.locust_args]
    print("Launching:", " ".join(cmd))
    print()
    result = subprocess.run(cmd, env=sub)
    print()
    print("Shot finished. On the VPS: Ctrl-C the watcher, then  bash ~/docker/on-all.sh")
    print(f"Then copy ~/load-watch/<date>/ into {RESULTS}, and report one line per step in topics/load-testing.md.")
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
