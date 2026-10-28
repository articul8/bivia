# Quote it verbatim

Use `/span` when you need the exact words from a document, not a paraphrase: a clause to cite, a figure to copy into a form, evidence to show a reviewer. Each quote comes back with character offsets into the text you sent, so you can verify it and highlight it in your UI.

## Run

```bash
python3 run.py     # or: ./run.sh  (curl + jq)
```

## The request

```json
POST /span
{
  "state": "<the full text of the document>",
  "question": "What is the deductible for theft?"
}
```

| Field | What to put in it |
|---|---|
| `state` | The document text. Offsets in the response index into exactly this string. |
| `question` | What you want quoted. |

## Reading the response

```json
{
  "status": "answered",
  "value": [{ "start": 462, "end": 468, "text": "$1,000" }]
}
```

- `value` is a list. A question can match more than one passage.
- `text` equals `state.slice(start, end)`. Check this before you trust a quote; both scripts do it for every span.
- An empty `value` (`[]`) means no passage answers the question.

## Adapting it

- Replace `data/policy.txt` with your own document and edit the questions in the script.
- To highlight a quote, use `start` and `end` as character offsets into your `state` (characters, not bytes).
- For PDFs, extract the text first and send that as `state`. The offsets then point into your extracted text.
