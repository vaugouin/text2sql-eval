"""Build vision-evals-review.html, the judge page of the vision evaluation candidates (FASTAPI-TEXT2SQL-277).

Input: vision-evals-review.csv (one row per unique image of the vision upload history, ';' separated,
UTF-8), deduplicated by identified work. Output: a self-contained HTML page that embeds every CSV
column, shows the thumbnail from the local mirror of the uploads, and lets Philippe judge each row:
yes / no on the expected answer, clues, the valid answer when it is wrong, the category, and a
remove switch to drop the row from the evaluation set. Judgments autosave in the browser
(localStorage) and leave the page through the Export button as vision-evals-review-judged-YYYYMMDD.csv,
the input of the new-evaluations file. Import reloads an export to resume on another browser.

Run: uv run python vision-evals-review.py [--images-dir <dir>] [--csv <file.csv> --title <page title>]
The second page, the images both models missed in the 2026-11-10 campaigns, is built with
  --csv vision-misses-review.csv --title "Vision misses review"
  --images-dir C:/Users/vaugo/Code/shared_data/text2sql-eval/fixtures/vision
The page reads the images from file:///, so it is meant to be opened locally, never published.
"""
import argparse
import csv
import html
import json
from pathlib import Path

HERE = Path(__file__).parent
DEFAULT_IMAGES = Path(r"C:\Users\vaugo\Code\shared_data\fastapi-text2sql\uploads\vision")
CATEGORIES = {
    "64": "Posters and Printed Media", "65": "Film and Series Frames", "66": "Screen Photos",
    "67": "Physical Media", "68": "Source Books and Adaptations", "69": "Faces",
    "70": "Iconic Objects", "71": "Unidentifiable",
}

PAGE = r"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>__TITLE__</title>
<style>
:root{--bg:#f7f7f5;--card:#fff;--fg:#1d1d1b;--mut:#6b6b66;--line:#ddd;--ok:#1f7a3a;--ko:#b42318;--warn:#b45309;--acc:#2f5fb3}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){--bg:#161615;--card:#20201e;--fg:#e8e8e3;--mut:#9a9a93;--line:#3a3a36;--ok:#4ade80;--ko:#f87171;--warn:#fbbf24;--acc:#7aa2f7}}
:root[data-theme="dark"]{--bg:#161615;--card:#20201e;--fg:#e8e8e3;--mut:#9a9a93;--line:#3a3a36;--ok:#4ade80;--ko:#f87171;--warn:#fbbf24;--acc:#7aa2f7}
*{box-sizing:border-box}body{margin:0;padding:16px;background:var(--bg);color:var(--fg);font:14px/1.45 system-ui,sans-serif}
header{position:sticky;top:0;z-index:2;background:var(--bg);padding:8px 0 10px;border-bottom:1px solid var(--line);display:flex;flex-wrap:wrap;gap:8px;align-items:center}
h1{font-size:18px;margin:0 12px 0 0}.stats{color:var(--mut)}button,select,input,textarea{font:inherit;color:var(--fg);background:var(--card);border:1px solid var(--line);border-radius:6px;padding:4px 8px}
button{cursor:pointer}button.on{border-color:var(--acc);color:var(--acc);font-weight:600}
.card{display:grid;grid-template-columns:240px 1fr 320px;gap:14px;background:var(--card);border:1px solid var(--line);border-radius:10px;padding:12px;margin:12px 0}
@media (max-width:900px){.card{grid-template-columns:1fr}}
.card img{max-width:100%;max-height:260px;border-radius:6px;display:block}
.card.removed{opacity:.4}.card.yes{border-left:5px solid var(--ok)}.card.no{border-left:5px solid var(--ko)}
.exp{font-size:16px;font-weight:600}.low{color:var(--warn);font-weight:700}.fail{color:var(--ko);font-weight:700}
dl{display:grid;grid-template-columns:110px 1fr;gap:2px 8px;margin:8px 0 0;font-size:13px}dt{color:var(--mut)}dd{margin:0;overflow-wrap:anywhere}
.judge label{display:block;margin:6px 0 2px;color:var(--mut);font-size:12px}.judge textarea,.judge input,.judge select{width:100%}
.verdict{display:flex;gap:6px}.verdict button{flex:1}.verdict .y.on{background:var(--ok);color:#fff;border-color:var(--ok)}.verdict .n.on{background:var(--ko);color:#fff;border-color:var(--ko)}
.rm{margin-top:10px;width:100%}.removed .rm{border-color:var(--ko);color:var(--ko)}
</style></head><body>
<header><h1>__TITLE__</h1><span class="stats" id="stats"></span>
<select id="filter"><option value="all">All</option><option value="pending">To judge</option><option value="yes">Yes</option><option value="no">No</option><option value="removed">Removed</option></select>
<select id="catfilter"><option value="">All categories</option></select>
<button id="export">Export CSV</button><label><button id="importbtn">Import</button><input id="import" type="file" accept=".csv" hidden></label>
</header>
<main id="list"></main>
<script>
const ROWS = __ROWS__;
const CATS = __CATS__;
const IMG = __IMG__;
const OUT = __OUT__;
const KEY = __KEY__;
const FIELDS = ["verdict","clues","valid_type","valid_title","valid_year","valid_tmdb","category_id","removed"];
let state = {};
try { state = JSON.parse(localStorage.getItem(KEY) || "{}"); } catch (e) { state = {}; }
const save = () => { try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) {} };
const st = r => (state[r.md5] ||= {category_id: r.category_id || ""});
const esc = s => String(s ?? "").replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const catOpts = sel => '<option value="">(choose)</option>' + Object.entries(CATS).map(([k,v]) => `<option value="${k}"${k===sel?" selected":""}>${k} ${esc(v)}</option>`).join("");
document.getElementById("catfilter").innerHTML += Object.entries(CATS).map(([k,v]) => `<option value="${k}">${k} ${esc(v)}</option>`).join("");

function card(r) {
  const s = st(r), conf = parseFloat(r.astra_conf);
  // The first page (candidates) shows Astra's history; a campaign review always has an expected answer.
  const failed = !r.expected_title && (!r.astra_title || r.astra_title === "none");
  const expected = failed ? '<span class="fail">No identification</span>' :
    `${esc(r.expected_type)}: ${esc(r.expected_title || r.astra_title)} ${esc(r.expected_year)}` +
    (r.astra_conf ? ` <span class="${conf < 0.9 ? "low" : ""}">[${esc(r.astra_conf)}]</span>` : "");
  const extra = Object.keys(r).filter(k => !["prefix","md5","file"].includes(k))
    .map(k => `<dt>${esc(k)}</dt><dd>${esc(r[k])}</dd>`).join("");
  const src = IMG + encodeURIComponent(r.file);
  return `<article class="card ${s.removed ? "removed" : ""} ${s.verdict || ""}" data-md5="${r.md5}">
  <div><a href="${src}" target="_blank" rel="noopener"><img loading="lazy" src="${src}" alt="${esc(r.prefix)}"></a></div>
  <div><div class="exp">${expected}</div><dl><dt>md5</dt><dd><code>${esc(r.md5)}</code></dd><dt>file</dt><dd>${esc(r.file)}</dd>${extra}</dl></div>
  <div class="judge">
    <label>Is the expected answer right?</label>
    <div class="verdict"><button class="y ${s.verdict==="yes"?"on":""}" data-v="yes">Yes</button><button class="n ${s.verdict==="no"?"on":""}" data-v="no">No</button></div>
    <label>Category</label><select data-f="category_id">${catOpts(s.category_id)}</select>
    <label>Valid answer if wrong: type</label><select data-f="valid_type">${["","movie","serie","person","collection","book","other","none"].map(t => `<option${t===(s.valid_type||"")?" selected":""}>${t}</option>`).join("")}</select>
    <label>Title / name</label><input data-f="valid_title" value="${esc(s.valid_title)}">
    <label>Year</label><input data-f="valid_year" value="${esc(s.valid_year)}" inputmode="numeric">
    <label>TMDb id (e.g. movie=62)</label><input data-f="valid_tmdb" value="${esc(s.valid_tmdb)}">
    <label>Additional clues</label><textarea data-f="clues" rows="3">${esc(s.clues)}</textarea>
    <button class="rm">${s.removed ? "Removed: restore to the eval set" : "Remove from the eval set"}</button>
  </div></article>`;
}

function visible(r) {
  const s = st(r), f = document.getElementById("filter").value, c = document.getElementById("catfilter").value;
  if (c && s.category_id !== c) return false;
  if (f === "removed") return !!s.removed;
  if (f === "all") return true;
  if (s.removed) return false;
  return f === "pending" ? !s.verdict : s.verdict === f;
}

function stats() {
  const v = ROWS.map(st), kept = v.filter(s => !s.removed);
  document.getElementById("stats").textContent =
    `${ROWS.length} images · ${kept.length} in the set · judged ${kept.filter(s => s.verdict).length} (yes ${kept.filter(s => s.verdict==="yes").length}, no ${kept.filter(s => s.verdict==="no").length}) · removed ${v.length - kept.length} · no category ${kept.filter(s => !s.category_id).length}`;
}

function render() {
  document.getElementById("list").innerHTML = ROWS.filter(visible).map(card).join("");
  stats();
}

document.getElementById("list").addEventListener("click", e => {
  const el = e.target.closest("button"); if (!el) return;
  const md5 = el.closest(".card").dataset.md5, r = ROWS.find(x => x.md5 === md5), s = st(r);
  if (el.dataset.v) s.verdict = s.verdict === el.dataset.v ? "" : el.dataset.v;
  if (el.classList.contains("rm")) s.removed = !s.removed;
  save(); const node = el.closest(".card"); node.outerHTML = card(r); stats();
});
document.getElementById("list").addEventListener("input", e => {
  const f = e.target.dataset.f; if (!f) return;
  const md5 = e.target.closest(".card").dataset.md5; st(ROWS.find(x => x.md5 === md5))[f] = e.target.value; save(); stats();
});
document.getElementById("filter").onchange = render;
document.getElementById("catfilter").onchange = render;

const csvCell = v => { v = String(v ?? ""); return /[;"\n\r]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v; };
document.getElementById("export").onclick = () => {
  const cols = Object.keys(ROWS[0]).filter(k => k !== "category_id");
  const head = [...cols, ...FIELDS];
  const lines = [head.join(";")].concat(ROWS.map(r => { const s = st(r);
    return [...cols.map(k => r[k]), ...FIELDS.map(k => k === "removed" ? (s.removed ? 1 : 0) : s[k])].map(csvCell).join(";"); }));
  const d = new Date(), ymd = d.getFullYear() + String(d.getMonth()+1).padStart(2,"0") + String(d.getDate()).padStart(2,"0");
  const a = document.createElement("a");
  a.href = URL.createObjectURL(new Blob(["\ufeff" + lines.join("\n")], {type: "text/csv;charset=utf-8"}));
  a.download = `${OUT}-judged-${ymd}.csv`; a.click(); URL.revokeObjectURL(a.href);
};

function parseCsv(t) {
  const out = []; let row = [], cell = "", q = false;
  for (let i = 0; i < t.length; i++) { const c = t[i];
    if (q) { if (c === '"') { if (t[i+1] === '"') { cell += '"'; i++; } else q = false; } else cell += c; }
    else if (c === '"') q = true; else if (c === ";") { row.push(cell); cell = ""; }
    else if (c === "\n") { row.push(cell.replace(/\r$/, "")); out.push(row); row = []; cell = ""; } else cell += c; }
  if (cell || row.length) { row.push(cell); out.push(row); }
  return out;
}
document.getElementById("importbtn").onclick = () => document.getElementById("import").click();
document.getElementById("import").onchange = async e => {
  const f = e.target.files[0]; if (!f) return;
  const [head, ...rows] = parseCsv((await f.text()).replace(/^\ufeff/, ""));
  const ix = k => head.indexOf(k);
  for (const row of rows) { const md5 = row[ix("md5")]; const r = ROWS.find(x => x.md5 === md5); if (!r) continue;
    const s = st(r); for (const k of FIELDS) if (ix(k) >= 0) s[k] = k === "removed" ? row[ix(k)] === "1" : row[ix(k)]; }
  save(); render();
};
render();
</script></body></html>
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--images-dir", default=str(DEFAULT_IMAGES))
    ap.add_argument("--csv", default=str(HERE / "vision-evals-review.csv"),
                    help="input CSV; the page is written beside it with the same name, .html")
    ap.add_argument("--title", default="Vision evals review")
    args = ap.parse_args()
    src = Path(args.csv)
    stem = src.stem
    with open(src, encoding="utf-8-sig", newline="") as f:
        rows = list(csv.DictReader(f, delimiter=";"))
    img = Path(args.images_dir).as_uri().rstrip("/") + "/"
    page = (PAGE.replace("__ROWS__", json.dumps(rows, ensure_ascii=False).replace("</", "<\\/"))
                .replace("__CATS__", json.dumps(CATEGORIES))
                .replace("__IMG__", json.dumps(img))
                .replace("__OUT__", json.dumps(stem))
                .replace("__KEY__", json.dumps("vision-evals-review-v1" if stem == "vision-evals-review" else stem + "-v1"))
                .replace("__TITLE__", html.escape(args.title)))
    out = src.with_suffix(".html")
    out.write_text(page, encoding="utf-8", newline="\n")
    print(f"{len(rows)} rows -> {out.name}")


if __name__ == "__main__":
    main()
