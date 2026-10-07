# Comparator verification

The current six-theorem harness uses the `lake comparator` bundled with Lean
4.35.0-rc2. `comparator.json` at repository root is identical to
`verification/comparator/config.json`; neither allows definition holes or
axioms beyond `propext`, `Classical.choice` and `Quot.sound`.

The independently compiled Challenge contains the exact module-only port of
OpenAI's original arithmetic model. `scripts/check-specification.py` compares
it with the immutable baseline. The Solution imports the actual all-fields
proof and proves these same six declarations:

1. `omega_bound`: the all-fields arithmetic exponent bound.
2. `admissible_bddBelow`: the admissible set is bounded below.
3. `admissible_nonempty`: the admissible set is nonempty.
4. `omega_lower`: the exponent is at least two.
5. `epsilon_cost`: one constant bounds correct programs at all positive sizes.
6. `exact_coefficients`: exact rank-one coordinate identities, including finite fields.

The final statement avoids importing any project-specific tensor definitions
into the Challenge. It explicitly states the matrix multiplication tensor
coordinates and their finite rank-one decomposition, with arbitrary positive
exponent slack.

## Reproduction

After bootstrap, run sequentially from repository root:

```sh
python3 scripts/check-specification.py
python3 scripts/check-comparator.py --trusted-local --negative-controls
```

The local command disables the native build sandbox and is for trusted source
only. It requests the independent checkers bundled with the selected Lean
toolchain. Its negative controls require rejection of an altered multiplication
cost and of a solution replaced with `sorry`.

For the full Linux sandbox, protected Challenge provenance audit, and Palomar's
selected independent kernels, use the pinned full workflow described in
[the submission guide](../../docs/palomar/README.md). A local run is not a
substitute for that workflow.

## Historical verification

The successful five-theorem Lean 4.34.1 run, exact old tool pins, negative
controls, and verification limits are preserved in
[historical-4341.md](historical-4341.md) and [result.txt](result.txt). They apply
to their named old snapshots, not automatically to the present compatibility
port. The current Palomar preflight status is recorded in the submission guide.
