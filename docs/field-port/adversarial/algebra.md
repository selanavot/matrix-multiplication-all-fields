# Adversarial proof/algebra review

> **AI-generated review report.** Written on 2026-10-06 by a fresh AI-agent session that did not
> write the proof, while the repository was private. It is not human peer review. Preserved as
> written, apart from redacted machine paths; see [ADVERSARIAL.md](../ADVERSARIAL.md) for how its
> findings were resolved.

Audited source: `<repository checkout>`, HEAD and peeled `all-fields-proof-v1` both `9bd2a64fa47efe678664b5401b6a8ea6d93238ad`. Baseline: peeled `openai-baseline-adc7f12`, `d2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653`. The source tree had no differences from the audited tag when checked. Review date: 2026-10-06.

## Result and limits

**No concrete mathematical or formalization bug was established in the reviewed field descent, Fourier/interpolation, character semantics/existence, or rank-to-arithmetic bridge.** This is a source review, not an independent kernel-verification result. No Lake command, build, source edit, or repository mutation was performed. The central coordinator owns fresh build, elaborated-type, and axiom verification. I did not treat the previous positive reviews or STATUS.md's completion claim as evidence of correctness.

The principal failure modes below were actively checked against definitions and proof bodies. The argument in these components does apply to finite fields of characteristics 2, 3, and 5, and does not need perfectness or separability. This report is not a comprehensive independent reproof of the determinant, entropy, sector, or growth argument supplying the numerical `9/4` bound.

All file references below are relative to `lean/OAI/LinearAlgebra/MatrixMultiplication/` in the audited repository.

## 1. Fixed finite coefficient algebra: no moving-dimension loophole found

`Arithmetic/FieldDescent.lean:87–92` has the essential quantifier order: from one finite exact decomposition it concludes `∃ d, 0 < d ∧ ∀ n, RankAtMost (Tensor.power T n) (r ^ n * d * d)`. The existential dimension precedes the power parameter.

At `:94–100`, the coefficients of all three factor families of this one rank decomposition are collected into a finite index type, and one algebra `S := Algebra.adjoin F (Set.range coeff)` is defined. Finiteness at `:101–103` follows from finite generation by elements integral over the field F. The proof obtains integrality from algebraicity over F; it does not assume E is a finite extension as a whole. Factor families over S and their original equality are constructed at `:104–114`. Only after S and `Module.finrank F S` are fixed does the proof introduce n (`:115–116`). All tensor powers are then formed inside this same S (`:117–122`).

I tried the standard counterargument that interpolation nodes, roots of unity, or a fresh decomposition might enlarge the coefficient algebra as n grows. That does not apply to this lemma or its exponent application: `AuxiliarySeparation/Arithmetic/FieldExtension.lean:39–51` first fixes one decomposition of the single matrix block of size u over E, and obtains a uniform d for its powers. The full algebraic closure can be infinite; only the coefficients of this block are adjoined. Constants may depend on the block u, as allowed when taking the infimum over u.

## 2. Rank projection and inseparability: no trace assumption found

`Arithmetic/FieldDescent.lean:15–54` expands the first two rank-one factors in an F-basis of E. The third factor is `π (basis i * basis j * c q z)` (`:27`). Thus each original simple tensor creates exactly d² simple tensors over F. The identity at `:28–44` uses the basis reconstruction identities, multiplication bilinearity, and F-linearity of π. It does not improperly apply π multiplicatively.

The linear functional at `:57–71` is constructed by selecting a nonzero coordinate of 1 and rescaling that coordinate map. It has `π 1 = 1`. It is not the field trace, and its construction never needs a nonzero trace or a separable extension. At `:79–80`, F-linearity and `π 1 = 1` give `π (algebraMap F E v) = v`. Nontriviality of E excludes a collapsed unit; a basis of a nontrivial finite algebra has positive dimension (`:115`).

Consequently purely inseparable finite coefficient extensions, including those arising over imperfect fields, do not invalidate this step. The lemma even allows a nontrivial commutative algebra E, with algebraicity/integrality ensuring the required finite coefficient algebra.

## 3. Descent-to-exponent calculation: overhead is removed in the correct order

`AuxiliarySeparation/Arithmetic/FieldExtension.lean:14–31` identifies the tensor power of a square matrix multiplication tensor with one of size `u ^ j` by coordinate bijections. It uses the actual zero/one coefficient condition, not an assumed matrix-size law. The product over coordinates gives conjunction of the matrix matching conditions.

At `:60–73`, the proof combines:

- the definition-derived lower bound `(u ^ j) ^ exactRankExponent F ≤ exactMatrixRank F (u ^ j)`;
- the descended upper bound `exactMatrixRank F (u ^ j) ≤ exactMatrixRank E u ^ j * d * d`;
- the constant-factor removal theorem, with `C = d * d` chosen before j (`:57–59`).

`AuxiliarySeparation/Growth/PolynomialOverhead.lean:22–44,52–60` removes a fixed constant using decay of `(a / b)^j` under a contradictory strict growth-rate inequality. This is not an exchange of limits with a varying extension degree. The comparison with the infimum over blocks occurs only afterward (`FieldExtension.lean:77–81`). The lower-bound and positivity hypotheses needed for logarithms are explicitly discharged (`:52–56`).

## 4. Small characteristic: Fourier and interpolation conditions are explicit

`AuxiliarySeparation/Separation/Fourier.lean:74–76` selects `5*M+1` precisely when the cast of `5*M` in K is zero, otherwise `5*M`. The cast is proved nonzero at `:89–94`; the positive-integer condition and `6*M` upper bound are established at `:83–99`. Primitive root existence at `:102–106` uses algebraic closedness together with `NeZero` of this cast.

In characteristic 5, the selected period is always `5*M+1`. In characteristics 2 and 3 it is shifted exactly when `5*M` vanishes. In every case the normalization denominator is invertible. The Fourier identity's cast-nonzero assumption remains visible at `:46–51` and in downstream projection at `Separation/FiniteProjection.lean:32–60`. A smaller-than-period bound is on the **integer** phase, so no finite-characteristic identification of different integer labels is used. Square filtering also uses integer/natural polynomial exponents (`FiniteProjection.lean:63–79,117–132`), not squaring field elements and inferring integer equality.

`AuxiliarySeparation/Character/FiniteSeparation.lean:65–87` supplies both period conditions to the construction and pays for L separate source copies, then bounds this count by `6*M` in the reals. It does not normalize by the real count while forgetting the field denominator.

`AuxiliarySeparation/Polynomial/Interpolation.lean:21–39` requires an infinite scalar field and constructs distinct **nonzero** nodes by an embedding into the complement of `{0}`. The proof does not reuse natural-number casts as distinct nodes in positive characteristic. `:49–63` applies Lagrange interpolation with injectivity and a strict degree/cardinality bound. Normalized leading-coefficient recovery also requires every node to be nonzero (`:68–87`). After tensor powering, the node count is `D*n+1`, rather than `(D+1)^n` (`:162–180`).

The underlying generic extraction theorem is unchanged upstream code: `Polynomial/ComplexPolynomialApproximation.lean:18–58` is over `[Field F]`; its `power` construction is generic (`:91–115`). A different old theorem `rank_power` at `:117` explicitly requires `[CharZero F]`, but the new interpolation proof calls the generic `RankAtMost.coeff` directly instead (`Interpolation.lean:173–175`). I found no accidental use of that characteristic-zero theorem in this route.

These infinite-field steps are applied to `AlgebraicClosure F`, not directly to a finite F: `AuxiliarySeparation/Main.lean:24–27`. Each F gets its own algebraic closure, and rank descent then returns to F.

## 5. Characters and tensor semantics: no weakened order or finite-characteristic cast found

The foundation definitions are unchanged from the baseline. `Tensor/ComplexTensor.lean:24–51` defines exact rank by an actual finite sum of three separated factors; restriction by three linear maps; product by coordinatewise tensor product; direct sum with three equal summand indices; and power by product over all coordinates. There is no substitution of border rank or support containment for exact rank/restriction.

The new matrix tensor at `AuxiliarySeparation/Tensor/MatrixMultiplication.lean:12–14` is the usual zero/one matrix multiplication coefficient tensor. Its equality to the preexisting generic `Tensor.matrixCoefficients` is definitional (`:21–23`).

`AuxiliarySeparation/Tensor/Semiring.lean:34–36` keeps `IsRestriction T S` as existence of three scalar-field linear maps with exact coefficient equality. `FiniteTensor` records genuine finite coefficient arrays (`:128–143`), the preorder uses this restriction (`:145–149`), and the quotient uses mutual restriction (`:174–186`). Direct-sum classes still correspond to sums of classes (`Tensor/DirectSumClass.lean:49–71`).

In particular, `(k : TensorClass K)` does **not** mean the scalar `k` in K. `Tensor/Scalar.lean:74–81` identifies this semiring natural cast with the diagonal tensor containing k independent summands, and `:43–47,106–107` proves its exact rank is k. Thus a p-fold direct sum does not vanish in characteristic p. This is essential for the rank obstruction and was explicitly checked.

`AuxiliarySeparation/Character/Basic.lean:37–57` retains nonnegativity, zero/unit normalization, direct-sum additivity, tensor-product multiplicativity, and exact-restriction monotonicity. `Tensor/Characters.lean:113–134` derives every field of this structure from an actual monotone semiring homomorphism; it does not quietly postulate a detecting character.

`Character/Existence.lean:27–45` proves existence using the no-catalyst obstruction and the normalized-state construction. I traced the finite obstruction and multiplicative-state interfaces: `Spectrum/StateObstruction.lean:156–175,179–223,277–302` and `Spectrum/MultiplicativeStates.lean:111–150,155–226`. Their compactness and fixed-point arguments take place in real-valued function spaces on a set of tensor classes, not in a topology on K. The required rank domination and `1 ≤ z` for nonzero tensors are provided explicitly in `Character/Existence.lean:30–44`. The relevant state files are unchanged from baseline. The generic tensor obstruction keeps its catalyst and rank constant fixed (`Spectrum/Obstruction.lean:150–160,219–249,255–292`), and handles a zero catalyst separately via an unbounded-rank contradiction (`:313–365`).

## 6. Exact-rank-to-arithmetic bridge: operations are charged

The original program, correctness, and exponent source files were not modified by this change. The new generic bridge is not an alias for a cheaper rank-only operation model. `AuxiliarySeparation/Arithmetic/Exponent.lean:32–36` aliases the existing `Arithmetic.omega` and `AdmissibleExponent`; `:46–51` retains the quantifier order `∀ ε > 0, ∃ C > 0, ∀ n ≥ 1, ∃ correct P` with the original program cost.

`Arithmetic/Growth.lean:220–229` calls the preexisting generic `RecursiveBlock.rank_block_step` and pays `6*R*n²*m²` for the linear combinations, in addition to R recursive calls. The underlying construction explicitly counts scalar multiplication and addition in linear expressions (`Arithmetic/RecursiveBlockPrograms.lean:44–59`) and counts all input/output combinations (`:293–301,321–326,346–351,376–392`). Its correctness theorem quantifies over all input matrices (`:360–374`), including over finite fields.

The recurrence at `Arithmetic/Growth.lean:31–62,179–208` uses a strict exponential gap supplied by ε; this handles the boundary case `R = n²`. Padding covers every positive size (`:25–29,64–89,210–218`). The infimum step does not assume attainment: `AuxiliarySeparation/Arithmetic/Exponent.lean:70–84,99–108` proves the arithmetic exponent is below each finite-block rank exponent, then below their infimum.

## Source hygiene and remaining verification

A scan of additions in the complete Lean diff found no added `sorry`, `admit`, mathematical `axiom`, `unsafe`, `implemented_by`, `extern`, `native_decide`, `run_tac`, elaborator, macro, or syntax declaration. The only matching added text was an audit comment mentioning axiom dependencies. The reviewed implementation directories likewise contained no such proof bypass. Source scanning is supplemental and cannot replace a transitive axiom check.

I requested central elaborated-type/axiom checks for `RankAtMost.descend_algebraic_powers`, `exactRankExponent_le_algebraic_extension`, `exists_detecting_character`, and `Arithmetic.admissibleExponent_of_rankAtMost`, plus a public-theorem specialization to `RatFunc (ZMod 2)` to exercise an explicitly imperfect field. These requests are not claimed as completed tests in this report.

Unresolved verification scope: this reviewer did not independently rebuild dependencies, audit the Lean kernel/toolchain, inspect every imported Mathlib proof, or fully re-audit the upstream determinant/entropy argument. No unresolved source-level flaw or specific hidden field hypothesis was found in the assigned components.

## Extended review: determinant, sectors, entropy, and profile interfaces

At the coordinator's request I extended the source review while the isolated build ran. I examined the complete changes to `Determinant/Filtration.lean`, `Determinant/Character.lean`, `Sector/Branches.lean`, `Sector/Degeneration.lean`, `Sector/Character.lean`, `Entropy/Tag.lean`, `Growth/NormalizedProfile.lean`, and `Polynomial/Inequalities.lean`, together with their relevant coefficient definitions, interpolation-rank and profile interfaces. I also inspected the unchanged `Determinant/Kernel.lean`, `Determinant/Basis.lean`, and the relevant unchanged `Sector/Weights.lean` definitions/lemmas. No further mathematical or formalization defect was established.

### Determinant signs and basis changes

The determinant kernel is already defined over an arbitrary commutative ring in the baseline (`Determinant/Kernel.lean:26–39`). Its map is `p ↦ (-X*p,p)` and diagonal substitution is `(A,B) ↦ A+X*B`. Their cancellation (`:49–69`) is valid in characteristic 2 as well: it does not require `-1 ≠ 1`. Kernel injectivity is recovered directly from the second component (`:52–55`), rather than from a determinant containing a factor 2.

The adapted vector independence proof (`Kernel.lean:261–280`) first applies diagonal substitution to isolate distinct quotient monomials, then the second-coordinate projection to isolate the kernel monomials. Distinct formal monomials are independent in every characteristic (`:251–256`). The basis (`Determinant/Basis.lean:89–105`) is built from this independence and equality of natural-number dimensions. There is no averaging, symmetrization operator over K, division by a factorial, or characteristic-sensitive binomial coefficient in this basis argument.

`Determinant/Filtration.lean:34–46` preserves the original adapted and graded coefficient tables, merely changing their scalar type from ℂ to K. The cross term in the adapted table remains coefficient one; its reconstruction is justified by the unchanged generic ring identity `Kernel.lean:185–190`. The actual source-coordinate restriction still uses original-basis coordinates for the input change and the **inverse** change for the output dual (`Filtration.lean:274–279,311–339`). I specifically checked that the output side was not accidentally changed to the forward matrix.

The degeneration is a genuine simultaneous polynomial restriction with the identity first map (`Filtration.lean:149–184`). Quotient-to-quotient and kernel-to-kernel terms acquire X, the sole unwanted cross block acquires X², and the opposite cross block is already zero. The leading coefficient is extracted at natural-number degree one. This remains correct when the field has characteristic 2. The source is convolution tensored with a two-dimensional dot tensor (`:260–271`), and the character cost of that dot tensor is `(2 : ℝ)^χ.pX` (`Determinant/Character.lean:116–137`); it is not the scalar 2 in K. Nonzero branches require `e > 0` (`:50–58`), which is supplied from the retained `b ≥ 2` hypothesis (`:170–178`).

### Three-sector degeneration and shared input

`Sector/Weights.lean:19–51,97–108` keeps widths, interval endpoints, branch indices, and degeneration weights in ℕ/ℤ. None is reduced modulo the characteristic. In `Sector/Degeneration.lean:67–90`, the retained tensor is the sum of **disjoint** branches; the proof explicitly invokes pairwise incompatibility. Thus in characteristic 3 the three branches do not become three coincident scalar coefficients that cancel.

The simultaneous local maps (`Degeneration.lean:107–123`) still fix the first input. The exact family is `X*C(retained)+X²*C(erased)` (`:133–160`), and the degeneration structure proves vanishing and leading coefficients directly (`:178–195`). The only field inverse here is an evaluation parameter with an explicit `t ≠ 0` premise (`:210–231`). Monotonicity under this degeneration retains an `[Infinite K]` premise (`Sector/Character.lean:84–86`).

The branch coordinate maps were checked against the baseline and their identities (`Sector/Branches.lean:25–49,90–139,185–254`). The middle branch uses first-coordinate reversal and swaps the final two tensor legs. That reversal occurs when identifying the **individual** branch's character value; it is not applied separately to pieces of the shared first input in the simultaneous degeneration. `Sector/Character.lean:90–93,127–140` combines the actual shared-first tensor with these individual value identities. Its fractions `1/3`, `2/3`, and multiplier `3^χ.pX` are all real-valued character expressions, not inverses of 3 in K. Algebraic closedness is explicitly required at the point that invokes the general tag inequality (`:127`).

### Entropy counting and the new constant six

The substantive numerical change in the entropy interface is a fixed loss from 5 to 6. `Tensor/TagInequality.lean:115–145` proves that new finite bound using the adjusted Fourier period. The multiplicity `M = card (ExactWords counts)` is positive (`:125–126`), and its cancellation happens in ℝ (`:135–145`). It never divides by this cardinality in K, so multinomial counts divisible by the characteristic cause no problem. The exact-type word construction is by coordinate pullback (`:83–100`), not by a sum of coordinate permutations with factorial normalization.

`Entropy/Tag.lean:187–215` consistently passes 6 to the existing theorem with an arbitrary positive real constant C. The latter scales counts by t before the entropy limit (`:143–175`) and has C fixed before that scaling. Therefore the port does not mistakenly discard a factor `6^t`. The real-valued entropy lemmas and rational-approximation route are unchanged; I inspected their interfaces and use of fixed C, not a new independent proof of their asymptotic estimates.

**Documentation-only defect:** the audited tag's comment at `Entropy/Tag.lean:184–186` still said “fixed loss five,” while the statement at `:194` and application at `:198` use 6. I reported this immediately. The coordinator reports correcting the comment on the audit branch to “field-independent fixed loss six.” This is not a mathematical issue and does not alter any proof or definition. The separate complex-only factor-five statements were not flagged as defects.

### Normalized profile and final numerical interface

The convolution coefficient definition remains `if i.val+j.val=k.val then 1 else 0` (`Convolution/Basic.lean:25–27`), with natural index equality. Its exact rank upper bound is still `a+b-1`, but `Convolution/Rank.lean:53–64` now correctly requires an infinite field and uses the injective interpolation nodes rather than natural casts. This hypothesis propagates to `Convolution/Symmetry.lean:129–131`.

The sixfold character product and normalization remain the original formulas (`Character/Symmetrization.lean:32–38,96–97`); the mean is `(χ.pX+χ.pY+χ.pZ)/3` in ℝ (`Convolution/Symmetry.lean:78`). Six and three in these formulas are real constants, so characteristic 2 or 3 is irrelevant. `Growth/NormalizedProfile.lean:55–66` keeps the positive-mean hypothesis needed to preserve inequalities while taking the normalization power.

`Polynomial/Inequalities.lean:56–109` constructs all fields of the **unchanged** `ScalarProfile` structure: positivity, symmetry, exact boundary values, concavity, shifted tripling, and the interpolation-rank bound. The numerical hypotheses at `Growth/Profile.lean:23–33` were not weakened. The additional `[IsAlgClosed K]` is retained on the profile constructor and character exponent bound; the `meanExponent ≤ 0` case is handled separately (`Polynomial/Inequalities.lean:112–122`). `Arithmetic/RankBound.lean:20–27` then uses actual detecting characters and the matrix-value identity, without assuming the numerical rank exponent conclusion.

The following relevant numerical/algebraic foundation files were confirmed unchanged by the baseline diff: `Determinant/Basis.lean`, `Determinant/Bounds.lean`, `Determinant/Kernel.lean`, `Sector/Weights.lean`, `Polynomial/ProductBounds.lean`, `Polynomial/Laws.lean`, and `Growth/Profile.lean`. This extended review did **not** independently reprove their entire numerical analysis or every imported combinatorial estimate. It checked the generalized coefficient constructions and that the unchanged numerical theorem receives its original hypotheses.
