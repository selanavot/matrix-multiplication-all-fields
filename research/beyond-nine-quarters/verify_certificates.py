#!/usr/bin/env python3
"""Independently replay saved packing certificates using only integer arithmetic.

This does not import the search code or trust solver status/bounds. It verifies
the selected branch supports and all degeneration weights, not optimality.
Run from any directory with Python 3; no third-party packages are needed.
"""

from copy import deepcopy
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def check(condition, message):
    if not condition:
        raise ValueError(message)


def branch_sets(branch, a, h):
    """Derive supports from factor orientations, independently of search code."""
    kind = branch["kind"]
    check(kind in {"FF", "FB", "BF", "BB"}, "invalid orientation")
    x, y = branch["x"], branch["y"]
    A = a - 1
    if kind[0] == "F":
        yrange, zrange = range(x, x + h), range(x, x + h + A)
    else:
        yrange, zrange = range(x, x + h + A), range(x + A, x + A + h)
    if kind[1] == "F":
        yheight, zheight = range(y, y + h + A), range(y, y + h)
    else:
        yheight, zheight = range(y, y + h), range(y - A, y + h)
    return ({(u, v) for u in yrange for v in yheight},
            {(w, z) for w in zrange for z in zheight})


def verify_packing(record):
    a, h, H = (record[key] for key in ("a", "h", "H"))
    check(min(a, h, H) > 0, "nonpositive dimensions")
    branches = record["branches"]
    check(len(branches) == record["kept"], "incorrect branch count")
    Y, Z = {}, {}
    for owner, branch in enumerate(branches):
        check(type(branch["potential"]) is int, "noninteger potential")
        ys, zs = branch_sets(branch, a, h)
        for u, v in ys:
            check(0 <= u < H and 0 <= v < H + a - 1, "Y out of bounds")
            check((u, v) not in Y, "overlapping Y branches")
            Y[u, v] = owner
        for w, z in zs:
            check(0 <= w < H + a - 1 and 0 <= z < H, "Z out of bounds")
            check((w, z) not in Z, "overlapping Z branches")
            Z[w, z] = owner

    counts = {(b, i, j): 0 for b in range(len(branches))
              for i in range(a) for j in range(a)}
    internal = cross = 0
    for (u, v), owner in Y.items():
        for i in range(a):
            for j in range(a):
                target = (u + i, v - j)
                if target not in Z:
                    continue
                other = Z[target]
                weight = branches[owner]["potential"] - branches[other]["potential"]
                if owner == other:
                    check(weight == 0, "nonzero retained weight")
                    counts[owner, i, j] += 1
                    internal += 1
                else:
                    check(weight > 0, "unwanted support edge survives")
                    cross += 1
    check(all(n == h * h for n in counts.values()), "wrong branch slice size")
    return {"a": a, "h": h, "H": H, "branches": len(branches),
            "internal_edges": internal, "erased_cross_edges": cross}


def verify_periodic(record):
    a, h, N = (record[key] for key in ("a", "h", "period"))
    occupied = [set(), set()]
    for branch in record["branches"]:
        for leg, points in enumerate(branch_sets(branch, a, h)):
            reduced = {(x % N, y % N) for x, y in points}
            check(len(reduced) == len(points), "branch wraps onto itself")
            check(not occupied[leg] & reduced, "periodic branches overlap")
            occupied[leg].update(reduced)
    check(all(len(leg) == N * N for leg in occupied), "not a complete torus cover")

    obstruction = record["finite_lift_obstruction"]
    cycle = obstruction["cycle_branches"]
    edges = obstruction["cycle_edges"]
    check(cycle[0] == cycle[-1], "cycle is not closed")
    check(len(edges) == len(cycle) - 1, "wrong cycle length")
    check(len({(b["kind"], b["x"], b["y"]) for b in cycle[:-1]}) == len(edges),
          "repeated cycle vertex")
    for branch in cycle[:-1]:
        check(any(branch["kind"] == b["kind"] and
                  (branch["x"] - b["x"]) % N == 0 and
                  (branch["y"] - b["y"]) % N == 0
                  for b in record["branches"]), "cycle not in lifted packing")
    for source, target, edge in zip(cycle, cycle[1:], edges):
        i, j = edge["X"]
        u, v = edge["Y"]
        w, z = edge["Z"]
        check(0 <= i < a and 0 <= j < a, "invalid X coordinate")
        check(w == u + i and v == z + j, "not a source tensor edge")
        check((u, v) in branch_sets(source, a, h)[0], "wrong cycle source")
        check((w, z) in branch_sets(target, a, h)[1], "wrong cycle target")
    return {"period": N, "branches": len(record["branches"]),
            "certified_cycle_length": len(edges)}


def main():
    records = []
    for name in ("construction_acyclic_results.json",
                 "construction_all_orientations_results.json"):
        records.extend(json.loads((HERE / name).read_text()))
    results = [verify_packing(record) for record in records]
    periodic = verify_periodic(json.loads((HERE / "construction_mixed_result.json").read_text()))

    # A verifier must reject a certificate that keeps known unwanted edges.
    control = deepcopy(next(record for record, result in zip(records, results)
                            if result["erased_cross_edges"] > 0))
    for branch in control["branches"]:
        branch["potential"] = 0
    try:
        verify_packing(control)
    except ValueError as error:
        check(str(error) == "unwanted support edge survives", "unexpected control failure")
    else:
        raise ValueError("corrupt-potential negative control was accepted")
    print(json.dumps({"status": "passed", "packing_certificates": results,
                      "periodic_obstruction": periodic,
                      "corrupt_potential_control": "rejected as expected"}, indent=2))


if __name__ == "__main__":
    main()
