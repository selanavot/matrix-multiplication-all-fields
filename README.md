# Matrix multiplication over arbitrary fields

This is a focused source fork of [OpenAI's mathematics repository](https://github.com/openai/math), extending its Lean proof of the matrix multiplication exponent bound **ω ≤ 9/4** from the complex numbers to **every field**. The original 9/4 construction and proof are OpenAI's work. This project generalizes the scalar field, supplies the necessary algebraic descent, and keeps the original arithmetic complexity specification.

The extension of OpenAI's proof to arbitrary fields was found and formalized by **consumer-grade GPT-6 Astra and GPT-6.1 Sol**, working under Sela Navot's direction. Lean checked the resulting formal proof; the verification scope is documented below.

The sources are extracted from the `MatrixMultiplication` subtree at OpenAI commit [`adc7f1241b42e322a6451854ab7e4b4c146bf78a`](https://github.com/openai/math/tree/adc7f1241b42e322a6451854ab7e4b4c146bf78a/lean/OAI/LinearAlgebra/MatrixMultiplication), packaged as a standalone Lake project. The preserved tag `openai-baseline-adc7f12` records that subtree before the extension. The accompanying OpenAI preprint is [*An Upper Bound of 9/4 for the Matrix Multiplication Exponent*](https://github.com/openai/math/blob/adc7f1241b42e322a6451854ab7e4b4c146bf78a/preprints/Matrix-Multiplication-Nine-Fourths-October-2-2026/build/paper.tex). See [UPSTREAM.md](UPSTREAM.md) for provenance.

## Premise and theorem-statement diff

The question behind this fork is whether the complex-field restriction is essential to the published proof technique. We keep OpenAI's definition of the arithmetic exponent and extend the proof, including its field-sensitive steps.

In namespace `OAI.MatrixMultiplication.AuxiliarySeparation`, the statement changes by introducing an arbitrary field (line wrapping normalized):

```diff
- theorem omega_le_nine_quarters :
-     Arithmetic.omega ℂ ≤ (9 : ℝ) / 4
+ theorem omega_le_nine_quarters (F : Type*) [Field F] :
+     Arithmetic.omega F ≤ (9 : ℝ) / 4
```

The public entry point exports the new `OAI.MatrixMultiplication.omega_le_nine_quarters` theorem. Its original `complex_omega_le_nine_quarters` declaration is retained as a specialization. The field may be finite or infinite, of any characteristic, and in any universe; no algebraic-closedness, perfectness, or separability assumption is imposed on it.

[`Model.lean`](lean/OAI/LinearAlgebra/MatrixMultiplication/Model.lean) is unchanged from the OpenAI baseline. Its `Arithmetic.omega` is the infimum of admissible exponents for division-free arithmetic programs: scalar addition, subtraction, and multiplication each cost one; input and constant loads are free. Correctness requires the program to multiply every pair of input matrices over the chosen field.

## Proof of the field extension

For a field F, the argument works over **its own algebraic closure** and then descends to F. It preserves the original auxiliary-separation, determinant, and asymptotic argument, with three changes where the scalar field matters:

1. **Fourier separation in every characteristic.** For a positive block count M, choose period `5*M` when its scalar image is nonzero, and `5*M+1` otherwise. The chosen period is invertible in the scalar field and at most `6*M`. Over the algebraic closure it admits the required primitive root of unity; the bounded overhead disappears in the asymptotic argument.
2. **Interpolation without integer nodes.** Use distinct nonzero nodes in the infinite algebraically closed field. This avoids collisions or zero denominators caused by reducing fixed integer nodes modulo a positive characteristic.
3. **Descent with a fixed overhead.** For a matrix multiplication tensor T over F, choose a fixed r-term decomposition of its scalar extension over `AlgebraicClosure F`. Its finitely many coefficients generate a finite-dimensional F-algebra of dimension d. Fix that algebra **before** taking tensor powers. An r-term decomposition then gives

   $$R_F(T^{\otimes m}) \le d^2 r^m$$

   for every m. The factor d² is independent of m, so it disappears at the exponent level. The descent uses an F-linear functional taking 1 to 1; it needs neither a field trace nor separability.

The resulting exact-rank bound is converted to the original arithmetic model using the existing generic block-program construction. The conversion counts the scalar operations in the linear combinations, and uses padding and positive exponent slack to cover every positive matrix size.

The main sources are [Fourier separation](lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Separation/Fourier.lean), [interpolation](lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Polynomial/Interpolation.lean), [finite-algebra descent](lean/OAI/LinearAlgebra/MatrixMultiplication/Arithmetic/FieldDescent.lean), and the [exponent comparison](lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Arithmetic/FieldExtension.lean). The [reviewer guide](docs/field-port/REVIEW.md) traces the complete proof route.

## Exact statements

The all-fields theorems are exported from [`OAI.LinearAlgebra.MatrixMultiplication.AllFields`](lean/OAI/LinearAlgebra/MatrixMultiplication/AllFields.lean), which imports only the all-fields proof. The public entry point [`OAI.LinearAlgebra.MatrixMultiplication.Main`](lean/OAI/LinearAlgebra/MatrixMultiplication/Main.lean) re-exports them alongside OpenAI's other retained results. Two supporting conclusions in namespace `OAI.MatrixMultiplication.AuxiliarySeparation` make the scope explicit.

**Exact coefficient rank.** If `R_F(n)` is the exact rank of the square matrix multiplication coefficient tensor, `exactRankExponent F` is `inf_{n ≥ 2} log_n R_F(n)`. The proof establishes:

```lean
theorem exactRankExponent_le_nine_quarters_allFields
    (F : Type*) [Field F] :
    exactRankExponent F ≤ (9 : ℝ) / 4
```

Here rank means an actual decomposition whose coefficients agree at every tensor coordinate. In particular, for every positive ε there is a finite block size n ≥ 2 and an exact decomposition of rank at most `n^(9/4 + ε)` over F.

**Arithmetic operation count.** The explicit program theorem is:

```lean
theorem matrix_multiplication_cost_le
    (F : Type*) [Field F] (ε : ℝ) (hε : 0 < ε) :
    ∃ C : ℝ, 0 < C ∧ ∀ n : ℕ, 1 ≤ n →
      ∃ P : Arithmetic.MatrixAlgorithm F n n n,
        P.Correct ∧
        (P.cost : ℝ) ≤ C * (n : ℝ) ^ ((9 : ℝ) / 4 + ε)
```

For each F and positive ε, one positive constant C works for **all** positive sizes n. The program may depend on n, but must work for every input pair. C may depend on F and ε. This is an asymptotic arithmetic-operation bound; it does not provide practical constants, a bit-complexity bound, or an effective procedure generating the programs.

Over finite fields, the original `P.Correct` predicate expresses equality of functions on field-valued inputs, which is weaker than formal polynomial equality—for example, `x²=x` on F₂. The separate exact coefficient-rank theorem supplies the stronger algebraic certificate: its identities are preserved under homomorphisms into arbitrary commutative semirings, including polynomial rings. The proof therefore does not obtain its bound from finite-field function identities. The exported program predicate itself remains the original functional one.

## Reproduction and verification

Install [elan](https://github.com/leanprover/elan), and have Git and Python 3 available. From the repository root, run these commands sequentially:

```sh
bash scripts/bootstrap.sh
bash scripts/check-proof.sh
bash scripts/check-kernel.sh
```

The toolchain and direct dependency pins are:

| Component | Pinned version |
| --- | --- |
| Lean | `leanprover/lean4:v4.34.1` |
| Mathlib | `d13f23b723b8a846827a245b89c10fc7d3f11612` |
| fixed-point-theorems | `770940ddf9878cf61952ed53d910b92bca841838` |

All transitive revisions are recorded in [`lean/lake-manifest.json`](lean/lake-manifest.json). Bootstrap obtains the matching Mathlib cache and applies the included [upstream Lean 4.34.1 compatibility patch](lean/patches/fixed-point-theorems-lean4341.patch) to fixed-point-theorems. Dependency validation checks the pinned revisions and that exact patch.

`check-proof.sh` compares eleven original specification and builder files with the immutable baseline, validates dependencies, and builds [`AllFields.lean`](lean/OAI/LinearAlgebra/MatrixMultiplication/AllFields.lean) and [`AllFieldsAudit.lean`](lean/OAI/LinearAlgebra/MatrixMultiplication/AllFieldsAudit.lean). The audit covers an arbitrary field universe, representative finite and infinite fields, the explicit cost statement, an exact coefficient-rank witness, and guarded axiom checks. Those guards require exactly `propext`, `Classical.choice`, and `Quot.sound` for the audited declarations; an additional axiom, including `sorryAx`, makes the check fail. The check does not compile the other OpenAI results that `Main` re-exports.

`check-kernel.sh` first runs the proof checks, then uses `leanchecker --fresh` to replay the audit target, including the exported all-fields theorems and all their imported declarations, in a fresh environment. This uses Lean's own kernel. It is not an independent kernel implementation or a rebuild of every dependency from source. The scripts default to one worker because the large imports require substantial memory. Run only one build or replay process at a time. To also compile the other OpenAI results that `Main` re-exports, which takes considerably longer, run `lake build OAI.LinearAlgebra.MatrixMultiplication.Main` from `lean/`.

> **Verified on 2026-10-06.** The isolated core source rebuild and fresh kernel replay passed at proof commit `9bd2a64`. The expanded public audit passed at `704431e`, including ten axiom guards; separate controls confirmed that added axioms and `sorry` are rejected. Three fresh adversarial source reviews found no fatal defect. Pinned third-party caches were reused, and the broader isolated rebuild of unrelated public results was not completed. The verification record gives the exact scope and documents subsequent comment-only attribution changes.

**Verification by OpenAI and Anthropic models.** Both checked that the theorem statement means what it claims and that the Lean verification works end to end. The OpenAI models credited above did so while developing the proof, with the results summarized in the box above. Anthropic's Claude (Opus 5.5), which took no part in the development, then repeated both checks independently on 2026-10-06:

- **The statement makes sense.**
  - `Model.lean` is byte-identical to OpenAI's upstream file, and the exported theorems depend only on Lean core, Mathlib and that file.
  - Its program model, correctness predicate and exponent match the textbook definition of ω exactly for infinite fields. For finite fields, the separate exact-rank theorem gives the textbook-strength statement.
  - The bound is not vacuous, since 2 ≤ ω(F) is proved.
- **The Lean verification works end to end.** From a fresh clone at commit `7c4b124`, with no OAI build outputs, `bash scripts/check-kernel.sh` exited 0:
  - all 126 OAI modules of the core compiled with no errors or `sorry`;
  - all ten axiom guards passed;
  - `leanchecker --fresh` replayed the audit target.

  Pinned third-party build caches were reused, and `bootstrap.sh` was not rerun.

See the [verification record](docs/field-port/VERIFICATION.md) and [adversarial audit](docs/field-port/ADVERSARIAL.md) for evidence and review limits. For the source comparison against OpenAI's preserved subtree:

```sh
git diff openai-baseline-adc7f12 -- lean/OAI/LinearAlgebra/MatrixMultiplication
```

## Attribution and scope

OpenAI's repository supplies the original 9/4 construction, the complex-scalar proof, and the arithmetic-program specification. This fork's contribution is the extension of that proof to arbitrary fields and the associated descent and verification work. It makes no claim of historical priority for the numerical bound or for field-independence arguments, and does not determine the exact matrix multiplication exponent.

The upstream [Apache License 2.0](LICENSE) is retained. See [UPSTREAM.md](UPSTREAM.md) for the exact source revision and the scope of the extraction.
