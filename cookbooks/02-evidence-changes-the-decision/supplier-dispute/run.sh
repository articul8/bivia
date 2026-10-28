#!/usr/bin/env bash
# Supplier dispute: ask one question of each input (contract, scorecard, gauge readings, dock photo, call video),
# then pass the typed answers as text to one /decide call.
#   ./run.sh
set -euo pipefail
cd "$(dirname "$0")"
. ../../lib/bivia.sh

US="We are Acme Manufacturing (乙 in the attached supplier contract). Our supplier is Toho Seiki (甲)."
CONTRACT="$(b64 data/contract_ja.pdf)"
SCORECARD="$(b64 data/scorecard.png)"
EMAIL="$(b64 data/delay_email.png)"
DOCK="$(b64 data/dock_photo.jpg)"
VIDEO="$(b64 data/call.mp4)"

# One line of text per answer, for the /decide state.
summary() {
  jq -r '
    def pct: "\(. * 100 | round)%";
    if .status == "abstained" then "abstained (\(.abstain_reason))"
    elif .hits then ([.hits[] | "\(.start | round)–\(.end | round) s"] | join(", ") | if . == "" then "not found" else . end)
    elif .value == null then "not available"
    elif (.value | type) == "array" then (.value | map(if type == "object" then .label else . end) | join(", ") | if . == "" then "none" else . end)
    else "\(.value)" + (if .probability then " (\(.probability | pct))" else "" end)
    end'
}

# ---- Step 1: one question per input.

echo "== Does the contract renew automatically?  (/boolean, PDF)"
RENEW=$(jq -n --rawfile pdf "$CONTRACT" '{
    state: "Attached: our supplier contract.",
    question: "Does this contract renew automatically?",
    documents: [{b64: $pdf, mime: "application/pdf"}],
    mode: "fast", allow_abstain: true
  }' | bivia /boolean)
echo "$RENEW" | jq -c '{status, value, probability}'

echo "== Which clauses matter if we leave Toho?  (/set, PDF + scorecard)"
CLAUSES=$(jq -n --rawfile pdf "$CONTRACT" --rawfile img "$SCORECARD" --arg us "$US" '{
    state: "\($us) Toho Seiki keeps shipping late and we plan to move GH-220 to another supplier. The screenshot is our supplier scorecard.",
    question: "Which contract clauses create a right, a cost, or a deadline for us if we move away from Toho Seiki?",
    options: [
      "Art. 1 — Purpose (第1条)", "Art. 5 — Late-delivery damages (第5条)", "Art. 8 — Quality warranty (第8条)",
      "Art. 12 — Term & automatic renewal (第12条)", "Art. 14 — Termination for repeated late delivery (第14条)",
      "Art. 16 — Minimum purchase volume (第16条)", "Art. 19 — Governing law (第19条)", "Art. 20 — Confidentiality (第20条)"
    ],
    images: [{b64: $img, mime: "image/png"}],
    documents: [{b64: $pdf, mime: "application/pdf"}],
    mode: "fast", allow_abstain: true
  }' | bivia /set)
echo "$CLAUSES" | jq -c '{status, value, probabilities}'

echo "== Is Toho's part quality slipping?  (/ds, gauge readings)"
QUALITY=$(jq -n --slurpfile g data/gauge.json '$g[0] as $g | {
    signals: [{name: $g.name, data: [$g.data], fs: 1, dtype: "float32"}],
    question: "Bore diameter (mm) of incoming Toho Seiki GH-220 lots, nominal \($g.nominal) ± \($g.tolerance), one value per lot in arrival order. What is happening to the process?",
    options: ["Process stable (in control)", "Mean drifting upward (trend)", "Variance increasing", "Sensor noise only"],
    kind: "set"
  }' | bivia /ds)
echo "$QUALITY" | jq -c '{status, value, probabilities}'

echo "== Damage in Toho's last shipment?  (/ground, dock photo)"
CRATE=$(jq -n --rawfile img "$DOCK" '{
    question: "Find the broken wooden crate.",
    images: [{b64: $img, mime: "image/jpeg"}]
  }' | bivia /ground)
echo "$CRATE" | jq -c '{found, value}'

echo "== When does the customer look angry on the call?  (/ground/video)"
ANGRY=$(jq -n --rawfile vid "$VIDEO" '{
    video: {b64: $vid, mime: "video/mp4"},
    query: "the customer on the call looks angry", kind: "object",
    coarse_step: 3, fine_resolution: 0.5, boxes_on_hits: false, max_probes: 80
  }' | bivia /ground/video)
echo "$ANGRY" | jq -c '{hits}'

echo "== Which supplier should we choose?  (/choice, PDF + screenshots)"
SUPPLIER=$(jq -n --rawfile pdf "$CONTRACT" --rawfile card "$SCORECARD" --rawfile email "$EMAIL" --arg us "$US" '{
    state: "\($us) Our customer Northline Automotive is escalating late GH-220 gear housings. Attached: our supplier scorecard and the delay email from Toho.",
    question: "Which supplier should we choose for GH-220 going forward?",
    choices: ["Stay with Toho Seiki", "Switch to Kestrel Components", "Switch to Meridian Castings",
              "Split volume: Toho Seiki + Meridian Castings"],
    images: [{b64: $card, mime: "image/png"}, {b64: $email, mime: "image/png"}],
    documents: [{b64: $pdf, mime: "application/pdf"}],
    mode: "fast", allow_abstain: true
  }' | bivia /choice)
echo "$SUPPLIER" | jq -c '{status, value, probability, distribution}'

# ---- Step 2: chain. /decide sees only the answers above, as text. No files are re-sent.

FINDINGS="1. Does the contract auto-renew? → $(summary <<<"$RENEW")
2. Which contract clauses apply if we move away from Toho? → $(summary <<<"$CLAUSES")
3. Is Toho's part quality slipping (gauge readings of Toho's lots)? → $(summary <<<"$QUALITY")
4. Damage found in the dock photo of Toho's last shipment → $(summary <<<"$CRATE")
5. Customer looks angry on the call at → $(summary <<<"$ANGRY")
6. Which supplier should we choose? → $(summary <<<"$SUPPLIER")"

echo
echo "== Decision from these findings  (/decide)"
echo "$FINDINGS"
jq -n --arg findings "$FINDINGS" --arg today "$(date '+%d %B %Y')" '{
    state: "We are Acme Manufacturing; our GH-220 supplier is Toho Seiki. Today is \($today).\n\nQuestions we already answered from the call, the contract, the screenshots, the dock photo and the gauge data:\n\($findings)",
    question: "Given these findings, what should Acme do about GH-220 now?",
    outcomes: [
      "Stay with Toho Seiki and accept their recovery plan",
      "Terminate Toho now under Art. 14, claim Art. 5 late-delivery damages, and move GH-220 to Kestrel",
      "Keep the Toho contract running, shift GH-220 volume to Kestrel, and pay the Art. 16 shortfall fee",
      "Send Toho a non-renewal notice under Art. 12 and move to Kestrel when the contract ends in March 2027",
      "Move GH-220 to Meridian Castings"
    ],
    mode: "fast", allow_abstain: true
  }' | bivia /decide | jq -c '{status, value, probability, abstain_reason}'
