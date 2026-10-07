# Adversarial review: trust, reproduction, and claims

> **AI-generated review report.** Written on 2026-10-06 by a fresh AI-agent session that did not
> write the proof, while the repository was private. It is not human peer review. Preserved as
> written, apart from redacted machine paths; see [ADVERSARIAL.md](../ADVERSARIAL.md) for how its
> findings were resolved.

Reviewed 2026-10-06. Reviewer role: adversarial reviewer (a fresh AI-agent session), not proof author. Repository was read-only throughout; no Lake build or source change was performed by this reviewer. This report is outside the repository.

Target: `all-fields-proof-v1`, peeled commit `9bd2a64fa47efe678664b5401b6a8ea6d93238ad`. Baseline: `openai-baseline-adc7f12`, peeled commit `d2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653`, corresponding to `openai/math` commit `adc7f1241b42e322a6451854ab7e4b4c146bf78a`.

## Verdict at this review stage

I found no hidden axiom, modified trusted arithmetic model, source override, wrong-field specialization, or demonstrated false proof. The recorded successful check is supported by the saved compiler trace and log, but it was an incremental check using a shared build directory, not an isolated source rebuild. That limitation is already disclosed in VERIFICATION.md, though the cache arrangement deserves clearer description. Root is independently rebuilding committed OAI sources and will run Lean's checker; this report does not preempt those results.

The strongest surviving claim is the precise theorem about the unchanged `Arithmetic.omega F`, for arbitrary universe and `[Field F]`, plus a separate exact coefficient-tensor rank exponent bound. Calling this historical novelty, a practical algorithm, or an independently established equivalence between finite-field functional and symbolic circuit exponents would exceed the checked evidence.

## Findings, distinguishing defects from limitations

### F1 — Medium verification limitation: the previous final check reused OAI build artifacts

Evidence:

- `lean/.lake/build` is a symlink to `<retired harness>/.lake/build`.
- `lean/.lake/packages` similarly points to the retired harness's dependency directory.
- `../lean-focus/OAI` points back to the canonical source checkout. The retired harness and canonical Lake package differ in package name and hook configuration, but use the same direct dependency pins and `autoImplicit=false`.
- `../final-proof-check.log` contains one newly built target: `Built ...AllFieldsAudit (34s)`, followed by `Build completed successfully (9437 jobs)`. Thus 9437 is the successful dependency graph job total, not evidence that 9437 source files were newly compiled in that run.
- All 508 saved OAI `.trace` files found contain the canonical source path. The audit trace specifically records Lean 4.34.1 commit `5045d0056413266e57c625dcd7c365b10e377c52`, the canonical `AllFieldsAudit.lean`, canonical OAI output path, and no module plugins/dynlibs. This rebuts a simple wrong-checkout explanation, but saved traces are not a fresh replay.
- VERIFICATION.md:68–71 expressly discloses Mathlib cache reuse and absence of a separate fresh checkout build. STATUS.md:57–59 describes cache links mainly as Mathlib reuse, omitting that the entire OAI build output is shared.

Not a confirmed proof defect. Resolution: isolated committed-source checkout with no OAI outputs, compile the full public audit, then run an independent kernel recheck. Record dependency-cache reuse separately from OAI source replay. Do not call this a complete from-source rebuild of all dependencies if Mathlib oleans remain reused.

### F2 — Medium scope limitation: functional correctness is not symbolic polynomial equality over a finite field

`Model.lean:80–81` defines `P.Correct` by evaluation equality on all matrices whose entries lie in F. It does not require equality of formal polynomials, or correctness of that same program over all F-algebras. Over a finite field F_q, X^q and X agree as functions but differ as formal polynomials. A scalar program computing x^q*y therefore illustrates why evaluation correctness alone is a weaker specification than the conventional symbolic identity specification.

This is inherited from upstream, not a weakening introduced by the extension. It does not refute the advertised original-model theorem. It also does not show the constructed algorithm is unsound symbolically: the proof exposes `AuxiliarySeparation.exactRankExponent_le_nine_quarters_allFields` in `AuxiliarySeparation/Main.lean:24–27`, and `Foundation.Tensor.RankAtMost` in `Tensor/ComplexTensor.lean:26–29` is exact equality of coefficient arrays. That is the relevant stronger algebraic fact and should be explicitly audited and cited when discussing conventional tensor/arithmetic complexity over finite fields.

Recommended wording: “Lean verifies the all-fields upper bound for the upstream arithmetic-program definition, and separately verifies the corresponding exact coefficient-tensor rank exponent bound.” The independently reviewed exact-rank bound is mathematically sufficient for the conventional algebraic upper bound: `RankAtMost.map` in `Tensor/ComplexTensor.lean:74–80` transports the coefficient identity along any map to a commutative semiring, including a polynomial ring. A separate fully formal symbolic circuit definition/bridge would be needed to claim that exact program-level formal statement has been checked. Equality of two exponent definitions is not proved merely by the one-way rank-to-program bridge.

### F3 — Low hardening issue: the permanent specification check protects only one file and trusts a movable tag

`scripts/check-proof.sh:9–10` compares only `Model.lean` against `openai-baseline-adc7f12`. The tag is conventionally protected, not intrinsically immutable. The script does not verify its peeled object ID, dependency HEADs/dirty content, Lake search paths, or the rest of the unchanged trusted builder/specification files. `AllFieldsAudit` then checks conclusions using the definitions in the imported environment; it is not an independent restatement of all underlying definitions.

No current tampering found. All files listed below are byte-identical to the baseline and actual upstream checkout. The Model blob is `6391818d80e13292e0c1819594a4c57cc4fcc582`. The entire baseline MatrixMultiplication subtree has the same Git tree ID in the private baseline and upstream commit: `d07dbc6b3ceb20ea2e19056095ee3bd1b3156267`.

Recommended protected files, under `lean/OAI/LinearAlgebra/MatrixMultiplication/`:

- `Model.lean`
- `Arithmetic/Complexity.lean`
- `Arithmetic/Programs.lean`
- `Arithmetic/RecursiveBlockPrograms.lean`
- `Arithmetic/Padding.lean`
- `Arithmetic/LowerBound.lean`
- `Arithmetic/Exponent.lean`
- `Tensor/ComplexTensor.lean`
- `Tensor/ComplexTensorFlattening.lean`
- `Tensor/ComplexMatrixTensor.lean`
- `Polynomial/ExpressionFamily.lean`

Use `git diff --exit-code d2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653 -- <paths>` so a moved tag cannot silently redefine the baseline. For intentionally changed generalizations, maintain direct definitional tests rather than pretending the whole file is unchanged.

### F4 — Low bootstrap hardening issue, not confirmed pin drift

`scripts/bootstrap.sh:14` calls bare `lake update`, which rebuilds the root manifest instead of treating it as an immutable lock. Some inherited entries have `inputRev: main/master`; this initially looked like floating dependencies.

The actual evidence resolves that suspicion for this setup. Both direct `require` revisions are full Git hashes. All eight inherited revisions exactly equal the pinned Mathlib checkout's committed manifest entries. Lean 4.34.1 Lake source `Lake/Load/Resolve.lean` shows `addDependencyEntries` loading the dependency manifests and later `updateAndMaterializeDep` reusing their concrete entries. The root's later Mathlib requirement is resolved before earlier fixed-point-theorems and therefore supplies its transitive manifest entries. I found no current moving-revision dependency.

Remaining hardening: after bootstrap, enforce `git diff --exit-code -- lean/lake-manifest.json lean/lean-toolchain`, and compare all installed dependency HEADs with committed manifest revisions. The post-update compatibility hook's reverse-apply check detects that the patch is present, but does not reject additional unrelated dirty changes; validate the exact patch delta too. A fresh bootstrap execution was not performed by this reviewer.

### F5 — Low documentation overbreadth/ambiguity

- “9437 successful build jobs” is accurate as Lake's total graph report, but should not imply 9437 fresh source compilations; the stored final log shows one newly compiled target.
- AllFieldsAudit's finite-field examples instantiate a theorem already universally quantified over F; they detect interface/premise errors, not execute the Fourier construction on concrete inputs.
- The axiom checks cover the transitive dependencies of six named declarations. They do not certify every declaration imported by `Main`, every unused source file, source/cache correspondence, or the semantic adequacy of definitions.
- STATUS.md:86–87 says unchanged comparator files “intentionally contain placeholders.” A scan of all 514 tracked OAI Lean files found no `sorry`, `admit`, `axiom` declaration, `unsafe`, `native_decide`, `implemented_by`, `extern`, or custom command elaborator/macro used as an escape. I did not establish what “placeholders” refers to, so treat that note as unexplained/stale rather than evidence of a current axiom problem.
- Six of the 514 OAI sources have no saved compile trace: Completion/{Cardinality,SquareRates}, Arithmetic/Compatibility, and ComplexBounds/{SquareCounts,SquareBound,SquareWitness}. None is evidence of a hole in the public target's dependency build; “whole repository built” would be broader than the observed target build.

## Positive adversarial checks and exact evidence

1. **No untracked source override:** Git status is clean; there are 514 tracked OAI Lean files and 514 actual OAI Lean files. There are no source symlinks and no ignored OAI files. Only `.lake` contains the known output/dependency links.
2. **No same-name package shadow found:** no installed dependency contains an `OAI` source/output root. No dependency supplies shadow copies of `Lean/Elab/GuardMsgs.olean` or `Lean/Elab/Print.olean`. Process `LEAN_PATH`, `LEAN_SRC_PATH`, `LAKE_HOME`, `ELAN_HOME`, and `LEAN_SYSROOT` were unset in the shell inspected.
3. **Dependency revisions:** all ten working HEADs equal manifest `rev`. Mathlib and the eight inherited dependencies are clean. Fixed-point-theorems is at `770940ddf9878cf61952ed53d910b92bca841838`; its entire `git diff --binary` is byte-for-byte equal to `lean/patches/fixed-point-theorems-lean4341.patch`.
4. **Compatibility patch provenance:** the committed patch exactly equals the patch in upstream adc7f12. SHA-256: `d70872e41e80b25191538d1659c4aa3a001349b5bd16f806c9e3833a502516e5`. The seven modified dependency files, including lakefile and toolchain, are all accounted for by that patch.
5. **Axiom guard semantics:** `AllFieldsAudit.lean:47–69` uses fully qualified names. Installed Lean 4.34.1 `Lean/Elab/Print.lean:240–251` resolves those declarations and calls `collectAxioms`. `Lean/Elab/GuardMsgs.lean:209–250` exact-compares expected and collected messages unless explicitly given substring mode; this audit only selects lax whitespace. Additional reported axioms therefore change the expected message and generate an error. No local custom elaborator/macro overrides were found. The guards are meaningful, conditional on trusted compiler/imported environment.
6. **Actual statement:** the saved audit trace prints `∀ (F : Type u_1) [inst : Field F], Arithmetic.omega F ≤ 9 / 4`. The source also independently checks an explicit original `MatrixAlgorithm` correctness/cost conclusion and arbitrary universe parameter. No extra characteristic/closedness/separability condition is visible.
7. **No infimum-only vacuity in the audit claim:** an explicit positive-epsilon uniform-cost theorem is checked in addition to the inequality involving `sInf`. Its constant quantifier precedes n, so the constant cannot vary arbitrarily with input size.

## Original-paper and novelty claims

The primary source was read directly from the recorded upstream Git object:

`git -C ../openai-math show adc7f1241b42e322a6451854ab7e4b4c146bf78a:preprints/Matrix-Multiplication-Nine-Fourths-October-2-2026/build/paper.tex`

Stable public source link: https://github.com/openai/math/blob/adc7f1241b42e322a6451854ab7e4b4c146bf78a/preprints/Matrix-Multiplication-Nine-Fourths-October-2-2026/build/paper.tex

The abstract and Theorem 1.1 explicitly concern complex matrices. The tensor section explicitly works over C. The final arithmetic argument uses exact bilinear identities on matrix blocks with central coefficients. The final remark says the argument is in the complex arithmetic model and explains that algebraic coefficients may be chosen in one number field. It does not state the all-characteristic/all-field 9/4 theorem.

Therefore “extends the recorded complex formal result” is supported as a repository-level statement. This review does not establish whether the extension is mathematically new, folklore, independently known, or already stated elsewhere. No claim about why the original authors chose a complex-only statement is warranted. README and VERIFICATION already disclaim historical novelty and author intent; preserve that qualification.

## Precise recommended adversarial tests for the root coordinator

1. Export committed `all-fields-proof-v1` sources into an isolated checkout; begin with no OAI build artifacts or harness links. Check source content equals that commit before and after the build. Rebuild `OAI.LinearAlgebra.MatrixMultiplication.AllFieldsAudit`.
2. Run Lean 4.34.1 `leanchecker --fresh` on the resulting auxiliary main/public target as supported by the installed checker. Record exact command, tool version, source commit, and distinction between independently checked OAI outputs and reused dependency artifacts.
3. Directly re-elaborate AllFieldsAudit after the target build so the guarded command checks are observed, not merely assumed from an up-to-date Lake target.
4. Include `#check @OAI.MatrixMultiplication.AuxiliarySeparation.exactRankExponent_le_nine_quarters_allFields` and `#print axioms` for it. Add a definitional check that the matrix tensor equals the original `Tensor.matrixCoefficients` and that `RankAtMost` is the displayed coefficient-array identity. This is especially useful for finite-field interpretation.
5. Negative test in a disposable external audit file: declare an extra axiom of the target proposition, define a theorem from that axiom, and place its `#print axioms` under an expected-standard-axioms `#guard_msgs`. Lean must fail. A separate `by sorry` version must report `sorryAx` and fail. Never alter the committed proof to run this test.
6. Check exact protected source hashes and dependency pin/patch deltas listed above. If bootstrap is exercised, require zero root manifest/toolchain diff afterward.
7. For finite-field scope, explicitly test or document the F_q identity-function counterexample X^q−X to prevent treating `Correct` as polynomial equality. Cite the exact-rank bound when making the stronger standard algebraic claim.

## Coverage limits

This is a trust/reproducibility/claims audit, not a complete mathematical reproof. The proof and specification reviewers handle detailed algebraic inference and asymptotic quantifiers. I did not run Lake, recompile dependencies, independently reconstruct the Mathlib cache, test a hostile compiler, inspect every downloaded toolchain binary, or establish historical novelty. Saved traces and clean source revisions reduce accidental mismatch risk but cannot by themselves prove source correspondence of every reused dependency olean. No external messages, publication, or repository changes were made.

## Dependency verifier produced on request

A read-only Python standard-library verifier was written outside the repository at `../adversarial-verify-dependencies.py`. It verifies the committed manifest, the audited upstream patch SHA-256, all ten package HEADs, clean indexes, absence of ordinary untracked files and ignored source overrides, absence of assume-unchanged/skip-worktree index flags, and exact allowed working deltas. It intentionally does not validate ignored generated `.lake` binaries.

Executed successfully against the canonical checkout with `python3 ../adversarial-verify-dependencies.py .`; all ten dependencies passed, including the exact fixed-point compatibility patch. Root can review and integrate it.
