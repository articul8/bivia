#!/usr/bin/env bash
# Multiple typed questions in one request
curl -s https://api.articul8.ai/bivia/v1/systemone \
  -H "Authorization: Bearer ${A8_API_KEY:?Set A8_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "I was double-charged and support never replied.",
    "questions": {
      "team": {
        "type": "choice",
        "instructions": "Which team?",
        "criteria": {
          "billing": "Billing disputes and invoices",
          "tech": "Product defects",
          "sales": "New purchases"
        }
      },
      "urgent": {
        "type": "boolean",
        "instructions": "Is this urgent?"
      },
      "risk": {
        "type": "score",
        "instructions": "Churn risk from 0 to 1",
        "buckets": 5
      }
    }
  }' | python3 -m json.tool
