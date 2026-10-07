# Upstream provenance and modifications

This is a focused source fork of [OpenAI's mathematics repository](https://github.com/openai/math).
The `lean/OAI/LinearAlgebra/MatrixMultiplication` subtree was extracted from
commit `adc7f1241b42e322a6451854ab7e4b4c146bf78a`:

https://github.com/openai/math/tree/adc7f1241b42e322a6451854ab7e4b4c146bf78a/lean/OAI/LinearAlgebra/MatrixMultiplication

The associated OpenAI preprint is *An Upper Bound of 9/4 for the Matrix
Multiplication Exponent* (October 2, 2026), available at that same pinned
revision under `preprints/Matrix-Multiplication-Nine-Fourths-October-2-2026`.
OpenAI supplies the original construction, complex-field proof, and arithmetic
specification. This fork extends the scalar-field scope of that proof.

## Preserved baseline

Tag `openai-baseline-adc7f12` points to immutable baseline commit
`d2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653`. Its matrix-multiplication subtree
preserves the upstream sources before our changes. Do not move the tag.
Compare against that baseline after development PRs merge:

```sh
git diff --diff-filter=AMR d2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653 -- lean/OAI/LinearAlgebra/MatrixMultiplication
```

The filter hides the upstream modules omitted from this extraction (below).
Git shows `Arithmetic/Growth.lean` as a rename of upstream
`ComplexArithmetic/Growth.lean`, which it generalizes to arbitrary fields.

The extraction is packaged as a standalone Lake project, keeping upstream's
Lean 4.34.1 toolchain, Mathlib commit, fixed-point dependency, and compatibility
patch. Other mathematical projects and their dependencies are omitted. Within
the matrix-multiplication subtree, only the import closure of `AllFieldsAudit`
is kept: 126 modules, of which 120 are upstream modules (40 of them modified)
and 6 are added by this fork. OpenAI's `Main`, its dual-exponent, rectangular
and conditional results, their numerical certificates, and the complex-only
program layer that the generic arithmetic bridge replaces
(`ComplexArithmetic/*` other than `Complexity`, `Arithmetic/Compatibility`,
`Polynomial/ComplexExpressionFamily`) are omitted. They remain available at the
pinned upstream revision. This
provenance describes the extracted source history; it does not claim to retain
the full upstream repository history or GitHub fork relationship.

## Scope of this fork's changes

- Parameterize the scalar-field-dependent tensor and spectral development.
- Choose a nonvanishing Fourier period in each characteristic and use arbitrary
  distinct nonzero interpolation nodes over the algebraic closure.
- Add algebraic-extension descent with a single fixed coefficient-algebra
  overhead across all tensor powers.
- Connect exact rank over arbitrary fields to the existing generic arithmetic
  program builder and original exponent definition.
- Export an arbitrary-field theorem and the complex specialization from a new
  `AllFields` entry point, which replaces upstream's `Main`, and add
  specification, representative-field, and axiom audits.

The mathematical contents of the original `Model.lean` and ten protected
specification/builder files are unchanged; the Palomar port below adds only
module-system annotations to these files. The README shows the small theorem-statement change; the
[reviewer guide](docs/field-port/REVIEW.md) traces the substantive proof changes.

## Attribution and verification

The original [Apache License 2.0](LICENSE) is retained. Modified pre-existing
upstream Lean files carry prominent modification notices; the upstream files
had no headers of their own. `Arithmetic/Growth.lean`, adapted from the omitted
upstream `ComplexArithmetic/Growth.lean`, carries the same notice. Those notices point here for the source revision and
scope. New proof and audit files are distributed under the repository license.

See [VERIFICATION.md](docs/field-port/VERIFICATION.md) for exact checked commits,
commands, axiom dependencies, and coverage limits, and
[ADVERSARIAL.md](docs/field-port/ADVERSARIAL.md) for three fresh source reviews.
No historical-priority claim or claim about the original authors' intentions
is made by this fork.

## Palomar compatibility port

The submission port adds `module`, public imports/sections, and exposed definition
bodies without changing the mathematical contents of the eleven protected
specification/builder files. `scripts/check-specification.py` checks equality to
the exact transformation of baseline `d2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653`.
Current toolchain/dependency pins are in the root manifest and `lean-toolchain`;
the earlier pins above describe the extraction and historical checks.

Five required Brouwer proof modules are vendored from harfe's
`fixed-point-theorems-lean4` commit `770940ddf9878cf61952ed53d910b92bca841838`, with
the preserved OpenAI compatibility patch and the module-system port. The
`child_map_inj` proof additionally supplies its equality argument explicitly
to each rewrite for the new elaborator; its statement is unchanged. The
upstream MIT licence is retained in `lean/FixedPointTheorems/LICENSE.txt`. Only
these modules are copied: `brouwer`, `apply_cubical_sperner`, `convex_homeos`,
`cubical_sperner`, and `cubical_sperner_prep`. The old patch is retained as a
provenance artifact and no build hook modifies dependency sources.
