# Construction search beyond nine quarters

Status: exploratory results and proved-on-paper barriers, not a new matrix-multiplication exponent theorem. No Lean theorem or trusted specification was changed. Primary sources are the current repository's `Sector/Weights.lean`, `Sector/Character.lean`, `Determinant/Character.lean`, and `Tensor/TagInequality.lean` under `lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/`. The source commit for this research pass is recorded by the coordinator.

## 1. More ordinary sectors cannot improve the affine shift

Write A=a−1. Suppose C(a,H) retains k copies of C(a,h), sharing its full first-input space, with disjoint second- and third-leg coordinate spaces. Let f copies preserve the outer legs and b exchange them, f+b=k. Counting dimensions on the two disjoint legs gives

- H ≥ kh+bA;
- H+A ≥ kh+fA.

Therefore H≥kh+max(b,f−1)A. For odd k the smallest possible coefficient is (k−1)/2; for even k it is k/2. The effective affine shift c/(k−1) is consequently at least 1/2. This is exactly the shift already attained by three sectors, and merely increasing their number cannot improve it.

The same argument holds for unequal widths h_i, replacing kh by Σh_i. These are dimension bounds for disjoint full convolution blocks; they do not rule out other tensors, cancellations, or overlapping coordinate descriptions.

There is an explicit matching construction for every odd k=2s+1. Concatenate alternating forward/exchanged branches. Their Y lengths alternate h,h+A,h,...,h; their Z lengths alternate h+A,h,h+A,...,h+A. Put weight 1 on odd Y blocks, −1 on odd Z blocks, and 0 elsewhere. Every original convolution support term has weight 0 or 1; weight zero means that its two block labels match. The retained blocks are k convolution copies, alternately exchanged, with H=kh+sA. This recovers the optimal dimension count, not a better shift.

`python3 research/beyond-nine-quarters/construction_checks.py` verifies exact support and weights for 864 parameter triples, a,h=1..12 and k=1,3,5,7,9,11. The accompanying general proof is the interval argument above; the finite check is a check on its implementation, not its universal proof.

The endpoint scalar profile established in `profile.md` satisfies every such dilation, including heterogeneous widths by concavity. Merely retaining separate character permutations also does not remove that witness.

## 2. A genuinely different attempt: couple two convolution factors

Consider

S_H = C(a,H) ⊗ C(a,H)^(23),

with actual common first-input coordinates (i1,i2), Y rectangle H×(H+A), and Z rectangle (H+A)×H. Its integer support equation is

z1 = y1+i1, z2 = y2−i2, 0≤i1,i2<a.

Try to extract multiple full product branches C(a,h)⊗C(a,h)^(23), allowing either orientation independently in each factor. This is a coupled packing problem, not necessarily a tensor product of two one-dimensional sector arrangements.

For the two balanced orientations FF and BB, each branch consumes h(h+A) coordinates in each leg. Pure dimensions allow up to H(H+A)/(h(h+A)) branches. This exceeds the square of the old affine ratio, ((H+A/2)/(h+A/2))². If this better capacity were attained by suitable degenerations uniformly over growing parameters, it would suggest a row cap sqrt(h(h+A))g(a); its diagonal coefficient sqrt(2), versus the original 3/2, would lead to the hypothetical target 3/sqrt(2)≈2.1213. **None of that stronger degeneration has been established.** A finite packing alone would also not establish the required uniform asymptotic statement.

### Exact packing and its failure as a degeneration

An exact-cover search found a periodic 12×12 packing at a=h=2 with 24 balanced branches, attaining the dimension capacity on the periodic grid. Its complete coordinates are in `construction_mixed_result.json`. Repeating it and discarding the boundary gives finite integer-coordinate packings with density 1/6; only O(H) branches are lost at a boundary of a square of side H, while the total is Θ(H²). This is a packing fact, not a restriction or degeneration.

The finite lift contains this directed interaction cycle:

BB(1,5) → BB(3,7) → FF(1,7) → BB(1,5).

The cross-branch source-support triples (X,Y,Z) are

- ((1,0),(3,6),(4,6));
- ((0,0),(3,7),(3,7));
- ((1,1),(1,7),(2,6)).

For a=h=2, keeping a complete branch forces first-leg weights to obey α11+α00=α10+α01, so they are affine in the two first indices. Gauge away these affine weights using the support equations. Connectivity inside each retained branch then makes its Y weights a constant c_B and its Z weights −c_B. A cross edge B→D has weight c_B−c_D. Every erased cross edge must have strictly positive weight; the displayed cycle would demand c_1>c_2>c_3>c_1. Thus this optimal-density packing cannot be obtained by a coordinate monomial degeneration.

A simpler two-cycle occurs at a=2,h=1 for FF origins (0,1) and (1,0). Keeping the full branch forces the same four-entry first-leg relation, while the two unwanted cross weights sum to zero. Nonnegative weights cannot erase both.

### Actual, exactly checked coupled degenerations

`construction_acyclic_packing.py` searches for disjoint boxes whose interaction graph is acyclic. It uses SciPy/HiGHS only to propose a packing; its returned support and topological integer weights are then checked with exact Python integer arithmetic. Set first-leg weights to zero, branch Y weights to their topological potentials, and branch Z weights to their negatives. Unused coordinates can receive a common sufficiently large positive weight. This gives a genuine finite monomial degeneration certificate.

The initial search restricted to FF/BB. Results are in `construction_acyclic_results.json`; at a=h=2 and H=5,7,8,10,12 it finds 4,6,9,13,20 balanced branches. This restriction omits homogeneous orientations, so those numbers are not upper bounds for all product branches.

The corrected search permits all four orientations FF,FB,BF,BB. Each factor permutation has the same sixfold symmetrized profile, so all four are relevant. Results are in `construction_all_orientations_results.json`. In particular a=h=2,H=7 recovers nine branches, the required product-of-tripling sanity check. No tested instance improved the endpoint profile ratio. Reported solver optima are numerical solver results, not independently certified exact upper bounds.

Example invocation (use a Python environment containing SciPy and NumPy):

```sh
python research/beyond-nine-quarters/construction_acyclic_packing.py --a 2 --h 2 --H 7 --all-orientations --seconds 12
```

## 3. A geometric barrier for these coupled monomial packings

The following argument explains the failure and applies to any number m of factors.

**Scope.** a≥2,h≥2. The source is a product of m copies of C(a,H), with any fixed outer-leg orientation in each factor. Retained branches are full products of C(a,h), allow independent outer-leg exchanges and first-index reversals, and use translated axis-aligned Y/Z boxes. The degeneration rescales actual coordinates by monomials; arbitrary non-diagonal basis changes and general polynomial restrictions are outside this claim.

In one positively oriented coordinate, a forward branch at integer origin s has half-open unit-cell intervals

Y_F=[s,s+h), Z_F=[s,s+h+A),

and a backward branch has

Y_B=[s,s+h+A), Z_B=[s+A,s+A+h).

Associate to a branch the Minkowski average (Y+Z)/2. Both orientations give an interval of length h+A/2. The source average is [0,H+A/2). For negative source orientation exchange Y and Z; the conclusion is identical.

If two shadow intervals overlap in their interiors, source support permits cross edges in both directions. This assertion includes integer endpoint effects. With one origin 0 and the other d:

- same orientations have both cross edges whenever |d|≤h+A−1;
- F followed by B has both whenever −h−A+1≤d≤h−1;
- B followed by F is the reversed condition.

For F/B, shadow-center displacement is d+A/2, and interior overlap implies precisely these integer inequalities. For matching orientations interior overlap is a stronger condition than the displayed cross-edge condition. `construction_checks.py` checks the implication using exact fractions in 18,432 cases, covering a=2..9,h=1..9, both orientations and all relevant origin displacements.

In m dimensions, shadow boxes all have volume (h+A/2)^m and lie in a box of volume (H+A/2)^m. If two shadow interiors overlap, the independent coordinate support equations provide cross edges in both directions between the full tensor branches.

Keeping one full convolution-product branch with h≥2 forces first-index weights to be affine in each coordinate: adjacent convolution terms identify all first-index differences, and the product equations identify the differences independently of the other first indices. Reversing indices preserves this property. Gauge these affine terms away. Branch connectivity again leaves one scalar potential per branch, so a pair of opposite cross edges cannot both be erased.

Consequently the shadow interiors must be disjoint, and

N (h+A/2)^m ≤ (H+A/2)^m.

An independent audit also extends the shadow-volume bound to fixed coordinate-dependent first widths a_j and branch-dependent second widths h_(B,j)≥2: sum_B product_j(h_(B,j)+(a_j−1)/2)≤product_j(H_j+(a_j−1)/2). This does not automatically cover branch-dependent first widths, because the common full first-input space and the affinity argument may be lost.

This exactly reproduces the old scalar-profile ratio. Axis-aligned coordinate monomial packing of full product branches cannot beat it, even when the factor packings are coupled and any of the 2^m orientations is allowed. This is a barrier for this specified candidate construction class, not a lower bound on omega, nor a barrier for all tensor methods.

## 4. Testing additive cancellation of the unwanted cross terms

Could one keep the periodic packing and subtract a correction tensor C of cross edges? Character subadditivity gives χ(retained)≤χ(source)+χ(C), since tensor addition is a restriction of direct sum. The correction cannot be charged as zero.

For the a=h=2 periodic packing, each fixed first input selects a partial permutation matrix. In a 12×12 periodic cell the source slice has 144 entries and the retained 24 branches have 24·h²=96 entries. The correction slice has 48 entries, hence rank 48. In a finite lift of side H, the slice rank is H²/3+O(H). Specializing the first input therefore proves

χ(C) ≥ (H²/3+O(H))^(p_X).

At the symmetric endpoint assignment p_X=3/4 and χ(C(2,2))=5/2, the proposed retained side has leading coefficient (25/4)/6^(3/4)≈1.630, while the source endpoint profile has coefficient sqrt(5/2)≈1.581. The hoped-for surplus is only about 0.049 times H^(3/2). The correction already has a lower coefficient 3^(−3/4)≈0.439, much larger. Thus the direct additive-correction inequality is compatible with the endpoint witness and cannot exploit this packing's dimensional surplus.

This does not prohibit cancellations internal to a new polynomial degeneration. A genuinely different next test is to seek a non-diagonal pencil/filtration construction that cancels cross terms without separately charging a correction tensor. Such a construction must give explicit linear maps or polynomial coefficients, preserve the common first-input space, and pass exact coefficient checking. Merely exhibiting a dense support packing or a low count of named correction tensors is insufficient.

## Reproduction and limitations

- `construction_checks.py`: standard library only, exact arithmetic.
- `construction_mixed_packing.py`: standard library exact cover and interaction-cycle checks. Its torus helper certifies a periodic packing only.
- `construction_mixed_result.json`: complete periodic packing and finite-lift cycle coordinates.
- `construction_acyclic_packing.py`: SciPy MILP proposal plus exact support/weight verification.
- `construction_acyclic_results.json`: two-orientation experiments.
- `construction_all_orientations_results.json`: corrected four-orientation experiments.

The shadow proof and odd-sector construction are written mathematical arguments, not Lean formalizations. Solver-reported optimality is numerical. Exact finite support certificates are verified independently of solver tolerances. No improved upper or lower bound on omega is claimed.

## Independent audit of the diagonal-filtration candidate

The coordinator's `diagonal_filtration_check.py` and the profile agent's new polynomial-filtration construction were independently inspected. The proposed degeneration of C(a,b)⊗C(c,d) retains a direct sum of

C(a+c−2r−1, b+d−2(r+ell)−1),

where 0≤r<min(a,c) and 0≤r+ell<min(b,d). This statement is a degeneration, not an equality of the original tensors. The argument passes the following mathematical checks:

1. In the space of bivariate polynomials with separate degree bounds <u,<v, divisibility by (x−y)^r reduces both degree bounds by r. The relevant leading coefficients are ±1. Thus this works over every field, including small positive characteristic.
2. Diagonal substitution on the reduced rectangle surjects onto all univariate monomials of degree <u+v−2r−1. Its kernel is the next filtration step. Choosing one monomial lift of each diagonal degree and multiplying it by (x−y)^r gives an integral basis with an integral inverse. Vanishing binomial coefficients modulo p do not threaten invertibility: the construction is unimodular over the integers.
3. Multiplication takes filtration orders r,s to order at least r+s, with leading diagonal coefficient exactly the ordinary convolution coefficient. The checker expands the product in the output basis; this computes the inverse output-basis map, as required for the dual third tensor leg. Applying the output basis itself would have been wrong.
4. With output order n, the total exponent L(n−r−s)+2r²+2(s−ell)²−(n−ell)² equals (r−s+ell)² at n=r+s. For n>r+s, L=4(min(U,V)+|ell|+1)² strictly dominates the possible negative quadratic term. Hence exactly n=r+s,s=r+ell survives.
5. Individual first/second/third-leg weights may be negative. To obtain polynomial coordinate maps rather than Laurent maps, shift each finite leg's weights upward by a constant. This introduces one common nonnegative leading order and preserves precisely the intended leading tensor. The formalization must retain that leading-order convention.
6. For fixed ell, n=2r+ell is injective in r, and the first and second filtration labels are also distinct. Consequently the retained components form a genuine direct sum on all three legs, rather than merely a shared-input collection.

No characteristic-zero representation-theoretic decomposition or division by factorials is needed. This audit supports the degeneration, but does not assert that its resulting inequality improves omega.

## One restricted finite nonmonomial candidate ruled out by a known lower bound

At a=2,h=1,H=2, consider the specific target of three **identically oriented FF branches**, all sharing the same actual first-input coordinates X_(i,j). One such branch has coefficient equation Σ_(i,j) X_(i,j)Y_j Z_i, so three FF branches give exactly the matrix multiplication tensor M_<2,2,3>. Three BB branches also give that tensor after one global first-leg transpose and suitable outer-leg reversals. The source C(2,2)⊗C(2,2)^(23) has tensor rank at most 3²=9 by evaluation/interpolation.

Conner, Harper, and Landsberg prove that the border rank of M_<2,2,3> over the complex numbers is 10: [New lower bounds for matrix multiplication and the 3x3 determinant, arXiv:1911.07981](https://arxiv.org/abs/1911.07981). Therefore this nine-rank source cannot degenerate to the target of three FF branches (or three BB branches), even with arbitrary non-diagonal coordinate maps or polynomial cancellations.

**This rejection does not cover mixed FF/BB targets.** After outer-leg coordinate reversals, an FF branch computes Xy while a BB branch computes X^T y. Exchanging i and j on the common first leg transforms all branches simultaneously and cannot independently align their orientations. We have not established a global tensor isomorphism from a mixed collection to M_<2,2,3>. Applying the cited border-rank theorem to that mixed target would therefore be unjustified. The earlier monomial shadow/cycle obstructions have their separate stated scopes.

This is a cited existing complex border-rank result for one restricted finite target, not a new lower bound on omega, and no positive-characteristic extension of the cited lower bound is asserted here.

## Mixed-target pencil obstruction: exact fixed-first-leg result

The smallest mixed target remains different from M_<2,2,3>, but it can be tested directly. Let S(X) be the 6×6 matrix pencil of C(2,2)⊗C(2,2)^(23), with rows Z=(k1,k2), columns Y=(j1,j2), and coefficient X_(k1−j1,j2−k2) when both indices are 0 or 1. The source determinant is −det(X)^3. Normalize at X=I2:

A_ij = S(I2)^(-1) S(E_ij).

`construction_pencil_check.py` computes these matrices over exact rational numbers. It finds

tr(A_01² A_10²) = −2.

For every target diag(X,...,X,X^T,...,X^T) with three total blocks, the normalized off-diagonal matrices square to zero on each block, so the same trace is 0. This includes the unresolved-by-M223-identification mixture of two forward and one transposed branch.

Under invertible changes S(X)↦U S(X)V on the two outer legs, the normalized matrices change by simultaneous conjugacy: A_ij↦V^(-1)A_ij V. The trace is unchanged. If a polynomial degeneration preserves the actual common first-leg variables and its limit has an invertible I2 slice, normalization and this trace are regular at the limit. Therefore no such degeneration of S can yield any of the three-block mixed targets over characteristic zero.

Independently, the exact associative algebra generated by the normalized A_ij has dimension 36, the full matrix algebra. The code supplies 36 independent matrix words. Thus there is no proper common invariant flag giving a block-diagonal target by ordinary semisimplification. This algebra calculation is additional evidence; the displayed trace already supplies the simple fixed-first-leg obstruction.

Complete exact matrices, words, and all eight ordered orientation targets are in `construction_pencil_result.json`. The trace test is not an all-characteristic assertion: −2 becomes zero in characteristic two.

### Extension to arbitrary first-leg maps: formal degeneration obstruction over C

The following written proof was independently checked by the adversarial review agent. Its scope is formal polynomial/Laurent degeneration families over C, allowing a finite Puiseux extension. It is not a Lean formalization, a positive-characteristic assertion, or an orbit-closure theorem invoking unstated curve selection.

Let K=C((t)) and its valuation ring be R=C[[t]]. Suppose a proposed normalized degeneration is

P_t(X)=A_t S(L_t X)B_t ∈ Mat_6(R[X]), with P_0(X)=D(X),

where D is any of the three-block mixtures of X and X^T. Since det D(X)=q(X)^3 for q=det_2 and det S(X)=−q(X)^3,

det P_t(X)=c_t q(L_t X)^3, c_t=−det(A_t)det(B_t).

The nonzero target determinant forces the two outer-leg maps to be invertible over the formal field. The first-leg map becomes invertible as well once its normalized quadratic form below is seen to have a nondegenerate limit. After a finite Puiseux extension choose gamma^3=c_t and put q_t=gamma·q∘L_t. The Gauss valuation of a polynomial cube is three times that of the polynomial. Since det P_t has valuation zero, q_t has valuation zero, lies in the valuation ring, and reduces to q_0 with q_0^3=q^3. The polynomial ring is a domain, so q_0=zeta·q for a cube root of unity zeta. Adjust gamma by zeta^(-1) to arrange q_0=q.

Choose delta^2=gamma, after a further finite extension if needed. Set L_normalized=delta·L and A'=delta^(-1)A; linearity of S preserves P=A'S(L_normalized X)B. Now q∘L_normalized=q_t tends to q.

Write q(X)=X^T Q X and q_t(X)=X^T Q_t X. Then H_t=Q^(-1)Q_t=I+O(t) is self-adjoint for Q. The formal binomial series R_t=H_t^(-1/2) lies in GL_4 of the valuation ring, tends to I, and satisfies R_t^T Q_t R_t=Q. Consequently G_t=L_normalized R_t preserves q exactly.

A linear automorphism of the rank-one 2×2 matrix cone preserves or exchanges its two families of maximal two-dimensional linear subspaces (fixed left factor or fixed right factor). These two rulings force its form to be X↦U X V or X↦U X^T V. The connected form is absorbed on the two outer legs of S using independent equivariance of binary polynomial multiplication in each factor. Explicitly, if m is degree-one by degree-one multiplication,

m(Gu,v)=Sym^2(G) m(u,G^(-1)v).

The transpose component is also controlled: S(X^T) is S(X)^T after fixed coordinate permutations, with row (k1,k2) exchanged to (k2,k1) and column (j1,j2) exchanged to (j2,j1). Transposing the source reverses matrix words; cyclicity leaves tr(A_01²A_10²)=−2 unchanged.

Finally P_t(R_t X) has the same target limit D(X), because P_t already has coefficients in the valuation ring and R_t→I. After absorbing G_t this is a degeneration using only outer-leg maps of S, or of its transpose. The I2 slice of D is invertible, so the rational normalized trace is regular at the limit. It would have to be both −2 and 0, a contradiction.

The order of this argument matters. Applying the near-identity change to the already bounded pencil P_t justifies preservation of its limit; dropping that change inside possibly unbounded outer-leg maps would not be justified. The determinant identity and quartic trace were independently recomputed exactly by the coordinator and the adversarial review agent.

### Wider binary pencils: a checked conjecture

For S_H=C(2,H)⊗C(2,H)^(23), exact rational calculations for H=1..6 give normalized quartic traces

0, −2, −10, −30, −70, −140.

These match −2·binomial(H+2,4). The general formula is conjectural here; six cases are not a proof. Reproduce with `python3 research/beyond-nine-quarters/construction_pencil_check.py --family-max 6`; add `--details` for all matrices and independent algebra words in the H=2 certificate. If a general formula is proved, it may obstruct further dimension-saturating targets, but no general obstruction is asserted on the strength of these samples.

## A stronger all-field obstruction from an explicit Koszul kernel

This final calculation supersedes the narrow mixed-target obstruction above: it handles arbitrary coordinate maps and polynomial degenerations in every characteristic, for the balanced binary-convolution target family specified here. The trace and determinant route is retained as a record of the independently checked investigation. No historical novelty is claimed for this Koszul calculation.

Write S_H=C(2,H)⊗C(2,H)^(23). Its first-leg dimension is four; each other leg has dimension H(H+1). Label first coordinates (p,q)∈{0,1}². Its coefficient matrices N_pq act on an array f(u,v), 0≤u<H and 0≤v≤H, by

(N_pq f)(w,z)=f(w−p,z+q),

with zero extension and output ranges 0≤w≤H,0≤z<H. The first Koszul flattening is

K(S_H): X⊗Y* → exterior²(X)⊗Z.

It has 4H(H+1) columns and 6H(H+1) rows. A kernel vector consists of four arrays f_rs satisfying N_pq f_rs=N_rs f_pq for every pair of first coordinates.

### Explicit kernel and exact rank

Choose an arbitrary array G(alpha,beta) on

0≤alpha≤H−2, 0≤beta≤H+1,

and define f_rs(u,v)=G(u−r,v+s), extending G by zero. Both sides of each kernel equation equal G(w−p−r,z+q+s). Boundary truncation causes no discrepancy: if w−p is outside 0..H−1, the resulting first G index is also outside 0..H−2. The second input index z+q always lies in 0..H. This gives a kernel subspace of dimension (H−1)(H+2). The map is injective: f_00 recovers G columns 0..H and f_01 at v=H recovers its final column H+1.

To see that this is the entire kernel, each Koszul matrix row has at most two nonzero entries, of signs +1 and −1. A two-entry equation identifies unknowns with the same label

(alpha,beta)=(u−r,v+s).

Labels with alpha=−1 or alpha=H−1 are forced to zero by a one-entry equation. For each interior alpha=0..H−2 and beta=0..H+1, all existing variables with that label form one connected component of equality equations. At beta=0 or H+1 there are two such variables connected directly. At interior beta, the four variables are connected by edges between the two second-index choices. Thus there is exactly one free scalar for each displayed label. This argument uses only equations x=y and x=0, so it remains valid in characteristic two.

Consequently, over every field,

rank K(S_H)=4H(H+1)−(H−1)(H+2)=3H(H+1)+2.

Unlike the earlier quartic-trace formula, this is a proved written formula, not a conjecture inferred from sample values. The finite checker additionally verifies the exact equality-component description.

### Consequences for balanced shared-first targets

The Koszul flattening is additive for blocks with disjoint Y/Z spaces sharing the same X. Exchanging the balanced branch orientation corresponds to invertible first-coordinate changes and/or transposition, with the same Koszul rank here. If S_H degenerates to N balanced branches of size S_h, therefore

N·(3h(h+1)+2) ≤ 3H(H+1)+2.

Koszul rank cannot increase under these degenerations: for invertible first-leg maps the construction is equivariant via the induced exterior maps; the outer-leg maps compose with its domain/codomain; and polynomial minors pass to the limit. The targets have full first-leg dimension four, forcing generic first-leg invertibility when such a degeneration exists. No requirement that the original first-leg coordinates be fixed remains.

For the smallest mixed target H=2,h=1,N=3, the source Koszul rank is 20 and the target rank is 3·8=24. This excludes every FF/BB mixture over every field, without identifying a mixed target with matrix multiplication and without the complex determinant-quadric normalization.

For H=10,h=2,N=18, source rank is 332 while target rank is 360. This rules out the previously surviving unsaturated candidate even though the source's ordinary rank upper bound alone did not.

More generally let A=H(H+1), b=h(h+1), and assume H≥h≥2. The new multiplicity bound is

N ≤ (A+2/3)/(b+2/3) ≤ (A+1/4)/(b+1/4) = ((H+1/2)/(h+1/2))².

The second inequality is strict when H>h, since increasing the common additive constant lowers (A+c)/(b+c). The right side is exactly the endpoint profile's squared ratio for C(2,H) versus C(2,h). Thus even arbitrary polynomial degenerations into these balanced product branches cannot beat the endpoint witness. This does **not** address targets containing the unbalanced FB/BF branches or different tensor families, and it is not a lower bound on omega.

### Reproduction

`python3 research/beyond-nine-quarters/construction_koszul_check.py --max-width 10` checks signed incidence equations and the explicit kernel labels using only integer arithmetic. It reports ranks

8,20,38,62,92,128,170,218,272,332

for H=1..10. Complete output is in `construction_koszul_result.json`. Because each row is an equality or a zero constraint, these checks compute exact ranks over every field rather than ranks modulo one selected prime.
