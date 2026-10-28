# Supplier dispute: many calls, one decision

Ask one question of each piece of evidence, whatever its format, then pass the typed answers as text to one `/decide` call. The decision rests only on findings you can inspect, and it changes when the findings change.

**The scenario:** Acme Manufacturing buys gear housings (GH-220) from Toho Seiki. Toho keeps shipping late, the last shipment arrived damaged, and Acme's customer escalates on a recorded video call. Acme has to decide what to do.

## Run

```bash
./run.sh     # curl + jq
```

The script prints each answer, the findings it passes to the decision, and the decision itself.

## The inputs

| File | What it is | Sent as |
|---|---|---|
| `data/contract_ja.pdf` | Supplier contract, in Japanese | `documents[]` |
| `data/scorecard.png` | Supplier scorecard (on-time rate, certification) | `images[]` |
| `data/delay_email.png` | The supplier's delay notice, in Japanese | `images[]` |
| `data/dock_photo.jpg` | The damaged shipment at the dock | `images[]` to `/ground` |
| `data/gauge.json` | 96 bore-diameter readings | `signals[]` to `/ds` |
| `data/call.mp4` | 41-second recorded customer video call | `video` to `/ground/video` |

## Step 1: one question per input

The questions are in English; the documents are in Japanese.

| Question | Endpoint | Candidates |
|---|---|---|
| Does the contract renew automatically? | `/boolean` | none |
| Which clauses apply if we move away from Toho? | `/set` | 8 contract articles; any number can apply |
| Is Toho's part quality slipping? | `/ds` | 4 process patterns, `kind: "set"` |
| Find the broken crate in the dock photo | `/ground` | none |
| When does the customer look angry on the call? | `/ground/video` | none |
| Which supplier should we choose? | `/choice` | 4 options |

A `/set` call looks like `/choice`, but any number of `options` can be true:

```json
POST /set
{
  "state": "We are Acme Manufacturing ... we plan to move GH-220 to another supplier.",
  "question": "Which contract clauses create a right, a cost, or a deadline for us if we move away from Toho Seiki?",
  "options": ["Art. 1 — Purpose (第1条)", "Art. 5 — Late-delivery damages (第5条)", "..."],
  "documents": [{ "b64": "<contract PDF>", "mime": "application/pdf" }],
  "images": [{ "b64": "<scorecard>", "mime": "image/png" }],
  "mode": "fast",
  "allow_abstain": true
}
```

It returns `value` (the options judged true) and `probabilities` (a score for every option).

## Step 2: chain into one decision

Each answer becomes one line of text, and those lines become the `state` of one `/decide` call:

```json
POST /decide
{
  "state": "We are Acme Manufacturing; our GH-220 supplier is Toho Seiki. Today is ...\n\nQuestions we already answered ...:\n1. Does the contract auto-renew? → <value> (<probability>)\n2. ...",
  "question": "Given these findings, what should Acme do about GH-220 now?",
  "outcomes": [
    "Stay with Toho Seiki and accept their recovery plan",
    "Terminate Toho now under Art. 14, claim Art. 5 late-delivery damages, and move GH-220 to Kestrel",
    "Keep the Toho contract running, shift GH-220 volume to Kestrel, and pay the Art. 16 shortfall fee",
    "Send Toho a non-renewal notice under Art. 12 and move to Kestrel when the contract ends in March 2027",
    "Move GH-220 to Meridian Castings"
  ],
  "mode": "fast",
  "allow_abstain": true
}
```

No video, PDF, image or signal is re-sent, so this call is small and fast, and everything the decision saw is printed above it.

