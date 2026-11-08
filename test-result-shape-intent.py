"""Standalone check of the `intent.task` clause of the result-shape grammar (FASTAPI-TEXT2SQL-353).

    uv run --no-project python test-result-shape-intent.py     # exits 1 on a failed case
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import result_shape_assertions as rsa

pre353 = {"result_kind": "entity_rows", "representation": "card-grid", "result_columns": []}
post353 = dict(pre353, intent={"entity": "movie", "task": "compare", "focus": "BUDGET", "requested_view": None})

bad = 0


def case(label, spec, resp, want_overall, want_pending):
    global bad
    ok, details = rsa.check_response(spec, resp)
    pending = rsa.not_emitted(details)
    good = (ok == want_overall and pending == want_pending)
    bad += not good
    print(f"{'ok ' if good else 'BAD'} {label}: overall={ok} not_emitted={pending}")


case("pre-353, intent only", "intent.task == compare", pre353, True, 1)
case("pre-353, intent and failing shape", "intent.task == compare; representation == value-cards", pre353, False, 1)
case("post-353, match", "intent.task == compare", post353, True, 0)
case("post-353, mismatch", "intent.task == rank", post353, False, 0)
case("post-353, != ", "intent.task != rank", post353, True, 0)
case("post-353, case", "INTENT.TASK == Compare", post353, True, 0)
case("post-353, list mismatch", "intent.task == list", post353, False, 0)
for spec in ("intent.task == ranking", "intent.task(X) == rank"):
    try:
        rsa.parse(spec)
        bad += 1
        print(f"BAD parse accepted {spec!r}")
    except ValueError as e:
        print(f"ok  parse refused {spec!r}: {e}")
sys.exit(1 if bad else 0)
