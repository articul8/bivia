#!/usr/bin/env bash
# Extract a single field, copied exactly from the document with offsets
curl -s https://api.articul8.ai/bivia/extract \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "Either party may terminate this agreement with 60 days written notice.",
    "question": "termination notice period"
  }' | python3 -m json.tool
