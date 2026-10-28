#!/usr/bin/env bash
# Numeric score on a 0-1 scale
curl -s https://api.articul8.ai/bivia/score \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "Customer threatened to cancel today.",
    "question": "How urgent is this (0=none, 1=critical)?",
    "range": [0, 1],
    "buckets": 11,
    "mode": "fast"
  }' | python3 -m json.tool
