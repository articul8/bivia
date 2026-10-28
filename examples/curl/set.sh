#!/usr/bin/env bash
# Multi-select — zero or more labels
curl -s https://api.articul8.ai/bivia/set \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "Ticket: I was charged twice for my order and support has not replied in a week.",
    "question": "Which actions are needed?",
    "options": ["refund", "apology", "escalate to engineering"],
    "mode": "fast"
  }' | python3 -m json.tool
