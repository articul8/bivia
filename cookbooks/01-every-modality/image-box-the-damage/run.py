"""Point to the damage in a dock photo. /ground returns one box per call, so each object is its own question.

    python3 run.py
    python3 run.py "Find the forklift."      ask your own question
"""
import pathlib
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent / "lib"))
from bivia import bivia, file  # noqa: E402

photo = file(HERE / "data" / "dock_photo.jpg")
questions = sys.argv[1:2] or ["Find the broken wooden crate.", "Find the rusted gear housing."]

with ThreadPoolExecutor() as pool:
    calls = list(pool.map(lambda q: {"question": q, **bivia("/ground", {"question": q, "images": [photo]})}, questions))

for c in calls:
    res = c["response"]
    print(f"\n{c['question']}  ({c['ms']} ms)")
    if c["http"] != 200:
        print(f"  HTTP {c['http']}: {str(res)[:200]}")
        continue
    if not res.get("found"):
        print("  not found")
    for v in res.get("value") or []:
        print(f"  {v['label']}: box {v['box']}")  # [x1, y1, x2, y2]
