#!/usr/bin/env bash
# Loop every 15m: emit AGENT_LOOP_TICK for validate-luure-migration.sh
#
# Usage:
#   ./scripts/loop-validate-luure.sh          # background loop (900s interval)
#   INTERVAL=300 ./scripts/loop-validate-luure.sh
#
# The agent should run validate-luure-migration.sh once immediately when arming
# this loop; the first AGENT_LOOP_TICK arrives after the initial sleep.
set -euo pipefail

INTERVAL="${INTERVAL:-900}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT='Run scripts/validate-luure-migration.sh from sovereignID.io and report any failures or DNS skips.'

echo "Loop every ${INTERVAL}s: validate-luure-migration.sh"
echo "First AGENT_LOOP_TICK in ${INTERVAL}s (run validation once now if arming from agent)."

while true; do
  sleep "$INTERVAL"
  echo "AGENT_LOOP_TICK_luure_validate {\"prompt\":\"${PROMPT}\"}"
done
