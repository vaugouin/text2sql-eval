#!/usr/bin/env bash
# Queue evaluation campaigns behind a long job: wait until a container has stopped, switch the
# scheduled tasks off, run the campaigns one after the other, then switch the tasks back on.
#
#   nohup bash queue-campaigns.sh <campaign file> > /tmp/queue-campaigns.log 2>&1 &
#   tail -f /tmp/queue-campaigns.log
#
# The campaign file holds one campaign per line, written as the environment of text2sql-eval.sh
# (blank lines and # comments ignored), for example:
#   EVAL_LANGUAGE=en ENTITY_EXTRACTION_MODEL=gpt-6.2-sol TEXT2SQL_MODEL=gpt-6.2-sol API_VERSION=1.1.20
#   EVAL_LANGUAGE=fr ENTITY_EXTRACTION_MODEL=gpt-6.2-sol TEXT2SQL_MODEL=gpt-6.2-sol API_VERSION=1.1.20
#
# Why each step is there:
# - It waits for the container WAIT_FOR (default wikidata-crawler) to stop, because a campaign that
#   shares the VPS with a Wikidata pass measures the contention, not the model.
# - With the default WAIT_FOR it also requires the stopped_run.json that a stop on request leaves
#   (wikidata-crawler/stop-at-step-boundary.sh). A crawler that ended without it failed or
#   finished, and someone should look before money is spent: the queue then stops, nothing runs.
#   REQUIRE_STOP_MARKER=0 drops that check.
# - off-all.sh runs first: a cron tick during a campaign would start a scheduled task again.
# - Each campaign gets EVAL_CONFIRM=yes, since nobody is at the terminal to type yes. The pre-flight
#   still prints its recap (cost estimate included) into this log.
# - text2sql-eval.sh follows the container's logs until it exits; the exit status is then read from
#   the last line of the run log. A failed campaign (cache guard = 3, crash) stops the queue: the
#   next one would hit the same cause.
# - on-all.sh runs at the end whatever happened, so the scheduled tasks never stay off. A stopped
#   wikidata-crawler does not restart: its stopped_run.json keeps run-if-new-dump.sh from launching.
# A Discord message is sent at each milestone when the webhook file of wikidata-crawler is there.
set -u
QUEUE=${1:-}
[ -n "$QUEUE" ] && [ -f "$QUEUE" ] || { echo "usage: $0 <campaign file> (one line of variables per campaign)"; exit 2; }
QUEUE=$(readlink -f "$QUEUE")
DOCKER_ROOT=${DOCKER_ROOT:-$HOME/docker}
EVAL_HOME=${EVAL_HOME:-$DOCKER_ROOT/text2sql-eval}
WAIT_FOR=${WAIT_FOR:-wikidata-crawler}
REQUIRE_STOP_MARKER=${REQUIRE_STOP_MARKER:-$([ "$WAIT_FOR" = "wikidata-crawler" ] && echo 1 || echo 0)}
STOP_MARKER=${STOP_MARKER:-$DOCKER_ROOT/shared_data/wikidata-crawler/stopped_run.json}
RUN_LOG=${RUN_LOG:-$DOCKER_ROOT/shared_data/logs/text2sql-eval/latest.log}
WEBHOOK_FILE=${DISCORD_WEBHOOK_FILE:-$DOCKER_ROOT/wikidata-crawler/.discord-webhook}
POLL=${POLL:-60}

say() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }
notify() {  # plain ASCII messages built here, so no JSON escaping is needed
    [ -s "$WEBHOOK_FILE" ] || return 0
    curl -fsS -m 20 -H 'Content-Type: application/json' -d "{\"content\": \"$1\"}" \
        "$(head -1 "$WEBHOOK_FILE" | tr -d '[:space:]')" >/dev/null || say "WARNING: Discord message not sent."
}
running() { [ -n "$(docker ps -q -f name="^$1\$")" ]; }

mapfile -t CAMPAIGNS < <(grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' "$QUEUE")
[ "${#CAMPAIGNS[@]}" -gt 0 ] || { echo "No campaign in $QUEUE."; exit 2; }
for c in "${CAMPAIGNS[@]}"; do
    for word in $c; do
        printf '%s' "$word" | grep -Eq '^[A-Z_][A-Z0-9_]*=[^[:space:]]*$' \
            || { echo "ERROR: '$word' in '$c' is not VAR=value. Nothing queued."; exit 2; }
    done
done
running text2sql-eval && { echo "ERROR: a text2sql-eval container is already running."; exit 2; }

say "queued ${#CAMPAIGNS[@]} campaign(s) from $QUEUE, after $WAIT_FOR has stopped:"
printf '    %s\n' "${CAMPAIGNS[@]}"
while running "$WAIT_FOR"; do sleep "$POLL"; done
say "$WAIT_FOR is not running."
if [ "$REQUIRE_STOP_MARKER" = "1" ] && [ ! -f "$STOP_MARKER" ]; then
    say "no $STOP_MARKER: $WAIT_FOR did not stop on request (failed or finished). Nothing launched."
    notify "**queue-campaigns : $WAIT_FOR s'est arrete sans stopped_run.json (echec ou fin). Aucune campagne lancee.**"
    exit 1
fi

if [ -f "$DOCKER_ROOT/off-all.sh" ]; then
    say "switching the scheduled tasks off: off-all.sh"
    bash "$DOCKER_ROOT/off-all.sh"
fi
notify "**queue-campaigns : $WAIT_FOR arrete, ${#CAMPAIGNS[@]} campagne(s) lancee(s).**"

STATUS=0; DONE=0
for c in "${CAMPAIGNS[@]}"; do
    say "=== campaign $((DONE + 1))/${#CAMPAIGNS[@]}: $c"
    before=$(readlink -f "$RUN_LOG" 2>/dev/null)
    # shellcheck disable=SC2086
    (cd "$EVAL_HOME" && env $c EVAL_CONFIRM=yes bash ./text2sql-eval.sh < /dev/null)
    rc=$?
    log=$(readlink -f "$RUN_LOG" 2>/dev/null)
    if [ "$rc" -ne 0 ] || [ -z "$log" ] || [ "$log" = "$before" ]; then
        say "text2sql-eval.sh exited with $rc before launching a run."; STATUS=1; break
    fi
    # docker logs -f returns as the container exits; the run log's last line follows within seconds.
    line=""
    for _ in $(seq 1 120); do
        line=$(grep -m1 '^=== text2sql-eval exited with status' "$log")
        [ -n "$line" ] && break
        sleep 5
    done
    code=$(printf '%s' "$line" | sed -nE 's/.*status ([0-9]+).*/\1/p')
    say "campaign ended: ${line:-no exit line in $log}"
    if [ "${code:-1}" != "0" ]; then STATUS=1; break; fi
    DONE=$((DONE + 1))
done

if [ -f "$DOCKER_ROOT/on-all.sh" ]; then
    say "switching the scheduled tasks back on: on-all.sh"
    bash "$DOCKER_ROOT/on-all.sh"
fi
if [ "$STATUS" -eq 0 ]; then
    say "all ${#CAMPAIGNS[@]} campaign(s) done."
    notify "**queue-campaigns : ${#CAMPAIGNS[@]} campagne(s) terminee(s), on-all.sh lance.**"
else
    say "queue stopped after $DONE campaign(s) out of ${#CAMPAIGNS[@]}; on-all.sh was run anyway."
    notify "**queue-campaigns : arret apres $DONE campagne(s) sur ${#CAMPAIGNS[@]} (voir /tmp/queue-campaigns.log), on-all.sh lance.**"
fi
exit "$STATUS"
