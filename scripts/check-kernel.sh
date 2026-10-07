#!/usr/bin/env bash
set -euo pipefail
export LEAN_NUM_THREADS="${LEAN_NUM_THREADS:-1}"

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$project_root"
bash scripts/check-proof.sh
cd -- lean

# Replay the exported all-fields theorems, the audit, and all their imported
# declarations in a fresh environment. This uses Lean's own kernel, not an
# independent implementation.
lake env leanchecker --fresh --verbose \
  OAI.LinearAlgebra.MatrixMultiplication.AllFieldsAudit
