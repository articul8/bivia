# Minimal Bivia helpers for the curl recipes. Source it:  . ../../lib/bivia.sh
# Needs: curl, jq (1.6+), base64. Reads A8_API_KEY (and optionally BIVIA_URL) from the environment or the cookbook's .env.

BIVIA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$BIVIA_ROOT/.env" ]; then set -a; . "$BIVIA_ROOT/.env"; set +a; fi
BIVIA_URL="${BIVIA_URL:-https://api.articul8.ai/bivia}"
: "${A8_API_KEY:?A8_API_KEY is not set. Copy .env.example to .env at the cookbook root and fill it in.}"

# Scratch space for base64 files; removed when the script exits.
BIVIA_TMP="$(mktemp -d)"
trap 'rm -rf "$BIVIA_TMP"' EXIT

# bivia /endpoint   — POST the JSON body read from stdin, print the JSON response.
bivia() {
  curl -sS -X POST "${BIVIA_URL%/}$1" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $A8_API_KEY" \
    --data-binary @- --max-time 300
}

# b64 path   — base64-encode a file into $BIVIA_TMP and print the path of the encoded copy.
# Pass it to jq with --rawfile; large files are too big for --arg.
b64() {
  local out="$BIVIA_TMP/$(basename "$1").b64"
  base64 < "$1" | tr -d '\n' > "$out"
  printf '%s' "$out"
}
