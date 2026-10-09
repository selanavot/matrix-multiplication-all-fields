#!/usr/bin/env python3
"""Bounded endpoint-profile check against offset diagonal filtrations.

Uses no external dependencies. Exact integer fourth-root intervals certify
individual inequalities; floats only rank the cases for reporting. A successful
finite run is NOT evidence of the inequality for unbounded dimensions.

Run: python3 research/beyond-nine-quarters/profile_filtration.py --max-size 12
"""

import argparse
from functools import lru_cache
from itertools import product
from math import isqrt


@lru_cache(maxsize=None)
def radicand(a, b):
    """The integer N such that the fake character value is N^(1/4)/2."""
    u, v = sorted((a, b))
    return (3 * u - 1) * (2 * v + u - 1) ** 3


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--max-size", type=int, default=12)
    parser.add_argument("--bits", type=int, default=80)
    args = parser.parse_args()
    if not 1 <= args.max_size <= 64:
        parser.error("--max-size must lie between 1 and 64")
    if not 16 <= args.bits <= 256:
        parser.error("--bits must lie between 16 and 256")

    @lru_cache(maxsize=None)
    def root_bounds(n):
        scaled = n << (4 * args.bits)
        lower = isqrt(isqrt(scaled))
        return lower, lower if lower**4 == scaled else lower + 1

    counts = {"certified": 0, "refuted": 0, "undecided": 0}
    best = (0.0, None)
    best_nontrivial = (0.0, None)
    examples = {"refuted": [], "undecided": []}

    for a, b, c, d in product(range(1, args.max_size + 1), repeat=4):
        left_n = radicand(a, b) * radicand(c, d)
        left_lo, left_hi = root_bounds(left_n)
        r_count, s_count = min(a, c), min(b, d)
        for offset in range(1 - r_count, s_count):
            blocks = [
                (a + c - 2 * r - 1, b + d - 2 * (r + offset) - 1)
                for r in range(max(0, -offset), min(r_count, s_count - offset))
            ]
            right_ns = [radicand(u, v) for u, v in blocks]
            bounds = [root_bounds(n) for n in right_ns]
            right_lo = 2 * sum(lo for lo, _ in bounds)
            right_hi = 2 * sum(hi for _, hi in bounds)
            # These cases reduce exactly to x >= x, regardless of whether
            # x is rational, and cannot be certified by separated intervals.
            symbolic_equality = len(right_ns) == 1 and left_n == 16 * right_ns[0]
            if symbolic_equality or left_lo >= right_hi:
                status = "certified"
            elif left_hi < right_lo:
                status = "refuted"
            else:
                status = "undecided"
            counts[status] += 1
            case = (a, b, c, d, offset)
            if status in examples and len(examples[status]) < 5:
                examples[status].append(case)
            ratio = 2 * sum(n**0.25 for n in right_ns) / left_n**0.25
            if ratio > best[0]:
                best = (ratio, case)
            if min(a, b, c, d) >= 2 and ratio > best_nontrivial[0]:
                best_nontrivial = (ratio, case)

    print(f"Dimensions 1..{args.max_size}; interval precision {args.bits} bits")
    print(f"Exact interval certificate counts: {counts}")
    print(f"Largest float ratio RHS/LHS: {best}")
    print(f"Largest ratio with every size >= 2: {best_nontrivial}")
    print(f"Uncertified examples: {examples}")
    print("This is a finite certificate only, not an unbounded theorem.")


if __name__ == "__main__":
    main()
