# Paper review record

This file records agent reviews of `paper.tex`. It is not human peer review,
and reviewing the exposition is separate from checking the Lean proof. No new
Lean build was run for the source and attribution review below.

## Source and attribution review — 2026-10-08

The source-review agent read the draft and checked its references against the
original manuscript at OpenAI revision
`adc7f1241b42e322a6451854ab7e4b4c146bf78a`, the current proof repository,
the v1.0.0 release record, and the archived mechanical report. The draft
credits the original numerical bound and its substantial construction to
OpenAI, identifies the characteristic-sensitive changes, and states the
limits of its formal and computational claims.

### Exact upstream references

The pinned manuscript source is
[OpenAI's `paper.tex`](https://github.com/openai/math/blob/adc7f1241b42e322a6451854ab7e4b4c146bf78a/preprints/Matrix-Multiplication-Nine-Fourths-October-2-2026/build/paper.tex).
The numbered statements and source lines checked are:

| Reference | Source line | Role in this note |
| --- | ---: | --- |
| Theorem 1.1 | 45 | Original complex-field arithmetic bound |
| Lemma 2.2 | 198 | Detecting characters; proof in Appendix A |
| Lemma 2.3 | 247 | Interpolation and degeneration monotonicity |
| Proposition 3.1 | 277 | Finite separation with original period `5M` |
| Corollary 3.2 | 350 | Entropy inequality from type counting |
| Lemma 4.1 | 442 | Discrete concavity from the determinant construction |
| Lemma 4.2 | 526 | Shifted tripling from the sector construction |
| Lemma 5.1 | 610 | Diagonal growth |
| Remark 5.2 | 690 | Algebraic coefficients and one finite number field |
| Appendix A | 700 | Detecting-character existence proof |

The distinction between the manuscript and the Lean implementation matters:
the written proof of Lemma 2.3 already permits arbitrary distinct nonzero
interpolation nodes. The original Lean implementation specializes these to
integer nodes in the complex field. The note correctly describes replacing
the integer nodes as a change to that implementation, rather than an
additional mathematical idea missing from the manuscript.

The new Fourier period preserves the original label filter and square-weight
calculation. The draft explicitly keeps the weights as integer exponents and
the character limits as real-valued calculations; it does not reduce either
modulo the characteristic. Its explanation of the factor `6^(1/N)` identifies
why the changed finite cost leaves the cited entropy inequality intact.

### Classical descent attribution

The relevant primary reference is A. Schönhage, *Partial and Total Matrix
Multiplication*, **SIAM Journal on Computing 10**(3) (1981), 434–455,
[DOI 10.1137/0210032](https://doi.org/10.1137/0210032).
Publisher metadata and the original paper's text were checked. The publisher
page exposes the bibliographic record; the original pages were inspected
through an [OCR mirror of the paper](https://id.scribd.com/document/867742732/10-1137-0210032),
using the article body rather than the hosting site's generated summary.

- Theorem 2.7, pp. 439–440, descends tensor decompositions through an algebra
  of the form `F[theta]/(g)`, with the multiplication cost of that algebra as
  overhead. The paragraph before Theorem 2.8 applies this to algebraic
  extensions using a minimal polynomial.
- Theorem 2.8, p. 441, states: “The exponent of matrix multiplication over F
  can only depend on the characteristic of F”. This is a 15-word quotation,
  with mathematical typography normalized from the scanned text.

This reference supports describing coefficient descent and
characteristic-zero transfer as established principles. The note's
contribution is adapting the particular OpenAI construction to all positive
characteristics and formalizing the resulting proof. A citation to
Schönhage should accompany the descent discussion; no historical-priority
claim is warranted for descent itself.

### Formal artifact and verification provenance

The reference artifact is v1.0.0,
[DOI 10.5281/zenodo.23219128](https://doi.org/10.5281/zenodo.23219128),
source commit `c88bb830aeb6ebd83f1e48a7bdae566ff5e0924d`.
The records inspected were [`docs/releases/v1.0.0.md`](../docs/releases/v1.0.0.md),
[`verification/comparator/README.md`](../verification/comparator/README.md),
[`formalization.yaml`](../formalization.yaml), and
[`verification/palomar/mechanical-report-2026-10-07.json`](../verification/palomar/mechanical-report-2026-10-07.json).

The report names proof snapshot
`8375e73ed454e3128500d10d87480c5dd597ff03`, Lean 4.35.0-rc2, and successful
Lean, nanoda, and con-ron kernel checks. Its six compared claims include
exact coefficient identities. The permitted axioms are `propext`,
`Classical.choice`, and `Quot.sound`; there are no definition holes. The
release record explains that the later archived source adds metadata and
documentation without changing Lean sources, dependency pins, Comparator
configuration, or verification scripts.

The current protected specification is mathematically unchanged under the
deterministic module-system port. It is therefore accurate to say that its
definitions are preserved, but inaccurate to call the current file
byte-identical to the original pre-port file. The draft uses the accurate
formulation. It also distinguishes functional circuit correctness over finite
fields from the separate exact coefficient identities, and does not claim
effective uniform generation, an endpoint `O(n^(9/4))` bound, or bit complexity.

### Attribution and bibliography recommendations

The draft has an empty author block and empty `pdfauthor` metadata, as
requested. Bibliographic credit to OpenAI, the authors of the cited classical
work, and S. Navot as the archived artifact's listed creator is retained.
The prose discloses substantive GPT-6 Astra and GPT-6.1 Sol contributions
through Codex and the AI-assisted preparation of the note. It does not
represent agent review as human peer review or imply endorsement by upstream
authors.

For the formalization paragraph, the standard infrastructure citations were
also checked:

- L. de Moura and S. Ullrich, *The Lean 4 Theorem Prover and Programming
  Language*, CADE 28 (2021), 625–635,
  [DOI 10.1007/978-3-030-79876-5_37](https://doi.org/10.1007/978-3-030-79876-5_37).
- The mathlib Community, *The Lean Mathematical Library*, CPP 2020,
  [DOI 10.1145/3372885.3373824](https://doi.org/10.1145/3372885.3373824),
  as requested by [Mathlib's citation file](https://github.com/leanprover-community/mathlib4/blob/master/CITATION.md).

The initial draft's source attributions are accurate. Addition of these
classical and infrastructure references was requested during review. This
review did not check the rendered PDF or rerun any proof verifier.

## Mathematical review — 2026-10-08

A second agent independently read the manuscript against the Fourier,
interpolation, entropy, finite-algebra descent, and exponent-comparison
sources. It found no substantive error in the following arguments:

- The nonzero Fourier period and integer no-wrap and square-weight arguments.
- Interpolation normalization and the factor removed by tensor powers.
- The rank projection with `d²`, obtained by expanding only two tensor legs.
- Fixing the coefficient algebra before powers vary, then taking the exponent
  limit before the infimum over block sizes.
- The arithmetic recurrence, padding, and positive exponent slack.

Two suggested precision edits were incorporated: functional versus coefficient
correctness is discussed for unrestricted arithmetic circuits (multilinear
tensor coefficients themselves are determined by evaluation on basis inputs),
and the type-counting parameter is restricted to multiples of a common
denominator of the rational type. The reviewers did not write the formal proof
during this review, and their review is not human peer review.

## Artifact validation — 2026-10-08

The paper branch is based on `ff411017acebeecae59505266c2a1756a9ce4540`.
No Lean source, dependency pin, or verification configuration was changed.
The existing verification results are cited at their recorded snapshots; a
new Lean build was not needed for these documentation-only changes.

The final title is *The Matrix Multiplication Bound ω ≤ 9/4 over Arbitrary
Fields*, as requested during review. Checks completed:

- The built-in LaTeX compiler accepted the saved source.
- `bash paper/build.sh` completed using pdfTeX 1.40.27 (TeX Live 2025), with
  no undefined references/citations or overfull boxes. The log's shell-escape
  warning is expected because the build disables that feature; the document
  does not need external conversion commands.
- Two successive builds with that installation produced byte-identical PDFs.
- All six pages were rendered with Poppler and visually inspected after the
  title change. Mathematical notation, links, page breaks, and margins are
  legible, with no clipped or overlapping content.
- `pdfinfo` confirms six US-letter pages, the requested title, and an empty
  Author field. The title page has no author byline. Names in bibliographic
  references remain as proper source attribution.
- `bash -n paper/build.sh`, `git diff --check`, and the README link-target
  checks passed.
- `python3 scripts/check-specification.py` passed: the eleven protected files
  and frozen Challenge model retain the exact module-only baseline port.

At initial paper commit `cd846fe`, the PDF was 295,708 bytes. SHA-256:
`4805e65c689e4c2a19f773ea9d66541acc856905b5c4bafc7357555915f2b09a`.

### Displayed date removed

At the user's request, the title-page date is now empty (`\date{}`); Git
commits identify manuscript versions. Bibliographic publication dates remain.
The native compiler and repository PDF build both passed again, all six pages
were rendered and inspected, and `git diff --check` passed. The updated PDF
is 273,060 bytes, with SHA-256:
`6669fa39da9696b141ae96537185467ba2469dd1a29c4727968799f93184a0ed`.
