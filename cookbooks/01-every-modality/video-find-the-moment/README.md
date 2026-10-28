# Find the moment in a video

Send a whole video file to `/ground/video` with a plain-language query. Bivia decodes the clip server-side, scans it coarsely, then refines around anything it finds. You get back when something is visible, or the moment it starts. No frame extraction or transcript on your side.

## Run

```bash
python3 run.py     # or: ./run.sh  (curl + jq)
```

The clips in `clips/` are short test videos: a traffic light, a ball that appears three times, a tank alarm, and a forklift that shows up once in three minutes.

## The request

```json
POST /ground/video
{
  "video": { "b64": "<clips/syn_traffic_light.mp4, base64>", "mime": "video/mp4" },
  "query": "the red traffic light is lit",
  "kind": "object",
  "coarse_step": 1.0,
  "fine_resolution": 0.25,
  "boxes_on_hits": false,
  "max_probes": 150
}
```

| Field | What to put in it |
|---|---|
| `query` | What to look for, in plain language |
| `kind` | `object` to find when something is visible; `event` to find the moment something starts |
| `coarse_step` | Seconds between first-pass probes. Must be shorter than the shortest thing you're looking for. |
| `fine_resolution` | How precisely the edges of a hit are refined, in seconds |
| `boxes_on_hits` | `true` also returns a box at each hit's peak frame |
| `max_probes` | Upper limit on frames examined. Each probe is an image, so this caps the cost. |

## Reading the response

For `kind: "object"`, one entry per window where the thing is visible:

```json
{ "duration_s": 25, "hits": [{ "start": 10, "end": 17.75, "peak_t": 10, "confidence": 0.99 }] }
```

For `kind: "event"`, the moment it starts:

```json
{ "hits": [{ "onset_t": 10, "confidence": 0.99 }] }
```

An empty `hits` list means it wasn't found.


