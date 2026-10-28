#!/usr/bin/env bash
# Find the answer as character offsets into the input text
curl -s https://api.articul8.ai/bivia/span \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "The launch window opens on March 3. The launch code word is HELIOTROPE.",
    "question": "What is the launch code word?"
  }' | python3 -m json.tool
