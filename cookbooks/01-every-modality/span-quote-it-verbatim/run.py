"""Ask questions about a policy and get back the exact words that answer them, as character offsets into the text.

    python3 run.py
"""
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent / "lib"))
from bivia import bivia  # noqa: E402

policy = (HERE / "data" / "policy.txt").read_text(encoding="utf-8")

QUESTIONS = [
    "What is the deductible for theft?",
    "How many days do I have to report a loss?",
    "What damage does the policy exclude?",
    "What is the maximum paid for personal items left in the car?",
    "Does the policy cover a rental car?",
]

for question in QUESTIONS:
    r = bivia("/span", {"state": policy, "question": question})
    spans = r["response"].get("value") or []
    print(f"\n{question}")
    if r["http"] != 200:
        print(f"  HTTP {r['http']}: {str(r['response'])[:200]}")
    elif not spans:
        print("  (no quote: the policy doesn't say)")
    for s in spans:
        # The offsets index into the exact string we sent, so slicing proves the quote is verbatim.
        print(f"  policy[{s['start']}:{s['end']}] = {s['text']!r}  verbatim={policy[s['start']:s['end']] == s['text']}")
