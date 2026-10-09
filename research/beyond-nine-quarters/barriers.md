# Barriers and adversarial checks

Status: research notes, 2026-10-08. The elementary deductions below are proved
on paper and independently checked where stated; none is a newly Lean-checked
result. No improvement to the matrix-multiplication exponent is claimed.

## 1. Independent check of the scalar-profile obstruction

The profile agent proposed the following global example. Put

\[
s(x)=(3x-1)/2,\qquad g(x)=s(x)^{1/3},\qquad
P_*(a,b)=g(\min(a,b))\bigl(\max(a,b)+(\min(a,b)-1)/2\bigr)
\]

for real `a,b >= 1`, and take `t=3/4`. I independently checked all of the
scalar hypotheses used in the final growth argument:

* Positivity and symmetry are immediate; `P_*(1,b)=b`.
* For fixed `a`, write `f(b)=P_*(a,b)`. On `1 <= b < a`,
  `f''(b) = (b-a)/(2*s(b)^(5/3)) <= 0`. The left derivative at `a` is
  `g(a)`, matching the derivative of the affine branch for `b >= a`.
  Thus the function is concave on the entire half-line. In particular,
  all of its integer second differences are nonpositive. Symmetry gives
  the other coordinate.
* The affine branch is the tangent line at `b=a`, so concavity gives
  `P_*(a,h) <= g(a)*(h+(a-1)/2)`. Since `3h+a-1 >= a`,
  `P_*(a,3h+a-1) = 3*g(a)*(h+(a-1)/2) >= 3*P_*(a,h)`.
* Write `m=min(a,b)`, `M=max(a,b)`, and `S=a+b-1`. Both
  `s(m) <= S` and `M+(m-1)/2 <= S`. Therefore
  `P_*(a,b)^3 = s(m)*(M+(m-1)/2)^3 <= S^4`, exactly the
  rank-derived scalar upper bound `P_*(a,b) <= S^(1/t)` at `t=3/4`.
* On the diagonal, `P_*(n,n)=((3n-1)/2)^(4/3)`. Its growth exponent is
  exactly `4/3`, rather than anything larger.

This is a global analytic countermodel, not merely a feasible point of a
finite numerical program. The listed scalar conditions cannot by themselves
imply a diagonal growth exponent above `4/3`, or eliminate `t=3/4`.

**Scope:** this does not establish a tensor character realizing `P_*`, a
lower bound `omega >= 9/4`, or a barrier for the entire OpenAI construction.
It isolates the information lost when the construction is reduced to these
scalar inequalities. New tensor inequalities, or constraints connecting
different tensor families, can still exclude this profile. See `profile.md`
for the originating argument and the full list of constraints used there.

The original profile and growth reduction are in Sections 4--5 of
[OpenAI's pinned manuscript](https://github.com/openai/math/blob/adc7f1241b42e322a6451854ab7e4b4c146bf78a/preprints/Matrix-Multiplication-Nine-Fourths-October-2-2026/build/paper.tex).

### Second adversarial pass: the generalized tradeoff

I independently checked the generalized witness and recurrence subsequently
added to `profile.md`. For `rho=c/(k-1)` in `[0,1]`, put
`A_j=(1+rho)j-rho` and `lambda=(1-rho)/(1+rho)`. Iterating the dilation
`h -> kh+c(a-1)` from `h=a` gives dimensions
`k^m A_a-rho(a-1)`, hence `D(a)<=A_a g(a)` after dividing by `k^m`
and taking the limiting row slope. The diagonal increment argument gives

\[
 \frac{D(j+1)}{A_{j+1}}\ge
 \frac{D(j)}{A_j}\frac{A_j+1}{A_{j+1}-1},\qquad
 \frac{A_j+1}{A_{j+1}-1}=1+\frac{\lambda}{j}.
\]

The claimed constant `exp(-lambda^2)` follows from
`log(1+x)>=x-x^2/2` and `sum_(j>=1) 1/j^2<=2`. The displayed
second derivative of `P_rho` and first derivative of its quotient `Q_a`
are algebraically correct, including at the endpoints `rho=0,1`.
The exact scalar endpoint is therefore `t=(1+rho)/2` for this family
of hypotheses. All dilations with `rho=1/2` leave `P_*` feasible.

For an actual tensor construction, `rho=1/3` would give exponent two through
this mechanism. A universal construction with `rho<1/3` and all the other
premises would contradict the arithmetic lower bound two; it is an
impossibility target, not a route to subquadratic matrix multiplication.

### Retaining the six orientations alone does not help

The formal local assignment `f_i(a,b)=P_*(a,b)^(3/4)` for all six orientations,
with `p_X=p_Y=p_Z=3/4`, passes every binary-probability determinant inequality
in the source. Raising to `4/3` gives

\[
 e^{H(q)}P_*(a,b+1)^qP_*(a,b-1)^{1-q}\le2P_*(a,b),
\]

which follows from the entropy variational identity and row concavity.
The existing per-character sector inequality reduces to tripling. Even
allowing nonuniform three-sector weights does not refute this assignment
when all three assigned branch values are equal, because their entropy
factor is maximized by the uniform law. Thus different probabilities in
different orientations and rearrangements of these same local inequalities
do not strengthen the conclusion.

This corrects the initial research suggestion below: preserving orientations
is useful only together with genuinely new constraints. Missing global
requirements include assigning values consistently to other tensor families,
their direct sums and products, and restrictions or degenerations linking
those families. For example, an admissible mixed-size shared-leg construction
would impose an optimized sum inequality on its branch profiles; it needs an
actual degeneration certificate, not just dimension-compatible packing.

## 2. Finite rank lower bounds do not establish a larger exponent

**Proved on paper; an explicit countermodel to a proposed inference.**
Suppose we have proved any finite collection of exact-rank lower bounds
`R(T_n) >= L_n` for `n <= N`, with `L_n <= n^3`. Define the abstract sequence

\[
 r_N(n)=n^2\min(n,N).
\]

It is increasing, obeys `n^2 <= r_N(n) <= n^3`, and satisfies every one of
those lower bounds. It is also submultiplicative, since

\[
 \min(mn,N)\leq\min(m,N)\min(n,N).
\]

If both `m,n < N`, the right side is `mn`; otherwise it is at least `N`.
Yet

\[
 \inf_{n\geq2}\log_n r_N(n)=2,
\]

because `r_N(n)=N*n^2` for `n>=N`. Thus finite rank lower bounds together
with these elementary sequence properties cannot force an exponent above
two. This does not claim that `r_N` is the rank function of any tensor family,
or that it meets additional known rank upper bounds.

The same distinction applies to a uniform bound such as `R(T_n)>=3n^2-o(n^2)`:
its logarithmic exponent tends to two. To show an exponent above two one
needs growth beyond `n^(2+delta)` for some fixed `delta>0`, with the relevant
asymptotic quantifiers, or a multiplicative invariant proving such growth.

[Landsberg's exact-rank lower bound](https://arxiv.org/abs/1206.1530)
is `3n^2-o(n^2)` over the complex numbers. It is a major finite-rank result,
but it supplies no positive improvement to the exponent lower bound.

## 3. A tempting spectral invariant that fails

**Proved on paper; exact counterexample.** Let `r_X,r_Y,r_Z` be the three
flattening ranks and define `G(T)=(r_X(T)*r_Y(T)*r_Z(T))^(1/3)`.
This is normalized, invariant under invertible changes of basis,
restriction-monotone, and multiplicative. It nevertheless is not a tensor
character: it is not additive on direct sums.

Take the oriented dot products

\[
 A=x\sum_{i=1}^m y_i z_i,\qquad
 B=y\sum_{i=1}^m x_i z_i,\qquad m>1.
\]

Their flattening-rank triples are `(1,m,m)` and `(m,1,m)`. Thus
`G(A)+G(B)=2*m^(2/3)`, while

\[
 G(A\oplus B)^3=2m(m+1)^2>8m^2=(G(A)+G(B))^3,
\]

where the strict difference is `2m(m-1)^2`. At `m=2`, the two cubed
quantities are `36` and `32`.

The product over six leg permutations used to define the original profile
is legitimate as a derived invariant; it is not itself an additive
character. Replacing the full character interface by multiplicativity,
monotonicity, or a capacity computation would drop a necessary hypothesis.
The actual interface is
[`Character.Basic`](../../lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Character/Basic.lean).

## 4. Current lower-bound tools and their actual scope

* **Linear flattenings:** Efremenko--Garg--Oliveira--Wigderson prove that
  rank methods cannot give superlinear rank lower bounds for general
  three-tensors of side dimension `N`.
  [Primary preprint](https://arxiv.org/abs/1710.09502).
  For matrix multiplication `N=n^2`, so this is an exponent-two barrier
  for that method, including its application to larger tensor powers.
* **New primary evidence, not independently audited here:** Lovitz's
  October 6, 2026 preprint sharpens linear-flattening potency over
  complex tensors to at most `2N-2+2/(N+1)` (Theorem 1.2). Theorem 1.1
  constructs explicit tensors of border rank at least `3N-11N^(3/4)`.
  The constructed tensors are not asserted to be matrix multiplication.
  Neither statement gives an exponent above two for matrix multiplication.
  [Versioned preprint](https://arxiv.org/html/2610.08504v1).
* **Coppersmith--Winograd route:** Alman's universal-method barrier is
  `2.16805` when the starting tensor is `CW_q`. This is a bound on a
  specified algorithm-construction method, not on the true exponent,
  and it does not rule out improving `9/4`. It must not be applied to
  the present construction without first proving that the construction
  belongs to the covered method and tensor family.
  [Published primary source](https://theoryofcomputing.org/articles/v017a001/).
* **Irreversibility:** Christandl--Vrana--Zuiddam quantify obstructions
  for algorithms that pass through a fixed intermediate tensor. The
  barrier is twice its irreversibility. This provides a concrete test
  for a proposed new intermediate tensor, rather than a universal
  lower bound on matrix multiplication.
  [Primary preprint](https://arxiv.org/abs/1812.06952).

**A useful calculation for known spectral points.** The singleton quantum
functionals are genuine complex tensor characters (Christandl--Vrana--Zuiddam,
Theorem 3.30 and Corollary 3.31). For normalized matrix multiplication
`n^(-3/2) sum_{ijk} e_ij tensor e_jk tensor e_ki`, each one-leg reduced density
matrix is `I_(n^2)/n^2`. Every marginal entropy is already maximal, so every
one of these functionals has value exactly `n^2`. On the oriented dot products
their exponents are `1-theta_X`, `1-theta_Y`, `1-theta_Z`, whose sum is two.
These calculations are our direct consequences of their entropy definition.
Optimizing over this known family therefore cannot produce a larger exponent
lower bound, and checking only this family cannot upper-bound *all* characters.
[Definitions and theorem](https://arxiv.org/html/1709.07851).

## 5. Circuit lower bounds need the correct model

The public `Arithmetic.omega F` counts arithmetic gates of circuits correct
as functions on `F`. The separate exact coefficient-rank exponent is stronger
data for upper bounds. For finite fields, a new exact-rank lower bound does
not automatically become a lower bound for functional circuits: a converse
to the existing rank-to-arithmetic bridge would need proof. The project
deliberately does not assert that equivalence. See
[`VERIFICATION.md`](../../docs/field-port/VERIFICATION.md).

There is nevertheless a direct all-fields output-counting proof of the
baseline arithmetic lower bound. The `n^2` output functions of matrix
multiplication are pairwise distinct: inputs `A=E_(i,k)` and `B=E_(k,j)`
make only output `(i,j)` equal to one. Each output is nonconstant and depends
on both input matrices, so it is not an input or constant load. Consequently
each output requires a distinct add/sub/mul gate, and cost is at least `n^2`.
Here `n>=1`, so an inner index `k` exists; the pairwise-distinct assertion
is vacuous when `n=1`, but the one output `xy` is still neither an input nor
a constant. Explicitly, `(x,y)=(1,0)` separates `xy` from `x`, `(0,1)`
separates it from `y`, and `(0,0),(1,1)` show nonconstancy. These arguments
use only `0 != 1`, so they cover `F_2` as well. For general `n`, dependence
on both matrices follows by fixing one of the displayed matrix units and
varying the matching entry of the other matrix. Each register in `Program`
has one originating gate, and distinct output functions require distinct
registers; thus free input/constant gates cannot evade the count.

This is a paper proof sketch of the familiar lower bound, not a new result
or a formalized declaration. Passing to `omega>=2` also uses nonemptiness
of the admissible exponent set (supplied by naive multiplication) and the
fact that `n^2<=C*n^b` for every positive integer `n` is impossible if `b<2`.
It does not exploit polynomial identity over an infinite field and so
survives the finite-field distinction.

## 6. Concrete next experiments and rejection criteria

1. Use `P_*` as an adversarial test of every proposed scalar inequality.
   If it satisfies the new inequality as well, that inequality has not
   closed the current scalar relaxation's gap. If it violates it, supply
   an exact tensor restriction/degeneration establishing the inequality
   for *every* character; the analytic counterexample alone supplies no
   such tensor construction.
2. Seek constraints linking the orientation-specific values to new tensor
   families or genuine mixed-size sector constructions. Merely keeping the
   six existing inequalities separate does not help: the local fake
   assignment above already satisfies all of them. Dimension packing alone
   is insufficient; the common degeneration weights or general linear maps
   must actually isolate the proposed blocks.
3. A lower-bound candidate character must satisfy direct-sum additivity
   as well as product multiplicativity and restriction monotonicity.
   Start with the two oriented dot products above as a cheap exact
   adversarial test. A scalar function or a finite feasible character
   table is not an extension to the full tensor semiring.
4. For a genuinely new lower-bound route, seek a multiplicative invariant
   detecting growth above `n^2` on matrix multiplication, beyond the
   flattening and singleton-entropy families, or an appropriate growing-
   degree algebraic obstruction. Merely improving a fixed leading
   constant in a rank lower bound will not suffice.

All four are research directions. No candidate passing the required full
proof obligations has been established in this note.

## 7. A new tensor-family test: ternary forms and their Koszul module

Status: **explicit construction and inequality proved on paper; global
countermodel independently verified; no Lean formalization.** This is an
independently derived research avenue, not a claim of historical novelty.

Let `R=F[x,y,z]`, let `R_d` be its homogeneous degree-`d` part, and let
`T_3(e,f)` encode multiplication `R_e x R_f -> R_(e+f)`. Define `T_2(e,f)`
similarly using two variables. Indices in this section are **degrees**, not
the coefficient-vector lengths used for `C(a,b)`; thus
`T_2(e,f)=C(e+1,f+1)`.

Consider the graded multiplication map

\[
 R_f\otimes F^3\longrightarrow R_{f+1},\qquad
 (u,v,w)\longmapsto xu+yv+zw,
\]

with kernel `K_f`. Multiplication by every element of `R_e` preserves these
kernels, so the exact sequence gives a compatible tensor filtration with
quotient `T_3(e,f+1)` and kernel-multiplication tensor `R_e x K_f -> K_(e+f)`.
The source is `T_3(e,f) tensor B_X(3)`.

There is a second compatible filtration with particularly concrete maps.
Write the three degree-one Koszul generators as

\[
 u=(-y,x,0),\quad v=(-z,0,x),\quad w=(0,-z,y).
\]

The first two freely generate a submodule `Ru+Rv` of `K`; the quotient is
`(R/(x))w`. Indeed, their only relation with the third generator is
`zu-yv+xw=0`. Alternatively, reducing `xb_1+yb_2+zb_3=0` modulo `x`
gives `(b_2,b_3)=(-zt,yt)` in `F[y,z]`, and subtracting a lift of `tw`
leaves a unique combination of `u,v`. This argument works in every field.
Consequently

\[
 0\longrightarrow R[-1]^2\longrightarrow K
 \longrightarrow (R/(x))[-1]\longrightarrow0.
\]

Combining the two filtrations yields four matched branches sharing their
first input:

\[
 T_3(e,f+1),\quad T_3(e,f-1),\quad T_3(e,f-1),\quad T_2(e,f-1)
 \qquad(f\ge1).
\]

The last branch uses the quotient `R_e -> (R/(x))_e` on the first leg;
zero-extension does not change its character value. To obtain actual
degeneration weights, choose bases adapted to the nested stable submodules
and give each filtration level its index on the input and its negative on
the output. The multiplication matrices are block triangular because every
first-input polynomial preserves the filtration. Strictly off-diagonal
blocks vanish and diagonal blocks remain. Refining the free submodule into
`Ru` and `Rv` separates its two branches. This supplies the compatible
filtration, rather than merely a dimension count.

For a character with `p=p_X>0`, write `Q_d(e,f)=lambda(T_d(e,f))^(1/p)`.
Optimizing the shared-leg entropy inequality gives the concrete relation

\[
 3Q_3(e,f)\ge Q_3(e,f+1)+2Q_3(e,f-1)+Q_2(e,f-1).
 \tag{K}
\]

Its boundary is `Q_3(0,f)=(f+1)(f+2)/2`, and polynomial evaluation gives
`Q_3(e,f)<=((e+f+1)(e+f+2)/2)^(1/p)` over an infinite field.
Unlike simply reoptimizing the original determinant inequality, (K) couples
two different polynomial families.

### Concrete evaluation of this avenue

At the fake endpoint `p=3/4`, freeze
`Q_2(e,f)=P_*(e+1,f+1)` and seek symmetric positive values `Q_3(e,f)`
satisfying (K), the exact boundary, coordinate monotonicity, and the rank
upper bound. Monotonicity comes from multiplying an input and its output by
a fixed variable; it also implies `Q_3(e,f)>=max(dim R_e,dim R_f)`.

The script `barrier_koszul_lp.py` builds this finite linear feasibility
problem. SciPy/HiGHS reported feasibility on both tested grids:

| Maximum degree | Variables | Inequalities | Largest floating residual |
| --- | ---: | ---: | ---: |
| 24 | 325 | 1,175 | `1.41e-11` |
| 80 | 3,321 | 12,879 | `3.21e-10` |

Run, using an environment with SciPy and NumPy:

```sh
python research/beyond-nine-quarters/barrier_koszul_lp.py --grid 24
```

The coordinator then found the simple **global** extension

\[
 Q_3(e,f)=\frac{e+f+2}{2}P_*(e+1,f+1).
\]

The profile agent proved its properties, and I independently verified the
calculation. With `a=e+1,b=f+1,s=a+b`, twice the slack in (K) is
`3sP(a,b)-(s+1)P(a,b+1)-2sP(a,b-1)`. Row concavity bounds this below by
`(s-1)*partial_b P(a,b)-P(a,b)`. For `b>=a` the latter equals
`g(a)(a-1)/2>=0`. For `b<=a`, writing `A=(3a-1)/2,B=(3b-1)/2`, its numerator
over the positive denominator `9B^(2/3)` is
`2A^2+B^2-A-2B>=3B(B-1)>=0`.

The boundary is exact, and positivity, symmetry, monotonicity, and the rank
upper bound also hold. The full proof is in `profile.md`. This global
countermodel supersedes finite LP feasibility as the reason (K) does not
exclude the endpoint. It is a consistent assignment for these particular
tensor-family constraints, not an actual character. A next substantive
step needs additional constraints on `T_3` or on other Schur-module
multiplication tensors; increasing the same finite grid cannot help.
No exponent improvement follows from this avenue.

## 8. Independent extension of the geometric shadow barrier

I checked the construction agent's shadow argument, including the necessary
sanity check `a=h=2,H=7`: the product of two three-sector constructions
retains nine branches. A search claiming a smaller optimum for the full
orientation class would be wrong.

The geometric proof extends to different fixed widths `a_j,H_j` in each
tensor factor and to branch-dependent second widths `h_(B,j)>=2`.
All branches must still use the same full first-input grid; put `A_j=a_j-1`.
In one coordinate, a forward branch of width `h` at zero and a backward
branch of width `k` at `d` have support cross edges in both directions exactly
when `-k-A+1 <= d <= h-1`. Interior overlap of their shadows gives exactly
these integer inequalities. For equal orientations, shadow overlap is a
stronger condition than bidirectional support. Product support factors
coordinatewise. The same affine first-leg argument and branch potentials
therefore imply disjoint interiors and

\[
 \sum_B\prod_j\left(h_{B,j}+\frac{A_j}{2}\right)
 \le\prod_j\left(H_j+\frac{A_j}{2}\right).
\]

If also `H_j>=a_j`, the fake profile obeys
`P_*(a_j,h)<=g(a_j)(h+A_j/2)` for every branch width, with equality at the
source width. Multiplying and summing shows that even mixed-width optimized
entropy inequalities from this packing class cannot exclude the fake
assignment.

This does **not** automatically cover branch-dependent first-input widths
`a_(B,j)`, first-leg subspaces, or arbitrary branches with `h=1`: the common
full-grid affine-weight argument can fail. Arbitrary linear basis changes,
nonmonomial cancellation, and other tensor families remain outside this
barrier.

## 9. Independent check of the stronger convolution-only obstruction

The profile agent subsequently proved that `f=P_*^(3/4)` is coordinate-sum
superadditive and coordinate-product submultiplicative. I independently
expanded the crossed-product polynomial using a separate exact-integer
sparse-polynomial implementation before reading the agent's implementation.
The result agrees: 525 nonzero coefficients, all positive, minimum 256,
total degree 14, constant coefficient zero. The reproducible certificate is
`profile_product_certificate.py`.

The global case reduction is valid. After arranging `a<=b,d<=c`, the case
`ac>bd` is transformed to `ac<=bd` by replacing the tuple with `(d,c,b,a)`.
Then `a=1+A,d=1+D,v=c/d=1+V,u=b/a=v+W` covers the entire remaining region
with nonnegative real parameters. Thus the certificate is global, not a
finite integer test.

The resulting flattening-budget obstruction also checks out: for a single
product of unpermuted convolutions degenerating to a full direct sum of
convolutions, the first-two flattening budgets plus the two inequalities
for `f` already imply the proposed character inequality. Consequently no
such construction can refute this fake assignment, even using arbitrary
linear coordinate changes.

One modest extension is valid: **target** convolution blocks may be
independently permuted. Any two dimensions of `C(u,v)` are a pair from
`{u,v,u+v-1}`; after sorting they dominate `(min(u,v),max(u,v))`.
Monotonicity therefore bounds the fake target value by `f` of its actual
first-two dimensions, after which the same budget proof applies.

Independent permutations of **source** factors involving their output legs
are not covered by this reasoning. Nor are target branches that themselves
are tensor products: their assigned product of `f` values need not be at
most `f` of their product dimensions. The mixed-source geometric obstruction
in Section 8 has separate hypotheses and does not fill these gaps for
arbitrary linear changes of basis. These scope distinctions matter when
choosing the next construction to test.

## 10. Audit of the mixed-pencil obstruction with all three legs varying

The construction agent's six-by-six pencil has
`det S(X)=-det(X)^3`. I independently verified this identity by expanding
all 720 determinant permutations with exact integer arithmetic, then ran
the exact normalized-trace checker. The source quartic trace is `-2` and
all eight targets consisting of three `X`/`X^T` diagonal blocks have trace
zero.

I also checked the proposed extension from fixed first-leg maps to formal
Laurent-series maps on all three legs. The normalization is valid over
`C((t))` after finite Puiseux extensions: take a cube root of the scalar
determinant factor, use the Gauss valuation to make the quadratic form
integral with reduction `det(X)`, and absorb a square root into the first-leg
map. The near-identity quadratic congruence is supplied by the formal
matrix series `(Q^-1 Q_t)^(-1/2)`. It must be composed with the already
bounded transformed pencil; dropping it inside separate unbounded maps
would be invalid.

The resulting determinant isometry is a left-right transformation of
two-by-two matrices, possibly followed by transpose. Binary-form
equivariance absorbs the connected case into the other two tensor legs.
The transpose case globally transposes the source pencil, up to basis
permutations, and the quartic trace `tr(A^2 B^2)` is unchanged by that
operation. The normalized trace is regular at the proposed limit because
its identity slice is invertible. Thus the incompatible trace values
exclude these formal degenerations. Complete normalization details were
sent to the construction agent for the proof in `constructions.md`.

**Scope:** complex formal Laurent/Puiseux degenerations for this fixed source
and these eight fixed targets, with arbitrary varying linear maps on all
three legs. No extension to positive characteristic is established here;
in particular the trace difference disappears in characteristic two.
An assertion about an entire geometric orbit closure would additionally
need the appropriate curve-selection result, which is not asserted in this
audit. This is an obstruction to a specific upper-bound construction, not
a new lower bound on the matrix-multiplication exponent.
