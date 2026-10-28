# Ask a French PDF in French

Send a PDF as the file itself, with no OCR or text extraction on your side, and ask questions about it in its own language. This recipe uses a 5-page French auto-claim file (`data/dossier_sinistre.pdf`). Some questions need two pages read together, such as the policy terms on page 5 and the liability finding on page 3.

## Run

```bash
python3 run.py     # or: ./run.sh  (curl + jq)
```

## The request

Yes/no questions go to `/boolean`:

```json
POST /boolean
{
  "state": "Pièce jointe : un dossier de sinistre automobile de 5 pages (PDF). Répondez uniquement d'après le contenu du dossier.",
  "question": "D'après les conditions générales, la franchise de 300 € doit-elle être appliquée à ce sinistre ?",
  "documents": [{ "b64": "<the PDF, base64>", "mime": "application/pdf", "filename": "dossier_sinistre.pdf" }],
  "mode": "fast",
  "allow_abstain": true
}
```

Pick-one questions go to `/choice` with a `choices` list:

```json
POST /choice
{
  "state": "...",
  "question": "Quel est l'assureur du véhicule B ?",
  "choices": ["Assurances Rhône-Alpes Mutuelle", "Assurances Saône Avenir", "Expertises Lyonnaises"],
  "documents": [ ... ],
  "mode": "fast",
  "allow_abstain": true
}
```

| Field | What to put in it |
|---|---|
| `state` | A short line saying what's attached and to answer only from it |
| `documents` | One or more files as `{ b64, mime, filename }` |
| `mode` | `fast`, or `deep` to have Bivia check its own answer before committing (slower) |
| `allow_abstain` | `true` lets Bivia decline when the file doesn't settle the question |

## Reading the response

```json
{ "status": "answered", "value": "no", "probability": 0.92 }
```

`/choice` also returns `distribution`, the probability of every choice. When `status` is `abstained`, `value` is `null` and `abstain_reason` says why.

## Adapting it

- Swap in your own PDF and edit the questions in the script. A question with a list of choices goes to `/choice`; the rest go to `/boolean`.
- Questions, `state` and the document can be in different languages. Ask in English about a French file if that suits your users.
- Scanned pages can also be sent as images in `images[]`.
