# Adversarial specification and semantics audit

> **AI-generated review report.** Written on 2026-10-06 by a fresh AI-agent session that did not
> write the proof, while the repository was private. It is not human peer review. Preserved as
> written, apart from redacted machine paths; see [ADVERSARIAL.md](../ADVERSARIAL.md) for how its
> findings were resolved.

Reviewer role: adversarial source review by a fresh AI-agent session, not proof author.
Date: 2026-10-06.
Target: then-private repository `matrix-multiplication-all-fields`, tag `all-fields-proof-v1`, merge commit `9bd2a64fa47efe678664b5401b6a8ea6d93238ad`.
Reference: tag `openai-baseline-adc7f12` / baseline `d2336fc`, compared where material with original `openai/math` commit `adc7f1241b42e322a6451854ab7e4b4c146bf78a` in the sibling `openai-math` clone.

All paths below are relative to `lean/OAI/LinearAlgebra/MatrixMultiplication/` in that repository, unless explicitly stated. No repository source was changed and no Lean/Lake compiler process was started by this reviewer. Compiler checks and axiom/environment integrity are the coordinator's separate responsibility.

## Decision

I did not find a specification counterexample to the actual all-fields `Arithmetic.omega F ≤ 9/4` claim. That conclusion is narrower than endorsing the entire numerical proof: this review attacks the meaning of the target, the exact-rank/arithmetic bridges, and their compatibility with the original specification. It does not independently reconstruct the entire spectral/determinant proof.

The most concrete semantic caveat is real: **over finite fields, `MatrixAlgorithm.Correct` is functional correctness on field-valued inputs, not formal polynomial correctness.** Any statement equating those two notions should be retracted or qualified. This limitation predates the port. It does not currently falsify the numerical upper bound, because the proof establishes a stronger, exact coefficient-tensor rank statement before converting to programs. The exact coefficient identity survives ring homomorphisms and does not exploit finite-field function identities.

I recommend retaining the carefully scoped theorem claim, while avoiding claims that the theorem supplies a uniform executable algorithm, practical constants, exactly `O(n^(9/4))` operations with zero slack, one field-independent constant, or a definition of `Correct` based on formal polynomials. The source does not establish those stronger statements.

## Confirmed findings and limitations

### S1. Medium interpretation risk; not an upper-bound error: finite-field functional versus polynomial correctness

Evidence:

- `Model.lean:80–81`: `Correct P` quantifies matrices with entries in `F` and asks that `P.eval A B = A * B`.
- `Model.lean:11–16`, `22–28`: programs can multiply previously computed quantities; there is no syntactic multilinearity constraint.
- `Model.lean:88–93`: this functional correctness notion is what defines the arithmetic exponent.

Concrete falsification of the stronger interpretation: over `F₂`, the scalar circuit computing `x*x*y` is functionally correct for `1 × 1` multiplication, since `x²=x` for both elements of `F₂`. The formal polynomial `X²Y−XY` is nonzero; it also fails as an identity after extension to `F₂(t)` with `x=t, y=1`. Thus functional correctness alone does not guarantee coefficient equality, extension stability, or formal polynomial correctness. An executable gate trace is simply input x, input y, multiply x by x, multiply the result by y. This observation does not require conjecturing an exotic machine model.

Why this does **not** presently break the theorem:

- `Tensor/ComplexTensor.lean:16`, `24–29`: `Tensor` is a coefficient array indexed by coordinate positions, and `RankAtMost` is exact equality with a sum of rank-one coefficient arrays. Its quantification is not over matrix entries of `F`.
- `Tensor/ComplexTensor.lean:74–80`: `RankAtMost.map` carries the coefficient identity through any commutative-semiring homomorphism, so it applies to polynomial coefficients as well.
- `AuxiliarySeparation/Main.lean:24–27`: the port proves `exactRankExponent F ≤ 9/4` before proving the arithmetic corollary.
- `Arithmetic/RecursiveBlockPrograms.lean:194–223`, `235–255`, `360–374`: the bridge contracts the coefficient identity, uses linear input/output combinations, and implements actual block multiplication. No use of `x^q=x` appears in this route.

Resolution needed only for a stronger claim: formalize polynomial/ring-valued evaluation and a corresponding correctness theorem for the generated recursive programs, or explicitly present exact coefficient-rank results as the stronger algebraic certificate. Do not silently assert that the existing `Correct` definition already has this meaning.

### S2. Low interpretation risk; standard model boundary: nonuniform existential circuits and unit-cost field arithmetic

Evidence:

- `Model.lean:30–35` makes constant and input loads free and charges one operation for each scalar add/subtract/multiply.
- `Model.lean:39–41` still requires a finite straight-line program.
- `Model.lean:66–69`, `88–91` permits a different circuit at each matrix size; it does not provide an effective constructor from `n`.
- `AuxiliarySeparation/Arithmetic/RankExponent.lean:39–48` uses `Nat.find` and classical existence for rank decompositions.
- `AuxiliarySeparation/Main.lean:31–34` chooses `C` after `F` and epsilon and before `n`.

There is no bit-cost, coefficient representation/description-cost, memory-cost, or runtime-for-generating-the-program bound. This is an arithmetic circuit existence statement. It is a meaningful asymptotic upper bound in the requested original model, not an implementation benchmark or a single computable procedure over all abstract fields. Existing README scope language generally respects this distinction.

### S3. No fatal specification finding

The primary model is unchanged, and the new matrix coefficient definition is definitionally identical to the existing generic one. I found no vacuous final hypothesis, no input-dependent constant, no free operation returning the answer, no overloaded order/scalar arithmetic instance used to trivialize the target, and no use of an empty or unbounded infimum to obtain the bound. The attacks and concrete reasons are listed below; this statement is not based on compilation alone.

## Attempted attacks and results

| Attack | Result and evidence |
| --- | --- |
| Change the trusted definition while preserving its name. | Rejected. `git diff openai-baseline-adc7f12 all-fields-proof-v1 -- .../Model.lean` is empty. SHA-256 of current `Model.lean` and `git show` of the original upstream commit both equal `eafe9983c1968b1b5ffa56d0ebc4a8ce123d8c82323e01ae05d1fd0281fe16f5`. |
| Prove a shadow `omega` unrelated to the advertised target. | Rejected at source level. Public `Main.lean:14–16` explicitly returns `Arithmetic.omega F`. Auxiliary `Arithmetic/Exponent.lean:32` is an abbreviation for `MatrixMultiplication.Arithmetic.omega K`, not a fresh exponent. `Main.lean:19–21` retains the complex theorem as specialization. Coordinator should still inspect the elaborated declaration. |
| Hide characteristic zero, infinitude, algebraic closedness, separability, or a vacuous premise in the final theorem. | Rejected at source level. `Main.lean:14–16` and `AuxiliarySeparation/Main.lean:24–41` have only the field parameter and `[Field F]`; the cost theorem additionally has the necessary positive epsilon. The closure is `AlgebraicClosure F`, not one fixed characteristic-zero field. Explicit arbitrary-universe check is `AllFieldsAudit.lean:15–20`. |
| Restrict to a finite list of fields or a single universe. | Rejected by the generic source signature and explicit `F : Type u` audit example, not by the representative finite-field examples. Small characteristic examples are not in themselves proof of generality. |
| Make the constant depend on input matrices or matrix size. | Rejected. In `Model.lean:88–91` and `AuxiliarySeparation/Main.lean:31–34`, the order is epsilon, positive C, all positive n, existence of P, and then `P.Correct`, which itself quantifies every pair of matrices. C can depend on F and epsilon; it cannot depend on n, A, or B. |
| Choose a different program after seeing matrix entries. | Rejected. P is selected before the universal inputs in `Correct`. Program syntax contains constants, fixed input indices, and fixed register indices only (`Model.lean:11–16`, `39–41`, `66–69`). |
| Exploit zero dimensions or an impossible output register type. | Rejected for exponent statement: all `n≥1` must be covered (`Model.lean:90`). The scalar base case is an actual one-multiplication program (`Arithmetic/Growth.lean:169`, `Arithmetic/Complexity.lean:55–71`); higher programs have concrete register/output witnesses. |
| Use an empty arithmetic-admissible set so real `sInf` returns a default value. | Rejected. `Arithmetic/NaiveAlgorithm.lean:80–100` constructs exponent 3 and nonemptiness. `Arithmetic/LowerBound.lean:199–209` proves lower bound 2 and uses bounded-below `csInf_le`. |
| Use an unbounded-below arithmetic-admissible set. | Rejected. `Arithmetic/LowerBound.lean:124–140` proves every correct positive-inner-dimension algorithm has at least one charged operation per output; `199–205` yields admissible exponents ≥2. This proof also works over F₂: it distinguishes 0 and 1, not infinitely many field elements. |
| Exploit reversed infimum direction or unattained optimum. | Rejected. `Arithmetic/Exponent.lean:35–51` derives epsilon admissibility of omega using an approximating exponent with epsilon/2. `AuxiliarySeparation/Arithmetic/Exponent.lean:105–108` correctly proves arithmetic omega is a lower bound on every finite rank exponent and hence ≤ its infimum. No attained minimum is presumed. |
| Use log base 0/1, rank 0, or degenerate exact-rank infimum. | Rejected. `AuxiliarySeparation/Arithmetic/RankExponent.lean:145–152` restricts to n≥2 and exhibits n=2. `117–134`, `154–180` prove positive rank and all ratios ≥2; `182–188` gives finite bounds. The n=1 case is handled separately at `199–204`. |
| Replace multiplication with a transposed/different tensor or omit outputs. | Rejected. `AuxiliarySeparation/Tensor/MatrixMultiplication.lean:12–23` is the 0/1 coefficient tensor for `(i,j),(j,k),(k,i)` and is rfl equal to existing `Tensor.matrixCoefficients`. `Tensor/ComplexMatrixTensor.lean:24–29` contracts output coordinate `(k,i)` to `sum_j A_ij B_jk`. `Arithmetic/RecursiveBlockPrograms.lean:194–203`, `235–255` and `360–374` preserve that orientation in actual matrix outputs. |
| Charge only tensor rank while giving all scalar linear combinations for free. | Rejected. `Arithmetic/RecursiveBlockPrograms.lean:44–59` charges a multiply and add for each linear-combination term. `376–392` proves exact block cost. In the square case it is `R*T(m)+6*R*b²*m²`. `Arithmetic/Growth.lean:220–229` uses this precise cost, and the recurrence at `179–208` absorbs it with positive slack. |
| Lose the quadratic overhead in the boundary case rank=b². | Rejected. `AuxiliarySeparation/Arithmetic/Exponent.lean:70–84` proves log_b R≥2 from the rank lower bound. `Arithmetic/Growth.lean:190–196` takes target growth b^(tau+epsilon), strictly above R and at least b². This pays for the potential logarithmic recurrence factor at tau=2. |
| Prove the bound only on a sparse subsequence of sizes. | Rejected. `Arithmetic/Growth.lean:25–29` finds a power between n and b*n; `64–89` pads/restricts at cost no larger than the larger program, with one constant independent of n. `Arithmetic/Padding.lean:76–100` supplies actual program substitution and correctness. |
| Hide a tensor-power-dependent extension dimension in descent. | Rejected at the interface and implementation examined here. `Arithmetic/FieldDescent.lean:90–92` chooses d before all powers. The subalgebra at `95–103` is generated only by the finite coefficients of one fixed decomposition; `115–122` takes powers afterwards. `AuxiliarySeparation/Arithmetic/FieldExtension.lean:51–73` uses the same d² factor for every j. This review did not duplicate the full independent algebra audit. |
| Introduce inconsistent scalar/order instances to prove a different inequality. | No evidence found in the diff. Added instance declarations are the finite-tensor order/semiring structures inherited from the generalized baseline construction, and the local prime-five fact in `AllFieldsAudit.lean:17`; none redefines real order or field arithmetic in the public target. Explicit compiled type/axiom inspection remains the coordinator's test. |

## Comparison with baseline

The arithmetic primitive definitions, program builders, correctness, generic padding, generic block programs, lower bound, and arithmetic infimum facts were already upstream. The port adds generic `Arithmetic/Growth.lean` and scalar descent, and changes the AuxiliarySeparation bridge from the legacy complex bridge to the existing generic builders.

I diffed new `Arithmetic/Growth.lean` against the unchanged `ComplexArithmetic/Growth.lean`. Apart from namespace/type parameter/import changes, adapting the generic padding arguments, scalar base case parameter, and normalizing the identical square block-cost formula, it preserves the original recurrence-to-asymptotic argument. This is relevant because it prevents the new proof from smuggling a rank-only cost model into the final arithmetic statement.

The exact-rank exponent changes in `AuxiliarySeparation/Arithmetic/RankExponent.lean` replace ℂ by a field parameter and the complex tensor by the new generic coefficient tensor. The infimum remains `inf_{n≥2} log_n exactMatrixRank(n)`; the witness, positivity, quadratic lower bound, and finite upper bound are maintained. The new generic tensor is definitionally the existing generic `matrixCoefficients`, and at ℂ this agrees with the original complex tensor (`Tensor/ComplexMatrixTensor.lean:21–22`).

## Unresolved scope and evidence that would change the decision

1. **Numerical proof outside this review.** A defect in the generalized character/separation/spectral argument could invalidate the informal interpretation of a major intermediate object even though the final target is soundly specified. Separate agents should audit those definitions and hypotheses. The present result should not be described as a complete independent mathematical verification of 9/4.
2. **Formal polynomial theorem.** The arithmetic `Correct` predicate's finite-field limitation is proved mathematically above; the coordinator was asked for a small Lean counterexample (`∀ x y : ZMod 2, x*x*y=x*y` together with nonzero `X²−X`). An explicit polynomial-evaluation theorem for the produced programs would close the stronger-specification gap. It would not require weakening or replacing the existing model.
3. **Elaborated-target integrity.** A compiler print showing different fully qualified constants, unexpected typeclass arguments/field premises, or extra axioms would change my conclusion immediately. Source signatures and searches alone cannot replace this check; cached build completion alone also cannot replace it.
4. **Bridge falsification.** A concrete program accepted as `Correct` with cost below the established quadratic lower bound, a coordinate counterexample to tensor contraction, or evidence that C/d can depend on the quantified n/j would be fatal to the corresponding bridge. I attempted each source attack and found explicit barriers above.
5. **Practical/constructive claims.** If prior user-facing text claimed a deployable algorithm, exact zero-slack operation bound, uniform construction, polynomial semantics of every `Correct` program, or field-independent constants, that text should be corrected regardless of whether the numerical theorem stands.

No source-level finding in this review currently warrants retracting the precise statement `∀ F [Field F], Arithmetic.omega F ≤ 9/4`. It does warrant preserving its exact scope and not treating compilation as a substitute for auditing the remaining mathematics.

## Smallest stronger certificate to expose in the permanent audit

The smallest existing theorem to add to the guarded axiom checks and documentation is:

```lean
OAI.MatrixMultiplication.AuxiliarySeparation.exactRankExponent_le_nine_quarters_allFields
```

Its meaning is already stronger than a functional finite-field circuit bound. For a reader-facing expanded audit statement, combine it with `AuxiliarySeparation.exists_rankAtMost_of_exponent_slack` to obtain, for every field F and every positive epsilon,

```lean
∃ n R : ℕ, 2 ≤ n ∧
  Foundation.Tensor.RankAtMost
    (AuxiliarySeparation.matrixMultiplicationTensor (K := F) n n n) R ∧
  (R : ℝ) ≤ (n : ℝ) ^ ((9 : ℝ) / 4 + ε)
```

The only further step after that existing slack lemma is monotonicity of `Real.rpow` in its exponent for n≥2, replacing `exactRankExponent F + ε` by `9/4 + ε`. Unfolding `RankAtMost` exposes three finite arrays of coefficients in F and equality at **every coordinate triple** with the correct matrix-multiplication 0/1 coefficients. There are no finite-field input evaluations in that assertion.

`Tensor.RankAtMost.map` can additionally be instantiated with any homomorphism `F →+* S`, where S is an arbitrary commutative semiring, and in particular the constant embedding into a multivariate polynomial ring. Its coefficient identity is enough, mathematically, to establish a formal bilinear multiplication scheme; the existing generic contraction identity explains the exact matrix coordinates. This is sufficient for confidence that the upper bound is not benefiting from the finite-field semantic gap.

A new universal polynomial-evaluation bridge is useful if the intended exported object is an `Arithmetic.MatrixAlgorithm` carrying an explicit symbolic-correctness predicate. It is not needed to interpret the exact coefficient-rank result as an upper bound for algebraic matrix multiplication. These are different documentation/formal interface requirements, and neither should be conflated with a discovered mathematical error.
