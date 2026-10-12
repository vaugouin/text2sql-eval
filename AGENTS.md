# AGENTS.md - Agent Guide for the Text2SQL evaluator

This file is for agent-facing operating context only. The evaluator itself (phases, CLI, assertion DSL, schema, exports, PHP UI, troubleshooting) is documented in @README.md, which is canonical and not duplicated here. The conversational benchmark has its own guide, @harness/AGENTS.md.

## Related repositories (project ecosystem)

`text2sql-eval` is one stage of **Agent BBB**, a multi-repository movie/TV database system owned by GitHub user `vaugouin`. All sibling repos live under `%USERPROFILE%/Code/<repo>` and at `github.com/vaugouin/<repo>`; they converge on a shared MariaDB database (`T_WC_*` tables) and a ChromaDB vector store. The canonical roster is `%USERPROFILE%/Nestor/projets/t2s-backlog/topics/related-repositories.txt` (documentation repo `Nestor`, outside `Code/`).

**This repository's role:** Evaluation stage. A client of the `fastapi-text2sql` API, in the same way as `voice-agent` or `tmdb-front`: it sends the questions of the evaluation bank (`T_WC_T2S_EVALUATION`) to `/search/text2sql` over HTTP, stores each answer in `T_WC_T2S_EVALUATION_EXECUTION`, scores it against the assertions and exports the results as JSON. It never imports the API's code.

## History

Until 2026-10-12 this code lived in `fastapi-text2sql/eval/`. It was split out with its git history (`git filter-repo --subdirectory-filter eval`), so `git log` and `git blame` go back to 2026-02-08. Commit messages and closed tickets written before that date say `eval/...`: read them as paths of this repository.

The scripts that import the API's own modules (`entity`, `main`, `text2sql`, `rapidfuzz_query`, `json_guardrails`) did **not** move: they test the API's internals, not the API as a client. They live in `fastapi-text2sql/checks/` (benches, `verif-*`, `check-*`, `eval-309`, the Jev bench, the ChromaDB checks). A few of them still read this repository's files, through the sibling folder `../text2sql-eval`.

## Deployment on the VPS

- `~/docker/text2sql-eval` is a **git clone** of this repository. Update it with `git pull --ff-only`; never copy files into it by hand. Before 2026-10-12 it was a flat copy of `fastapi-text2sql-green/eval/*`, which drifted silently.
- Its `.env` is not tracked (`.gitignore`) and is the only file there that git does not bring. `.env.example` lists the keys.
- `text2sql-eval.sh` builds the image `text2sql-eval-python-app`, runs a read-only pre-flight (which also warns when the clone is behind `origin/main` or carries local edits) and waits for a typed `yes` before spending anything. `harness-eval.sh` runs the harness with the same image.
- Results go to `~/docker/shared_data/text2sql-eval` (mounted as `/shared`).
- A `.sql` of this repository runs with `~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/<file>.sql`, after a `git pull` in the clone; the result lands next to the `.sql` as `<file>-YYYYMMDD.txt`.

## Local layout

- Tracked: the evaluator (`text2sql-eval.py`, `text2sql_eval_functions.py`, `entity_extraction_eval_functions.py`, `citizenphil.py`), its launchers and Dockerfile, `harness/`, the bank migrations (`*.sql` and their dated results), `archive/`, and `data/evaluation/` plus `data/evaluation_category/` (the question bank, refreshed from the VPS export by `voice-agent/doc/logs-download`).
- Local only (`.gitignore`): `.env`, `lib/` (the PHP graph UI, deliberately unversioned), `claude/`, `codex/`, `logs/`, `data/evaluation_execution/`, `data/harness/`, `data/bench/`.
- The DDL of the evaluation tables stays in `fastapi-text2sql/doc/sql/T2S_EVALUATION-tables.sql`.

## Conventions

- Line endings are LF (`.gitattributes`), as everywhere in the stack.
- Offline checks of the DSL need no database: `uv run --no-project --with pandas test-cell-condition.py`, `test-unified-schema-bridge.py`, `test-subset-301.py`.
- One-off `.sql` files and their dated results move to `archive/` once their ticket is closed.
- Tickets about the evaluator are tracked in the T2S backlog (`Nestor/projets/t2s-backlog/`), under `repos/text2sql-eval.md` and the `EVALUATIONS-*` topic.
