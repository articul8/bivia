#!/usr/bin/env bash
# Yes/no decision
curl -s https://api.articul8.ai/bivia/boolean \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "Customer threatened to cancel today.",
    "question": "Is this urgent?",
    "mode": "fast"
  }' | python3 -m json.tool
