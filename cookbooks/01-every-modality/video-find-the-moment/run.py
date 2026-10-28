"""Send a whole video to /ground/video and get back when something is visible (kind "object")
or when something starts (kind "event"). Bivia decodes and scans the clip server-side.

    python3 run.py
"""
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent / "lib"))
from bivia import bivia, file  # noqa: E402

CASES = [
    {"clip": "syn_traffic_light", "query": "the red traffic light is lit", "kind": "object"},
    {"clip": "syn_traffic_light", "query": "the traffic light turns red", "kind": "event"},
    {"clip": "syn_ball_three_times", "query": "a red ball", "kind": "object"},
    {"clip": "syn_tank_overflow", "query": "the alarm lamp is lit bright red", "kind": "object"},
    {"clip": "syn_tank_overflow", "query": "a dog", "kind": "object"},
    {"clip": "syn_haystack_forklift", "query": "a yellow forklift", "kind": "object", "coarse_step": 3, "fine_resolution": 0.5},
]

# One at a time: a scan is heavy (each probed frame is an image), and some deployments process one request at a time.
for c in CASES:
    r = bivia("/ground/video", {
        "video": file(HERE / "clips" / f"{c['clip']}.mp4"),
        "query": c["query"],
        "kind": c["kind"],
        "coarse_step": c.get("coarse_step", 1.0),
        "fine_resolution": c.get("fine_resolution", 0.25),
        "boxes_on_hits": False,
        "max_probes": 150,
    })
    hits = r["response"].get("hits") or []
    shown = ", ".join(f"starts {h['onset_t']} s" if "onset_t" in h else f"{h['start']}–{h['end']} s" for h in hits) or "no hit"
    print(f"{c['clip']}  \"{c['query']}\" ({c['kind']})\n"
          f"    {shown if r['http'] == 200 else 'HTTP ' + str(r['http'])}   {r['ms']} ms")
