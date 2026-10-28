#!/usr/bin/env bash
# Is the supplier's part quality slipping? Send 96 raw bore-diameter readings to /ds.
#   ./run.sh
set -euo pipefail
cd "$(dirname "$0")"
. ../../lib/bivia.sh

jq '{
  signals: [{name: .name, data: [.data], fs: 1, dtype: "float32"}],
  question: "Bore diameter (mm) of incoming GH-220 lots, nominal \(.nominal) ± \(.tolerance), one value per lot in arrival order. What is happening to the process?",
  options: ["Process stable (in control)", "Mean drifting upward (trend)", "Variance increasing", "Sensor noise only"],
  kind: "set"
}' data/gauge.json | bivia /ds | jq '{status, value, probabilities}'
