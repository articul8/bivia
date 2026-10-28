#!/usr/bin/env bash
# Auto-detect the decision type from the question
curl -s https://api.articul8.ai/bivia/decide \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "Ticket: I was charged twice for my order and support has not replied in a week.",
    "question": "Which team should handle this?",
    "outcomes": ["billing", "technical", "shipping"],
    "mode": "fast"
  }' | python3 -m json.tool
