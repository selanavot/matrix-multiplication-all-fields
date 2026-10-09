#!/usr/bin/env python3
"""Exact polynomial certificate for the fake profile's crossed product case.

No external dependencies, no floating point, no bounded dimension search.
The expanded identity holds over the reals. All four parameters are
nonnegative, and all nonzero polynomial coefficients are positive.

Run: python3 research/beyond-nine-quarters/profile_product_certificate.py
Use --print-terms to print every monomial and its integer coefficient.
"""

import argparse
from collections import defaultdict
from math import prod

ZERO = (0, 0, 0, 0)


def constant(n):
    return {ZERO: n} if n else {}


def add(*polynomials):
    result = defaultdict(int)
    for polynomial in polynomials:
        for monomial, coefficient in polynomial.items():
            result[monomial] += coefficient
    return {m: c for m, c in result.items() if c}


def multiply(p, q):
    result = defaultdict(int)
    for m, c in p.items():
        for n, d in q.items():
            result[tuple(x + y for x, y in zip(m, n))] += c * d
    return {m: c for m, c in result.items() if c}


def scale(p, c):
    return {m: v * c for m, v in p.items() if v * c}


def power(p, n):
    result = constant(1)
    for _ in range(n):
        result = multiply(result, p)
    return result


def variable(i):
    monomial = [0] * 4
    monomial[i] = 1
    return {tuple(monomial): 1}


def radicand_polynomial(a, b):
    # For 1 <= a <= b, f(a,b)^4 = N(a,b)/16.
    return multiply(
        add(scale(a, 3), constant(-1)),
        power(add(scale(b, 2), a, constant(-1)), 3),
    )


def evaluate(p, parameters):
    return sum(
        coefficient * prod(x**k for x, k in zip(parameters, m))
        for m, coefficient in p.items()
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--print-terms", action="store_true")
    args = parser.parse_args()

    # A=a-1, D=d-1, V=v-1, W=u-v; all are nonnegative.
    # a<=b, d<=c, and ac<=bd hold for this parameterization.
    a = add(constant(1), variable(0))
    d = add(constant(1), variable(1))
    v = add(constant(1), variable(2))
    u = add(v, variable(3))
    b = multiply(a, u)
    c = multiply(d, v)
    expanded = add(
        multiply(radicand_polynomial(a, b), radicand_polynomial(d, c)),
        scale(radicand_polynomial(multiply(a, c), multiply(b, d)), -16),
    )
    assert expanded, "Expected a nonzero polynomial"
    assert all(coefficient > 0 for coefficient in expanded.values())

    # Independent scalar substitutions guard against transcription errors in
    # the symbolic constructor. They are sanity checks, not the certificate.
    def scalar_n(x, y):
        return (3 * x - 1) * (2 * y + x - 1) ** 3

    for parameters in [(0, 0, 0, 0), (1, 2, 3, 4), (3, 0, 2, 1), (0, 5, 0, 7)]:
        A, D, V, W = parameters
        aa, dd, vv = 1 + A, 1 + D, 1 + V
        uu = vv + W
        bb, cc = aa * uu, dd * vv
        direct = scalar_n(aa, bb) * scalar_n(dd, cc) - 16 * scalar_n(aa * cc, bb * dd)
        assert evaluate(expanded, parameters) == direct

    print("Polynomial: N(a,b)N(d,c) - 16N(ac,bd)")
    print("Parameters: a=1+A, d=1+D, v=1+V, u=v+W, b=au, c=dv")
    print(f"Exact integer expansion: {len(expanded)} nonzero monomials")
    print(f"Every coefficient is positive; minimum {min(expanded.values())}")
    print(f"Constant coefficient: {expanded.get(ZERO, 0)}")
    print("This proves nonnegativity for all real A,D,V,W >= 0.")
    print("It concerns an artificial profile, not a tensor character or omega lower bound.")
    if args.print_terms:
        for monomial, coefficient in sorted(expanded.items()):
            print(monomial, coefficient)


if __name__ == "__main__":
    main()
