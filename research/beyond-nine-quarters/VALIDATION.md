# Research checkpoint validation

Date: 2026-10-08. These checks concern exploratory research outside the public
Lean proof. No improved bound on omega has been established, and no new Lean
theorem was compiled. AI agents supplied the mathematical derivations and
adversarial reviews; this is not a record of human peer review.

The coordinator independently replayed these commands from the repository root:

| Command under `research/beyond-nine-quarters/` | Result |
| --- | --- |
| `python3 verify_certificates.py` | All 12 saved finite packing certificates pass independent support/weight verification; the periodic cover and its three-cycle pass; a corrupt potential assignment is rejected. |
| `python3 construction_checks.py` | 864 odd-sector cases and 18,432 rational shadow-interval cases pass; 24 periodic branches, four correction-slice ranks of 48, and the three cycle edges pass. |
| `python3 diagonal_filtration_check.py` | 784 integral basis inverse checks, 256 dimension quadruples, 704 offset degenerations, and 12,932 nonzero source coefficients pass. |
| `python3 profile_product_certificate.py` | Exact crossed-product expansion has 525 positive coefficients, minimum 256, and zero constant term. A separate agent independently reproduced the expansion. |
| `python3 profile_filtration.py` | Default sizes 1 through 12: 166,464 interval-certified inequalities, zero violations, zero undecided cases. The subsequent global proof supersedes the finite search. |
| `python3 construction_pencil_check.py` | Exact source quartic trace is -2; all eight ordered target orientations give 0; normalized source algebra has dimension 36. |
| `python3 construction_koszul_check.py --max-width 10` | Source ranks 8, 20, 38, 62, 92, 128, 170, 218, 272, 332; all-field kernel-label checks pass. Four width-two target orientations have ranks 15, 20, 20, 20 and weighted cost 50 each. |
| `python barrier_koszul_lp.py --grid 24` in the optional search environment | Numerical feasibility, 325 variables and 1,175 inequalities; residual approximately `1.41e-11`. The explicit global ternary countermodel supersedes this numerical result. |

The profile agent also reported the optional size-32 filtration scan:
22,380,544 interval certificates, no violations, no undecided cases. The
coordinator did not repeat that larger scan after the global proof was found.
The numerical search environment used Python 3.12.14, NumPy 2.5.3, and SciPy
1.18.1. See `requirements-search.txt`.

The ordinary-sector, endpoint-profile, convolution-product, diagonal-filtration,
ternary-countermodel, and explicit Koszul-kernel arguments are written proofs.
Finite checks validate concrete instances and implementations; they do not
replace the universal arguments. Saved MILP statuses are numerical claims of
optimality, not exact upper-bound certificates. The independent verifier only
certifies the returned constructions and stated cycle obstruction.

All changes in this checkpoint are under `research/beyond-nine-quarters/`.
The arithmetic model, theorem statements, Lean source, dependency pins, and
published paper are unchanged.
