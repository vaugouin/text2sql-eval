"""Paired comparison of two evaluation campaigns (arms), with a noise threshold (TEXT2SQL-EVAL-013).

Generalises archive/compare-terra-1-1-20.py (GPT-6-008) to any two tuple folders of the local execution
mirror. Pass = `scoring.assertions_total_score == 1.0`, as everywhere in the evaluator.

What the script reports, per language and pooled:
1. The paired 2x2 table on the common evaluation ids: pass/pass, A only, B only, fail/fail. The
   gain of B over A is the net of the two discordant cells, tested with an exact McNemar test
   (two-sided binomial on the discordant pairs). Comparing two headline rates instead hides how
   many questions actually moved: at a pass rate near 80 %, the 95 % margin of a paired gap is
   about +-1.8 points over 1,804 cases, so a one- or two-point gap can be noise.
2. A verdict next to the net: gain, loss, or within noise (alpha 0.05 by default), with the 95 %
   confidence interval of the paired difference in points.
3. The scorable rate: the pass rate on evaluations whose execution carries at least one assertion
   score. Evaluations without any assertion get a null total score and fail in every arm, which
   dilutes the headline rate without moving the gap.
4. The normalised gain (SkillsBench): (rate B - rate A) / (1 - rate A), the share of A's
   remaining failures that B fixes, net of what it breaks.
5. Results per category, since two arms can swap ranks from one category to another.
6. The cautions of archive/compare-terra-1-1-20.py, which the verdict rests on:
   - A rescore re-checks the stored result against today's assertions, it does not rerun the SQL.
     A flip with byte-identical SQL on both sides is data drift between the two execution dates,
     never an arm effect ("same_sql_flips"). On 2026-11-09 they were 13 of the Terra-Sol flips.
   - Time-sensitive questions (trending, died recently, most famous) move with the data even when
     the SQL differs. Both kinds are left out of the adjusted net, which carries the verdict.
   - Several JSON files can exist for one evaluation id (retired executions stay in the additive
     local mirror): the highest `execution_row_id` wins.
   - Cost and text2sql latency of each arm, from `llm_usage`, `llm_cost` and `timings`.
7. Compute per arm (TEXT2SQL-EVAL-014): escalations to the complex model, LLM calls and tokens over
   all tasks, cost per 1,000 passed questions; a flag when the adjusted winner spent more than 10 %
   extra, and the real flips that coincide with an escalation on one side only.
8. Failure triage (TEXT2SQL-EVAL-014): every failure sorted by its first failing stage (process,
   extraction, sql, result_empty, result_wrong, unscored), per arm and for the real flips, so a
   regression points to the layer that broke.

Pooled across languages, the EN and FR runs of one question are not independent, so the pooled
test does not count 2n cases: each question gets a difference in {-1, -0.5, 0, 0.5, 1} (mean of
its EN and FR flips), the sign test runs on the questions whose difference is not zero, and the
interval uses the variance of those per-question differences.

Run:
  cd text2sql-eval
  PYTHONUTF8=1 uv run --no-project python compare-arms.py \
      --a 001.001.020_{lang}_gpt-6-sol_gpt-6-sol_gpt-6-1-sol_re-gpt-6-luna \
      --b 001.001.020_{lang}_gpt-6-sol_gpt-6-1-terra_gpt-6-1-sol_re-gpt-6-luna [--lang en|fr|both]
A folder name may carry `{lang}`; without it, the language field of the name (the second
`_`-separated field) is swapped for each language asked. `--exec-dir` defaults to
~/Code/shared_data/text2sql-eval/evaluation_execution. Writes claude/compare_arms_<A>_vs_<B>.json
(local only: `claude/` is git-ignored because the output carries bank questions verbatim).
"""
import argparse
import collections
import json
import math
import re
import statistics as st
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_EXEC_DIR = ROOT.parent / "shared_data" / "text2sql-eval" / "evaluation_execution"
EVAL_DIR = ROOT / "data" / "evaluation"
CATEGORY_DIR = ROOT / "data" / "evaluation_category"
# Questions whose expected rows move with the data (popularity, recency, "most famous"); found in
# the Terra-Sol comparison of 2026-11-09. Extend with --time-sensitive.
TIME_SENSITIVE = {2324, 2342, 2345, 2390, 2442, 2471, 2503, 2527}
COMPONENTS = ("assertions_entity_extraction_score", "assertions_sql_query_score",
              "assertions_result_score")
Z95 = 1.959964


def load_run(folder: Path) -> dict[int, dict]:
    if not folder.is_dir():
        raise SystemExit(f"No such arm folder: {folder}")
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


def scorable(x) -> bool:
    return any(x["scoring"].get(k) is not None for k in COMPONENTS)


def norm_sql(q) -> str:
    return re.sub(r"\s+", " ", q or "").strip().rstrip(";").replace(" OFFSET 0", "").upper()


def quant(vals, p):
    vals = sorted(v for v in vals if v is not None)
    return round(vals[int(p * (len(vals) - 1))], 2) if vals else None


def binom_two_sided(k: int, n: int) -> float:
    """Exact two-sided p-value of k successes out of n under p = 0.5 (McNemar exact)."""
    if n == 0:
        return 1.0
    tail = sum(math.comb(n, i) for i in range(0, min(k, n - k) + 1)) / 2 ** n
    return min(1.0, 2 * tail)


def paired_test(diffs: list[float], alpha: float) -> dict:
    """Verdict on per-question differences B - A (each in [-1, 1]); zeros are concordant."""
    n = len(diffs)
    pos = sum(1 for d in diffs if d > 0)
    neg = sum(1 for d in diffs if d < 0)
    mean = sum(diffs) / n if n else 0.0
    var = sum((d - mean) ** 2 for d in diffs) / (n - 1) if n > 1 else 0.0
    half = Z95 * math.sqrt(var / n) if n else 0.0
    p = binom_two_sided(pos, pos + neg)
    verdict = "within noise" if p >= alpha else ("gain" if mean > 0 else "loss")
    return {"n": n, "b_better": pos, "a_better": neg, "p_value": round(p, 4),
            "diff_points": round(100 * mean, 2),
            "ci95_points": [round(100 * (mean - half), 2), round(100 * (mean + half), 2)],
            "verdict": verdict}


def arm_name(spec: str, lang: str) -> str:
    if "{lang}" in spec:
        return spec.format(lang=lang)
    parts = spec.split("_")
    if len(parts) > 2 and parts[1] in ("en", "fr"):
        parts[1] = lang
    return "_".join(parts)


def short_label(a: str, b: str) -> tuple[str, str]:
    """The tuple fields where the two arm names differ, for file names and print-outs."""
    pa, pb = a.replace("{lang}", "xx").split("_"), b.replace("{lang}", "xx").split("_")
    if len(pa) == len(pb):
        da = [x for x, y in zip(pa, pb) if x != y]
        db = [y for x, y in zip(pa, pb) if x != y]
        if da:
            return "-".join(da), "-".join(db)
    return "a", "b"


def load_categories() -> tuple[dict[int, int], dict[int, str]]:
    cat_of = {}
    for p in EVAL_DIR.glob("*.json"):
        m = re.match(r"(\d+)_(\d+)_", p.name)
        if m:
            cat_of[int(m.group(1))] = int(m.group(2))
    names = {}
    for p in CATEGORY_DIR.glob("*.json"):
        with p.open(encoding="utf-8") as f:
            c = json.load(f)
        names[int(c["evaluation_category_id"])] = str(c.get("description") or "").strip("'")
    return cat_of, names


def t2s_usage(x) -> dict:
    return (x["api_output"].get("llm_usage") or {}).get("text2sql") or {}


STAGES = ("process", "extraction", "sql", "result_empty", "result_wrong", "unscored")


def failure_stage(x) -> str | None:
    """First failing stage of an execution, or None if it passed.

    Sorting failures by kind tells which layer a fix belongs to (Tian et al. 2026, "Harness
    Evolution Hits a Ceiling": process failures yield to pipeline changes, content failures do
    not). Order of precedence: process (API error or no SQL produced: the pipeline gave no
    answer), extraction (entity extraction assertion failed), sql (SQL regex assertion failed),
    result_empty (the SQL ran and returned no row), result_wrong (rows returned, result assertion
    failed), unscored (no assertion at all: null total score).
    """
    if passed(x):
        return None
    o, s = x["api_output"], x["scoring"]
    if o.get("error") or not (o.get("sql_query") or "").strip():
        return "process"
    if not scorable(x):
        return "unscored"
    if s.get("assertions_entity_extraction_score") == 0:
        return "extraction"
    if s.get("assertions_sql_query_score") == 0:
        return "sql"
    if not o.get("result"):
        return "result_empty"
    return "result_wrong"


def compute(R: dict, ids: list[int]) -> dict:
    """What each arm spent: escalations, LLM calls and tokens over all tasks, cost.

    A gain bought with more compute is not the same gain (Ding et al. 2026, "Harness-Delta
    Attribution": over 21 significant harness gains, 14 % came from extra test-time compute).
    On this pipeline the extra compute is escalation to the complex model and reasoning tokens.
    """
    agg = collections.Counter()
    per_task = collections.Counter()
    for i in ids:
        for task, u in (R[i]["api_output"].get("llm_usage") or {}).items():
            if not isinstance(u, dict):
                continue
            per_task[task] += u.get("calls") or 0
            for k in ("calls", "prompt_tokens", "cached_tokens", "completion_tokens", "reasoning_tokens"):
                agg[k] += u.get(k) or 0
    n = len(ids)
    esc = sum(1 for i in ids if R[i]["timings"].get("complex_model_used"))
    cost = sum((R[i]["api_output"].get("llm_cost") or {}).get("total_usd") or 0 for i in ids)
    p = sum(passed(R[i]) for i in ids)
    return {
        "escalations": esc,
        "escalation_pct": round(100 * esc / n, 1) if n else None,
        "llm_calls": agg["calls"],
        "calls_per_question": round(agg["calls"] / n, 2) if n else None,
        "calls_per_task": dict(per_task),
        "prompt_tokens": agg["prompt_tokens"],
        "uncached_prompt_tokens": agg["prompt_tokens"] - agg["cached_tokens"],
        "completion_tokens": agg["completion_tokens"],
        "reasoning_tokens": agg["reasoning_tokens"],
        "cost_usd": round(cost, 2),
        "usd_per_1000_passed": round(1000 * cost / p, 2) if p else None,
    }


def escalated(x) -> bool:
    return bool(x["timings"].get("complex_model_used"))


def triage(A: dict, B: dict, ids: list[int], won: list[int], lost: list[int]) -> dict:
    """Failures per stage in each arm, the stage of each real flip, and flips tied to escalation."""
    fa = collections.Counter(failure_stage(A[i]) for i in ids)
    fb = collections.Counter(failure_stage(B[i]) for i in ids)
    return {
        "a_failures": {s: fa[s] for s in STAGES},
        "b_failures": {s: fb[s] for s in STAGES},
        # B won: the stage at which A failed; B lost: the stage at which B failed.
        "b_won_from_stage": dict(collections.Counter(failure_stage(A[i]) for i in won)),
        "b_lost_at_stage": dict(collections.Counter(failure_stage(B[i]) for i in lost)),
        "b_won_with_escalation_only_in_b": [i for i in won if escalated(B[i]) and not escalated(A[i])],
        "b_lost_with_escalation_only_in_a": [i for i in lost if escalated(A[i]) and not escalated(B[i])],
    }


def compute_flag(r: dict, threshold: float = 0.10) -> str | None:
    """A note when the adjusted verdict is a gain or a loss and the winner spent clearly more."""
    v = r["test_adjusted"]["verdict"]
    if v == "within noise":
        return None
    win, lose = ("b", "a") if v == "gain" else ("a", "b")
    cw, cl = r["compute"][win], r["compute"][lose]
    more = [k for k in ("escalations", "llm_calls", "reasoning_tokens", "cost_usd")
            if cl[k] and (cw[k] - cl[k]) / cl[k] > threshold]
    if not more:
        return None
    return (f"the winning arm {win.upper()} spent more than 10 % extra on {', '.join(more)}:"
            f" part of the {v} may be compute; compare at equal budget before keeping it")


def arm_stats(R: dict, ids: list[int]) -> dict:
    n = len(ids)
    sc = [i for i in ids if scorable(R[i])]
    p = sum(passed(R[i]) for i in ids)
    ps = sum(passed(R[i]) for i in sc)
    t2s = [R[i]["timings"].get("text2sql_processing_time") for i in ids]
    tot = [R[i]["timings"].get("total_processing_time") for i in ids]
    calls = sum(t2s_usage(R[i]).get("calls") or 0 for i in ids)
    t2s_cost = sum(t2s_usage(R[i]).get("cost_usd") or 0 for i in ids)
    all_cost = sum((R[i]["api_output"].get("llm_cost") or {}).get("total_usd") or 0 for i in ids)
    dates = collections.Counter(str(R[i]["tim_execution"])[:10] for i in ids)
    return {
        "passed": p,
        "rate_pct": round(100 * p / n, 2) if n else None,
        "scorable": len(sc),
        "scorable_passed": ps,
        "scorable_rate_pct": round(100 * ps / len(sc), 2) if sc else None,
        "errors": sum(1 for i in ids if R[i]["api_output"].get("error")),
        "complex_used": sum(1 for i in ids if R[i]["timings"].get("complex_model_used")),
        "text2sql_s": {"median": quant(t2s, .5), "p90": quant(t2s, .9), "max": quant(t2s, 1)},
        "total_s": {"median": quant(tot, .5), "p90": quant(tot, .9)},
        "text2sql_cost_usd": round(t2s_cost, 2),
        "text2sql_usd_per_1000_calls": round(1000 * t2s_cost / calls, 2) if calls else None,
        "all_tasks_cost_usd": round(all_cost, 2),
        "service_tiers": dict(collections.Counter(str(t2s_usage(R[i]).get("service_tier")) for i in ids)),
        "execution_dates": dict(sorted(dates.items())),
    }


def compare_lang(A: dict, B: dict, time_sensitive: set[int], cat_of: dict, cat_names: dict,
                 alpha: float) -> dict:
    ids = sorted(A.keys() & B.keys())
    n = len(ids)
    pa = {i: passed(A[i]) for i in ids}
    pb = {i: passed(B[i]) for i in ids}
    table = collections.Counter((pa[i], pb[i]) for i in ids)
    b_won = [i for i in ids if pb[i] and not pa[i]]
    b_lost = [i for i in ids if pa[i] and not pb[i]]
    same = {i for i in ids if norm_sql(A[i]["api_output"].get("sql_query"))
            == norm_sql(B[i]["api_output"].get("sql_query"))}
    drift = same | time_sensitive
    kept = [i for i in ids if i not in drift or pa[i] == pb[i]]
    raw = paired_test([pb[i] - pa[i] for i in ids], alpha)
    adj = paired_test([pb[i] - pa[i] for i in kept], alpha)
    sa, sb = arm_stats(A, ids), arm_stats(B, ids)
    ra, rb = sa["passed"] / n if n else 0, sb["passed"] / n if n else 0
    per_cat = collections.defaultdict(lambda: {"n": 0, "a": 0, "b": 0, "b_won": [], "b_lost": []})
    for i in ids:
        c = per_cat[cat_of.get(i, 0)]
        c["n"] += 1
        c["a"] += pa[i]
        c["b"] += pb[i]
        if i in b_won:
            c["b_won"].append(i)
        if i in b_lost:
            c["b_lost"].append(i)
    cats = sorted(({"category_id": k, "category": cat_names.get(k, "?"), **v,
                    "net": len(v["b_won"]) - len(v["b_lost"])} for k, v in per_cat.items()),
                  key=lambda c: (-abs(c["net"]), -len(c["b_won"]) - len(c["b_lost"]), c["category_id"]))
    return {
        "common": n,
        "a_only": len(A.keys() - B.keys()),
        "b_only": len(B.keys() - A.keys()),
        "table": {"both_pass": table[(True, True)], "a_only_pass": table[(True, False)],
                  "b_only_pass": table[(False, True)], "both_fail": table[(False, False)]},
        "a": sa,
        "b": sb,
        "net_raw": len(b_won) - len(b_lost),
        "test_raw": raw,
        "same_sql_flips": sorted(i for i in b_won + b_lost if i in same),
        "time_sensitive_flips": sorted(i for i in b_won + b_lost if i in time_sensitive and i not in same),
        "net_adjusted": adj["b_better"] - adj["a_better"],
        "test_adjusted": adj,
        "normalised_gain": round((rb - ra) / (1 - ra), 3) if ra < 1 else None,
        "b_won": b_won,
        "b_lost": b_lost,
        "b_won_adjusted": [i for i in b_won if i not in drift],
        "b_lost_adjusted": [i for i in b_lost if i not in drift],
        "compute": {"a": compute(A, ids), "b": compute(B, ids)},
        "triage": triage(A, B, ids, [i for i in b_won if i not in drift], [i for i in b_lost if i not in drift]),
        "per_category": [c for c in cats if c["b_won"] or c["b_lost"]],
        "flip_questions": {i: B[i]["api_output"].get("question") for i in b_won + b_lost},
        "_pass": (pa, pb, drift),
    }


def pooled(per_lang: dict, alpha: float) -> dict:
    """Per-question differences averaged over the languages where the question ran in both arms."""
    diffs_raw, diffs_adj = collections.defaultdict(list), collections.defaultdict(list)
    for r in per_lang.values():
        pa, pb, drift = r["_pass"]
        for i in pa:
            d = pb[i] - pa[i]
            diffs_raw[i].append(d)
            diffs_adj[i].append(0 if i in drift else d)
    return {
        "questions": len(diffs_raw),
        "test_raw": paired_test([sum(v) / len(v) for v in diffs_raw.values()], alpha),
        "test_adjusted": paired_test([sum(v) / len(v) for v in diffs_adj.values()], alpha),
    }


def fmt_test(t: dict) -> str:
    lo, hi = t["ci95_points"]
    return (f"B better {t['b_better']}, A better {t['a_better']}, diff {t['diff_points']:+.2f} pts"
            f" [95 % CI {lo:+.2f}, {hi:+.2f}], p = {t['p_value']} -> {t['verdict'].upper()}")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--a", required=True, help="reference arm folder name (may contain {lang})")
    ap.add_argument("--b", required=True, help="challenger arm folder name (may contain {lang})")
    ap.add_argument("--lang", choices=("en", "fr", "both"), default="both")
    ap.add_argument("--exec-dir", type=Path, default=DEFAULT_EXEC_DIR)
    ap.add_argument("--alpha", type=float, default=0.05)
    ap.add_argument("--time-sensitive", type=int, nargs="*", default=[],
                    help="extra evaluation ids to treat as time-sensitive")
    ap.add_argument("--out", type=Path, help="output JSON (default claude/compare_arms_<A>_vs_<B>.json)")
    args = ap.parse_args()

    langs = ("en", "fr") if args.lang == "both" else (args.lang,)
    time_sensitive = TIME_SENSITIVE | set(args.time_sensitive)
    cat_of, cat_names = load_categories()
    la, lb = short_label(args.a, args.b)
    report = {"a": args.a, "b": args.b, "label_a": la, "label_b": lb, "alpha": args.alpha,
              "time_sensitive": sorted(time_sensitive), "languages": {}}
    print(f"A = {la}   B = {lb}")
    for lang in langs:
        A = load_run(args.exec_dir / arm_name(args.a, lang))
        B = load_run(args.exec_dir / arm_name(args.b, lang))
        r = compare_lang(A, B, time_sensitive, cat_of, cat_names, args.alpha)
        report["languages"][lang] = r
        n, t = r["common"], r["table"]
        print(f"\n=== {lang.upper()}  common {n} (A only {r['a_only']}, B only {r['b_only']})")
        for arm, s in (("A", r["a"]), ("B", r["b"])):
            print(f"  {arm}: {s['passed']} ({s['rate_pct']} %), scorable {s['scorable_passed']}/{s['scorable']}"
                  f" ({s['scorable_rate_pct']} %), t2s median {s['text2sql_s']['median']} s p90"
                  f" {s['text2sql_s']['p90']} s, ${s['text2sql_usd_per_1000_calls']}/1000 t2s calls,"
                  f" all tasks ${s['all_tasks_cost_usd']}, errors {s['errors']}, run {list(s['execution_dates'])}")
        print(f"  table: both pass {t['both_pass']}, A only {t['a_only_pass']}, B only {t['b_only_pass']},"
              f" both fail {t['both_fail']}; normalised gain {r['normalised_gain']}")
        print(f"  raw      net {r['net_raw']:+d}: {fmt_test(r['test_raw'])}")
        print(f"  set apart: same-SQL flips {r['same_sql_flips']}, time-sensitive {r['time_sensitive_flips']}")
        print(f"  adjusted net {r['net_adjusted']:+d}: {fmt_test(r['test_adjusted'])}")
        print(f"  B won {r['b_won_adjusted']}  B lost {r['b_lost_adjusted']}")
        for arm in ("a", "b"):
            c = r["compute"][arm]
            print(f"  compute {arm.upper()}: escalations {c['escalations']} ({c['escalation_pct']} %),"
                  f" {c['calls_per_question']} LLM calls/question, uncached prompt {c['uncached_prompt_tokens']:,},"
                  f" completion {c['completion_tokens']:,}, reasoning {c['reasoning_tokens']:,},"
                  f" ${c['cost_usd']} (${c['usd_per_1000_passed']}/1000 passed)")
        r["compute_flag"] = compute_flag(r)
        if r["compute_flag"]:
            print(f"  !! {r['compute_flag']}")
        tr = r["triage"]
        for arm in ("a", "b"):
            f = tr[f"{arm}_failures"]
            print(f"  failures {arm.upper()}: " + ", ".join(f"{s} {f[s]}" for s in STAGES))
        print(f"  real flips: B won from {tr['b_won_from_stage']}, B lost at {tr['b_lost_at_stage']};"
              f" won with escalation only in B {tr['b_won_with_escalation_only_in_b']},"
              f" lost with escalation only in A {tr['b_lost_with_escalation_only_in_a']}")
        for c in r["per_category"][:8]:
            print(f"    cat {c['category_id']:>3} {c['category'][:40]:<40} n {c['n']:>3}  A {c['a']:>3}  B {c['b']:>3}"
                  f"  net {c['net']:+d}")
    if len(langs) > 1:
        p = pooled(report["languages"], args.alpha)
        report["pooled"] = p
        print(f"\n=== POOLED by question ({p['questions']} questions, EN and FR averaged per question)")
        print(f"  raw      {fmt_test(p['test_raw'])}")
        print(f"  adjusted {fmt_test(p['test_adjusted'])}")
    for r in report["languages"].values():
        del r["_pass"]
    out = args.out or ROOT / "claude" / f"compare_arms_{la}_vs_{lb}.json"
    out.parent.mkdir(exist_ok=True)
    out.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nWrote {out}")


if __name__ == "__main__":
    main()
