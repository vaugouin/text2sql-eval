"""Image campaign gpt-6-astra vs claude-fable-5-2 (FASTAPI-TEXT2SQL-277): re-score without faces,
and the review CSV of the images both models missed.

Inputs:
  check-vision-campaign-YYYYMMDD.txt        result of check-vision-campaign.sql (per image scores)
  vision-evals-review-judged-20261110.csv   Philippe's judgments, the source of evaluations 2732 to 2814
  <export>/evaluation_execution/*_vis-<model>/*.json   the two campaigns (local mirror of /shared)
Outputs:
  stdout                                    scores per model and language, whole set and two cuts
  vision-misses-review.csv                  one row per image missed by both models in at least one
                                            language, input of vision-evals-review.py --csv

The image is matched by md5: the API names an upload after the md5 of its bytes, and so does the
fixture, so image_ref and the judged CSV share it.

Run: uv run --no-project python vision-campaign-misses.py [--check check-vision-campaign-20261111.txt]
"""
import argparse
import csv
import glob
import json
import re
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).parent
EXPORT = Path(r"C:\Users\vaugo\Code\shared_data\text2sql-eval\evaluation_execution")
MODELS = ("gpt-6-astra", "claude-fable-5-2")
FACES = "69"


def read_check(path):
    """{(eval_id, lang): row} from section 2 of the check result."""
    out = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        p = [x.strip() for x in line.strip().strip("|").split("|")]
        if len(p) == 9 and p[0].isdigit():
            out[(p[0], p[1])] = {"eval_id": p[0], "lang": p[1], "cat": p[2], "type": p[3], "title": p[4],
                                 "gpt-6-astra": p[5], "claude-fable-5-2": p[6]}
    return out


def read_exports():
    """{(model, eval_id, lang): latest export} for both campaigns."""
    best = {}
    for model in MODELS:
        for f in glob.glob(str(EXPORT / f"*_vis-{model}" / "*.json")):
            d = json.loads(Path(f).read_text(encoding="utf-8"))
            k = (model, str(d["evaluation_id"]), d["language"])
            if k not in best or d["execution_row_id"] > best[k]["execution_row_id"]:
                best[k] = d
    return best


def md5_of(name):
    m = re.search(r"_([0-9a-f]{32})\.", name or "")
    return m.group(1) if m else ""


def answer(d):
    """'type: title year [conf]' of the scored prediction, or 'nothing identified'."""
    ve = (d or {}).get("api_output", {}).get("vision_evidence") or {}
    pred = ve.get("selected")
    if not pred and ve.get("candidates"):
        pred = max(ve["candidates"], key=lambda c: c.get("confidence") or 0)
    if not pred:
        return "nothing identified", {}
    return (f"{pred.get('type')}: {pred.get('value')} {pred.get('year') or ''} [{pred.get('confidence')}]"
            .replace("  ", " "), pred)


def table(check, keep, label):
    print(f"\n{label}")
    print(f"  {'model':18} {'en':>9} {'fr':>9}")
    for model in MODELS:
        cells = []
        for lang in ("en", "fr"):
            rows = [r for (e, l), r in check.items() if l == lang and keep(r)]
            cells.append(f"{sum(r[model] == '1' for r in rows)}/{len(rows)}")
        print(f"  {model:18} {cells[0]:>9} {cells[1]:>9}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", default=str(HERE / "check-vision-campaign-20261111.txt"))
    ap.add_argument("--judged", default=str(HERE / "vision-evals-review-judged-20261110.csv"))
    args = ap.parse_args()
    check = read_check(Path(args.check))
    exports = read_exports()

    table(check, lambda r: True, "Whole set")
    table(check, lambda r: r["cat"] != FACES, f"Without the Faces category ({FACES})")
    table(check, lambda r: r["cat"] != FACES and r["type"] != "person",
          "Without Faces and without any expected person (screen photos, frames of a person)")

    with open(args.judged, encoding="utf-8-sig", newline="") as f:
        judged = {r["md5"]: r for r in csv.DictReader(f, delimiter=";")}

    missed = defaultdict(set)
    for (e, lang), r in check.items():
        if all(r[m] == "0" for m in MODELS):
            missed[e].add(lang)
    rows = []
    for e in sorted(missed, key=int):
        r0 = check.get((e, "en")) or check.get((e, "fr"))
        any_export = next(exports[k] for k in [(m, e, l) for m in MODELS for l in ("en", "fr")] if k in exports)
        md5 = md5_of(any_export["api_output"].get("image_ref"))
        j = judged.get(md5, {})
        fixed = j.get("verdict") == "no" and j.get("valid_title")
        row = {
            "prefix": md5[:8], "category_id": r0["cat"], "eval_id": e,
            "missed_in": " ".join(sorted(missed[e])),
            "expected_type": r0["type"], "expected_title": r0["title"],
            "expected_year": (j.get("valid_year") if fixed else j.get("expected_year")) or "",
        }
        astra_txt, astra_pred = answer(exports.get(("gpt-6-astra", e, "en")))
        row.update({"astra_type": astra_pred.get("type", "none"), "astra_title": astra_pred.get("value", ""),
                    "astra_year": astra_pred.get("year", "") or "", "astra_conf": astra_pred.get("confidence", "")})
        for m, short in (("gpt-6-astra", "astra"), ("claude-fable-5-2", "fable")):
            for lang in ("en", "fr"):
                row[f"{short}_{lang}"] = answer(exports.get((m, e, lang)))[0]
            d = exports.get((m, e, "en")) or {}
            row[f"{short}_answer_en"] = (d.get("api_output", {}).get("answer") or "").replace("\n", " ")
        hints = (exports.get(("claude-fable-5-2", e, "en")) or {}).get("api_output", {}).get("vision_evidence", {}).get("hints") or {}
        row["fable_title_text"] = hints.get("title_text", "")
        row["fable_faces"] = " | ".join(hints.get("faces") or [])
        row["judge_clues_20261110"] = j.get("clues", "")
        row["judge_verdict_20261110"] = j.get("verdict", "")
        row["file"] = j.get("file") or ""
        row["md5"] = md5
        rows.append(row)

    out = HERE / "vision-misses-review.csv"
    with open(out, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]), delimiter=";")
        w.writeheader()
        w.writerows(rows)
    print(f"\n{len(rows)} images missed by both models ({sum(len(v) for v in missed.values())} image-language pairs)"
          f" -> {out.name}; without a fixture file name: {sum(not r['file'] for r in rows)}")


if __name__ == "__main__":
    main()
