#!/usr/bin/env bash
set -euo pipefail
export LEAN_NUM_THREADS="${LEAN_NUM_THREADS:-1}"

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$project_root"

if ! command -v lake >/dev/null 2>&1; then
  printf '%s\n' 'Install elan first: https://github.com/leanprover/elan' >&2
  exit 1
fi

# The committed configuration pins every dependency. Brouwer sources, including
# the historical compatibility patch, are now vendored under lean/FixedPointTheorems.
lake update
git -C "$project_root" diff --exit-code HEAD -- lake-manifest.json lean-toolchain
python3 "$project_root/scripts/verify-dependencies.py" "$project_root"
lake exe cache get

printf '%s\n' 'Dependencies and Mathlib cache prepared. Run lake build or bash scripts/check-proof.sh from the repository root.'
