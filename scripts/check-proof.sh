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
git diff --exit-code "$baseline" -- \
  "$spec_root/Model.lean" \
  "$spec_root/Arithmetic/Complexity.lean" \
  "$spec_root/Arithmetic/Programs.lean" \
  "$spec_root/Arithmetic/RecursiveBlockPrograms.lean" \
  "$spec_root/Arithmetic/Padding.lean" \
  "$spec_root/Arithmetic/LowerBound.lean" \
  "$spec_root/Arithmetic/Exponent.lean" \
  "$spec_root/Tensor/ComplexTensor.lean" \
  "$spec_root/Tensor/ComplexTensorFlattening.lean" \
  "$spec_root/Tensor/ComplexMatrixTensor.lean" \
  "$spec_root/Polynomial/ExpressionFamily.lean"

python3 scripts/verify-dependencies.py "$project_root"

cd -- lean
# This target imports the all-fields theorems (not the other upstream results
# re-exported by Main), preserves the complex theorem, checks arbitrary
# universes and representative fields, and audits axioms.
lake build OAI.LinearAlgebra.MatrixMultiplication.AllFieldsAudit
