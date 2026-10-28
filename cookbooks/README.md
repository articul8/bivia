# Bivia Cookbook

Runnable recipes for Bivia by Articul8. Each recipe ships sample inputs, a script, and a guide to the request, the response, and how to adapt it to your own data.

Every Bivia call has the same shape:

```
state + question + candidates  →  { value, probability, status }
```

- `state`: the context, as text. Files go alongside it in `images[]`, `documents[]`, `video` or `signals[]`.
- `question`: what you want decided, in plain language.
- `candidates`: the allowed answers. Their name depends on the endpoint (`choices`, `options`, `outcomes`, or a `range` for scores). `/boolean`, `/span` and `/ground` don't take any.
- `status` is `answered` or `abstained`. With `allow_abstain: true`, Bivia returns `value: null` and an `abstain_reason` when the evidence doesn't support an answer. Your code decides what happens next.

## Recipes

### 1. One input, every modality

| Recipe | Endpoint | Use it to |
|---|---|---|
| [Find the moment in a video](01-every-modality/video-find-the-moment) | `/ground/video` | Find when something is visible, or when it starts, in a whole video file |
| [Box the damage in a photo](01-every-modality/image-box-the-damage) | `/ground` | Get a labelled bounding box for an object in an image |
| [Quote it verbatim](01-every-modality/span-quote-it-verbatim) | `/span` | Pull the exact words that answer a question, with character offsets |
| [Ask a French PDF in French](01-every-modality/french-pdf) | `/boolean`, `/choice` | Ask questions of a PDF sent as the file itself, in any language |
| [Read a raw sensor signal](01-every-modality/sensor-signal-patterns) | `/ds` | Classify patterns in raw numeric readings |

### 2. The decision changes as evidence arrives

| Recipe | Use it to |
|---|---|
| [Supplier dispute](02-evidence-changes-the-decision/supplier-dispute) | Ask one question per input across video, documents, images and signals, then chain the answers into one `/decide` call |
| [Insurance claim flips with one new record](02-evidence-changes-the-decision/claim-flips-with-new-record) | Use an abstain as a signal to fetch more evidence, then ask again |

### 3. Knowing when not to answer

| Recipe | Use it to |
|---|---|
| [Is the vendor sanctioned?](03-knowing-when-to-abstain/vendor-sanctions-check) | Route the checks Bivia can't settle to a human |

## Setup

You need a Bivia API key: **[sign up at Articul8](https://app.articul8.ai/registration?source=bivia&code=bivia)**. Full API reference: **[api-docs.app.articul8.ai/bivia](https://api-docs.app.articul8.ai/bivia)**.

```bash
cp .env.example .env     # then fill in A8_API_KEY
cd 01-every-modality/span-quote-it-verbatim
python3 run.py           # Python 3.9+, standard library only
./run.sh                 # or the same calls with curl + jq
```

Each recipe has a `run.py` and a `run.sh` that make the same calls; the supplier dispute has `run.sh` only. Both print the answers to the terminal.

## Calling Bivia from your own code

With curl:

```bash
curl -sS -X POST https://api.articul8.ai/bivia/boolean \
  -H "Content-Type: application/json" -H "Authorization: Bearer $A8_API_KEY" \
  -d '{
    "state": "Invoice INV-8841 total $5,000. Purchase order PO-2207 total $5,000.",
    "question": "Does the invoice total match the purchase order total?",
    "allow_abstain": true
  }'
```

With Python, copy `lib/bivia.py`:

```python
from bivia import bivia, file

r = bivia("/boolean", {
    "state": "Invoice INV-8841 total $5,000. Purchase order PO-2207 total $5,000.",
    "question": "Does the invoice total match the purchase order total?",
    "allow_abstain": True,
})
# r["response"]["status"], r["response"]["value"], r["response"]["probability"]
```

Use `file("path/to/photo.jpg")` to build the `{ b64, mime }` object for `images[]`, `documents[]` or `video`.

## About the inputs

All documents, photos, people and data in this repo were made for these recipes. They are not real customers, claims or contracts. The car and dock photos and the people on the supplier call are AI-generated.
