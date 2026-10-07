#!/usr/bin/env bash
set -euo pipefail

# Whole-Mathlib imports make each worker memory-heavy. Allow explicit overrides.
export LEAN_NUM_THREADS="${LEAN_NUM_THREADS:-1}"

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$project_root"

# Keep the original specification and supporting arithmetic/tensor definitions.
# Use an immutable commit rather than a movable tag for the trusted baseline.
baseline=d2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653
spec_root=lean/OAI/LinearAlgebra/MatrixMultiplication
python3 scripts/check-specification.py

python3 scripts/verify-dependencies.py "$project_root"

# This target imports the AllFields entry point, preserves the complex theorem,
# checks arbitrary universes and representative fields, and audits axioms.
lake build OAI.LinearAlgebra.MatrixMultiplication.AllFieldsAudit
