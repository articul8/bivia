# Bivia

Bivia is a **calibrated decision engine** by [Articul8 AI](https://articul8.ai). Ask a question with context — text, images, audio, documents, or signals — and get back a **typed, structured answer** with a probability distribution and honest abstention when the model isn't confident enough.

No free-form text. No hallucination. Just decisions you can act on.

## What makes Bivia different

- **Typed outputs** — yes/no, pick-one, numeric score, multi-select, text span, or bounding box. Every answer is machine-readable.
- **Calibrated probabilities** — not softmax scores, real calibrated confidence you can threshold on.
- **Honest abstention** — when the model isn't sure, it says so. You always know whether to trust the answer.
- **Multimodal** — text, images, audio, documents, and raw signals in one API.
- **Evidence** — every answer traces back to the input with character offsets or bounding boxes.

## Quick start

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

| Endpoint | Returns |
|---|---|
| `POST /boolean` | `yes` or `no` with P(value) |
| `POST /choice` | One label from your list, with distribution |
| `POST /decide` | Auto-detects the best type from the question |
| `POST /score` | A number on your scale, with per-level mass |
| `POST /set` | Zero or more labels (multi-select) |
| `POST /span` | Character offsets into the input text |
| `POST /ground` | Bounding boxes in images |
| `POST /ground/video` | Object/event intervals in video |

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

## API Reference

Full API documentation: [docs.articul8.ai/bivia](https://docs.articul8.ai/bivia)

OpenAPI spec: [`openapi.yaml`](https://github.com/articul8/bivia-api/blob/main/openapi.yaml)

## Model

The current model is **`dec-1`** (Bivia foundation decision model). Discover available models via `GET /v1/models`.

## License

Proprietary. See [Terms of Service](https://articul8.ai/eula).
