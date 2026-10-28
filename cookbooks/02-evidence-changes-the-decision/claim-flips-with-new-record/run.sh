#!/usr/bin/env bash
# Three yes/no checks on an auto claim. If the payment check abstains, add the billing record and ask again.
#   ./run.sh
set -euo pipefail
cd "$(dirname "$0")"
. ../../lib/bivia.sh

CLAIM='Auto claim CLM-30418, Lakeshore Mutual.
Claimant: Maria Lopez. Vehicle: 2019 sedan, dark blue.
Date of loss: 2026-10-18. Reported: 2026-10-19. Description: "Rear-ended while stopped at a red light. Rear bumper crushed, left tail light broken."
The other driver was cited for following too closely. Their insurer, Crestline Auto, has been notified; we pay the claim now and recover the payment and the deductible from Crestline.
Repair estimate RE-7790, Rivera Auto Body, 2026-10-21: rear bumper cover replace $640; bumper reinforcement $310; left tail lamp $285; trunk lid repair $420; refinish $560; labor $820; total $3,035.
Policy AU-55219, holder Maria Lopez. Coverage: collision, $500 deductible, $25,000 limit. Policy term: 2025-10-15 to 2026-10-15. Renewal notice for the 2026-10-15 to 2027-10-15 term sent 2026-09-15. Status: pending renewal, payment not yet posted.
Fast-track rule: estimates under $5,000 can be paid without an adjuster visit.'
BILLING_RECORD='Billing record: renewal premium for the 2026-10-15 to 2027-10-15 term received by mailed check on 2026-10-12, posted to the policy late on 2026-10-22.'
PHOTO="$(b64 data/car_damage.jpg)"
PAID_Q="Has the renewal premium been paid for the policy term that includes the date of loss?"

# check STATE QUESTION [with-photo]
check() {
  jq -n --arg state "$1" --arg question "$2" --rawfile photo "$PHOTO" --arg with_photo "${3:-}" '
    {state: $state, question: $question, mode: "deep", allow_abstain: true}
    + (if $with_photo == "" then {} else {images: [{b64: $photo, mime: "image/jpeg"}]} end)' \
    | bivia /boolean
}

echo "Round 1: the claim file"
echo "== Does the photo show damage to the rear of the car?"
check "$CLAIM"$'\n'"Attached: the claimant's photo of the car." "Does the photo show damage to the rear of the car?" photo \
  | jq -c '{status, value, probability, abstain_reason}'
echo "== Is the repair estimate under the fast-track limit?"
check "$CLAIM" "Is the repair estimate under the fast-track limit?" | jq -c '{status, value, probability, abstain_reason}'
echo "== $PAID_Q"
check "$CLAIM" "$PAID_Q" | tee "$BIVIA_TMP/paid.json" | jq -c '{status, value, probability, abstain_reason}'

# Round 2: same question, same settings, one more record.
if [ "$(jq -r .status "$BIVIA_TMP/paid.json")" = "abstained" ]; then
  echo
  echo "Round 2: added the billing record"
  echo "== $PAID_Q"
  check "$CLAIM"$'\n'"$BILLING_RECORD" "$PAID_Q" | jq -c '{status, value, probability, abstain_reason}'
fi
