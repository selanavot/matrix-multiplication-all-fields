#!/usr/bin/env python3
"""Explore a new ternary-form/Koszul profile family at the fake endpoint.

Requires NumPy/SciPy. This is floating-point feasibility, NOT a certificate
of a global character or a complexity bound. See barriers.md for the exact
module filtration behind the inequalities. Default grid is bounded.
"""
import argparse
import json
import numpy as np
from scipy.optimize import linprog
from scipy.sparse import coo_array


def pstar(a, b):
    a, b = sorted((a, b))
    return ((3*a-1)/2)**(1/3)*(b+(a-1)/2)


def solve(n):
    pairs = [(a, b) for a in range(n+1) for b in range(a, n+1)]
    idx = {p: i for i, p in enumerate(pairs)}
    def at(a, b): return idx[tuple(sorted((a, b)))]
    def dim(a): return (a+1)*(a+2)/2
    bounds = [(dim(b), dim(b)) if a == 0 else
              (max(dim(a), dim(b)), dim(a+b)**(4/3)) for a, b in pairs]
    rows, cols, vals, rhs = [], [], [], []
    def row(coeff, bound):
        r = len(rhs)
        for c, v in coeff.items():
            rows.append(r); cols.append(c); vals.append(v)
        rhs.append(bound)
    for a in range(n+1):
        for b in range(1, n):
            coeff = {}
            for c, v in [(at(a,b+1), 1), (at(a,b-1), 2), (at(a,b), -3)]:
                coeff[c] = coeff.get(c, 0) + v
            row(coeff, -pstar(a+1, b))
        for b in range(n):
            row({at(a,b): 1, at(a,b+1): -1}, 0)
    matrix = coo_array((np.array(vals, dtype=float),
                        (np.array(rows, dtype=np.int32), np.array(cols, dtype=np.int32))),
                       shape=(len(rhs), len(pairs))).tocsr()
    result = linprog(np.zeros(len(pairs)), A_ub=matrix,
                     b_ub=np.array(rhs), bounds=bounds, method='highs')
    residual = None if result.x is None else float(np.max(matrix @ result.x - rhs))
    return {'grid': n, 'variables': len(pairs), 'constraints': len(rhs),
            'solver_status': int(result.status), 'solver_message': result.message,
            'max_constraint_violation': residual,
            'interpretation': 'Finite floating-point feasibility only; no global character or exponent claim.'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--grid', type=int, default=24)
    args = parser.parse_args()
    if not 2 <= args.grid <= 200:
        parser.error('--grid must lie between 2 and 200')
    print(json.dumps(solve(args.grid), indent=2))
