#!/usr/bin/env bash
# Send a whole video to /ground/video and get back when something is visible or when it starts.
#   ./run.sh
set -euo pipefail
cd "$(dirname "$0")"
. ../../lib/bivia.sh

# scan CLIP QUERY KIND [COARSE_STEP] [FINE_RESOLUTION]
scan() {
  echo "== $1  \"$2\" ($3)"
  jq -n --rawfile b64 "$(b64 "clips/$1.mp4")" --arg query "$2" --arg kind "$3" \
    --argjson coarse "${4:-1.0}" --argjson fine "${5:-0.25}" '{
      video: {b64: $b64, mime: "video/mp4"},
      query: $query, kind: $kind,
      coarse_step: $coarse, fine_resolution: $fine,
      boxes_on_hits: false, max_probes: 150
    }' | bivia /ground/video | jq -c '{duration_s, hits}'
}

scan syn_traffic_light     "the red traffic light is lit"       object
scan syn_traffic_light     "the traffic light turns red"        event
scan syn_ball_three_times  "a red ball"                         object
scan syn_tank_overflow     "the alarm lamp is lit bright red"   object
scan syn_tank_overflow     "a dog"                              object
scan syn_haystack_forklift "a yellow forklift"                  object 3 0.5
