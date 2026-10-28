#!/usr/bin/env bash
# French questions on a 5-page French claim file, sent as the PDF itself.
#   ./run.sh
set -euo pipefail
cd "$(dirname "$0")"
. ../../lib/bivia.sh

PDF="$(b64 data/dossier_sinistre.pdf)"
STATE="Pièce jointe : un dossier de sinistre automobile de 5 pages (PDF). Répondez uniquement d'après le contenu du dossier."

# yes/no question → /boolean
ask_boolean() {
  echo "== $1"
  jq -n --rawfile pdf "$PDF" --arg state "$STATE" --arg question "$1" '{
      state: $state, question: $question,
      documents: [{b64: $pdf, mime: "application/pdf", filename: "dossier_sinistre.pdf"}],
      mode: "fast", allow_abstain: true
    }' | bivia /boolean | jq -c '{status, value, probability, abstain_reason}'
}

# pick-one question → /choice; choices as a JSON array
ask_choice() {
  echo "== $1"
  jq -n --rawfile pdf "$PDF" --arg state "$STATE" --arg question "$1" --argjson choices "$2" '{
      state: $state, question: $question, choices: $choices,
      documents: [{b64: $pdf, mime: "application/pdf", filename: "dossier_sinistre.pdf"}],
      mode: "fast", allow_abstain: true
    }' | bivia /choice | jq -c '{status, value, probability, distribution}'
}

ask_boolean "Le sinistre a-t-il eu lieu à Lyon ?"
ask_boolean "Le conducteur du véhicule B a-t-il franchi un feu rouge ?"
ask_boolean "L'expert a-t-il jugé le véhicule économiquement irréparable ?"
ask_boolean "Le montant TTC de la facture dépasse-t-il 1 200 € ?"
ask_boolean "D'après les conditions générales, la franchise de 300 € doit-elle être appliquée à ce sinistre ?"
ask_boolean "Le sinistre a-t-il été déclaré dans le délai prévu par le contrat ?"
ask_boolean "L'assurée a-t-elle demandé un véhicule de remplacement ?"
ask_choice  "Quel est l'assureur du véhicule B ?" \
  '["Assurances Rhône-Alpes Mutuelle", "Assurances Saône Avenir", "Expertises Lyonnaises"]'
ask_choice  "Quelle part de responsabilité a été retenue pour l'assurée ?" '["0 %", "50 %", "100 %"]'
