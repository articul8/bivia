"""Three yes/no checks on an auto claim. If a check abstains, add the missing record to the state
and ask the same question again with the same settings.

    python3 run.py
"""
import pathlib
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent / "lib"))
from bivia import bivia, file  # noqa: E402

photo = file(HERE / "data" / "car_damage.jpg")

CLAIM = [
    "Auto claim CLM-30418, Lakeshore Mutual.\nClaimant: Maria Lopez. Vehicle: 2019 sedan, dark blue.",
    'Date of loss: 2026-10-18. Reported: 2026-10-19. Description: "Rear-ended while stopped at a red light. '
    'Rear bumper crushed, left tail light broken."',
    "The other driver was cited for following too closely. Their insurer, Crestline Auto, has been notified; "
    "we pay the claim now and recover the payment and the deductible from Crestline.",
    "Repair estimate RE-7790, Rivera Auto Body, 2026-10-21: rear bumper cover replace $640; bumper reinforcement $310; "
    "left tail lamp $285; trunk lid repair $420; refinish $560; labor $820; total $3,035.",
    "Policy AU-55219, holder Maria Lopez. Coverage: collision, $500 deductible, $25,000 limit. "
    "Policy term: 2025-10-15 to 2026-10-15. Renewal notice for the 2026-10-15 to 2027-10-15 term sent 2026-09-15. "
    "Status: pending renewal, payment not yet posted.",
    "Fast-track rule: estimates under $5,000 can be paid without an adjuster visit.",
]
# The record an adjuster would fetch when the payment check abstains.
BILLING_RECORD = ("Billing record: renewal premium for the 2026-10-15 to 2027-10-15 term received by mailed check "
                  "on 2026-10-12, posted to the policy late on 2026-10-22.")

SETTINGS = {"mode": "deep", "allow_abstain": True}
CHECKS = [
    {"id": "photo", "question": "Does the photo show damage to the rear of the car?",
     "extra": "Attached: the claimant's photo of the car.", "images": [photo]},
    {"id": "fast_track", "question": "Is the repair estimate under the fast-track limit?"},
    {"id": "paid", "question": "Has the renewal premium been paid for the policy term that includes the date of loss?"},
]


def body_for(check, lines):
    body = {"state": "\n".join(lines + ([check["extra"]] if "extra" in check else [])), "question": check["question"], **SETTINGS}
    if "images" in check:
        body["images"] = check["images"]
    return body


def show(label, r):
    res = r["response"]
    if r["http"] != 200:
        print(f"✗ {label}\n    HTTP {r['http']}: {str(res)[:200]}")
        return
    abstained = res.get("status") == "abstained"
    answer = f"abstained: {res.get('abstain_reason')}" if abstained else f"{res['value']} · {res['probability'] * 100:.1f}%"
    print(f"{'?' if abstained else ' '} {label}\n    {answer}   ({r['ms']} ms)")


# Round 1: the claim file as it is.
print("Round 1: the claim file\n")
with ThreadPoolExecutor() as pool:
    first = list(pool.map(lambda c: {"id": c["id"], **bivia("/boolean", body_for(c, CLAIM))}, CHECKS))
for check, r in zip(CHECKS, first):
    show(check["question"], r)

# Round 2: resend only what abstained, with the billing record added.
abstained = [c for c, r in zip(CHECKS, first) if r["http"] == 200 and r["response"].get("status") == "abstained"]
if abstained:
    print(f"\nRound 2: added the billing record, resending {len(abstained)} check(s)\n")
    for check in abstained:
        r = bivia("/boolean", body_for(check, CLAIM + [BILLING_RECORD]))
        show(check["question"], r)
else:
    print("\nNo check abstained, so there's nothing to resend.")
