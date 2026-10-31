# AGENTS.md - Agent Guide for the Text2SQL evaluator

Agent-facing operating context only. The evaluator itself (phases, CLI, assertion DSL, schema, exports, PHP UI, launcher pre-flight, troubleshooting, version history) is documented in @README.md, which is canonical. The conversational benchmark has its own guide, @harness/AGENTS.md.

## Related repositories (project ecosystem)

Evaluation stage of **Agent BBB** (`vaugouin`, siblings under `%USERPROFILE%/Code/<repo>`; roster `%USERPROFILE%/Nestor/projets/t2s-backlog/topics/related-repositories.txt`). A pure HTTP client of `fastapi-text2sql` (`/search/text2sql`), like `voice-agent` or `tmdb-front`: it never imports the API's code. Scripts that test the API's internals live in `fastapi-text2sql/checks/`; some read this repo through `../text2sql-eval`.

**Cinéphile Bench** (definition at the top of @README.md): use this name, with the accent, in docs, posts and reports. A score always names its bench version (v1 = 902 questions frozen 2026-10-14) and shows the EN and FR pass rates next to the pooled figure. `cinephile-bench-v1.sql` stays at the root as a living reference, not an archive candidate.

## History

Until 2026-10-12 this code lived in `fastapi-text2sql/eval/` (history kept by `git filter-repo`): commit messages and tickets before that date say `eval/...`, read them as paths of this repository.

## Deployment on the VPS

- `~/docker/text2sql-eval` is a **git clone**: update it with `git pull --ff-only`, never copy files in by hand. Its untracked `.env` is the only file git does not bring (`.env.example` lists the keys).
- `text2sql-eval.sh` (and `harness-eval.sh`) build and run the image after a read-only pre-flight and a typed `yes`; results go to `~/docker/shared_data/text2sql-eval` (`/shared`).
- After a campaign, suggest to Philippe the PC-side mirror `cd C:\Users\vaugo\Code\voice-agent\doc\logs-download` then `uv run --no-project --with paramiko python sync_vps_docker.py` (Windows terminal; it asks for the SSH key passphrase). Never launch it from a session.
- A `.sql` of this repo runs on the VPS per rule `sql-vps.md` (clone `text2sql-eval`); the dated result `<file>-YYYYMMDD.txt` lands next to the `.sql`.

## Local layout

- Tracked: evaluator, launchers, Dockerfile, `harness/`, bank migrations (`*.sql` and dated results), `archive/`, and `data/evaluation/` plus `data/evaluation_category/` (the question bank, refreshed from the VPS export by `voice-agent/doc/logs-download`).
- Local only (`.gitignore`): `.env`, `lib/` (the PHP graph UI, deliberately unversioned), `claude/`, `codex/`, `logs/`, `data/evaluation_execution/`, `data/harness/`, `data/bench/`.
- The DDL of the evaluation tables stays in `fastapi-text2sql/doc/sql/T2S_EVALUATION-tables.sql`.

## Conventions

- Line endings are LF (`.gitattributes`).
- Offline DSL checks, no database: `uv run --no-project --with pandas test-cell-condition.py`, `test-unified-schema-bridge.py`, `test-subset-301.py`.
- One-off `.sql` files and their dated results move to `archive/` once their ticket is closed.
- **Version:** `VERSION` at the root (MAJOR.MINOR.PATCH) is the source of truth. Bump it in the same commit as any change (PATCH by default, MINOR for a new option or behaviour) and add a row to the README version history.
- Tickets: T2S backlog (`Nestor/projets/t2s-backlog/`), `repos/text2sql-eval.md` and the `EVALUATIONS-*` topic.
