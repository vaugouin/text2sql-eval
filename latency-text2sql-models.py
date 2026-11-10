"""Text-to-SQL latency of two models on the live API, same questions, interleaved (GPT-6-008).

Why it exists: on 2026-11-10 gpt-6.1-terra became the text2sql default after a campaign that ran
on Flex, then was reverted the same day when this check showed it slower than gpt-6-sol at the
standard tier (median 4.14 s against 2.88 s, 62 against 87 output tokens/s, Sol faster on 18 of
20 questions). Rerun it before switching again: a model weeks old may gain capacity.

How it measures: N questions drawn (fixed seed) from one campaign export, keeping only rows that
produced SQL without escalating to the complex model, so the timing is the text2sql step alone.
Each question goes to the API once per model, the order alternating from one question to the next,
with retrieve_from_cache and store_to_cache off and no flex_processing (standard tier, as in
production). Only llm_model_text2sql changes; the other tasks keep the API defaults. About
$0.01 per question and model on a warm cache.

Run (PC, over Tailscale; Blue = 8186, Green = 8187):
  cd text2sql-eval
  PYTHONUTF8=1 uv run --no-project python latency-text2sql-models.py \
      --models gpt-6.1-terra,gpt-6-sol --n 20 --port 8186
The API key is read from .env (TEXT2SQL_API_KEY), never printed. The full per-question result is
written to data/bench/latency-text2sql-YYYYMMDD.json, which stays local (data/bench/ is
git-ignored: it carries bank questions verbatim, EVALUATIONS-008).
"""
import argparse
import datetime
import json
import random
import statistics as st
import sys
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_EXPORT = (ROOT.parent / "shared_data" / "text2sql-eval" / "evaluation_execution"
                  / "001.001.020_en_gpt-6-sol_gpt-6-1-terra_gpt-6-1-sol_re-gpt-6-luna")  # same 20 questions as 2026-11-10


def api_key() -> str:
    for line in (ROOT / ".env").read_text(encoding="utf-8").splitlines():
        if line.startswith("TEXT2SQL_API_KEY="):
            return line.split("=", 1)[1].strip().strip('"').strip("'")
    sys.exit("TEXT2SQL_API_KEY missing from .env")


def pick_questions(export: Path, n: int, seed: int) -> list[tuple[int, str]]:
    best: dict[int, dict] = {}
    for p in export.glob("20*.json"):
        x = json.loads(p.read_text(encoding="utf-8"))
        e = x["evaluation_id"]
        if e not in best or x["execution_row_id"] > best[e]["execution_row_id"]:
            best[e] = x
    ids = sorted(i for i, x in best.items()
                 if not x["timings"].get("complex_model_used") and x["api_output"].get("sql_query"))
    random.seed(seed)
    return [(i, best[i]["api_output"]["question"]) for i in random.sample(ids, n)]


def ask(url: str, key: str, question: str, model: str) -> dict:
    body = json.dumps({"question": question, "retrieve_from_cache": False, "store_to_cache": False,
                       "llm_model_text2sql": model}).encode()
    req = urllib.request.Request(url, data=body, headers={"X-API-Key": key, "Content-Type": "application/json"})
    t0 = time.time()
    d = json.load(urllib.request.urlopen(req, timeout=300))
    u = (d.get("llm_usage") or {}).get("text2sql") or {}
    return {"t2s": d.get("text2sql_processing_time"), "total": d.get("total_processing_time"),
            "wall": round(time.time() - t0, 2), "calls": u.get("calls"), "out": u.get("completion_tokens"),
            "reasoning": u.get("reasoning_tokens"), "cached": u.get("cached_tokens"), "model": u.get("model"),
            "tier": u.get("service_tier"), "error": d.get("error")}


def describe(vals: list[float]) -> str:
    v = sorted(x for x in vals if x is not None)
    return f"median {st.median(v):.2f}  p90 {v[int(.9 * (len(v) - 1))]:.2f}  mean {st.mean(v):.2f}"


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--models", default="gpt-6.1-terra,gpt-6-sol", help="two models, comma-separated")
    ap.add_argument("--n", type=int, default=20)
    ap.add_argument("--seed", type=int, default=20261110)
    ap.add_argument("--host", default="100.113.161.122")
    ap.add_argument("--port", type=int, default=8186, help="8186 Blue, 8187 Green")
    ap.add_argument("--export", type=Path, default=DEFAULT_EXPORT, help="campaign export folder to draw from")
    args = ap.parse_args()
    a, b = [m.strip() for m in args.models.split(",")]
    url, key = f"http://{args.host}:{args.port}/search/text2sql", api_key()
    rows = []
    for n, (i, q) in enumerate(pick_questions(args.export, args.n, args.seed)):
        r = {"id": i, "question": q}
        for m in ([a, b] if n % 2 == 0 else [b, a]):
            r[m] = ask(url, key, q, m)
        rows.append(r)
        print(f"{i:5d} {a} {r[a]['t2s']:6.2f}s out {r[a]['out']} | {b} {r[b]['t2s']:6.2f}s out {r[b]['out']} | {q[:50]}",
              flush=True)
    print(f"\ntext2sql time, {len(rows)} questions, interleaved, standard tier:")
    for m in (a, b):
        rate = st.median(r[m]["out"] / r[m]["t2s"] for r in rows if r[m]["t2s"] and r[m]["out"])
        print(f"  {m:15s} {describe([r[m]['t2s'] for r in rows])}  out tok/s {rate:.1f}")
    print(f"  {a} faster on {sum(r[a]['t2s'] < r[b]['t2s'] for r in rows)}/{len(rows)}"
          f"; tiers {sorted({str(r[m]['tier']) for r in rows for m in (a, b)})}"
          f"; errors {[r['id'] for r in rows if r[a]['error'] or r[b]['error']]}")
    out = ROOT / "data" / "bench" / f"latency-text2sql-{datetime.date.today():%Y%m%d}.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(rows, indent=1, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {out}")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
