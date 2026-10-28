# Bivia

<p>
  <a href="https://app.articul8.ai/registration?source=bivia&code=bivia"><img alt="Get an API key" src="https://img.shields.io/badge/Get_an_API_key-0A66C2?style=for-the-badge"></a>
  <a href="https://api-docs.app.articul8.ai/bivia"><img alt="Read the docs" src="https://img.shields.io/badge/Read_the_docs-2EA44F?style=for-the-badge"></a>
</p>

Bivia is a **calibrated decision engine** by [Articul8 AI](https://articul8.ai/?utm_source=github&utm_medium=readme&utm_campaign=bivia&utm_content=intro). Ask a question with context — text, images, audio, documents, or signals — and get back a **typed, structured answer** with a probability distribution and honest abstention when the model isn't confident enough.

No free-form text. No guessing. Just decisions you can act on.

**[Get your API key →](https://app.articul8.ai/registration?source=bivia&code=bivia)** &nbsp;·&nbsp; **[Read the docs →](https://api-docs.app.articul8.ai/bivia)**

## What makes Bivia different

- **Typed outputs** — yes/no, pick-one, numeric score, multi-select, text span, or bounding box. Every answer is machine-readable.
- **Calibrated probabilities** — not softmax scores, real calibrated confidence you can threshold on.
- **Honest abstention** — when the model isn't sure, it says so. You always know whether to trust the answer.
- **Multimodal** — text, images, audio, documents, and raw signals in one API.
- **Evidence** — every answer traces back to the input with character offsets or bounding boxes.

## Quick start

1. **[Sign up and get an API key](https://app.articul8.ai/registration?source=bivia&code=bivia).**
2. Make your first decision:

```bash
export A8_API_KEY="your-key"

curl -s https://api.articul8.ai/bivia/boolean \
  -H "Authorization: Bearer $A8_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "Customer threatened to cancel today.",
    "question": "Is this urgent?"
  }'
```

```json
{
  "type": "boolean",
  "value": "yes",
  "probability": 0.92,
  "distribution": { "yes": 0.92, "no": 0.08 },
  "status": "answered",
  "model": "dec-1"
}
```

**Next:** browse every endpoint, parameter, and response in the **[API docs](https://api-docs.app.articul8.ai/bivia)**, run the ready-made scripts in [`examples/curl`](examples/curl), or try an end-to-end recipe in the **[Cookbook](cookbooks)**.

## Cookbook

Runnable recipes with sample inputs, in Python and curl. See [`cookbooks/`](cookbooks) for all of them.

| Recipe | What it shows |
|---|---|
| [Find the moment in a video](cookbooks/01-every-modality/video-find-the-moment) | When something is visible, or starts, in a whole video file |
| [Box the damage in a photo](cookbooks/01-every-modality/image-box-the-damage) | Labelled bounding boxes in an image |
| [Quote it verbatim](cookbooks/01-every-modality/span-quote-it-verbatim) | The exact words that answer a question, with character offsets |
| [Ask a French PDF in French](cookbooks/01-every-modality/french-pdf) | Questions over a PDF in any language |
| [Read a raw sensor signal](cookbooks/01-every-modality/sensor-signal-patterns) | Patterns in raw numeric readings |
| [Supplier dispute](cookbooks/02-evidence-changes-the-decision/supplier-dispute) | One question per input across video, documents, images and signals, chained into one decision |
| [Insurance claim flips with one new record](cookbooks/02-evidence-changes-the-decision/claim-flips-with-new-record) | Abstain, fetch more evidence, ask again |
| [Is the vendor sanctioned?](cookbooks/03-knowing-when-to-abstain/vendor-sanctions-check) | Route the checks Bivia can't settle to a human |

## SDKs

| Language | Install | Repository |
|---|---|---|
| **Python** | `pip install bivia` | [articul8/bivia-python](https://github.com/articul8/bivia-python) |
| **Node.js** | `npm install @articul8/bivia` | [articul8/bivia-node](https://github.com/articul8/bivia-node) |
| **Go** | `go get github.com/articul8/bivia-go` | [articul8/bivia-go](https://github.com/articul8/bivia-go) |
| **Rust** | `cargo add bivia` | [articul8/bivia-rust](https://github.com/articul8/bivia-rust) |

### Python

```python
from bivia import Bivia

client = Bivia()  # reads $A8_API_KEY

result = client.decisions.boolean(
    state="Customer threatened to cancel today.",
    question="Is this urgent?",
)
print(result.value, result.probability)  # "yes" 0.92
```

### Node.js

```typescript
import Bivia from '@articul8/bivia';

const client = new Bivia();  // reads $A8_API_KEY

const result = await client.decisions.boolean({
  state: 'Customer threatened to cancel today.',
  question: 'Is this urgent?',
});
console.log(result.value, result.probability);  // "yes" 0.92
```

### Go

```go
client := bivia.NewClient()  // reads $A8_API_KEY

result, _ := client.Decisions.Boolean(ctx, &bivia.BooleanParams{
    Question: "Is this urgent?",
    State:    bivia.String("Customer threatened to cancel today."),
})
fmt.Println(result.Value, result.Probability)  // "yes" 0.92
```

## Decision types

| Endpoint | What it returns |
|---|---|
| `POST /boolean` | `yes` or `no` with P(value) |
| `POST /choice` | One label from your list, with distribution |
| `POST /decide` | Auto-detects the best type from the question |
| `POST /score` | A number on your scale, with per-level mass |
| `POST /set` | Zero or more labels (multi-select) |
| `POST /span` | Character offsets into the input text |
| `POST /extract` | Exact field values copied from document text, with offsets |
| `POST /ground` | Bounding boxes in an image or temporal intervals in a video |
| `POST /ds` | Decision over profiled numeric signals |
| `POST /v1/systemone` | Multiple named typed answers in a single batch call |

Request and response schemas for each endpoint are in the **[API docs](https://api-docs.app.articul8.ai/bivia)**.

## Abstention

When Bivia isn't confident, it abstains instead of guessing:

```json
{
  "status": "abstained",
  "value": null,
  "abstain_reason": "low_confidence",
  "distribution": { "yes": 0.52, "no": 0.48 }
}
```

Set `"allow_abstain": false` to force a best-effort answer.

## Modes

- **`fast`** (default) — single-pass, lowest latency
- **`deep`** — adds verification for higher confidence on hard questions

## Multimodal inputs

Every endpoint accepts text, images, audio, documents, and signals:

```python
result = client.decisions.choice(
    question="Which team name is in the image?",
    choices=["billing", "technical"],
    images=[{"url": "https://example.com/label.png"}],
)
```

## Documentation

**[api-docs.app.articul8.ai/bivia](https://api-docs.app.articul8.ai/bivia)** — the full Bivia API reference.

- OpenAPI spec: [`openapi.yaml`](openapi.yaml)
- curl examples for every endpoint: [`examples/curl`](examples/curl)
- End-to-end recipes: [`cookbooks`](cookbooks)

## Model

The current model is **`dec-1`** (Bivia foundation decision model). Discover available models via `GET /v1/models`.

## Get started

Ready to build? **[Sign up](https://app.articul8.ai/registration?source=bivia&code=bivia)** to get your API key, or read the [docs](https://api-docs.app.articul8.ai/bivia).

Questions? Email [support@articul8.ai](mailto:support@articul8.ai).

## License

Proprietary. See [Terms of Service](https://articul8.ai/eula).
