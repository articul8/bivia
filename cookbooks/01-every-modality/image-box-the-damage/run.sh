#!/usr/bin/env bash
# Point to the damage in a dock photo. /ground returns one box per call.
#   ./run.sh
#   ./run.sh "Find the forklift."
set -euo pipefail
cd "$(dirname "$0")"
. ../../lib/bivia.sh

PHOTO="$(b64 data/dock_photo.jpg)"
if [ $# -gt 0 ]; then QUESTIONS=("$1"); else QUESTIONS=("Find the broken wooden crate." "Find the rusted gear housing."); fi

for q in "${QUESTIONS[@]}"; do
  echo "== $q"
  jq -n --rawfile b64 "$PHOTO" --arg question "$q" \
    '{question: $question, images: [{b64: $b64, mime: "image/jpeg"}]}' \
    | bivia /ground | jq -c '{found, value}'   # box is [x1, y1, x2, y2]
done
