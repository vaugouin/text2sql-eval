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

`answer` clauses (FASTAPI-TEXT2SQL-368: no database id in the banner sentence) are tallied on
their own line, like the intent clauses, so adding them to the bank does not move the shape
figures. They are read from `api_output` even on an export whose shape is recomputed or
missing.

The same clause also runs as a bank-wide invariant (Philippe, 2026-11-08), on EVERY execution of
the folder, asserted or not: no database identifier in the answer to a question that typed none
(`rsa.ANSWER_INVARIANT_SPEC`, `rsa.question_types_id`). It is reported on its own line and needs
nothing in the bank; a question that types an id is skipped.
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


def load_questions(bank_dir):
    """Map evaluation_id -> (QUESTION, QUESTION_FR), for the bank-wide answer invariant."""
    out = {}
    for path in glob.glob(os.path.join(bank_dir, "*.json")):
        try:
            d = json.load(open(path, encoding="utf-8"))
        except Exception:
            continue
        out[d.get("evaluation_id")] = (d.get("question_en") or "", d.get("question_fr") or "")
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
    questions = load_questions(args.bank)
    if not assertions:
        print(f"No ASSERTIONS_RESULT_SHAPE found in {args.bank} "
              "(has the exporter run since the column was added?); answer invariant only.")

    # The export folder keeps every file ever written for the tuple: a question replayed after a
    # retire has several, and a retired row's file stays on disk. Keep the latest execution row
    # per question, or the counts double and a stale response is judged (seen on 1.1.20,
    # 2026-11-05: 136 checks for 76 questions).
    latest = {}
    for path in glob.glob(os.path.join(args.exec_dir, "*.json")):
        try:
            d = json.load(open(path, encoding="utf-8"))
        except Exception:
            continue
        eid = d.get("evaluation_id")
        row = d.get("execution_row_id") or 0
        if eid not in latest or row > latest[eid][0]:
            latest[eid] = (row, d)

    n_checked = n_pass = n_fail = n_notemitted = n_recalc = 0
    n_intent_q = n_intent_pending = n_intent_pass = n_intent_fail = 0
    n_answer_q = n_answer_pass = n_answer_fail = 0
    failures = []
    answer_failures = []
    n_inv = n_inv_pass = n_inv_skip = n_inv_unknown = 0
    inv_failures = []
    for eid in sorted(latest, key=lambda e: (e is None, e)):
        d = latest[eid][1]
        api = d.get("api_output") or {}
        if isinstance(api, str):
            try:
                api = json.loads(api)
            except Exception:
                api = {}
        lang = d.get("language") or d.get("lang") or "?"
        # Bank-wide invariant (FASTAPI-TEXT2SQL-368, Philippe 2026-11-08): no database identifier
        # in the answer to a question that typed none. Every execution, asserted or not.
        if eid not in questions:
            n_inv_unknown += 1
        else:
            ok, message = rsa.check_answer_invariant(api, *questions[eid])
            if ok is None:
                n_inv_skip += 1
            else:
                n_inv += 1
                if ok:
                    n_inv_pass += 1
                else:
                    inv_failures.append((eid, lang, message))
        spec = assertions.get(eid)
        if not spec:
            continue
        recomputed = False
        shape_missing = False
        if "result_kind" not in api and "representation" not in api:
            resp = recompute_hint(result_shape, api)
            if resp is None:
                # No shape on disk; the answer clauses can still be judged on their own.
                resp, shape_missing = {}, True
            else:
                recomputed = True
            resp["answer"] = api.get("answer")
        else:
            resp = api
        passed, details = rsa.check_response(spec, resp)
        # Answer clauses (FASTAPI-TEXT2SQL-368) are judged apart and stay out of the shape
        # figures: a question asserted on its answer alone does not enter `checked`.
        answer_details = [x for x in details if x["message"].startswith("answer ")]
        if answer_details:
            n_answer_q += 1
            if all(x["passed"] for x in answer_details):
                n_answer_pass += 1
            else:
                n_answer_fail += 1
                answer_failures.append((eid, lang, [x["message"] for x in answer_details if x["passed"] is False]))
        details = [x for x in details if not x["message"].startswith("answer ")]
        if not details:
            continue  # answer clauses only: no shape to judge
        if shape_missing:
            n_notemitted += 1
            continue
        passed = all(x["passed"] for x in details if x["passed"] is not None)
        # Intent clauses (FASTAPI-TEXT2SQL-353) are tallied apart: before -353 the API emits no
        # intent, the clause is NOT EMITTED and must not move the shape figures.
        intent_details = [x for x in details if x["message"].startswith("intent.")]
        if intent_details:
            n_intent_q += 1
            if any(x["passed"] is None for x in intent_details):
                n_intent_pending += 1
            elif all(x["passed"] for x in intent_details):
                n_intent_pass += 1
            else:
                n_intent_fail += 1
        if not rsa.judged(details):
            continue  # only intent clauses, none emitted: nothing to judge yet
        n_checked += 1
        if recomputed:
            n_recalc += 1
        if passed:
            n_pass += 1
        else:
            n_fail += 1
            msgs = [x["message"] for x in details if x["passed"] is False]
            failures.append((eid, lang, recomputed, msgs))

    print(f"Campaign: {os.path.basename(args.exec_dir.rstrip(os.sep))}")
    print(f"Questions with a result-shape assertion: {len(assertions)}")
    print(f"  checked: {n_checked}   PASS {n_pass}   FAIL {n_fail}"
          + (f"   (of which {n_recalc} recomputed offline, no re-run)" if n_recalc else ""))
    print(f"  not emitted and not recomputable (no rows on disk): {n_notemitted}")
    if n_intent_q:
        print(f"Questions with an intent.task clause: {n_intent_q}   PASS {n_intent_pass}   "
              f"FAIL {n_intent_fail}   not emitted (API before FASTAPI-TEXT2SQL-353) {n_intent_pending}")
    if n_answer_q:
        print(f"Questions with an answer clause: {n_answer_q}   PASS {n_answer_pass}   FAIL {n_answer_fail}")
    print(f"Answer invariant (no database id in the answer, FASTAPI-TEXT2SQL-368): {n_inv} checked   "
          f"PASS {n_inv_pass}   FAIL {len(inv_failures)}   skipped (id typed in the question) {n_inv_skip}"
          + (f"   not in the bank {n_inv_unknown}" if n_inv_unknown else ""))
    if failures:
        print("\n=== FAIL ===")
        for eid, lang, recomputed, msgs in failures:
            print(f"  {eid} [{lang}]{' (recomputed)' if recomputed else ''}")
            for m in msgs:
                print(f"     {m}")
    if answer_failures:
        print("\n=== ANSWER FAIL ===")
        for eid, lang, msgs in answer_failures:
            print(f"  {eid} [{lang}]")
            for m in msgs:
                print(f"     {m}")
    if inv_failures:
        print("\n=== ANSWER INVARIANT FAIL ===")
        for eid, lang, message in inv_failures:
            print(f"  {eid} [{lang}]  {message}")
    return 1 if (args.strict and (n_fail or n_answer_fail or inv_failures)) else 0


if __name__ == "__main__":
    sys.exit(main())
