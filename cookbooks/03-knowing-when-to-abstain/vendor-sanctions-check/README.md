# Is the vendor sanctioned? Hand the call to a human

Run several checks on one file with `allow_abstain: true`, and route the ones Bivia can't settle to a person. This recipe uses a vendor payment file and asks, among other checks, whether the vendor is on a sanctions list. Nothing in the file answers that.

## Run

```bash
python3 run.py     # or: ./run.sh  (curl + jq)
```

The script prints each check's answer or abstain, then lists the checks that need a reviewer.

## The file

Each line is one line of `state`:

| Document | Contents |
|---|---|
| Vendor | Novex Data Ltd |
| Purchase order PO-203 | $14,000 for data analytics services, signed by the CFO |
| Invoice INV-006 | Novex Data Ltd (London, UK), $14,000, dated 2026-10-22 |
| Receiving confirmation | Dashboard access delivered, signed 2026-10-23 |

## The checks

All three go to `/boolean` in parallel with identical settings, so the only difference between an answer and an abstain is the evidence:

```json
POST /boolean
{
  "state": "<every line of the file>",
  "question": "Is this vendor on a sanctions list?",
  "mode": "deep",
  "allow_abstain": true
}
```

The three checks:

- Does the invoice amount match the approved purchase order?
- Was the service delivered?
- Is this vendor on a sanctions list?

## Reading the response

```json
{ "status": "answered", "value": "yes", "probability": 0.99 }
{ "status": "abstained", "value": null, "abstain_reason": "insufficient_evidence" }
```

Branch on `status`, not on `value`. `status: "abstained"` means "don't decide this automatically".

## Adapting it

- Edit `state` (the documents) and `CHECKS` (the questions).
- Route each abstained check to the right person, such as the compliance team or the AP reviewer.
- Send the reviewer the question and the `abstain_reason`, so they know exactly what to confirm.
- To settle the sanctions check automatically, add the result of your sanctions screening to `state` and ask again.
