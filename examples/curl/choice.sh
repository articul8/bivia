#!/usr/bin/env bash
# Pick one from a list
curl -s https://api.articul8.ai/bivia/choice \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "I am NOT asking for a refund, I only need a copy of my invoice.",
    "question": "Which team handles this?",
    "choices": ["billing", "refunds", "technical"],
    "mode": "fast",
    "think": true
  }' | python3 -m json.tool
