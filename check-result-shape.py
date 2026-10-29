"""Out-of-score check of the result-shape hint (FASTAPI-TEXT2SQL-349).

Reads a campaign's execution exports and, for every question that carries an
ASSERTIONS_RESULT_SHAPE in the bank, compares the API's `result_kind`, `result_columns`
and `representation` (already captured in each export's `api_output`) against the
assertion. Prints a PASS/FAIL report and never touches the campaign score: the campaign
pass is `query_result` alone (harness/harness_lib.py). This check evaluates the rendering
feature without perturbing the accuracy number.

It needs no database and no live API, like checks/bench-result-entity.py in
fastapi-text2sql: the API response is on disk in the execution export, the assertion is in
the bank JSON. Run it anywhere the two folders are synced.

Usage:
    uv run --no-project python check-result-shape.py <execution_export_dir> [--strict]
    # <execution_export_dir> is one campaign tuple, e.g.
    #   .../shared_data/text2sql-eval/evaluation_execution/001.001.020_en_gpt-6-sol_..._...
    # --strict exits 1 when at least one confirmed FAIL is found (default: always 0).

A question whose export predates -349 (no `result_kind` in `api_output`) is RECOMPUTED
offline from the stored `sql_query` and `result` rows, with the same deterministic module
the API uses, so an old campaign is checked without any re-run or token cost (pass
--no-recompute to disable). Only an export that also lacks the rows stays NOT-EMITTED; that
one genuinely needs re-execution against the live API.
"""
import argparse
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import result_shape_assertions as rsa

DEFAULT_BANK = os.path.join(HERE, "data", "evaluation")

# The result-shape hint is DETERMINISTIC in the SQL executed and the result rows (see
# fastapi-text2sql/result_shape.py). So an export that predates -349, with no `result_kind`
# in its api_output but with `sql_query` and `result` on disk, can be checked WITHOUT
# re-running the pipeline: recompute the hint offline with the very module the API uses,
# zero LLM calls and zero cost. That is the point of the RECALC path below: forcing the
# recompute of old evaluations without re-executing them. Re-execution is only needed when
# the export lacks the rows too. The import is best-effort; if result_shape cannot be found,
# a pre-349 export stays NOT-EMITTED exactly as before.


def _load_result_shape(explicit_dir=None):
    """Import fastapi-text2sql's result_shape module, or return None.

    Looks in, in order: --fastapi-dir, $FASTAPI_TEXT2SQL_DIR, then sibling clones next to
    this repo (the live-colour clones on the VPS are suffixed -green / -blue)."""
    candidates = []
    if explicit_dir:
        candidates.append(explicit_dir)
    env = os.getenv("FASTAPI_TEXT2SQL_DIR")
    if env:
        candidates.append(env)
    parent = os.path.dirname(HERE)
    candidates += [os.path.join(parent, name) for name in
                   ("fastapi-text2sql", "fastapi-text2sql-green", "fastapi-text2sql-blue")]
    for d in candidates:
        if d and os.path.isfile(os.path.join(d, "result_shape.py")):
            if d not in sys.path:
                sys.path.insert(0, d)
            try:
                import result_shape  # noqa: F401
                return result_shape
            except Exception:
                return None
    return None


def recompute_hint(result_shape, api):
    """Recompute {result_kind, result_columns, representation} from a pre-349 export.

    Returns a response dict in the API's wire shape (result_columns), or None when the
    export lacks the rows needed to recompute (then re-execution is genuinely required)."""
    if result_shape is None:
        return None
    if "sql_query" not in api or "result" not in api:
        return None
    c = result_shape.classify_result(api.get("sql_query") or "", api.get("result") or [],
                                     api.get("result_entity") or "")
    return {"result_kind": c["result_kind"], "result_columns": c["columns"],
            "representation": c["representation"]}


def load_assertions(bank_dir):
    """Map evaluation_id -> ASSERTIONS_RESULT_SHAPE string, over the bank JSON exports."""
    out = {}
    for path in glob.glob(os.path.join(bank_dir, "*.json")):
        try:
            d = json.load(open(path, encoding="utf-8"))
        except Exception:
            continue
        spec = (d.get("assertions") or {}).get("result_shape")
        if spec and str(spec).strip():
            out[d.get("evaluation_id")] = str(spec)
    return out


def main():
    ap = argparse.ArgumentParser(description="Out-of-score result-shape check (FASTAPI-TEXT2SQL-349).")
    ap.add_argument("exec_dir", help="One campaign's evaluation_execution tuple folder.")
    ap.add_argument("--bank", default=DEFAULT_BANK, help="Bank JSON folder (default: data/evaluation).")
    ap.add_argument("--strict", action="store_true", help="Exit 1 if any confirmed FAIL.")
    ap.add_argument("--fastapi-dir", default="", help="Path to the fastapi-text2sql clone "
                    "(for recomputing the hint on pre-349 exports). Defaults to a sibling clone.")
    ap.add_argument("--no-recompute", action="store_true", help="Do not recompute the hint on "
                    "pre-349 exports; report them as NOT-EMITTED (the old behaviour).")
    args = ap.parse_args()
    result_shape = None if args.no_recompute else _load_result_shape(args.fastapi_dir or None)

    if not os.path.isdir(args.exec_dir):
        print(f"not a directory: {args.exec_dir}", file=sys.stderr)
        return 2
    assertions = load_assertions(args.bank)
    if not assertions:
        print(f"No ASSERTIONS_RESULT_SHAPE found in {args.bank}. Nothing to check "
              "(has the exporter run since the column was added?).")
        return 0

    n_checked = n_pass = n_fail = n_notemitted = n_recalc = 0
    failures = []
    for path in sorted(glob.glob(os.path.join(args.exec_dir, "*.json"))):
        try:
            d = json.load(open(path, encoding="utf-8"))
        except Exception:
            continue
        eid = d.get("evaluation_id")
        spec = assertions.get(eid)
        if not spec:
            continue
        api = d.get("api_output") or {}
        if isinstance(api, str):
            try:
                api = json.loads(api)
            except Exception:
                api = {}
        recomputed = False
        if "result_kind" not in api and "representation" not in api:
            resp = recompute_hint(result_shape, api)
            if resp is None:
                n_notemitted += 1
                continue
            recomputed = True
        else:
            resp = api
        n_checked += 1
        if recomputed:
            n_recalc += 1
        passed, details = rsa.check_response(spec, resp)
        lang = d.get("language") or d.get("lang") or "?"
        if passed:
            n_pass += 1
        else:
            n_fail += 1
            msgs = [x["message"] for x in details if not x["passed"]]
            failures.append((eid, lang, recomputed, msgs))

    print(f"Campaign: {os.path.basename(args.exec_dir.rstrip(os.sep))}")
    print(f"Questions with a result-shape assertion: {len(assertions)}")
    print(f"  checked: {n_checked}   PASS {n_pass}   FAIL {n_fail}"
          + (f"   (of which {n_recalc} recomputed offline, no re-run)" if n_recalc else ""))
    print(f"  not emitted and not recomputable (no rows on disk): {n_notemitted}")
    if failures:
        print("\n=== FAIL ===")
        for eid, lang, recomputed, msgs in failures:
            print(f"  {eid} [{lang}]{' (recomputed)' if recomputed else ''}")
            for m in msgs:
                print(f"     {m}")
    return 1 if (args.strict and n_fail) else 0


if __name__ == "__main__":
    sys.exit(main())
