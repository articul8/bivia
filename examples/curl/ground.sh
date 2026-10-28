#!/usr/bin/env bash
# Visual grounding — locate objects in an image
curl -s https://api.articul8.ai/bivia/ground \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "the invoice total",
    "images": [{"url": "https://example.com/invoice.png"}]
  }' | python3 -m json.tool
