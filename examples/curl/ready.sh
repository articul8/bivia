#!/usr/bin/env bash
# Service readiness
curl -s https://api.articul8.ai/bivia/ready \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" | python3 -m json.tool
