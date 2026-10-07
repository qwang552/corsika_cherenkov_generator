#!/usr/bin/env bash
# Wrapper for jobs/generate.sub: activate the python environment, then run generate.py
# from the code directory.  Environment: GEN_CODE (code directory), GEN_ENV (activate script).
set -euo pipefail
if [[ -f "${GEN_ENV:-}" ]]; then
  # shellcheck disable=SC1090
  source "$GEN_ENV"
else
  echo "WARNING: environment file not found (${GEN_ENV:-unset}); using the current python" >&2
fi
cd "$GEN_CODE"
export PYTHONUNBUFFERED=1
echo "generate: args=[$*] host=$(hostname) date=$(date -Is)"
python -c "import torch; print('cuda', torch.cuda.is_available(), torch.cuda.get_device_name(0) if torch.cuda.is_available() else '')"
python generate.py "$@"
