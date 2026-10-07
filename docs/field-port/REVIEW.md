# Reviewer guide

**The all-fields theorem and expanded audit passed.** The core proof was
rebuilt from committed sources in isolation and replayed in a fresh Lean
kernel environment. The canonical public build, ten axiom guards, and
intentional axiom/sorry rejection controls also passed. See
[ADVERSARIAL.md](ADVERSARIAL.md) and [VERIFICATION.md](VERIFICATION.md) for
scope, evidence, and the use of pinned third-party caches.

The source baseline is preserved by tag `openai-baseline-adc7f12`, at
commit `d2336fc`. It contains OpenAI's
`adc7f1241b42e322a6451854ab7e4b4c146bf78a` MatrixMultiplication subtree.
Review against that tag, even after development changes are merged into
`main`, rather than against an unrelated current upstream revision.

## Start with the specification

[Model.lean](../../lean/OAI/LinearAlgebra/MatrixMultiplication/Model.lean)
is unchanged. It defines the existing division-free programs, evaluation,
correctness, operation count, admissible exponents, and `Arithmetic.omega`.
`P.Correct` still means correctness for every pair of input matrices. Addition,
subtraction, and multiplication each cost one; input and constant loads cost
zero. The admissibility quantifiers remain
`∀ ε > 0, ∃ C > 0, ∀ n ≥ 1, ∃ P`, with one cost constant for all sizes.

For finite fields this is functional correctness, not formal polynomial
correctness: `x²=x` over F₂ is the simplest distinction. The separate
`exactRankExponent_le_nine_quarters_allFields` theorem concerns equality of
every coefficient of the matrix multiplication tensor. `RankAtMost.map`
preserves it under arbitrary commutative-semiring homomorphisms. This stronger
certificate supplies the algebraic bound; do not attribute symbolic semantics
to the unchanged `Correct` predicate itself.

The primary arithmetic files `Complexity`, `Programs`, `RecursiveBlockPrograms`,
`Padding`, `LowerBound`, and `Exponent` also remain unchanged. The new
`SquareAlgorithm F n` is only an abbreviation for the original
`MatrixAlgorithm F n n n`.

## Follow the proof route

| Step | Key source | What to check |
| --- | --- | --- |
| Repair the field-sensitive construction | [Fourier](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Separation/Fourier.lean), [FiniteProjection](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Separation/FiniteProjection.lean) | The period is `5*M` or `5*M+1`, its field cast is nonzero, and it is at most `6*M`. The cancellation and square weights retain the same tensor blocks. |
| Extract degeneration coefficients | [Interpolation](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Polynomial/Interpolation.lean), [Character.Degeneration](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Character/Degeneration.lean) | Distinct nonzero nodes come from an infinite field; no integer-node or characteristic-zero assumption is used. |
| Recover the original asymptotic inequality | [TagInequality](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Tensor/TagInequality.lean), [Entropy.Tag](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Entropy/Tag.lean) | The finite overhead is six, and the type-counting limit removes this constant. |
| Obtain the closed-field rank bound | [RankBound](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Arithmetic/RankBound.lean) | Generic characters, determinant/sector constructions, real growth inequalities, and detecting characters give `ν(K) ≤ 9/4` when `K` is algebraically closed. |
| Descend without changing the exponent | [FieldDescent](../../lean/OAI/LinearAlgebra/MatrixMultiplication/Arithmetic/FieldDescent.lean), [FieldExtension](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Arithmetic/FieldExtension.lean) | One finite coefficient algebra is fixed before tensor powers vary. Its dimension-squared cost is a single fixed factor, giving `ν(F) ≤ ν(AlgebraicClosure F)`. No separability premise is needed. |
| Convert rank to the existing arithmetic exponent | [Growth](../../lean/OAI/LinearAlgebra/MatrixMultiplication/Arithmetic/Growth.lean), [Arithmetic.Exponent](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Arithmetic/Exponent.lean) | The unchanged generic block builder supplies the actual correct programs and pays their linear-combination cost. Padding and positive exponent slack prove `omega F ≤ ν(F)`. |
| Assemble the conclusion | [AuxiliarySeparation.Main](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Main.lean), [AllFields](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AllFields.lean) | The final field parameter has only `[Field F]`; the complex theorem remains a specialization. |

## Arithmetic fidelity review

The new growth proof adapts the upstream complex growth argument to the
already-existing generic program builder. It retains the scalar base program
of cost one and the block recurrence
`S(n*m) ≤ R*S(m) + 6*R*n^2*m^2`. The quadratic overhead is counted, including
multiplications by fixed constants. Positive exponent slack handles both that
overhead and the boundary case of quadratic block rank. The existing padding
theorem supplies smaller correct programs without increasing cost.

The auxiliary `omega F` and `ArithmeticBound F` names directly abbreviate
`Arithmetic.omega F` and `Arithmetic.AdmissibleExponent F`; they introduce no
replacement complexity model. The infimum argument bounds the arithmetic
exponent by every finite rank exponent and does not assume the infimum is
attained. Source review found no specification weakening in either bridge.

## Reproduce the final checks

Run `bash scripts/check-proof.sh` from the repository root after bootstrapping
dependencies. It verifies eleven original files against an immutable baseline,
checks all ten dependency revisions and the exact compatibility patch, and builds
`AllFieldsAudit.lean`, which imports the exported all-fields theorems in
`AllFields.lean`, checks an arbitrary
universe and characteristic-2/3/5 examples, an infinite characteristic-two
rational-function field, the original correctness/cost statement, and an
expanded exact coefficient-rank witness. Ten guarded axiom checks
accept exactly `propext`, `Classical.choice`, and `Quot.sound`; any added axiom
or `sorryAx` causes a build failure. The expanded audit's execution status and
three fresh adversarial reports are recorded in [ADVERSARIAL.md](ADVERSARIAL.md).
