# Comparator verification

This harness checks the existing all-fields proof against a separately frozen
specification using [Lean Comparator](https://github.com/leanprover/comparator).
It does not change the matrix multiplication model or proof.

## Challenge and trust boundary

[`Challenge.lean`](../../lean/ComparatorAudit/Challenge.lean) starts with an exact
copy of OpenAI's `Model.lean`, taken from the immutable extracted baseline
`d2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653`. It imports only Mathlib and appends five
theorem statements. Its deliberate `sorry` proofs are challenge placeholders;
this module must never be imported into OAI or the solution.

[`Solution.lean`](../../lean/ComparatorAudit/Solution.lean) imports the actual
auxiliary all-fields theorem and proves the same five statements:

1. For every field in every universe, `omega F ≤ 9/4`.
2. The set of admissible exponents is bounded below.
3. That set is nonempty.
4. `2 ≤ omega F`.
5. For every positive ε, one positive constant works for correct arithmetic
   programs at all positive matrix sizes, with cost at most `C n^(9/4 + ε)`.

Comparator builds and exports the two modules separately, compares the theorem
statements and the declarations they depend on, audits the solution's axiom
dependencies, and replays the exported solution through Lean's kernel. There
are **no definition holes**. Only `propext`, `Classical.choice`, and `Quot.sound`
are permitted. The runner also compares both the frozen and working model
with the baseline and checks the project's dependency pins and patch.

The runner checks the frozen challenge's hash before and after verification.
This is a reproducible check against a reviewable specification, not a proof
that the specification captures every desired informal interpretation.

## Reproduction

First bootstrap the normal proof project as documented in the root README.
Git, Python 3, elan, and the pinned Lean toolchain must be available.
The runner downloads and builds the pinned Comparator sources if missing:

```sh
python3 scripts/check-comparator.py --trusted-local --negative-controls
```

**`--trusted-local` deliberately uses upstream's development runner without a
build sandbox.** It is appropriate only when the source and build environment
are trusted. This mode is available on macOS. It still performs Comparator's
statement/definition comparison, axiom checks, and Lean-kernel replay, but
does not provide Linux hostile-build isolation. No independent kernel is
configured.

The default tool directory is `lean/.lake/comparator-tool`; optionally pass
`--comparator-dir /path/to/comparator` to use an existing clean checkout at
the required pin. No toolchains or generated binaries are committed.

For Linux, install the genuine `landrun` described in Comparator's README and
follow its systemd restriction. A corresponding invocation is:

```sh
systemd-run --property=RestrictAddressFamilies=~AF_UNIX --user --pty \
  -E PATH="$PATH" --working-directory "$PWD" -- \
  python3 scripts/check-comparator.py --negative-controls
```

The Linux invocation is provided for reproduction; the local macOS run does
not establish that this Linux deployment has been tested. In trusted local
mode, proof targets are prebuilt with one worker before Comparator runs its
cached build steps. Linux mode leaves those builds to Landrun; upstream
Comparator does not forward `LEAN_NUM_THREADS` into that sandbox.

## Pins

Machine-readable pins are in [`pins.json`](pins.json):

| Component | Revision |
| --- | --- |
| Comparator | `d03acab154d269c06e60e4de7e4cc85deebff94b` |
| lean4export | `076e8e57707e813375e8f9da8bf989799ace9680` |
| Build and proof toolchain | `leanprover/lean4:v4.34.1` |

The pinned upstream Comparator checkout specifies Lean 4.34.0. The runner
explicitly overrides that selection with the proof project's Lean 4.34.1
when building both the checker and exporter; it does not edit their sources
or update dependency revisions. The project toolchain remains unchanged.

## Negative controls

With `--negative-controls`, the runner generates separate, ignored modules
and requires Comparator to reject both:

- A challenge in which multiplication costs zero rather than one. The real
  solution must fail on a `Gate.cost` definition mismatch.
- A solution in which the explicit cost theorem's proof is replaced by
  `sorry`. It must fail for the forbidden `sorryAx` dependency.

These controls use the actual model and theorem wrappers. They do not modify
the real challenge, solution, or proof. Their sources are removed afterwards;
diagnostic logs are left under `lean/.lake/`.

## Recorded outcome

Verification is in progress. No successful Comparator result is recorded yet.
