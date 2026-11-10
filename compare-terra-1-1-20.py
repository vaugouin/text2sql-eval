"""Compare gpt-6.1-terra with gpt-6-sol on the text2sql task, API v1.1.20, EN + FR (GPT-6-008).

Both arms share the production tuple except text2sql: entity extraction gpt-6-sol, complex
gpt-6.1-sol, result_entity gpt-6-luna, answer_single_value gpt-4o. The Terra arm ran on
2026-11-09 (Flex); the Sol rows were written 2026-11-03 to -08 and rescored on 2026-11-09.
Pass = `scoring.assertions_total_score == 1.0`.

What the script separates, because the raw net overstates Terra:
- A rescore re-checks the stored result against today's assertions, it does not rerun the SQL.
  A flip with byte-identical SQL on both sides is therefore data drift between the two execution
  dates, never a model effect ("same_sql_flips").
- Time-sensitive questions (trending, popular right now, died recently, most famous) move with
  the data even when the SQL differs; they are listed apart (TIME_SENSITIVE) and left out of the
  adjusted net.
- Latency is read per 10-minute slot: on Flex, Terra's slow calls come in bursts at the same
  output size (throughput 100 -> 26 tokens/s), which points to Flex capacity, not to the model.

Several JSON files can exist for one evaluation id (retired executions stay in the additive
local mirror): the highest `execution_row_id` wins.

Run:  cd text2sql-eval && PYTHONUTF8=1 uv run --no-project python compare-terra-1-1-20.py [EXEC_DIR]
EXEC_DIR defaults to ~/Code/shared_data/text2sql-eval/evaluation_execution.
Writes claude/compare_terra_1_1_20.json (local only: `claude/` is git-ignored because the output
carries bank questions verbatim, see AGENTS.md).
"""
import collections
import json
import re
import statistics as st
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
EXEC_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else (
    ROOT.parent / "shared_data" / "text2sql-eval" / "evaluation_execution")
OUT_JSON = ROOT / "claude" / "compare_terra_1_1_20.json"

RUNS = {
    "terra": "001.001.020_{lang}_gpt-6-sol_gpt-6-1-terra_gpt-6-1-sol_re-gpt-6-luna",
    "sol": "001.001.020_{lang}_gpt-6-sol_gpt-6-sol_gpt-6-1-sol_re-gpt-6-luna",
}
LANGS = ("en", "fr")
# The counting questions of FASTAPI-TEXT2SQL-303 (the 25 rerun ids plus 29, 89 and 867).
COUNTING = [29, 45, 89, 197, 352, 413, 446, 474, 790, 791, 792, 793, 867, 1112, 2169, 2170, 2171,
            2172, 2247, 2280, 2287, 2301, 2313, 2349, 2437, 2446, 2447, 2481]
# Questions whose expected rows move with the data (popularity, recency, "most famous").
TIME_SENSITIVE = {2324, 2342, 2345, 2390, 2442, 2471, 2503, 2527}
SLOW_SECONDS = 8.0


def load_run(folder: Path) -> dict[int, dict]:
    best: dict[int, dict] = {}
    for p in folder.glob("20*.json"):
        with p.open(encoding="utf-8") as f:
            x = json.load(f)
        e = x["evaluation_id"]
        if e not in best or x["execution_row_id"] > best[e]["execution_row_id"]:
            best[e] = x
    return best


def passed(x) -> bool:
    return (x["scoring"].get("assertions_total_score") or 0) >= 1.0


def norm_sql(q) -> str:
    return re.sub(r"\s+", " ", q or "").strip().rstrip(";").replace(" OFFSET 0", "").upper()


def quant(vals, p):
    vals = sorted(v for v in vals if v is not None)
    return round(vals[int(p * (len(vals) - 1))], 2) if vals else None


def t2s_usage(x) -> dict:
    return (x["api_output"].get("llm_usage") or {}).get("text2sql") or {}


def arm_stats(R: dict, ids: list[int]) -> dict:
    t2s = [R[i]["timings"].get("text2sql_processing_time") for i in ids]
    tot = [R[i]["timings"].get("total_processing_time") for i in ids]
    agg = collections.Counter()
    tiers = collections.Counter()
    for i in ids:
        u = t2s_usage(R[i])
        if not u:
            continue
        for k in ("calls", "prompt_tokens", "cached_tokens", "completion_tokens", "reasoning_tokens",
                  "cache_write_tokens", "flex_retries", "flex_fallbacks"):
            agg[k] += u.get(k) or 0
        agg["cost_usd"] += u.get("cost_usd") or 0
        tiers[u.get("service_tier")] += 1
    all_cost = sum((R[i]["api_output"].get("llm_cost") or {}).get("total_usd") or 0 for i in ids)
    return {
        "passed": sum(passed(R[i]) for i in ids),
        "errors": sum(1 for i in ids if R[i]["api_output"].get("error")),
        "complex_used": sum(1 for i in ids if R[i]["timings"].get("complex_model_used")),
        "resolution_mode_respected": dict(collections.Counter(
            str(R[i]["timings"].get("resolution_mode_respected")) for i in ids)),
        "text2sql_s": {"median": quant(t2s, .5), "p90": quant(t2s, .9), "max": quant(t2s, 1),
                       "over_8s": sum(1 for v in t2s if v and v > SLOW_SECONDS)},
        "total_s": {"median": quant(tot, .5), "p90": quant(tot, .9)},
        "text2sql_tokens": {k: agg[k] for k in ("calls", "prompt_tokens", "cached_tokens", "completion_tokens",
                                                "reasoning_tokens", "cache_write_tokens")},
        "cache_hit_pct": round(100 * agg["cached_tokens"] / agg["prompt_tokens"], 1) if agg["prompt_tokens"] else None,
        "text2sql_cost_usd": round(agg["cost_usd"], 2),
        "text2sql_usd_per_1000_calls": round(1000 * agg["cost_usd"] / agg["calls"], 2) if agg["calls"] else None,
        "all_tasks_cost_usd": round(all_cost, 2),
        "service_tiers": dict(tiers),
        "flex_retries": agg["flex_retries"],
        "flex_fallbacks": agg["flex_fallbacks"],
    }


def slow_slots(R: dict) -> dict:
    """Share of text2sql calls over SLOW_SECONDS per 10-minute slot, and throughput slow/fast."""
    rows = []
    for x in R.values():
        u = t2s_usage(x)
        t = x["timings"].get("text2sql_processing_time")
        if t and u:
            rows.append((str(x["tim_execution"])[11:15] + "0", t, u.get("completion_tokens") or 0))
    slow = [r for r in rows if r[1] > SLOW_SECONDS]
    fast = [r for r in rows if r[1] <= SLOW_SECONDS]
    by_slot = collections.Counter(r[0] for r in slow)
    all_slot = collections.Counter(r[0] for r in rows)
    return {
        "slots": {s: f"{by_slot[s]}/{all_slot[s]}" for s in sorted(all_slot)},
        "tokens_per_s_slow": round(st.median(r[2] / r[1] for r in slow), 1) if slow else None,
        "tokens_per_s_fast": round(st.median(r[2] / r[1] for r in fast), 1) if fast else None,
        "completion_tokens_median_slow": st.median(r[2] for r in slow) if slow else None,
        "completion_tokens_median_fast": st.median(r[2] for r in fast) if fast else None,
    }


def main():
    report = {}
    for lang in LANGS:
        T = load_run(EXEC_DIR / RUNS["terra"].format(lang=lang))
        S = load_run(EXEC_DIR / RUNS["sol"].format(lang=lang))
        ids = sorted(T.keys() & S.keys())
        won = [i for i in ids if passed(T[i]) and not passed(S[i])]
        lost = [i for i in ids if passed(S[i]) and not passed(T[i])]
        same = {i for i in ids if norm_sql(T[i]["api_output"].get("sql_query"))
                == norm_sql(S[i]["api_output"].get("sql_query"))}
        drift = same | TIME_SENSITIVE
        real_won = [i for i in won if i not in drift]
        real_lost = [i for i in lost if i not in drift]
        counting = [i for i in COUNTING if i in T and i in S]
        sol_dates = collections.Counter(str(S[i]["tim_execution"])[:10] for i in ids)
        report[lang] = {
            "common": len(ids),
            "terra_only": len(T.keys() - S.keys()),
            "sol_only": len(S.keys() - T.keys()),
            "sol_execution_dates": dict(sorted(sol_dates.items())),
            "terra": arm_stats(T, ids),
            "sol": arm_stats(S, ids),
            "net_raw": len(won) - len(lost),
            "won": won,
            "lost": lost,
            "same_sql_flips": sorted(i for i in won + lost if i in same),
            "time_sensitive_flips": sorted(i for i in won + lost if i in TIME_SENSITIVE and i not in same),
            "net_adjusted": len(real_won) - len(real_lost),
            "won_adjusted": real_won,
            "lost_adjusted": real_lost,
            "counting": {"n": len(counting), "terra": sum(passed(T[i]) for i in counting),
                         "sol": sum(passed(S[i]) for i in counting),
                         "flips": [i for i in counting if passed(T[i]) != passed(S[i])]},
            "terra_window_count_over": sum(" OVER ()" in (T[i]["api_output"].get("sql_query") or "") for i in ids),
            "terra_latency_slots": slow_slots({i: T[i] for i in ids}),
            "flip_questions": {i: T[i]["api_output"].get("question") for i in won + lost},
        }
        r = report[lang]
        n = r["common"]
        print(f"=== {lang.upper()}  n={n}  terra {r['terra']['passed']} ({100 * r['terra']['passed'] / n:.1f} %)"
              f"  sol {r['sol']['passed']} ({100 * r['sol']['passed'] / n:.1f} %)")
        print(f"  net raw {r['net_raw']:+d} (won {len(won)}, lost {len(lost)});"
              f" same-SQL flips {r['same_sql_flips']}; time-sensitive {r['time_sensitive_flips']}")
        print(f"  net adjusted {r['net_adjusted']:+d}  won {real_won}  lost {real_lost}")
        print(f"  counting {r['counting']}  terra OVER() {r['terra_window_count_over']}")
        for arm in ("terra", "sol"):
            a = r[arm]
            print(f"  {arm}: t2s {a['text2sql_s']}  hit {a['cache_hit_pct']} %"
                  f"  ${a['text2sql_usd_per_1000_calls']}/1000 calls  all tasks ${a['all_tasks_cost_usd']}"
                  f"  errors {a['errors']}  tiers {a['service_tiers']}")
        sl = r["terra_latency_slots"]
        print(f"  terra throughput slow {sl['tokens_per_s_slow']} tok/s, fast {sl['tokens_per_s_fast']} tok/s")
    OUT_JSON.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {OUT_JSON}")


if __name__ == "__main__":
    main()
