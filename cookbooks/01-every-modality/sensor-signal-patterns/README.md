# Read a raw sensor signal

Send raw numeric readings to `/ds` and ask which patterns are present: no chart, no summary statistics. Bivia profiles the signal server-side. This recipe asks whether a supplier's part quality is slipping, using 96 bore-diameter readings (nominal 62.000 ± 0.025 mm) in `data/gauge.json`.

## Run

```bash
python3 run.py     # or: ./run.sh  (curl + jq)
```

## The request

```json
POST /ds
{
  "signals": [{ "name": "bore_diameter_mm", "data": [[62.0, 61.9971, 62.0, ...]], "fs": 1, "dtype": "float32" }],
  "question": "Bore diameter (mm) of incoming GH-220 lots, nominal 62.000 ± 0.025, one value per lot in arrival order. What is happening to the process?",
  "options": ["Process stable (in control)", "Mean drifting upward (trend)", "Variance increasing", "Sensor noise only"],
  "kind": "set"
}
```

| Field | What to put in it |
|---|---|
| `signals[].data` | A list of channels, each a list of numbers. One sensor is `[[...]]`; a 3-axis accelerometer is `[[x...], [y...], [z...]]`. |
| `signals[].fs` | Samples per second. Use `1` for one-reading-per-item data like lots or days. |
| `question` | Say what the numbers are, their unit, the spec, and the order they're in. |
| `options` | The patterns to choose from. |
| `kind` | `set` when several options can be true at once; `choice` when exactly one applies. |

## Reading the response

```json
{
  "status": "answered",
  "value": ["Mean drifting upward (trend)", "Variance increasing"],
  "probabilities": { "Process stable (in control)": 0.29, "Mean drifting upward (trend)": 0.96, ... }
}
```

For `set`, `value` lists every option judged present, and `probabilities` scores each option independently, so they don't sum to 1. For `choice`, `value` is a single option.

## Adapting it

- Replace `data/gauge.json` or build `data` from your own readings. Edit the question so it describes your units and spec.
- Keep options concrete and mutually distinguishable ("mean drifting upward", "sudden step change in the mean", "stuck sensor") rather than vague ("something wrong").

