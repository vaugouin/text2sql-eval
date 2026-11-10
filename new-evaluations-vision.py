"""Write new-evaluations-vision.sql from Philippe's judgments (FASTAPI-TEXT2SQL-277).

Inputs: vision-evals-review-judged-20261110.csv (the judge page export) and
check-vision-evals-ids-20261110.txt (the ids resolved in the base). Output: one guarded INSERT
per kept image into T_WC_T2S_EVALUATION, and fixtures-vision-files.txt, the list of pictures to
copy into the evaluator fixtures folder.

Run: uv run python new-evaluations-vision.py
"""
import csv
import json
import re
from pathlib import Path

HERE = Path(__file__).parent
JUDGED = HERE / "vision-evals-review-judged-20261110.csv"
CHECK = HERE / "check-vision-evals-ids-20261110.txt"
# Removed by Philippe on 2026-11-10 after the review: no settled answer.
UNSETTLED = {"13c5c715", "9d8f999c", "00c8a453", "904544ed"}
# Collection ids seen in accepted result rows (T_WC_T2S_COLLECTION.ID_T2S_COLLECTION).
COLLECTION_IDS = {"04be4ac5": 67}
ID_COLUMN = {"movie": "ID_MOVIE", "serie": "ID_SERIE", "person": "ID_PERSON"}


def table_rows(text, section):
    """Rows of the mariadb table printed after the SECTION line that starts with `section`."""
    block = text.split(section, 1)[1].split("| SECTION", 1)[0]
    lines = [l for l in block.splitlines() if l.startswith("| ")]
    head = [c.strip() for c in lines[0].strip("|").split("|")] if lines else []
    return [dict(zip(head, [c.strip() for c in l.strip("|").split("|")])) for l in lines[1:]]


def sql(value):
    if value is None or value == "":
        return "NULL"
    return "'" + str(value).replace("\\", "").replace("'", "''") + "'"


def main():
    check = CHECK.read_text(encoding="utf-8")
    resolved = {r["PREFIX"]: r for r in table_rows(check, "| 1. Ids")}
    for r in table_rows(check, "| 2. Titles without id"):
        resolved.setdefault(r["PREFIX"], {"KIND": r["KIND"], "ID_ENTITY": r["ID_ENTITY"], "NAME_IN_BASE": r["NAME_IN_BASE"],
                                          "ORIGINAL_TITLE": "NULL", "YEAR_IN_BASE": r["YEAR_IN_BASE"]})
    with open(JUDGED, encoding="utf-8-sig", newline="") as f:
        rows = [o for o in csv.DictReader(f, delimiter=";") if o["removed"] != "1" and o["prefix"] not in UNSETTLED]

    inserts, files = [], []
    for o in rows:
        p, res = o["prefix"], resolved.get(o["prefix"])
        if res:
            kind, ident = res["KIND"], int(res["ID_ENTITY"])
            title = res["NAME_IN_BASE"]
            orig = None if res.get("ORIGINAL_TITLE") in (None, "NULL", title) else res["ORIGINAL_TITLE"]
            year = None if res["YEAR_IN_BASE"] in ("NULL", "") or kind == "person" else int(res["YEAR_IN_BASE"])
        else:
            kind = o["valid_type"] or o["astra_type"]
            if kind == "other" and o["category_id"] == "68":
                kind = "book"
            ident, orig = COLLECTION_IDS.get(p), None
            title = o["valid_title"] or o["astra_title"]
            year = int(o["astra_year"]) if o["astra_year"].isdigit() else None
        expected = {"type": kind, "id": ident, "title": title, "original_title": orig, "year": year}
        qr = f"{ID_COLUMN[kind]} IN ({ident})" if kind in ID_COLUMN and ident else None
        astra = f"{o['astra_type']}: {o['astra_title']} {o['astra_year']} [{o['astra_conf']}]".strip() if o["astra_title"] not in ("", "none") else "nothing identified"
        desc = (f"Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of {o['date']}, image {p}, {o['kind']}. "
                f"gpt-6-astra said: {astra}. Judged by Philippe on 2026-11-10: {o['verdict'] or 'yes'}."
                + (f" Clues: {o['clues'].strip()}" if o["clues"].strip() else ""))
        path = "vision/" + o["file"]
        files.append(o["file"])
        inserts.append(
            "INSERT INTO T_WC_T2S_EVALUATION\n"
            "  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,\n"
            "   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)\n"
            f"SELECT '', '', {int(o['category_id'])}, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),\n"
            f"  'image', {sql(path)}, {sql(json.dumps(expected, ensure_ascii=False))}, {sql(qr)},\n"
            f"  {sql(desc)}\n"
            "FROM DUAL WHERE NOT EXISTS (\n"
            "  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION\n"
            f"    WHERE INPUT_IMAGE_PATH = {sql(path)}) AS guard);\n")

    header = f"""-- New image-input evaluations for FASTAPI-TEXT2SQL-277 (gpt-6-astra vs claude-fable-5-2 on image recognition).
-- Built 2026-11-10 by new-evaluations-vision.py from Philippe's judgments
-- (vision-evals-review-judged-20261110.csv: 96 unique images, 9 removed on the judge page, 4 unsettled
-- rows removed afterwards) and the ids resolved by check-vision-evals-ids.sql. {len(inserts)} evaluations.
--
-- WHAT EACH ROW HOLDS
--   INPUT_KIND = 'image', INPUT_IMAGE_PATH = vision/<file of the upload history>, the picture the
--   evaluator deposits on POST /uploads/vision before asking. QUESTION and QUESTION_FR are empty:
--   the task is the identification of the picture alone, as in most of the history. The two
--   languages differ only by ui_language.
--   ASSERTIONS_VISION_IDENTIFICATION: the expected identification (JSON), checked against the base
--   for every movie, series and person (TMDb id, title, original title, year). Books carry the
--   work, not an adaptation; collections and the one location carry a title.
--   ASSERTIONS_QUERY_RESULT: ID_MOVIE / ID_SERIE / ID_PERSON IN (<id>) when the id is known, so the
--   rest of the pipeline is scored too; NULL otherwise.
--   LONG_DESC: the image, what gpt-6-astra said, Philippe's verdict and clues.
--   Category: Philippe's choice among 64 to 70 (children of 63, Vision - Image Input).
--
-- FLAGS: IS_EVAL = 0 and IS_SAMPLE = 0 ON PURPOSE. The current evaluator does not know INPUT_KIND:
-- with IS_EVAL = 1 it would send an empty question without the picture. Both flags go to 1 in a
-- later update file, once the runner change of -277 is deployed.
--
-- PREREQUISITE: migrate-evaluation-vision.sql (voie 2, Philippe). Without it this file stops on
-- "Unknown column 'INPUT_KIND'".
--
-- ROUTING: INSERT on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-vision.sql
-- Every INSERT is guarded by NOT EXISTS on INPUT_IMAGE_PATH: a rerun inserts nothing.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

"""
    footer = """
SELECT 'Vision evaluations per category' AS SECTION;
SELECT e.ID_T2S_EVALUATION_CATEGORY, c.DESCRIPTION, COUNT(*) AS N, SUM(e.ASSERTIONS_QUERY_RESULT IS NOT NULL) AS WITH_QUERY_RESULT,
       MIN(e.ID_T2S_EVALUATION) AS FIRST_ID, MAX(e.ID_T2S_EVALUATION) AS LAST_ID
FROM T_WC_T2S_EVALUATION e LEFT JOIN T_WC_T2S_EVALUATION_CATEGORY c ON c.ID_T2S_EVALUATION_CATEGORY = e.ID_T2S_EVALUATION_CATEGORY
WHERE e.INPUT_KIND = 'image' AND e.DELETED = 0
GROUP BY e.ID_T2S_EVALUATION_CATEGORY, c.DESCRIPTION ORDER BY 1;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION WHERE INPUT_KIND = 'image' AND DELETED = 0 ORDER BY ID_T2S_EVALUATION;
"""
    out = HERE / "new-evaluations-vision.sql"
    out.write_text(header + "\n".join(inserts) + footer, encoding="utf-8", newline="\n")
    (HERE / "fixtures-vision-files.txt").write_text("\n".join(sorted(files)) + "\n", encoding="utf-8", newline="\n")
    print(f"{len(inserts)} evaluations -> {out.name}; {len(files)} files -> fixtures-vision-files.txt")


if __name__ == "__main__":
    main()
