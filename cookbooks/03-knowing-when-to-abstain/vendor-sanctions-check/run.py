"""Three yes/no checks on one vendor payment file, sent to /boolean at once with allow_abstain.
Checks Bivia can't settle from the file come back abstained; route those to a person.

    python3 run.py
"""
import pathlib
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent / "lib"))
from bivia import bivia  # noqa: E402

state = "\n".join([
    "Vendor: Novex Data Ltd",
    "PO-203: approved $14,000 for data analytics services, signed by CFO.",
    "INV-006: Novex Data Ltd (London, UK), $14,000, dated 2026-10-22.",
    "Receiving confirmation: dashboard access delivered, signed 2026-10-23.",
])

# Same settings on every check, so an abstain reflects the evidence, never the settings.
SETTINGS = {"mode": "deep", "allow_abstain": True}
CHECKS = [
    "Does the invoice amount match the approved purchase order?",
    "Was the service delivered?",
    "Is this vendor on a sanctions list?",
]

with ThreadPoolExecutor() as pool:
    results = list(pool.map(lambda q: {"question": q, **bivia("/boolean", {"state": state, "question": q, **SETTINGS})}, CHECKS))

needs_review = []
for r in results:
    res = r["response"]
    if r["http"] != 200:
        print(f"✗ {r['question']}\n    HTTP {r['http']}: {str(res)[:200]}")
        needs_review.append(r["question"])
    elif res.get("status") == "abstained":
        print(f"? {r['question']}\n    abstained: {res.get('abstain_reason')}   ({r['ms']} ms)")
        needs_review.append(r["question"])
    else:
        print(f"  {r['question']}\n    {res['value']} · {res['probability'] * 100:.1f}%   ({r['ms']} ms)")

if needs_review:
    print("\nHold the payment. Send to a reviewer:\n" + "\n".join(f"  - {q}" for q in needs_review))
else:
    print("\nAll checks answered.")
