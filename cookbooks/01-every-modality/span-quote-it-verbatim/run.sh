#!/usr/bin/env bash
# Ask questions about a policy and get back the exact words that answer them, as character offsets into the text.
#   ./run.sh
set -euo pipefail
cd "$(dirname "$0")"
. ../../lib/bivia.sh

QUESTIONS=(
  "What is the deductible for theft?"
  "How many days do I have to report a loss?"
  "What damage does the policy exclude?"
  "What is the maximum paid for personal items left in the car?"
  "Does the policy cover a rental car?"
)

for q in "${QUESTIONS[@]}"; do
  echo "== $q"
  jq -n --rawfile state data/policy.txt --arg question "$q" '{state: $state, question: $question}' \
    | bivia /span > "$BIVIA_TMP/res.json"
  jq '{status, value}' "$BIVIA_TMP/res.json"
  # Prove each quote is verbatim: slice the policy at the returned offsets.
  jq -r --rawfile policy data/policy.txt \
    '.value[]? | "policy[\(.start):\(.end)] = \($policy[.start:.end] | tojson)  verbatim=\($policy[.start:.end] == .text)"' \
    "$BIVIA_TMP/res.json"
  echo
done
