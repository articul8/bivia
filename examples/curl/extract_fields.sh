#!/usr/bin/env bash
# Extract several fields in one request
curl -s https://api.articul8.ai/bivia/extract \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "Either party may terminate this agreement with 60 days written notice.",
    "fields": ["termination notice period", "governing law"]
  }' | python3 -m json.tool
