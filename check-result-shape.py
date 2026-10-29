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

A question whose export predates -349 (no `result_kind` in `api_output`) is reported as
NOT-EMITTED, not as a failure: it means the campaign ran on an API without the hint.
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
    args = ap.parse_args()

    if not os.path.isdir(args.exec_dir):
        print(f"not a directory: {args.exec_dir}", file=sys.stderr)
        return 2
    assertions = load_assertions(args.bank)
    if not assertions:
        print(f"No ASSERTIONS_RESULT_SHAPE found in {args.bank}. Nothing to check "
              "(has the exporter run since the column was added?).")
        return 0

    n_checked = n_pass = n_fail = n_notemitted = 0
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
        if "result_kind" not in api and "representation" not in api:
            n_notemitted += 1
            continue
        n_checked += 1
        passed, details = rsa.check_response(spec, api)
        lang = d.get("language") or d.get("lang") or "?"
        if passed:
            n_pass += 1
        else:
            n_fail += 1
            msgs = [x["message"] for x in details if not x["passed"]]
            failures.append((eid, lang, msgs))

    print(f"Campaign: {os.path.basename(args.exec_dir.rstrip(os.sep))}")
    print(f"Questions with a result-shape assertion: {len(assertions)}")
    print(f"  checked (hint present): {n_checked}   PASS {n_pass}   FAIL {n_fail}")
    print(f"  not emitted (pre-349 export): {n_notemitted}")
    if failures:
        print("\n=== FAIL ===")
        for eid, lang, msgs in failures:
            print(f"  {eid} [{lang}]")
            for m in msgs:
                print(f"     {m}")
    return 1 if (args.strict and n_fail) else 0


if __name__ == "__main__":
    sys.exit(main())
