# Matrix multiplication over arbitrary fields

> Operating instructions for the AI coding agents that developed this fork.
> They are kept in the public repository for transparency about how the work
> was produced.

## Objective and trusted specification

Extend OpenAI's matrix-multiplication `9/4` proof to the theorem

```lean
theorem omega_le_nine_quarters (F : Type u) [Field F] :
    OAI.MatrixMultiplication.Arithmetic.omega F ≤ (9 : ℝ) / 4
```

Use the repository's existing arithmetic-program and `Arithmetic.omega`
definitions. Do not weaken correctness, redefine the exponent to make the
conclusion trivial, introduce new axioms, or finish with `sorry`/`admit`.
Keep the original complex theorem available as a specialization.

The public baseline is `openai/math` commit
`adc7f1241b42e322a6451854ab7e4b4c146bf78a`. The proof family is
`lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation`.
The user wants a comprehensible diff against that baseline.

## Publication and version control

- The repository `selanavot/matrix-multiplication-all-fields` is public.
  Everything committed or written in PR descriptions is publicly visible.
  Never push to OpenAI's upstream repository or open an upstream OpenAI PR
  for this work without new explicit user authorization.
- Preserve an upstream baseline commit and use a separate work branch.
- Save meaningful work in commits. Label incomplete checkpoints honestly;
  a source checkpoint is not a verified theorem.
- Open/update a PR in this repository before calling the work
  complete. The user explicitly authorizes merging development PRs;
  merge verified checkpoints when useful, retaining the upstream baseline.
- Do not commit downloaded toolchains, dependency checkouts, build caches,
  credentials, machine-specific paths, or large generated logs.

## Restart procedure

1. Read this file, `README.md`, and `docs/field-port/VERIFICATION.md`.
2. Inspect `git status`, the latest commits, and the active branch. Preserve
   other agents' uncommitted work.
3. Check the current build environment and last successful target. Treat
   notes as a starting point; verify source and compiler output before
   claiming success.
4. Continue the active task, rather than restarting the proof audit or
   replacing the accepted mathematical approach.

## Proof approach

For each arbitrary field `F`, work over its own `AlgebraicClosure F`. This
is infinite; it is not one field containing all characteristics.

1. Generalize the concrete tensors, characters, rank exponent, and spectral
   argument to a scalar field parameter.
2. Choose the Fourier period as `5*M` if its cast is nonzero and `5*M+1`
   otherwise. Its cast is nonzero and the period is at most `6*M`.
3. Use arbitrary distinct nonzero interpolation nodes in an infinite field.
4. Prove the `9/4` exact-rank bound over algebraically closed fields.
5. Descend a fixed finite rank scheme and all its tensor powers through
   its finite coefficient algebra. The fixed dimension-squared overhead
   disappears at the exponent level.
6. Use the generic exact-rank-to-arithmetic bridge for the unchanged
   `Arithmetic.omega` definition.

Do not descend a single block with extra rank cost and recursively compose
that descended block: that would charge the extension overhead at every
recursion level. Descend all powers with one fixed coefficient algebra.

## Collaboration and durable progress

- Coordinate file ownership before editing shared files. All agents use one
  shared checkout and branch; do not revert or reset another agent's work.
- Record verified facts separately from drafted/uncompiled statements.
- Prefer focused `lake build <module>` checks; once dependencies compile,
  build the final theorem and inspect `#print axioms` for its declaration.
- Run `bash scripts/check-proof.sh` for the complete public theorem and
  specification/dependency/axiom audit. `bash scripts/check-kernel.sh` adds
  fresh-environment replay using Lean's own kernel. Only the root coordinator
  starts Lake builds or kernel replay;
  concurrent builds against shared artifacts previously caused contention
  and transient missing-olean errors. Source editing can remain parallel.
- The scripts default `LEAN_NUM_THREADS=1`, honoring explicit overrides. Use
  the same setting for direct builds on this 24 GB host: unrestricted builds
  spawned nine whole-Mathlib import workers and exhausted available memory
  during the adversarial audit. Two workers still ran close to the host's
  available memory, so subsequent verification uses one. Completed modules
  survive an interrupted build.
- An isolated audit checkout may reuse verified pinned dependency caches, but
  must start with no OAI build outputs. Record the exact source commit, compare
  it before and after compilation, and distinguish this from rebuilding Lean
  and all dependencies from source. Only the coordinator may run such a build.
- For finite fields, do not conflate `MatrixAlgorithm.Correct` (equality on
  field-valued inputs) with formal polynomial equality. Use the separate exact
  coefficient-rank theorem when explaining the stronger algebraic guarantee.

The user authorizes installing tools needed for this proof. Lean 4.34.1 is
installed. Use the exact dependency pins recorded in the project manifest;
do not silently upgrade them. No brain icons or graphics in project output.
