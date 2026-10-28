# Insurance claim: one new record flips the answer

Use an abstain as a trigger to go and get more evidence. Three checks run on an auto claim. When a check abstains, the script adds the missing billing record and asks the same question again, with the same settings.

## Run

```bash
python3 run.py     # or: ./run.sh  (curl + jq)
```

The script runs all three checks, then resends only the ones that abstained, with the billing record added.

## The claim file

Each line of the file is one line of `state`:

| Line | Contents |
|---|---|
| Claim form | Auto claim CLM-30418, claimant Maria Lopez |
| Date of loss | 2026-10-18, rear-ended at a red light |
| Fault | The other driver was cited; their insurer will be billed |
| Repair estimate | $3,035 |
| Policy record | Term 2025-10-15 to 2026-10-15; "pending renewal, payment not yet posted" |
| Claims desk rule | Estimates under $5,000 can be fast-tracked |

The photo check also sends `data/car_damage.jpg` in `images[]`.

## Round 1: three checks

All three go to `/boolean` in parallel, with identical settings:

```json
POST /boolean
{
  "state": "<every line of the claim file>",
  "question": "Has the renewal premium been paid for the policy term that includes the date of loss?",
  "mode": "deep",
  "allow_abstain": true
}
```

The three checks:

- Does the photo show damage to the rear of the car?
- Is the repair estimate under the fast-track limit?
- Has the renewal premium been paid for the policy term that includes the date of loss?

`deep` mode has Bivia check its own answer before committing. It takes longer than `fast`.

## Round 2: add the evidence, ask again

An abstain looks like this:

```json
{ "status": "abstained", "value": null, "abstain_reason": "insufficient_evidence" }
```

The script appends the record an adjuster would fetch:

> Billing record: renewal premium for the 2026-10-15 to 2027-10-15 term received by mailed check on 2026-10-12, posted to the policy late on 2026-10-22.

Then it resends only the abstained check. Same question, same settings, more evidence.

## Adapting it

- Edit `CLAIM` (the file lines), `BILLING_RECORD` (the evidence that resolves the abstain) and `CHECKS`.
- Map each `abstain_reason` to an action: fetch a record, ask the customer, or assign an adjuster.
