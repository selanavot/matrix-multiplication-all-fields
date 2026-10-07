# Palomar submission preparation

This package records the extension of OpenAI's 9/4 complex-field construction
and proof to arbitrary fields. It does not claim priority for the numerical
bound or for field-independence techniques. The repository contains the
substantive development, and Sela Navot is its responsible maintainer.

## Exact submission paths

- Repository: `selanavot/matrix-multiplication-all-fields`
- Project directory: repository root (leave `project_path` blank)
- Comparator configuration: `comparator.json`
- Metadata: `formalization.yaml`
- Challenge: `lean/ComparatorAudit/Challenge.lean`
- Solution: `lean/ComparatorAudit/Solution.lean`
- Commit: use the full 40-character SHA of a pushed, successfully checked snapshot.

No Palomar intake or registration has been requested by this preparation work.
The final snapshot must pass the complete pinned Palomar workflow before intake.

## Recorded claims

The Challenge imports only Mathlib. Its arithmetic model is the exact
module-system port of OpenAI's original `Model.lean`; the comparator checks the
Solution against these separately compiled definitions. There are no definition
holes. All proved claims allow only `propext`, `Classical.choice`, and `Quot.sound`.

1. `omega_bound`: the arithmetic exponent over every field is at most 9/4.
2. `admissible_bddBelow`: the defining set is bounded below.
3. `admissible_nonempty`: the defining set is nonempty.
4. `omega_lower`: the arithmetic exponent is at least two.
5. `epsilon_cost`: for every positive epsilon, one positive constant bounds the
   cost of correct programs at every positive matrix size by `C n^(9/4 + ε)`.
6. `exact_coefficients`: for every positive epsilon, there is a block size at
   least two with an exact rank-one coefficient decomposition of at most
   `n^(9/4 + ε)` terms.

The last statement spells out every tensor coordinate using only field
operations, finite sums, and equality. Over finite fields it is stronger than
the program model's functional correctness predicate. It certifies algebraic
identities, rather than relying on coincidences such as `x² = x` on F₂. It does
not claim an effective uniform generator, a bit-complexity bound, practical
constants, or the exact exponent. The README explains the field-dependent
Fourier period, interpolation nodes and fixed-coefficient-algebra descent.

## Compatibility port and trust boundary

Palomar's current minimum is Lean 4.35.0-rc2. This branch pins that toolchain and
Mathlib release commit `065356127b1dc0016f66b7283ce0ce2c4055aa55`. All repository
Lean sources use `module`; legacy imports and declarations remain public and
definition bodies remain exposed. `scripts/check-specification.py` compares the
eleven protected upstream files and the frozen Challenge model with an exact,
deterministic module-only transformation of the immutable baseline. It does not
ignore arbitrary source changes or weaken the mathematical definitions.

Outside those protected files, the port also makes proof helpers used inside
exposed definitions public, supplies an ordered-sum import explicitly, and
uses Mathlib's public entropy rewrite lemmas in place of unfolding hidden
implementation bodies. These are compatibility changes to proofs and module
interfaces, not changes to the six stated claims.
The vendored Brouwer proof also passes an existing equality hypothesis explicitly
to two rewrites, as recorded in `UPSTREAM.md`.

The five MIT-licensed Brouwer modules previously supplied by a runtime-patched
Git dependency are vendored in `lean/FixedPointTheorems`. This lets a clean,
network-isolated Palomar build consume the actual patched sources without a
post-update hook. Their MIT notice is preserved. The historical patch remains
under `lean/patches` as a provenance artifact; it is no longer applied at build
time. Third-party caches and compiled artifacts are not committed.

## Verification

Run the ordinary checks sequentially from the repository root:

```sh
bash scripts/bootstrap.sh
bash scripts/check-proof.sh
bash scripts/check-kernel.sh
python3 scripts/check-comparator.py --trusted-local --negative-controls
```

The local Comparator command trusts source/build code. Palomar's Linux sandbox,
protected statement build, dependency provenance audit and independent kernels
are checked by `.github/workflows/palomar.yml`, using the complete reusable
Palomar workflow in `mode: full`, pinned to pipeline commit
`d4e41c1d5b0d114c4859e6e5831dc6d3ad1d0d44`. A local build alone is not a passing
Palomar preflight. Inspect the uploaded mechanical report and require
`status: pass` for the exact source SHA before requesting intake.

Before the full reusable verifier, the workflow runs the ordinary build,
fresh-environment replay and native Comparator rejection controls on a separate
clean Linux runner. Its complete compiler log makes compatibility failures
visible even when they fall outside Palomar's bounded report tail. This job
does not replace the full sandboxed Palomar verification.

The PR checks and uploaded mechanical report are the authority for the current
candidate: require `status: pass` bound to the exact submitted source SHA.
Historical successful checks in `docs/field-port/VERIFICATION.md` apply only to
the earlier pinned snapshots, not automatically to this compatibility port.

## Submission and registration

Before intake, show Sela the exact source SHA, repository, configuration path,
and proposed relationship `maintainer`, and obtain agreement to that submission.
Use Palomar's documented agent protocol at
<https://submit.palomar-registry.org/llms.txt>; do not automate its browser OAuth.
After review, show Sela the review and explain the permanent public record, then
obtain an explicit instruction before registration. A passing mechanical
preflight or automated review is not human peer review or endorsement.
