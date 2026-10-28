#!/usr/bin/env bash
# Three yes/no checks on one vendor payment file with allow_abstain. Abstained checks go to a person.
#   ./run.sh
set -euo pipefail
cd "$(dirname "$0")"
. ../../lib/bivia.sh

STATE='Vendor: Novex Data Ltd
PO-203: approved $14,000 for data analytics services, signed by CFO.
INV-006: Novex Data Ltd (London, UK), $14,000, dated 2026-10-22.
Receiving confirmation: dashboard access delivered, signed 2026-10-23.'

CHECKS=(
  "Does the invoice amount match the approved purchase order?"
  "Was the service delivered?"
  "Is this vendor on a sanctions list?"
)

for q in "${CHECKS[@]}"; do
  echo "== $q"
  # Same settings on every check, so an abstain reflects the evidence, never the settings.
  jq -n --arg state "$STATE" --arg question "$q" \
    '{state: $state, question: $question, mode: "deep", allow_abstain: true}' \
    | bivia /boolean | jq -c '{status, value, probability, abstain_reason}'
done
