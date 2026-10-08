# The matrix multiplication bound ω ≤ 9/4 over arbitrary fields

[Read the paper (PDF)](paper.pdf) · [LaTeX source](paper.tex)

This self-contained paper directory describes the contribution on top of
OpenAI's original proof: the nonvanishing Fourier period, the characteristic-free
interpolation implementation, and fixed-overhead descent from an algebraic
closure. The original construction is cited rather than reproduced. The paper
has no author byline and its PDF Author metadata is empty; bibliographic and
development attribution remain explicit.

The paper cites the immutable OpenAI baseline and the existing
[v1.0.0 formalization archive](https://doi.org/10.5281/zenodo.23219128).
That archive predates this paper and does not contain it. Adding this paper
does not modify the archived release or assert a new proof-verification run.

## Build

Use an existing TeX Live or MiKTeX installation with `pdflatex`, Latin Modern,
`geometry`, `microtype`, the AMS packages, `mathtools`, and `hyperref`. From
the repository root:

```sh
bash paper/build.sh
```

The script runs three passes, rejects undefined references/citations and
overfull boxes, and writes the tracked `paper/paper.pdf`. Intermediate files
stay in ignored `paper/build/`. It disables shell escape and fixes PDF timestamps;
byte-for-byte reproduction requires the same TeX distribution and package versions.
No Lean build is needed to typeset this document.

When editing, rebuild the PDF, inspect every rendered page, and commit source
and PDF together. Keep the author block and PDF Author metadata empty.
See [REVIEW.md](REVIEW.md) for the mathematical and artifact review record.
