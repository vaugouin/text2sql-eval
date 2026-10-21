"""Load bench of the T2S stack before public demos (LOAD-TESTING-004, Nestor topics/load-testing.md).

Run from the PC, never from the VPS (the bench would measure its own CPU). Switch the updates off
first (~/docker/off-all.sh), avoid 00:00 and 06:00-07:30, and start tools/watch-load.sh on the VPS
(LOAD-TESTING-005) before the first request. Commands and scenarios: README.md, section 14.

One run = one scenario, chosen by the user classes named on the command line, plus ProbeUser:
  A  ApiWarmUser        POST /search/text2sql, showcase questions, cache on (a prepared demo)
  B  ApiColdUser        same route, cache off both ways (a question from the floor); costs money,
                        refused unless LOAD_ALLOW_COLD=yes
  C  ApiDetailUser      GET /movies|/persons|/series/{id} (the synchronous routes)
  D  VoiceToolUser      voice-agent POST /tool/text2sql (the fronts' real path, retries included)
     VoiceChatUser      voice-agent POST /text-chat (one OpenAI call per turn on top)
  E  TmdbSearchUser     tmdb-front /tmdb/?search= (PHP-FPM, curl to the API)
     TmdbPageUser       tmdb-front movie pages, no search (must keep answering when E saturates)
  ProbeUser             GET / on the API every second, always one, whatever the step: when it slows
                        down while OpenAI is not involved, the API event loop is blocked (-006)

Load shape (LOAD_SHAPE): "steps" (default) holds 1, 2, then 4 users (LOAD_STEPS) for
LOAD_STEP_SECONDS each; "endurance" holds LOAD_USERS users for LOAD_ENDURANCE_MINUTES.
At the end, <--csv prefix>_steps.csv gets one line per step and request name: count, failures,
429s, p50, p90, p99, max (seconds). Locust's own CSVs aggregate the whole run, steps mixed.
"""

import csv
import json
import os
import random
import time
from pathlib import Path

from locust import HttpUser, LoadTestShape, between, constant, events, task

ROOT = Path(__file__).resolve().parent.parent


def read_env_file(path):
    values = {}
    if path.is_file():
        for line in path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                values[key.strip()] = value.strip().strip('"').strip("'")
    return values


ENV = {**read_env_file(ROOT / ".env"), **os.environ}


def env(name, default=""):
    return ENV.get(name, default) or default


# Targets. The API is plain HTTP on its port; Green 8187 serves 1.1.19.
API_BASE = env("LOAD_API_BASE", f"{env('TEXT2SQL_API_URL', 'http://www.vaugouin.com').rstrip('/')}:{env('API_PORT_GREEN', '8187')}")
# A dedicated key, added to API_KEYS for the occasion, keeps the bench's lines apart in the API logs.
API_KEY = env("LOAD_API_KEY") or env("TEXT2SQL_API_KEY")
SITE_BASE = env("LOAD_SITE_BASE", "https://www.vaugouin.com")
LANG = env("LOAD_LANG", "en")  # en, fr, or both
THINK = [float(x) for x in env("LOAD_THINK_SECONDS", "5,15").split(",")]
API_TIMEOUT = float(env("LOAD_API_TIMEOUT_SECONDS", "120"))
SEED = int(env("LOAD_SEED", "42"))
QUESTION_LIMIT = int(env("LOAD_QUESTION_LIMIT", "30"))

MOVIE_IDS = env("LOAD_MOVIE_IDS", "238,550,680,155,13,424,129,278").split(",")
PERSON_IDS = env("LOAD_PERSON_IDS", "287,31,138,1032,5292").split(",")
SERIE_IDS = env("LOAD_SERIE_IDS", "1399,1396,1668,60625").split(",")


def load_questions(flag):
    """Questions of the bank carrying `flag` (is_showcase, is_eval), as (text, language) pairs.
    A fixed seed and a limit: the warm scenario must ask a small, repeatable set, or it is not warm."""
    pairs = []
    for path in sorted((ROOT / "data" / "evaluation").glob("*.json")):
        item = json.loads(path.read_text(encoding="utf-8"))
        if item.get("deleted") or not item.get(flag):
            continue
        for lang in (("en", "fr") if LANG == "both" else (LANG,)):
            text = (item.get(f"question_{lang}") or "").strip()
            if text:
                pairs.append((text, lang))
    random.Random(SEED).shuffle(pairs)
    return pairs[:QUESTION_LIMIT] if QUESTION_LIMIT > 0 else pairs


SHOWCASE = load_questions("is_showcase")
EVAL = load_questions("is_eval")


def api_headers():
    return {"X-API-Key": API_KEY, "Content-Type": "application/json"}


def check_t2s(response):
    """A 200 that carries an error is a failure too: that is how the API reports most of its own."""
    if response.status_code != 200:
        response.failure(f"HTTP {response.status_code}")
        return
    try:
        body = response.json()
    except ValueError:
        response.failure("not JSON")
        return
    if isinstance(body, dict) and body.get("error"):
        response.failure(f"API error: {str(body['error'])[:120]}")
    else:
        response.success()


class ProbeUser(HttpUser):
    fixed_count = 1
    host = API_BASE
    wait_time = constant(1)

    def on_start(self):
        self.client.headers.update(api_headers())

    @task
    def probe(self):
        self.client.get("/", name="probe GET /", timeout=30)


class ApiWarmUser(HttpUser):
    host = API_BASE
    wait_time = between(*THINK)

    def on_start(self):
        self.client.headers.update(api_headers())

    @task
    def search(self):
        question, lang = random.choice(SHOWCASE)
        payload = {"question": question, "ui_language": lang, "retrieve_from_cache": True,
                   "store_to_cache": True, "complex_question_processing": True}
        with self.client.post("/search/text2sql", json=payload, name="A text2sql warm",
                              timeout=API_TIMEOUT, catch_response=True) as response:
            check_t2s(response)


class ApiColdUser(HttpUser):
    host = API_BASE
    wait_time = between(*THINK)

    def on_start(self):
        self.client.headers.update(api_headers())

    @task
    def search(self):
        question, lang = random.choice(EVAL)
        payload = {"question": question, "ui_language": lang, "retrieve_from_cache": False,
                   "store_to_cache": False, "complex_question_processing": True}
        with self.client.post("/search/text2sql", json=payload, name="B text2sql cold",
                              timeout=API_TIMEOUT, catch_response=True) as response:
            check_t2s(response)


class ApiDetailUser(HttpUser):
    host = API_BASE
    wait_time = between(*THINK)

    def on_start(self):
        self.client.headers.update(api_headers())

    @task(3)
    def movie(self):
        self.client.get(f"/movies/{random.choice(MOVIE_IDS)}", params={"ui_language": LANG if LANG != "both" else "en"},
                        name="C GET /movies/{id}", timeout=API_TIMEOUT)

    @task(2)
    def person(self):
        self.client.get(f"/persons/{random.choice(PERSON_IDS)}", name="C GET /persons/{id}", timeout=API_TIMEOUT)

    @task(1)
    def serie(self):
        self.client.get(f"/series/{random.choice(SERIE_IDS)}", name="C GET /series/{id}", timeout=API_TIMEOUT)


class VoiceToolUser(HttpUser):
    host = SITE_BASE
    wait_time = between(*THINK)

    @task
    def tool_text2sql(self):
        question, lang = random.choice(SHOWCASE)
        with self.client.post("/voice-agent/tool/text2sql", json={"query": question, "ui_language": lang},
                              name="D voice /tool/text2sql", timeout=API_TIMEOUT + 30,
                              catch_response=True) as response:
            check_t2s(response)


class VoiceChatUser(HttpUser):
    host = SITE_BASE
    wait_time = between(*THINK)

    @task
    def text_chat(self):
        question, _lang = random.choice(SHOWCASE)
        with self.client.post("/voice-agent/text-chat", json={"message": question, "context": []},
                              name="D voice /text-chat", timeout=API_TIMEOUT + 60,
                              catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")


class TmdbSearchUser(HttpUser):
    host = SITE_BASE
    wait_time = between(*THINK)

    @task
    def search(self):
        question, _lang = random.choice(SHOWCASE)
        with self.client.get("/tmdb/", params={"search": question}, name="E tmdb search",
                             timeout=API_TIMEOUT, catch_response=True) as response:
            # tmdb-front answers 200 even when the API failed; its error line carries this id.
            if response.status_code != 200:
                response.failure(f"HTTP {response.status_code}")
            elif 'id="t2straceerror"' in response.text:
                response.failure("search error shown on the page")
            else:
                response.success()


class TmdbPageUser(HttpUser):
    host = SITE_BASE
    wait_time = between(*THINK)

    @task
    def movie_page(self):
        self.client.get("/tmdb/movie.php", params={"movieid": random.choice(MOVIE_IDS)},
                        name="E tmdb movie page", timeout=60)


# --- Load shape ---------------------------------------------------------------------------------

STEPS = [int(x) for x in env("LOAD_STEPS", "1,2,4").split(",")]
STEP_SECONDS = int(env("LOAD_STEP_SECONDS", "300"))
ENDURANCE_USERS = int(env("LOAD_USERS", "2"))
ENDURANCE_SECONDS = int(float(env("LOAD_ENDURANCE_MINUTES", "45")) * 60)
SHAPE = env("LOAD_SHAPE", "steps")


def step_of(elapsed):
    """The step a request belongs to, by its start time: the label written in _steps.csv."""
    if SHAPE == "endurance":
        return f"endurance {ENDURANCE_USERS} users"
    index = min(int(elapsed // STEP_SECONDS), len(STEPS) - 1)
    return f"step {index + 1}: {STEPS[index]} users"


if SHAPE == "endurance":
    class EnduranceShape(LoadTestShape):
        def tick(self):
            if self.get_run_time() >= ENDURANCE_SECONDS:
                return None
            return ENDURANCE_USERS + 1, ENDURANCE_USERS + 1  # + ProbeUser
else:
    class StepShape(LoadTestShape):
        def tick(self):
            run_time = self.get_run_time()
            if run_time >= STEP_SECONDS * len(STEPS):
                return None
            users = STEPS[int(run_time // STEP_SECONDS)]
            return users + 1, users + 1  # + ProbeUser


# --- Per-step recorder ----------------------------------------------------------------------------

RECORDS = []
STARTED = [None]


@events.test_start.add_listener
def on_test_start(environment, **_kwargs):
    STARTED[0] = time.time()
    names = {cls.__name__ for cls in (environment.user_classes or [])}
    if not API_KEY and names & {"ProbeUser", "ApiWarmUser", "ApiColdUser", "ApiDetailUser"}:
        print("No API key: set LOAD_API_KEY, or TEXT2SQL_API_KEY in text2sql-eval/.env.")
        environment.runner.quit()
    if "ApiColdUser" in names and env("LOAD_ALLOW_COLD") != "yes":
        print("Scenario B calls the whole pipeline with the cache off, so every question is paid for:")
        print("roughly 8 to 50 USD per 1,000 questions depending on the models in service.")
        print("Announce the budget, then rerun with LOAD_ALLOW_COLD=yes.")
        environment.runner.quit()
    if SHAPE == "endurance":
        print(f"Endurance: {ENDURANCE_USERS} users for {ENDURANCE_SECONDS // 60} min, plus the probe.")
    else:
        print(f"Steps: {STEPS} users, {STEP_SECONDS} s each, plus the probe. API {API_BASE}, site {SITE_BASE}.")


@events.request.add_listener
def on_request(request_type, name, response_time, response_length, response=None, exception=None, start_time=None, **_kwargs):
    began = start_time or time.time()
    status = getattr(response, "status_code", 0) if response is not None else 0
    RECORDS.append((step_of(began - (STARTED[0] or began)), name, response_time / 1000.0,
                    exception is not None, status == 429))


def percentile(sorted_values, share):
    if not sorted_values:
        return ""
    index = min(len(sorted_values) - 1, max(0, int(round(share * (len(sorted_values) - 1)))))
    return round(sorted_values[index], 2)


@events.quitting.add_listener
def on_quitting(environment, **_kwargs):
    prefix = environment.parsed_options.csv_prefix if environment.parsed_options else None
    if not RECORDS or not prefix:
        return
    groups = {}
    for step, name, seconds, failed, throttled in RECORDS:
        groups.setdefault((step, name), []).append((seconds, failed, throttled))
    out = Path(f"{prefix}_steps.csv")
    with out.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["step", "name", "count", "failures", "http_429", "p50_s", "p90_s", "p99_s", "max_s"])
        for (step, name), rows in sorted(groups.items()):
            times = sorted(r[0] for r in rows)
            writer.writerow([step, name, len(rows), sum(r[1] for r in rows), sum(r[2] for r in rows),
                             percentile(times, 0.5), percentile(times, 0.9), percentile(times, 0.99),
                             round(times[-1], 2)])
    print(f"Per-step results: {out}")
