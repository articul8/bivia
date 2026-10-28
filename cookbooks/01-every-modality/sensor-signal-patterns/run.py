"""Is the supplier's part quality slipping? Send 96 raw bore-diameter readings to /ds and ask which patterns are present.

    python3 run.py
"""
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent / "lib"))
from bivia import bivia  # noqa: E402

gauge = json.loads((HERE / "data" / "gauge.json").read_text())

body = {
    "signals": [{"name": gauge["name"], "data": [gauge["data"]], "fs": 1, "dtype": "float32"}],
    "question": f"Bore diameter (mm) of incoming GH-220 lots, nominal {gauge['nominal']:.3f} ± {gauge['tolerance']}, "
                "one value per lot in arrival order. What is happening to the process?",
    "options": ["Process stable (in control)", "Mean drifting upward (trend)", "Variance increasing", "Sensor noise only"],
    "kind": "set",
}

r = bivia("/ds", body)
res = r["response"]
if r["http"] != 200:
    sys.exit(f"HTTP {r['http']}: {str(res)[:300]}")
print(f"{len(gauge['data'])} readings, {r['ms']} ms, status {res.get('status')}\n")
for option, p in sorted((res.get("probabilities") or {}).items(), key=lambda kv: -kv[1]):
    print(f"  {'●' if option in (res.get('value') or []) else '○'} {option:<30} {p * 100:.1f}%")
