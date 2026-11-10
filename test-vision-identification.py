"""Offline check of the image-evaluation scorer (FASTAPI-TEXT2SQL-277). No API, no database.

Run: uv run --no-project --with pandas python test-vision-identification.py
"""
import json
import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import text2sql_eval_functions as t2s_eval  # noqa: E402


def resp(selected=None, candidates=None, empty=False):
    return {"vision_evidence": {"selected": selected, "candidates": candidates or ([selected] if selected else []),
                                "authoritative_empty": empty}}


def item(typ, value, year="", conf=0.9):
    return {"type": typ, "value": value, "year": year, "confidence": conf}


BLACK_BOX = {"type": "movie", "id": 663260, "title": "Black Box", "original_title": "Boîte noire", "year": 2021}
CASES = [
    # (label, assertion, response, expected score)
    ("original title, accents", BLACK_BOX, resp(item("movie", "Boite Noire", "2021")), 1),
    ("English title", BLACK_BOX, resp(item("movie", "Black Box", "2021")), 1),
    ("Astra's real miss: Dark Waters", BLACK_BOX, resp(item("movie", "Dark Waters", "2019", 0.73)), 0),
    ("nothing identified on a known answer", BLACK_BOX, resp(empty=True), 0),
    ("year two off", BLACK_BOX, resp(item("movie", "Black Box", "2019")), 0),
    ("year one off is tolerated", BLACK_BOX, resp(item("movie", "Black Box", "2022")), 1),
    ("year missing on the prediction (Hope, Premiere cover)",
     {"type": "movie", "title": "Hope", "year": 2026}, resp(item("movie", "Hope", "")), 1),
    ("wrong type", BLACK_BOX, resp(item("serie", "Black Box", "2021")), 0),
    ("book as other, title then author",
     {"type": "book", "title": "Heart of Darkness, a novella by Joseph Conrad"},
     resp(item("other", "Heart of Darkness, a novella by Joseph Conrad")), 1),
    ("book bank title shorter than the value",
     {"type": "book", "title": "Heart of Darkness"}, resp(item("other", "Heart of Darkness, a novella by Joseph Conrad")), 1),
    ("value inside the expected title is refused", {"type": "movie", "title": "Aliens", "year": 1986},
     resp(item("movie", "Alien", "1986")), 0),
    ("alias", {"type": "book", "title": "Nineteen Eighty-Four", "aliases": ["1984"]}, resp(item("other", "1984")), 1),
    ("expected none, nothing identified", {"type": "none"}, resp(empty=True), 1),
    ("expected none, something named", {"type": "none"}, resp(item("movie", "Vipere", "", 0.42)), 0),
    ("no selected: most confident candidate", BLACK_BOX,
     resp(None, [item("movie", "Dark Waters", "2019", 0.4), item("movie", "Black Box", "2021", 0.6)]), 1),
    ("no vision_evidence: image not read", BLACK_BOX, {"answer": "?"}, 0),
    ("person", {"type": "person", "id": 34262, "title": "Bertrand Blier"}, resp(item("person", "Bertrand Blier")), 1),
    ("collection", {"type": "collection", "id": 67, "title": "The Lord of the Rings"},
     resp(item("collection", "The Lord of the Rings Collection")), 1),
]

failures = 0
for label, assertion, response, want in CASES:
    got, lines = t2s_eval.score_vision_identification(json.dumps(assertion, ensure_ascii=False), response)
    ok = got == want
    failures += 0 if ok else 1
    print(f"{'OK ' if ok else 'BAD'} {label}: got {got}, want {want}" + ("" if ok else f"\n    {lines}"))

got, _ = t2s_eval.score_vision_identification("not json", resp(item("movie", "x")))
print(f"{'OK ' if got is None else 'BAD'} malformed assertion is not scored: {got}")
failures += 0 if got is None else 1
got, _ = t2s_eval.score_vision_identification("&quot;x&quot;", resp(item("movie", "x")))
print(f"{'OK ' if got is None else 'BAD'} assertion without type is not scored: {got}")
failures += 0 if got is None else 1

with tempfile.TemporaryDirectory() as root:
    os.makedirs(os.path.join(root, "vision"))
    good = t2s_eval.fixture_path(root, "vision/a.jpg").endswith(os.path.join("vision", "a.jpg"))
    print(f"{'OK ' if good else 'BAD'} fixture path inside the folder")
    failures += 0 if good else 1
    for bad in ("../secret.jpg", "", None, "/etc/passwd"):
        try:
            t2s_eval.fixture_path(root, bad)
            print(f"BAD fixture path accepted: {bad!r}")
            failures += 1
        except ValueError:
            print(f"OK  fixture path refused: {bad!r}")

total = len(CASES) + 7
print(f"\n{total - failures}/{total}")
sys.exit(1 if failures else 0)
