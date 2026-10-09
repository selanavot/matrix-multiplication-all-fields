#!/usr/bin/env python3
"""Exact coefficient check of the diagonal-filtration degenerations in profile.md.

All polynomial coefficients and changes of basis are integral. Expansion uses
division by the monic polynomial x-y, never division by a field element. This
bounded check complements, and does not replace, the general paper proof.
"""

import argparse
from collections import defaultdict
from itertools import product
from math import comb


def check(condition, message):
    if not condition:
        raise ValueError(message)


def clean(polynomial):
    return {key: value for key, value in polynomial.items() if value}


def representative(u, v, degree):
    i = min(degree, u - 1)
    j = degree - i
    check(0 <= i < u and 0 <= j < v, "representative out of bounds")
    return i, j


def basis(u, v):
    result = {}
    for order in range(min(u, v)):
        for degree in range(u + v - 2 * order - 1):
            i, j = representative(u - order, v - order, degree)
            result[order, degree] = {
                (i + order - k, j + k): (-1) ** k * comb(order, k)
                for k in range(order + 1)
            }
    check(len(result) == u * v, "wrong basis cardinality")
    return result


def expand(polynomial, u, v):
    """Expand in the displayed integral basis by successive diagonal division."""
    p = clean(polynomial)
    result = {}
    for order in range(min(u, v)):
        q = defaultdict(int, p)
        diagonal = defaultdict(int)
        for (i, j), value in p.items():
            diagonal[i + j] += value
        for degree, value in diagonal.items():
            if value:
                result[order, degree] = value
                q[representative(u - order, v - order, degree)] -= value
        q = clean(q)
        quotient = defaultdict(int)
        while q:
            i, j = max(q)
            value = q.pop((i, j))
            check(i > 0, "remainder not divisible by x-y over the integers")
            quotient[i - 1, j] += value
            q[i - 1, j + 1] = q.get((i - 1, j + 1), 0) + value
            if q[i - 1, j + 1] == 0:
                del q[i - 1, j + 1]
        p = clean(quotient)
    check(not p, "unexpanded tail")
    return result


def multiply(p, q):
    result = defaultdict(int)
    for (i, j), x in p.items():
        for (k, l), y in q.items():
            result[i + k, j + l] += x * y
    return clean(result)


def verify(a, b, c, d):
    left, right = basis(a, c), basis(b, d)
    U, V = a + b - 1, c + d - 1
    triples = []
    for (r, i), p in left.items():
        for (s, j), q in right.items():
            coefficients = expand(multiply(p, q), U, V)
            check(coefficients.get((r + s, i + j)) == 1,
                  "leading normal-order product is not ordinary convolution")
            for (n, degree), value in coefficients.items():
                check(n >= r + s, "normal order decreased")
                triples.append((r, i, s, j, n, degree, value))
    offset_count = 0
    for offset in range(1 - min(a, c), min(b, d)):
        L = 4 * (min(U, V) + abs(offset) + 1) ** 2
        actual = set()
        for r, i, s, j, n, degree, value in triples:
            weight = L * (n - r - s) + 2 * r * r + 2 * (s - offset) ** 2 - (n - offset) ** 2
            check(weight >= 0, "negative degeneration weight")
            if weight == 0:
                check(s == r + offset and n == r + s and degree == i + j and value == 1,
                      "unwanted term survives or incorrect retained coefficient")
                actual.add((r, i, s, j, n, degree))
        expected = {(r, i, s, j, r + s, i + j)
                    for r, i in left for s, j in right if s == r + offset}
        check(actual == expected, "missing target coefficient")
        offset_count += 1
    return offset_count, len(triples)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--max-dimension", type=int, default=4)
    args = parser.parse_args()
    m = args.max_dimension
    check(m >= 1, "max dimension must be positive")
    inverses = 0
    for u, v in product(range(1, 2 * m), repeat=2):
        for key, p in basis(u, v).items():
            check(expand(p, u, v) == {key: 1}, "basis inverse failure")
            inverses += 1
    cases = offsets = coefficients = 0
    for a, b, c, d in product(range(1, m + 1), repeat=4):
        count, terms = verify(a, b, c, d)
        cases += 1
        offsets += count
        coefficients += terms
    print({"status": "passed", "max_dimension": m,
           "integral_basis_inverse_checks": inverses,
           "dimension_quadruples": cases, "offset_degenerations": offsets,
           "source_coefficients_checked": coefficients})


if __name__ == "__main__":
    main()
