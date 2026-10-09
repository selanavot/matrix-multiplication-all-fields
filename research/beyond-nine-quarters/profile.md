# Sharpness of the scalar-profile argument

Status: **proved on paper; not Lean-checked**. The proof below constructs one
global profile on all positive integer pairs, not merely a finite feasible grid.
It establishes a limitation of the scalar inequalities used by the existing
argument. It is **not** a lower bound on matrix-multiplication complexity, nor
does it construct a tensor character attaining the bound.

## Exact global witness at the endpoint

The hypotheses of `AuxiliarySeparation/Growth/Profile.lean` admit a profile at
`t = 3/4`. Consequently those hypotheses alone cannot prove `t < 3/4`, and
cannot improve the resulting bound `omega <= 9/4`.

For real `a >= 1`, set

\[
 A_a=\frac{3a-1}{2},\qquad g(a)=A_a^{1/3}.
\]

For `a,b >= 1`, with `u=min(a,b)` and `v=max(a,b)`, define

\[
 P(a,b)=g(u)\left(v+\frac{u-1}{2}\right).
 \tag{1}
\]

Restrict (1) to positive integers, assigning arbitrary values, for example zero,
on the two unused coordinate axes. We verify every scalar-profile hypothesis.

### Positivity, symmetry, and boundary

Positivity and symmetry are immediate from (1). Since `g(1)=1`,
`P(1,b)=b` for every `b>=1`.

### Row concavity, including across the diagonal

Fix `a>=1` and abbreviate `A=A_a`. For `1<=b<=a`, put `s=(3b-1)/2`.
Then

\[
 P(a,b)=\frac13s^{1/3}(2A+s),\qquad
 \frac{\partial P}{\partial b}
   =\frac{A+2s}{3s^{2/3}},\qquad
 \frac{\partial^2P}{\partial b^2}
   =\frac{s-A}{3s^{5/3}}\le0.
\]

For `b>=a`, the row is linear:

\[
 P(a,b)=A^{1/3}\left(b+\frac{a-1}{2}\right).
\]

The two branches have matching values and derivatives at `b=a`: the derivative
on both sides is `A^(1/3)`. Hence the entire real row on `[1,infinity)` is
concave, which implies the required discrete inequalities

\[
 P(a,h-1)+P(a,h+1)\le2P(a,h)\qquad(h\ge2).
\]

### Shifted tripling, with an exact algebraic slack identity

For `a,h>=1`, the target `H=3h+a-1` always satisfies `H>=a`. Therefore

\[
 P(a,H)=3g(a)\left(h+\frac{a-1}{2}\right).
\]

If `h>=a`, this is exactly `3P(a,h)`. If `h<=a`, let `x=g(h)` and `y=g(a)`,
so `0<x<=y`, `h=(2x^3+1)/3`, and `a=(2y^3+1)/3`. Direct substitution gives

\[
 P(a,3h+a-1)-3P(a,h)
 =y^4-2xy^3+2x^3y-x^4
 =(y-x)^3(y+x)\ge0.
\]

Thus the tripling inequality holds globally. It is an equality throughout
the entire region `h>=a`.

### Rank upper bound at `t=3/4`

Assume without loss of generality `1<=a<=b`, and let `S=a+b-1`. Then

\[
 0<A_a=\frac{3a-1}{2}\le S,\qquad
 0<b+\frac{a-1}{2}\le S.
\]

The first inequality follows from `a+1<=2b`. Hence

\[
 P(a,b)=A_a^{1/3}\left(b+\frac{a-1}{2}\right)
 \le S^{1/3}S=S^{4/3}=S^{1/t}.
\]

This verifies the last hypothesis with its exact constant one.

## Why the witness meets the bottleneck

The limiting slope of row `a` is exactly `g(a)`, and the diagonal is

\[
 D(a)=P(a,a)=\left(\frac{3a-1}{2}\right)^{4/3}
     =\frac{3a-1}{2}g(a).
\]

Thus the slope-to-diagonal upper inequality used in the proof is attained
exactly. The exponent of the diagonal growth is exactly `4/3`. The witness
also satisfies the existing diagonal lower bound `a^4<=P(a,a)^3`, since
`(3a-1)/2>=a` for `a>=1`.

Any new estimate valid for every scalar profile must remain consistent with
this example. Improving constants, using longer row intervals, iterating
tripling differently, or optimizing finite collections of the same
inequalities cannot exclude this endpoint. An improvement in omega requires
an additional property of actual tensor characters, a stronger tensor
construction, or another argument that is absent from the scalar-profile
axioms.

This leaves open an important distinction: the formula (1) has **not** been
shown to arise from any actual tensor character. A genuinely tensorial
constraint may rule it out, so the witness is not evidence that `omega=9/4`.

## Verification and provenance

- Source of the axioms: OpenAI's scalar-profile argument, as ported in
  `lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Growth/Profile.lean`.
- All assertions in the main witness proof above follow from the displayed
  elementary derivative formulas and polynomial identity. No numerical search
  or LP feasibility result is used as evidence.
- No Lean build was run, no public theorem was changed, and no new axioms or
  unfinished formal proofs were introduced.
- Independent adversarial review was requested through the coordinating agent.

## A sharp tradeoff for any number of sectors

Status: **proved on paper; not Lean-checked**. This strengthens the preceding
barrier and relates it to the construction agent's sector-count obstruction.

Suppose the tripling hypothesis is replaced by

\[
 kP(a,h)\le P(a,kh+c(a-1)),\qquad k\ge2,
 \tag{2}
\]

where `k,c` are integers and

\[
 \rho=\frac{c}{k-1}\in[0,1].
\]

Retain positivity, symmetry, boundary, row concavity, and the rank upper bound.
Then the exact scalar endpoint is

\[
 t\le\frac{1+\rho}{2}.
 \tag{3}
\]

Both the deduction and an endpoint witness are given below. In particular,
adding arbitrarily many inequalities (2) with normalized shift `rho=1/2`
does not improve `t<=3/4`.

### Derivation of the endpoint

Let `g(a)` be the nonnegative limiting slope of the positive concave row, as
in the existing proof, and write `D(a)=P(a,a)` and

\[
 A_a=(1+\rho)a-\rho.
\]

Iterating (2) from `h=a` and dividing by `k^m`, then taking `m` to infinity,
gives `D(a)<=A_a g(a)`. Symmetry and the lower bound of every row increment
by its limiting slope give

\[
 D(a+1)\ge D(a)+g(a)+g(a+1)
 \ge D(a)+\frac{D(a)}{A_a}+\frac{D(a+1)}{A_{a+1}}.
\]

Since `A_(a+1)>1`, rearrangement and iteration, starting from `D(1)=A_1=1`,
yield

\[
 \frac{D(n)}{A_n}
 \ge \prod_{j=1}^{n-1}\frac{A_j+1}{A_{j+1}-1}
 =\prod_{j=1}^{n-1}\left(1+\frac{\lambda}{j}\right),
 \qquad \lambda=\frac{1-\rho}{1+\rho}.
\]

For `lambda in [0,1]`, the inequalities
`log(1+x)>=x-x^2/2`, `sum_(j<n) 1/j>=log n`, and
`sum_(j<n) 1/j^2<=2` give

\[
 D(n)\ge e^{-\lambda^2} A_n n^\lambda
       \ge e^{-\lambda^2}n^{1+\lambda}.
\]

Comparing with `D(n)<=(2n-1)^(1/t)` forces
`1+lambda<=1/t`, proving (3). This argument uses the same row-slope mechanism
as the original proof, with the normalized shift made explicit.

### Endpoint witnesses for the whole tradeoff

For each `rho in [0,1]`, set

\[
 \lambda=\frac{1-\rho}{1+\rho},\qquad
 g_\rho(a)=((1+\rho)a-\rho)^\lambda,
\]

and define, with `u=min(a,b)`, `v=max(a,b)`,

\[
 P_\rho(a,b)=g_\rho(u)\bigl(v+\rho(u-1)\bigr).
 \tag{4}
\]

It has the required boundary and symmetry. For a fixed row and `1<=b<=a`,
put `s=(1+rho)b-rho`. Direct differentiation gives

\[
 \frac{\partial^2 P_\rho(a,b)}{\partial b^2}
 =2\lambda\rho(1+\rho)(b-a)s^{\lambda-2}\le0.
\]

At the diagonal its derivative matches that of the linear upper branch,
namely `g_rho(a)`, so the entire row is concave. For `1<=a<=b`, both
`(1+rho)a-rho` and `b+rho(a-1)` are at most `a+b-1`; hence

\[
 P_\rho(a,b)\le(a+b-1)^{1+\lambda}.
\]

This is the rank bound at `t=1/(1+lambda)=(1+rho)/2`.

Finally define

\[
 Q_a(b)=\frac{P_\rho(a,b)}{b+\rho(a-1)}.
\]

For `1<=b<=a`, its derivative is exactly

\[
 Q_a'(b)=
 \frac{\rho(1-\rho)(a-b)^2s^{\lambda-1}}
 {(b+\rho(a-1))^2}\ge0.
\]

For `b>=a`, `Q_a(b)=g_rho(a)` is constant. Thus `Q_a` is nondecreasing
globally. For **every real** `k>=1`, put
`H=kh+(k-1)rho(a-1)`, so
`H+rho(a-1)=k(h+rho(a-1))` and `H>=h`. It follows that

\[
 P_\rho(a,H)\ge kP_\rho(a,h).
\]

Consequently the witness simultaneously satisfies every dilation with the
same normalized shift. Formula (1) is precisely the case `rho=1/2`.

### Consequence for research direction

Replacing three sectors by five, seven, or any larger number, while retaining
the dimension-optimal normalized shift `rho=1/2`, leaves this exact witness
feasible. A successful new tensor construction must improve a different
feature, such as the normalized shift, the profile's boundary/rank relation,
or constraints discarded in scalar symmetrization. This is a restriction on
the specified method, not a general complexity lower bound.

Within this mechanism, the corresponding formal exponent bound is
`omega<=3(1+rho)/2`. Thus `rho<1/2` is necessary for a strict improvement on
`9/4`, and `rho<=1/3` would give the target `omega<=2`. These are conditional
targets for a new construction, not constructions or new complexity bounds.

## Additional constraints investigated

### Kronecker substitution does not exclude the witness

Status: **proved on paper; not Lean-checked**.

There is an explicit coefficient restriction

\[
 C(a,b)\otimes C(c,d)\preceq C(A,B),\quad
 N=a+b-1,\quad A=a+N(c-1),\quad B=b+N(d-1).
\]

Encode each first input index pair as `i+N i'`, each second input pair as
`j+N j'`, and each output pair as `k+N k'`. The low output digit is at most
`a+b-2=N-1`, so there are no carries or collisions. Restriction monotonicity
and multiplicativity, applied in all six orders of the legs, imply the
necessary relation

\[
 P(A,B)\ge P(a,b)P(c,d).
 \tag{5}
\]

The endpoint witness (1) satisfies (5) globally. For aligned orientations
`a<=b` and `c<=d`, write `L(a,b)=b+(a-1)/2`. Then

\[
 g(A)^3-g(a)^3g(c)^3
 =\frac34(c-1)(2b-a-1)\ge0,
\]

and

\[
 L(A,B)-L(a,b)L(c,d)
 =\frac{a-1}{2}\left(d-1+\frac{c-1}{2}\right)\ge0.
\]

Multiplying proves (5). To cover crossed orientations, note that `A+B` is
unchanged by reversing either input pair. The aligned orientation maximizes
`|A-B|`: its value is `|b-a|+N|d-c|`; the crossed orientation has the absolute
difference of these two nonnegative terms. At a fixed sum, (1) is increasing
as the pair becomes more balanced: for `a<=b`, the derivative along
`a+b=constant` has sign `b-a>=0`. Thus the aligned orientation is the worst
case, and proves all cases.

A bounded exploratory float scan over `1<=a,b,c,d<=25` found no violation;
the algebra above supersedes the scan and proves the unbounded statement.

### Optimizing the six existing entropy inequalities separately is insufficient

Status: **proved on paper for these specific local inequalities; not a tensor
character construction**.

The endpoint profile can be lifted to an assignment of six *formal local
values* by setting, for all six leg permutations,

\[
 f_i(a,b)=P(a,b)^{3/4},\qquad
 p_X=p_Y=p_Z=3/4.
\]

This assignment satisfies each unsymmetrized determinant inequality in
`Determinant/Character.lean`, for every binary probability `q`. Raising that
inequality to the power `4/3` reduces it to

\[
 e^{H(q)}P(a,b+1)^qP(a,b-1)^{1-q}\le2P(a,b).
\]

The entropy variational inequality bounds the left side by
`P(a,b+1)+P(a,b-1)`, and row concavity completes the proof. It also satisfies
each three-sector inequality in `Sector/Character.lean`: after raising to
`4/3`, that inequality is exactly shifted tripling.

Thus the loss responsible for this obstruction cannot be repaired merely by
choosing different binary probabilities for different leg permutations or by
rearranging the same six local inequalities before multiplication. The fake
assignment makes all six orientations identical. It has not been extended to
an additive, multiplicative, restriction-monotone valuation on all tensors.
Such a global extension is the missing and potentially decisive constraint.

## New oblique tensor degeneration: diagonal normal-order filtration

Status: **proved on paper**; independently derived and coefficient-checked by
the coordinator in a separate script. The profile tests below have exact
computational certificates. This section introduces a new family of tensor
inequalities; none excludes the endpoint profile.

Write `Q_(a,c)` for polynomials of degree at most `a-1` in `x` and `c-1` in
`y`. The product tensor `C(a,b) tensor C(c,d)` is exactly

\[
 Q_{a,c}\times Q_{b,d}\longrightarrow Q_{a+b-1,c+d-1}.
\]

Filter each space by divisibility by `Delta=x-y`. Its normal-order `r`
quotient is identified, by dividing by `Delta^r` and setting `y=x=z`, with
the univariate polynomials of degree at most `a+c-2r-2`. This identification
is valid over **every field**: the kernel is precisely the next divisibility
step, and every monomial up to that degree has a lift. No division by two or
semisimplicity of a representation is required.

For first and second input orders `r,s`, multiplication has output order
`n>=r+s`. On the quotient `n=r+s`, it is the convolution tensor

\[
 C(a+c-2r-1,\ b+d-2s-1).
\]

Choose an integer offset `ell`. First pass to this associated graded tensor,
then give fine weights `2r^2`, `2(s-ell)^2`, and `-(n-ell)^2` to the two
inputs and the output. On a graded multiplication block their sum is

\[
 2r^2+2(s-\ell)^2-(r+s-\ell)^2=(r-s+\ell)^2.
\]

It retains exactly `s=r+ell`, with distinct output orders `2r+ell`. Therefore

\[
 C(a,b)\otimes C(c,d)\ \succeq_{\rm deg}\
 \bigoplus_r C(a+c-2r-1,\ b+d-2r-2\ell-1),
 \tag{6}
\]

where `0<=r<min(a,c)` and `0<=r+ell<min(b,d)`. To combine the two stages
into one weighting, use total weight

\[
 L(n-r-s)+2r^2+2(s-\ell)^2-(n-\ell)^2
\]

with `L` larger than the square of the largest possible `|n-ell|`. All
higher-order terms then have positive weight. Applying the quadratic weights
alone before taking the associated graded would be invalid: higher jets can
otherwise have negative weights.

### Small example and a reproducible finite certificate

Taking `a=b=c=d=2`, `ell=0`, gives

\[
 C(2,2)^{\otimes2}\succeq_{\rm deg} C(3,3)\oplus 1.
\]

Every genuine character must consequently satisfy
`chi(C(2,2))^2 >= chi(C(3,3))+1`. For the artificial local character values

\[
 f(a,b)=P(a,b)^{3/4},
\]

the inequality reads `25/4 >= 5`, so the new constraint does not rule them
out. More generally the diagonal equal-size case has the exact slack

\[
 f(a,a)^2-\sum_{j=1}^a f(2j-1,2j-1)
 =\frac{(a-1)(3a-1)}4\ge0.
\]

For all sizes `1..32` and every allowed offset, the script

```sh
python3 research/beyond-nine-quarters/profile_filtration.py --max-size 32
```

certified all **22,380,544** individual fake-value inequalities, with zero
refuted or undecided cases. It uses integer fourth-root intervals at 80-bit
precision; floating point is used only to display ratios. The largest ratio
of right to left sides when all four sizes are at least two was `0.8`, at
`(2,2,2,2,ell=0)`. The default maximum size is 12, giving 166,464 certificates.
This finite result alone would not establish an unbounded claim. The global
argument next supersedes it.

## Global obstruction for unpermuted full direct sums

Status: **proved on paper with an exact polynomial-positivity certificate for
one algebraic inequality**. No Lean checking or character-realizability claim.

The artificial local function `f=P^(3/4)` satisfies, for all real indices at
least one,

\[
 f(a+c,b+d)\ge f(a,b)+f(c,d),\qquad
 f(ac,bd)\le f(a,b)f(c,d).
 \tag{7}
\]

It is also increasing in each coordinate. The first inequality was independently
identified by the barriers agent. Here are proofs including all orientations.

### Coordinate-sum superadditivity

When `a<=b` and `c<=d`, write

\[
 A_a=(3a-1)/2,\quad L(a,b)=b+(a-1)/2,\quad
 f(a,b)=A_a^{1/4}L(a,b)^{3/4}.
\]

Both factors for `(a+c,b+d)` exceed the sums of their corresponding factors
by `1/2`. The weighted geometric mean `(x,y) -> x^(1/4)y^(3/4)` is concave,
homogeneous of degree one, and increasing, and hence superadditive. This
proves the aligned case.

At a fixed sum, `f(a,b)` increases when the two coordinates become more
balanced; this follows from the same property already proved for `P`.
If the two input pairs have crossed orientations, their coordinate sum is
more balanced than the sum after aligning the two smaller coordinates.
The right side of (7) is unchanged by that alignment. This proves every case.

### Coordinate-product submultiplicativity

For the aligned case `a<=b`, `c<=d`, one has

\[
 A_aA_c-A_{ac}=\frac34(a-1)(c-1)\ge0.
\]

Writing `B=b-a>=0` and `D=d-c>=0` gives

\[
 L(a,b)L(c,d)-L(ac,bd)
 =\frac34(a-1)(c-1)+\frac12B(c-1)+\frac12D(a-1)\ge0.
\]

Combining the two factors proves the aligned case.

For crossed orientations, symmetry permits `a<=b` and `d<=c`. We can also
assume `ac<=bd`: if necessary interchange the two factors and reverse both
input pairs, replacing `(a,b,c,d)` by `(d,c,b,a)`. This preserves the claim
and reverses that last comparison.

Put

\[
 a=1+A,\quad d=1+D,\quad v=c/d=1+V,\quad
 u=b/a=v+W,
\]

where `A,D,V,W>=0`. These nonnegative real parameters cover the entire
remaining case. For `x<=y`, define the integer-coefficient polynomial

\[
 N(x,y)=(3x-1)(2y+x-1)^3,\qquad f(x,y)^4=N(x,y)/16.
\]

After the substitution `b=au,c=dv`, the polynomial

\[
 N(a,b)N(d,c)-16N(ac,bd)
 \tag{8}
\]

expands into **525 monomials, all with positive integer coefficients**; the
minimum coefficient is 256 and the constant coefficient is zero. Hence (8)
is nonnegative for all these real parameters. Taking fourth roots proves
the crossed case of (7). This is an exact symbolic certificate, not a finite
grid argument. Reproduce it with the dependency-free command

```sh
python3 research/beyond-nine-quarters/profile_product_certificate.py
# Add --print-terms to inspect all 525 monomials and integer coefficients.
```

The script constructs the polynomial with exact integer sparse arithmetic,
checks every coefficient, and also verifies several direct substitutions as
transcription checks. It is not a Lean proof or an independent-kernel check.

### Consequence of the flattening-dimension budgets

First suppose a tensor product of ordinary, consistently oriented convolutions
degenerates to a full direct sum of likewise oriented convolutions:

\[
 \bigotimes_i C(a_i,b_i)\succeq_{\rm deg}\bigoplus_j C(u_j,v_j).
\]

Each convolution has full first and second flattening ranks, so monotonicity
of flattening rank forces

\[
 \sum_j u_j\le\prod_i a_i,\qquad
 \sum_j v_j\le\prod_i b_i.
\]

By repeated use of (7) and coordinate monotonicity, these necessary dimension
budgets already imply

\[
 \sum_j f(u_j,v_j)
 \le f\left(\sum_j u_j,\sum_j v_j\right)
 \le f\left(\prod_i a_i,\prod_i b_i\right)
 \le\prod_i f(a_i,b_i).
\]

This extends to arbitrary, independently chosen leg permutations of the
**target blocks**. If a target `C(u,v)` has first and second actual dimensions
`s,t`, their sorted pair dominates the sorted pair `(u,v)`: the third
dimension `u+v-1` is at least each input dimension. Consequently
`f(u,v)<=f(s,t)`, and the identical argument applies to the budgets on the
actual first and second dimensions.

Thus **no such full-direct-sum construction can violate this particular fake
local assignment**, regardless of tensor-power size, target-block leg
permutations, or the chosen linear coordinate changes. This includes every
offset filtration (6), and explains the finite certificate above.

The scope matters: source input-coordinate swaps are covered, but cyclic leg
permutations of **source factors** that exchange an input leg with the output
leg are not covered by this argument. Nor are target blocks that are
themselves tensor products, arbitrary new tensor families, or restrictions
coupling several tensors without yielding a full direct sum of convolutions.
The conclusion does not classify actual tensor characters or give a lower
bound on omega. It shows that this broad family of necessary constraints is
consistent with artificial local values having `pX+pY+pZ=9/4`.

The barriers agent independently reconstructed the polynomial expansion with
a separately written sparse-polynomial implementation and obtained the same
525 positive coefficients, minimum coefficient 256, total degree 14, and
zero constant coefficient. That review also supplied the extension to
permuted target blocks above.

## Global extension to the ternary Koszul inequality

Status: **proved on paper; independently derived/check-verified by the
coordinator and profile agent; not Lean-checked**. This replaces a merely
finite feasibility result with an explicit global countermodel for the
particular ternary coupling in `barriers.md`, Section 7.

Use degree indices `e,f>=0`, put `p=3/4`, and keep the binary assignment

\[
 Q_2(e,f)=P(e+1,f+1).
\]

The newly derived Koszul inequality is

\[
 3Q_3(e,f)\ge Q_3(e,f+1)+2Q_3(e,f-1)+Q_2(e,f-1),
 \qquad f\ge1.
 \tag{K}
\]

Define the following global extension:

\[
 \boxed{Q_3(e,f)=\frac{e+f+2}{2}\,P(e+1,f+1).}
 \tag{9}
\]

It is positive, symmetric, and increasing in each coordinate, because the
two factors have these properties. Its boundary is exactly correct:

\[
 Q_3(0,f)=\frac{(f+1)(f+2)}2.
\]

### Verification of the Koszul inequality

Set `a=e+1`, `b=f+1`, and `s=a+b`; thus `b>=2`. Abbreviate
`P=P(a,b)`, `P_+=P(a,b+1)`, `P_-=P(a,b-1)`. Twice the slack in (K) is

\[
 3sP-(s+1)P_+-2sP_-.
\]

Concavity gives `P_+<=2P-P_-`, so this is at least

\[
 -P+(s-1)(P-P_-)
 \ge -P+(a+b-1)\,\partial_bP(a,b).
 \tag{10}
\]

The last inequality is the usual backward-secant bound for a differentiable
concave function; the explicit profile is differentiable also at its diagonal.

For `b>=a`, the final expression in (10) is
`g(a)(a-1)/2>=0`. For `b<=a`, put `A=(3a-1)/2` and `B=(3b-1)/2`. Using the
explicit derivative from the profile proof gives

\[
 (a+b-1)\partial_bP(a,b)-P(a,b)
 =\frac{2A^2+B^2-A-2B}{9B^{2/3}}.
\]

Since `A>=B>=1`, its numerator is at least `3B(B-1)>=0`:
subtracting this latter quantity leaves `(A-B)(2(A+B)-1)>=0`.
This proves (K) for every pair of nonnegative integer degrees.

### Verification of the evaluation-rank upper bound

Let `S=e+f+1>=1` and `N=S(S+1)/2`, the dimension of ternary forms of
degree `e+f`. By the binary rank bound,

\[
 Q_3(e,f)\le\frac{S+1}{2}\,S^{4/3}
 \le\left(\frac{S(S+1)}2\right)^{4/3}=N^{1/p},
\]

where the second inequality uses `(S+1)/2>=1`. Thus (9) obeys every
condition used by the finite ternary feasibility test: symmetry, positivity,
coordinate monotonicity, exact boundary, (K), and the rank upper bound.

For a fixed `e`, the row has leading term

\[
 Q_3(e,f)\sim\frac12g(e+1)f^2\qquad(f\longrightarrow\infty).
\]

This also attains the leading coefficient suggested by iterating the
Koszul recurrence under a polynomial upper bound. The finite-grid test was
not overlooking a contradiction at larger degrees: the explicit formula
works at every degree.

The conclusion is narrow but definitive: **the new coupling (K), together
with those boundary, monotonicity, and rank conditions, cannot exclude the
fake endpoint assignment at `p=3/4`**. The assignment is still not an actual
tensor character. Additional constraints involving ternary forms, their
products, or further syzygy modules could invalidate it; (9) does not claim
to satisfy those unproved or untested constraints.
