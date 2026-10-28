#!/usr/bin/env bash
# Decision over numeric signals
curl -s https://api.articul8.ai/bivia/ds \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "signals": [
      {
        "name": "temperature",
        "data": [[20.1, 20.4, 21.0, 22.3, 24.1, 26.8]],
        "fs": 1
      }
    ],
    "question": "Which analyses are appropriate?",
    "options": ["trend analysis", "spectral analysis", "anomaly detection"],
    "kind": "set"
  }' | python3 -m json.tool
