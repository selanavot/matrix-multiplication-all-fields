# Research beyond the 9/4 bound

Status: exploratory research, begun 2026-10-08. No stronger exponent bound has
been established by this project. The existing theorem and paper remain the
verified baseline; this directory must not be imported by the public proof.

Baseline: repository `08481ef22bca7dc9ffba091083b7c1e81e537220`; original
construction from OpenAI's pinned `adc7f1241b42e322a6451854ab7e4b4c146bf78a`.

## What this research pass established

The most useful result is an explicit obstruction to improving the existing
scalar argument. For `u=min(a,b)` and `v=max(a,b)`, the function

$$P_*(a,b)=\left(\frac{3u-1}{2}\right)^{1/3}
                 \left(v+\frac{u-1}{2}\right)$$

satisfies every hypothesis of the current `ScalarProfile` at `t=3/4`.
This is a global mathematical example, not a finite numerical fit. It means
that optimizing those hypotheses alone cannot improve the resulting `9/4`
bound. **It is not a tensor character or a lower bound on omega.** The proof
and its independent AI review are in [profile.md](profile.md) and
[barriers.md](barriers.md). The new arguments have not been formalized in Lean,
and their historical novelty has not been established.

| Approach investigated | Result | Evidence and limits |
| --- | --- | --- |
| Sharpen the scalar growth argument | The explicit endpoint example rules this out under the existing hypotheses. | Global paper proof. |
| Increase the number of ordinary sectors | Dimension counting forces normalized shift at least `1/2`, the current value. | Global paper proof; exact support checks for 864 cases. |
| Couple differently oriented convolution factors | Found genuine finite degenerations, but no improvement; a shadow-box argument explains the obstruction for full coordinate boxes. | Exact integer certificates; the general barrier is proved on paper. |
| Use a dense periodic packing | A dimension-optimal packing exists, but an exact directed cycle obstructs monomial separation. | Saved packing and cycle certificate. Separately charging cancellation costs erases the hoped-for gain. |
| Change basis using diagonal polynomial filtrations | Obtained an all-characteristic family of direct-sum degenerations, including `C(2,2)^2 -> C(3,3) + 1`. | Paper proof and independent exact coefficient checks; still compatible with the endpoint example. |
| Extract other full convolution blocks | A stronger dimension-based barrier covers arbitrary changes of basis for consistently oriented source products and individual convolution target blocks. | Global paper proof, including a 525-term positive-coefficient certificate checked by two agents. It does not cover every orientation or product-valued target. |
| Encode matrix/vector and transposed-matrix/vector products together | The smallest mixed candidate fails an exact trace invariant; a separate Koszul-rank calculation obstructs a larger family of balanced coupled branches. | Paper proofs with exact rational/integer checks. The trace argument is over characteristic zero; the separate Koszul kernel is described over every field. |
| Couple binary and ternary polynomial multiplication | Derived a Koszul-filtration inequality connecting the two tensor families, then found an explicit global endpoint example satisfying it. | Paper construction and global analytic countermodel; this supersedes the exploratory finite numerical LP results. |
| Improve the exponent lower bound | No improvement. Audited the distinction between finite rank bounds, method barriers, and a true omega lower bound. | Primary references and explicit counterexamples in [barriers.md](barriers.md). |

The generalized scalar calculation gives a concrete target. If a valid new
sector construction achieved

$$kP(a,h)\le P(a,kh+c(a-1)),\qquad \rho=c/(k-1),$$

with the other hypotheses unchanged, its scalar endpoint would be
`t=(1+rho)/2`, corresponding to an upper bound `3(1+rho)/2` for omega.
Beating `9/4` requires `rho<1/2`; `rho=1/3` would give two. Ordinary disjoint
sectors cannot achieve that improvement. Values below `rho=1/3` would
contradict the established lower bound two under these premises.

## Surviving directions and next proof obligations

1. **Constructions outside the proved packing and Koszul-rank barriers.**
   Possibilities include different first-input subspaces, heterogeneous
   product branches, or new tensor families. Check the exact scopes in
   [constructions.md](constructions.md) before choosing a target: arbitrary
   changes of basis do not by themselves escape the newer rank obstruction.
   Do not identify a mixture of matrix/vector and transposed-matrix/vector
   products with ordinary rectangular multiplication without one common
   first-leg isomorphism.
2. **Further relations between genuinely different tensor families.** The
   ternary Koszul relation is a concrete starting point, but the explicit
   example `Q3(e,f)=(e+f+2)P_*(e+1,f+1)/2` satisfies all its tested conditions
   globally. Add a genuinely new product, filtration, or sector relation.
   Neither that example nor a numerically feasible table is a character on
   the full tensor semiring.
3. **A different lower-bound invariant.** A candidate must detect a fixed
   positive exponent gap beyond quadratic growth and satisfy the necessary
   multiplicative and additive properties. The existing checks reject the
   tempting geometric mean of flattening ranks as a character.

For an upper-bound candidate, first derive actual coefficient maps or a
degeneration, then test its inequality against `P_*`. Excluding this one
example would be progress, but would not itself exclude every endpoint
profile or prove a strict improvement in omega. Only a complete exponent
argument followed by a faithful formalization can justify changing the
public theorem.

## Reproduce the exact checks

Run from the repository root; these checks use only the Python standard
library and do not require Lean, SciPy, or saved solver output to be trusted:

```sh
python3 research/beyond-nine-quarters/verify_certificates.py
python3 research/beyond-nine-quarters/construction_checks.py
python3 research/beyond-nine-quarters/diagonal_filtration_check.py
python3 research/beyond-nine-quarters/profile_product_certificate.py
python3 research/beyond-nine-quarters/profile_filtration.py
python3 research/beyond-nine-quarters/construction_pencil_check.py
```

`verify_certificates.py` independently reconstructs the selected supports,
checks all retained and erased edge weights in the saved packing certificates,
checks the periodic obstruction, and rejects a deliberately corrupted
potential assignment. It does not import the search implementation or accept
solver-reported optimality as a proof. `diagonal_filtration_check.py` checks
integral basis inversion and every coefficient of 704 offset degenerations
for dimensions at most four. The scripts print the exact scope of each run.

The optional searches use Python 3.12.14, NumPy 2.5.3, and SciPy 1.18.1 in the
recorded run. Keep their environment outside the repository:

```sh
python3 -m venv ../omega-research-venv
../omega-research-venv/bin/python -m pip install -r research/beyond-nine-quarters/requirements-search.txt
../omega-research-venv/bin/python research/beyond-nine-quarters/construction_acyclic_packing.py --a 2 --h 2 --H 7 --all-orientations --seconds 12
```

See [constructions.md](constructions.md) and [barriers.md](barriers.md) for
the other search commands and numerical scopes. MILP optimality and floating
LP feasibility remain numerical evidence; only the separately checked finite
support certificates are exact. None of these commands builds or verifies a
new Lean theorem.

## Questions and ownership

- `profile.md`: sharpness of the scalar-profile argument, possible stronger
  consequences, and extremal examples. Owned by profile agent.
- `constructions.md`: improved sector/separation constructions and alternative
  tensor routes. Owned by construction agent.
- `barriers.md`: lower bounds, model distinctions, and adversarial constraints.
  Owned by barriers agent.
- Coordinator: integrate evidence, run independent experiments, and record
  surviving conjectures and next proof obligations in this README.

## Evidence rules

Label every result as proved on paper, Lean-checked, exact computational
certificate, numerical evidence, conjecture, or refuted. Record counterexamples
and dead ends. A finite search or floating-point optimization is not a theorem.
An example satisfying profile inequalities is not automatically a tensor
character. A lower bound for one technique is not a lower bound on omega.

Agents keep their findings in their owned files before concluding. Any scripts
must have reproducible commands and bounded defaults. Only the coordinator
starts Lean builds. Do not modify the protected model, main theorem, dependency
pins, or published paper while exploring. No new axioms or unfinished proofs may
enter the public theorem import closure. No external messages or publication
claims; open a research PR for review, with no merge absent specific approval.
