#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# Fixed UTC timestamp makes successive builds reproducible with the same TeX
# distribution; the manuscript date is explicit in paper.tex.
export SOURCE_DATE_EPOCH=1791417600
export FORCE_SOURCE_DATE=1
mkdir -p build
for pass in 1 2 3; do
  if ! pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error \
    -file-line-error -output-directory=build paper.tex >"build/pass-${pass}.txt"; then
    cat "build/pass-${pass}.txt" >&2
    exit 1
  fi
done
if grep -Eq 'LaTeX Warning: (Citation|Reference).*undefined|There were undefined references|Rerun to get cross-references right|Overfull' build/paper.log; then
  grep -A 5 -B 1 -E 'undefined|Rerun to get cross-references right|Overfull' build/paper.log >&2
  exit 1
fi
cp build/paper.pdf paper.pdf
printf 'Built paper/paper.pdf\n'
