# Verification record

Date: 2026-10-06. Toolchain: `leanprover/lean4:v4.34.1` on arm64 macOS.
Core proof commit: `9bd2a64fa47efe678664b5401b6a8ea6d93238ad`
(`all-fields-proof-v1`). Expanded audit source: `704431ea67e20489dba45b47c70813a6075c554c`.

## Checked conclusion and unchanged specification

The public declaration elaborates to:

```lean
OAI.MatrixMultiplication.omega_le_nine_quarters :
  ∀ (F : Type u_1) [inst : Field F],
    OAI.MatrixMultiplication.Arithmetic.omega F ≤ 9 / 4
```

The universe is arbitrary and `[Field F]` is the only field hypothesis.
`Model.lean` is byte-for-byte unchanged from immutable baseline
`d2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653`. The strengthened check script also
compares ten other original arithmetic, tensor, and expression files with
that baseline. It neither changes correctness nor introduces a replacement
arithmetic exponent.

`AuxiliarySeparation.matrix_multiplication_cost_le` proves that for every
positive real ε there is one positive real C such that, at every positive
matrix size n, an original `Arithmetic.MatrixAlgorithm F n n n` is correct
and has original cost at most `C * n ^ (9/4 + ε)`. C may depend on F and ε,
but not on n or the inputs. Addition, subtraction, and multiplication each
cost one; input and constant loads cost zero.

The separate `exactRankExponent_le_nine_quarters_allFields` conclusion
concerns exact tensor coefficients. This matters over finite fields:
the original program predicate is equality on field-valued inputs, not
formal polynomial equality. The expanded audit exhibits the distinction
on F₂ and checks an exact finite coefficient-rank witness with every positive
exponent slack. It does not assert an equivalence of functional and symbolic
circuit exponents.

## Mechanical checks and their scope

| Check | Source and outcome |
| --- | --- |
| Isolated source re-elaboration of the auxiliary all-fields Main and its complete OAI dependency chain | Passed at proof commit `9bd2a64`, starting with no OAI build outputs. |
| Fresh-environment kernel replay of that Main and every imported declaration | `LEAN_NUM_THREADS=1 lake env leanchecker --fresh --verbose OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Main` exited 0 in the isolated checkout. |
| Canonical public theorem and expanded audit | `bash scripts/check-proof.sh` passed at `704431e`, exit 0, including the public Main and expanded AllFieldsAudit. Its 9437-job graph was incremental. |
| Direct elaborated-type/definition inspection and deliberately failing guard controls | Direct Lean run printed the expected types/definitions and exited 1 from exactly two intended axiom-list guard mismatches; no other errors. |
| Original specification/builder comparison | Eleven files match the immutable baseline. |
| Installed dependency source validation | All ten full Git revisions match; nine checkouts are clean and fixed-point-theorems has exactly the permitted upstream patch. |
| Whitespace and shell syntax | `git diff --check` and `bash -n` on the verification scripts passed. |

The isolated checkout was a local clone detached at the proof commit.
Its source tree matched that commit before and after the run. Its ordinary
OAI build directory started empty; only the exact-pinned third-party package
checkouts and build caches were shared. `LEAN_PATH` resolved OAI imports to
the isolated output directory, not the original OAI cache.

At `9bd2a64`, the broader isolated build of the then-public entry point,
upstream's `Main`, was stopped before completion after the all-fields core had
compiled. The remaining modules concerned OpenAI's other upstream bounds,
which that `Main` re-exported and which this repository has since removed. The
canonical build at `704431e` checked compatibility with those results, using
its existing cache. **The runs at `9bd2a64` and `704431e` do not include a fresh
source rebuild of upstream's `Main`, Lean, or the third-party dependencies;**
later fresh rebuilds are recorded at the end of this file.

`leanchecker --fresh` imports the target environment and then replays every
constant into a fresh environment using Lean's own kernel. It is additional
kernel checking, not an independent kernel implementation. The installed
checker comes with the pinned Lean toolchain. Its successful process exit,
together with the module-name output, establishes completion; an empty log
while it was running did not establish success.

As an additional correspondence check, these isolated `.olean` files were
byte-identical to their original cached counterparts:

| Module | SHA-256 |
| --- | --- |
| `Model` | `b28869bf0b85bfa4734860ee6ecc6047155038b0fc2d72848a2cb8cd4dd04a71` |
| `AuxiliarySeparation.Main` | `ad33737010636e98f73b544bff32466d2f35061a25ac31e030767a211c5d0ec9` |
| `Arithmetic.FieldDescent` | `6f410d94d4cf08b6a4095788a90c3049c2ff46d5e9b8301f1b4466da32ddab43` |
| `AuxiliarySeparation.Arithmetic.FieldExtension` | `b554efa06ae01699171ffcc512de74467ccdfd4cd6ed92c5e71ceebe3fd3fa3f` |

The correspondence check predates the audit's comment and provenance changes.
It is supporting evidence for these four artifacts, not a claim that every
third-party binary was rebuilt or source-verified.

## Expanded statement and axiom checks

`AllFieldsAudit.lean` checks an arbitrary field in an arbitrary universe,
`ZMod 2`, `ZMod 3`, `ZMod 5`, ℚ, ℝ, ℂ, and `RatFunc (ZMod 2)`. It also checks
the explicit original correctness/cost claim and the statement

```lean
∀ ε > 0, ∃ n R : ℕ, 2 ≤ n ∧
  Foundation.Tensor.RankAtMost
    (AuxiliarySeparation.matrixMultiplicationTensor (K := F) n n n) R ∧
  (R : ℝ) ≤ (n : ℝ) ^ ((9 : ℝ) / 4 + ε)
```

Ten guarded `#print axioms` checks require exactly
`[propext, Classical.choice, Quot.sound]`:

- `OAI.MatrixMultiplication.omega_le_nine_quarters`
- `OAI.MatrixMultiplication.complex_omega_le_nine_quarters`
- `AuxiliarySeparation.exactRankExponent_le_nine_quarters_allFields`
- `AuxiliarySeparation.matrix_multiplication_cost_le`
- `AuxiliarySeparation.exactRankExponent_le_algebraicClosure`
- `AuxiliarySeparation.exists_detecting_character`
- `Foundation.Tensor.RankAtMost.descend_algebraicClosure_powers`
- `Foundation.Tensor.RankAtMost.descend_algebraic_powers`
- `AuxiliarySeparation.exactRankExponent_le_algebraic_extension`
- `Arithmetic.admissibleExponent_of_rankAtMost`

Names after the first two are relative to `OAI.MatrixMultiplication`.
The negative controls deliberately introduce an axiom and a `sorry` in an
external scratch file, then apply the same standard-axioms-only guards.
They must fail because the actual lists include `adversarialInjected` and
`sorryAx`, respectively. Those declarations are not repository proof sources
or imports. Both guards failed for exactly those reasons. The only other diagnostic was the expected warning that the deliberately unfinished scratch theorem uses `sorry`.

## Reproduction, attribution changes, and limits

From a normal checkout, run sequentially:

```sh
bash scripts/bootstrap.sh
bash scripts/check-proof.sh
bash scripts/check-kernel.sh
```

The final command repeats the proof checks before fresh kernel replay.
Since `7c4b124`, both scripts target `AllFieldsAudit`, which imports
`AllFields` instead of upstream's `Main`, and the kernel replay targets
`AllFieldsAudit`. The repository was then trimmed to the 126 modules that
`AllFieldsAudit` imports, removing `Main` and OpenAI's other results. The runs
recorded in this section and the next predate both changes.
Scripts default to one worker because whole-Mathlib imports can exhaust
memory when several compiler processes run together. The manifest contains
ten exact dependency revisions, and the bootstrap script rejects pin drift.
The fixed-point compatibility patch is the one preserved from upstream;
its SHA-256 is `d70872e41e80b25191538d1659c4aa3a001349b5bd16f806c9e3833a502516e5`.

After those Lean checks, short provenance/modification comments were added to the 41 modified pre-existing upstream Lean files (40 remain after the trim removed the modified copy of OpenAI's `Main.lean`; `Arithmetic/Growth.lean`, adapted from an omitted upstream file, received the notice later). Removing only those exact comments restored every pre-insertion source byte, checked against a saved snapshot. No theorem, definition, import, or proof body changed. The unchanged specification files received no notices and remain byte-identical to baseline. The comment-only additions did not trigger another full Lean run. Documentation changes and shortened machine-specific paths in review reports likewise do not change the proof.

A compact transcript of the successful checks and intended guard failures is preserved in [mechanical-checks.txt](adversarial/mechanical-checks.txt).

The initial pre-adversarial audit had already built the public theorem and
six axiom guards. Its reported Lake totals of 9053, 9436, and 9437 jobs describe
build graphs, not counts of fresh compilations. The checks above supersede
that record with the more precise scope.

Three fresh source reviews found no proof counterexample, hidden field
premise, weakened model, misplaced tensor-power quantifier, or omitted
linear-combination cost. Their mathematical review and its limits are in
[ADVERSARIAL.md](ADVERSARIAL.md). They are not a guarantee of infallibility or
a separate formalization. Historical priority, the original authors' reasons
for their scope, the exact exponent, practical constants, and an effective
algorithm generator are not established by this audit.

## Independent re-verification by Anthropic's Claude

Date: 2026-10-06. Checker: Anthropic's Claude (Opus 5.5), which took no part
in developing the proof. Toolchain: `leanprover/lean4:v4.34.1` on arm64 macOS,
`LEAN_NUM_THREADS=1`.

**Core proof, end to end.** Fresh clones from GitHub were checked at three
commits. Each run started from an empty OAI build directory, and in each all
ten dependency checkouts passed `verify-dependencies.py`.

| Commit | Change | `check-kernel.sh` |
| --- | --- | --- |
| `7c4b124` | Exported theorems moved into `AllFields.lean`, unchanged; scripts target `AllFieldsAudit` | exit 0, 29 min |
| `dc21b40` | Repository trimmed to the 126 modules `AllFieldsAudit` imports | exit 0, 31 min |
| `620b5ed` | Modification notice added to `Arithmetic/Growth.lean`; last commit to change Lean sources or scripts | exit 0, 34 min |

In each run:

- the eleven protected files matched the baseline;
- 126 OAI modules compiled with no errors or `sorry` warnings;
- the ten guarded axiom checks passed;
- `leanchecker --fresh` replayed `AllFieldsAudit` and all its imported
  declarations.

The source commit and a clean working tree were confirmed before and after
each run. Pinned third-party build caches were reused, and `bootstrap.sh` was
not rerun.

**Earlier full build.** A separate fresh clone was checked at commit
`2bb9a6f`, the `main` commit before `AllFields` was introduced. Its scripts
built the then entry point `Main` together with OpenAI's other results (the
dual-exponent, rectangular and conditional bounds and their certificates),
which this repository has since removed. `check-proof.sh` completed (9437 jobs; 508
OAI modules compiled from empty outputs, with no errors). That run was
interrupted once and resumed from its own completed modules.
`check-kernel.sh` then exited 0, including its fresh replay of
`AuxiliarySeparation.Main`.

**Statement checks.** Additional Lean files were elaborated against these
builds and confirmed the following.

- **The headline depends only on the specification.** The fully explicit
  statement of `omega_le_nine_quarters` uses only `Model.lean` definitions and
  standard Mathlib instances. A dependency walk over the types and definition
  bodies of the exported statements reaches only Lean core, Mathlib and
  `Model.lean`.
- **The infimum is not vacuous.** 2 ≤ `Arithmetic.omega F`; the admissible
  set is non-empty and bounded below; 9/4 is admissible. The headline also
  holds with every specification definition unfolded by hand.
- **The rank notions are the standard ones.** At ℂ, the generic matrix
  multiplication tensor is definitionally OpenAI's original tensor.
  `RankAtMost` is an exact sum of rank-one tensors, and the 2×2 tensor
  provably has rank greater than 3.
- **The proof ingredients behave as described.** The Fourier period selector
  gives the stated values on `ZMod 2`, `ZMod 5` and ℚ. The descent,
  Fourier, interpolation, character and bridge lemmas depend only on
  `propext`, `Classical.choice` and `Quot.sound`.
- **OpenAI's other exported statements (at `2bb9a6f`; since removed).** Against that full build, the same
  dependency walk shows that OpenAI's α and rectangular statements also reach
  only Lean core, Mathlib and `Model.lean`, and that they depend only on the
  three standard axioms. The exact-rank statement additionally reaches only
  the rank definitions `exactRankExponent`, `exactMatrixRank`, `exactRank`,
  `matrixMultiplicationTensor`, `RankAtMost` and `rankOne`.

**Statement review.** Separate source reviews found no specification change,
and found that the elaborated theorem means what the README states. They also
found that OpenAI's program model, correctness predicate and exponent match
the textbook definition of ω:

- **Infinite fields:** an exact match.
- **Finite fields:** `Correct` is equality of functions on field-valued
  inputs, so `Arithmetic.omega F` is at most the textbook value. The
  exact-rank theorem gives the textbook-strength statement there.

These reviews are AI review, not human peer review. The Lean checks retain
the usual trust in Lean's kernel, Mathlib and the toolchain.
