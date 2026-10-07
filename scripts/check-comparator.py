#!/usr/bin/env python3
"""Run pinned Comparator against a frozen model and the real all-fields proof.

The explicit --trusted-local option uses upstream's development runner, which
does not sandbox builds. Without it, invoke this script inside the Linux
systemd restriction documented in verification/comparator/README.md.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
LEAN = ROOT / "lean"
SPEC = ROOT / "verification/comparator"
PINS = json.loads((SPEC / "pins.json").read_text())
MARKER = b"\n-- COMPARATOR FROZEN MODEL ENDS HERE\n"


def run(args, *, cwd=ROOT, env=None, capture=False):
    return subprocess.run(
        list(map(str, args)), cwd=cwd, env=env, check=True,
        text=True, stdout=subprocess.PIPE if capture else None,
    ).stdout


def revision(path):
    return run(["git", "rev-parse", "HEAD"], cwd=path, capture=True).strip()


def require_clean_pin(path, expected):
    if revision(path) != expected:
        raise RuntimeError(f"Unexpected revision in {path}; expected {expected}")
    if run(["git", "status", "--porcelain", "--untracked-files=no"],
           cwd=path, capture=True).strip():
        raise RuntimeError(f"Tracked source changes in {path}")


def verify_spec():
    original = subprocess.check_output([
        "git", "show", f"{PINS['model_baseline']}:{PINS['model_path']}"
    ], cwd=ROOT)
    current = (ROOT / PINS["model_path"]).read_bytes()
    challenge = (LEAN / "ComparatorAudit/Challenge.lean").read_bytes()
    if challenge.count(MARKER) != 1:
        raise RuntimeError("Missing or duplicated frozen-model boundary")
    if challenge.split(MARKER)[0] != original or current != original:
        raise RuntimeError("Challenge/current model differs from immutable baseline")
    config = json.loads((SPEC / "config.json").read_text())
    if config.get("definition_names"):
        raise RuntimeError("Definition holes would weaken the frozen specification")
    if config["permitted_axioms"] != ["propext", "Classical.choice", "Quot.sound"]:
        raise RuntimeError("Unexpected permitted axioms")
    expected_theorems = [f"ComparatorChecks.{name}" for name in [
        "omega_bound", "admissible_bddBelow", "admissible_nonempty",
        "omega_lower", "epsilon_cost",
    ]]
    if config != {
        "challenge_module": "ComparatorAudit.Challenge",
        "solution_module": "ComparatorAudit.Solution",
        "theorem_names": expected_theorems,
        "permitted_axioms": ["propext", "Classical.choice", "Quot.sound"],
    }:
        raise RuntimeError("Comparator configuration differs from the five-theorem audit")
    if (LEAN / "lean-toolchain").read_text().strip() != PINS["toolchain"]:
        raise RuntimeError("Project toolchain differs from Comparator pins")
    print(f"Frozen model SHA-256: {hashlib.sha256(original).hexdigest()}", flush=True)
    return hashlib.sha256(challenge).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--trusted-local", action="store_true",
                        help="Use upstream's unsandboxed development runner")
    parser.add_argument("--comparator-dir", type=Path,
                        default=LEAN / ".lake/comparator-tool")
    parser.add_argument("--negative-controls", action="store_true",
                        help="Also require rejection of changed cost and sorry proofs")
    args = parser.parse_args()
    before = verify_spec()
    run([sys.executable, ROOT / "scripts/verify-dependencies.py", ROOT])
    tool = args.comparator_dir.resolve()
    env = os.environ.copy()
    env["ELAN_TOOLCHAIN"] = PINS["toolchain"]
    env["LEAN_NUM_THREADS"] = "1"
    if args.trusted_local:
        print("MODE: trusted local sources; NO Comparator build sandbox; Lean kernel only.",
              flush=True)
    elif sys.platform != "linux" or not shutil.which("landrun"):
        raise RuntimeError("Linux Landrun required; for trusted sources only, explicitly use --trusted-local")
    if not tool.exists():
        tool.parent.mkdir(parents=True, exist_ok=True)
        run(["git", "clone", "--no-checkout", "https://github.com/leanprover/comparator.git", tool])
        run(["git", "checkout", "--detach", PINS["comparator"]], cwd=tool)
    require_clean_pin(tool, PINS["comparator"])
    manifest = json.loads((tool / "lake-manifest.json").read_text())
    exporter_pin = next(p["rev"] for p in manifest["packages"] if p["name"] == "lean4export")
    if exporter_pin != PINS["lean4export"]:
        raise RuntimeError("Unexpected exporter manifest pin")
    run(["lake", "build", "lean4export", "comparator"], cwd=tool, env=env)
    exporter = tool / ".lake/packages/lean4export"
    require_clean_pin(exporter, PINS["lean4export"])
    print(f"Comparator: {revision(tool)}\nlean4export: {revision(exporter)}", flush=True)
    run(["lean", "--version"], cwd=LEAN, env=env)
    env["COMPARATOR_LEAN4EXPORT"] = str(exporter / ".lake/build/bin/lean4export")
    if args.trusted_local:
        env["COMPARATOR_LANDRUN"] = str(tool / "scripts/fake-landrun.sh")
    else:
        env["COMPARATOR_LANDRUN"] = shutil.which("landrun")
    # Only prebuild outside Landrun when explicitly trusting local sources.
    if args.trusted_local:
        run(["lake", "build", "ComparatorAudit.Challenge", "ComparatorAudit.Solution"],
            cwd=LEAN, env=env)
    command = ["lake", "env", tool / ".lake/build/bin/comparator"]
    run(command + [SPEC / "config.json"], cwd=LEAN, env=env)
    if verify_spec() != before:
        raise RuntimeError("Frozen challenge changed during verification")
    print("PASS: five theorems, frozen definitions, standard axioms, Lean kernel replay.",
          flush=True)
    if args.negative_controls:
        negative_controls(command, env, args.trusted_local)
    if verify_spec() != before:
        raise RuntimeError("Frozen challenge changed during controls")


def negative_controls(command, env, trusted_local):
    """Use actual challenge/solution variants, never weaken the real config."""
    generated = LEAN / "ComparatorAudit/GeneratedControls"
    if generated.exists():
        raise RuntimeError(f"Refusing to overwrite existing control directory: {generated}")
    config = json.loads((SPEC / "config.json").read_text())
    challenge = (LEAN / "ComparatorAudit/Challenge.lean").read_text()
    solution = (LEAN / "ComparatorAudit/Solution.lean").read_text()
    cost = "  | .mul _ _ => 1"
    proof = "AuxiliarySeparation.matrix_multiplication_cost_le F ε hε"
    if challenge.count(cost) != 1 or solution.count(proof) != 1:
        raise RuntimeError("Control source anchors changed")
    cases = [
        ("ChangedCost", "challenge_module", challenge.replace(cost, "  | .mul _ _ => 0"),
         "Const does not match between challenge and target"),
        ("SorryProof", "solution_module", solution.replace(proof, "by sorry"),
         "Illegal axiom detected: 'sorryAx'"),
    ]
    generated.mkdir()
    try:
        for name, side, source, expected in cases:
            module = f"ComparatorAudit.GeneratedControls.{name}"
            (generated / f"{name}.lean").write_text(source)
            altered = dict(config)
            altered[side] = module
            cfg = generated / f"{name}.json"
            cfg.write_text(json.dumps(altered, indent=2) + "\n")
            if trusted_local:
                run(["lake", "build", module], cwd=LEAN, env=env)
            result = subprocess.run(list(map(str, command + [cfg])), cwd=LEAN,
                                    env=env, text=True, capture_output=True)
            output = result.stdout + result.stderr
            log = LEAN / ".lake" / f"comparator-{name}.log"
            log.write_text(output)
            if result.returncode == 0 or expected not in output:
                print(output, file=sys.stderr)
                raise RuntimeError(f"{name} did not fail for the expected reason; see {log}")
            if name == "ChangedCost" and "OAI.MatrixMultiplication.Arithmetic.Gate.cost" not in output:
                raise RuntimeError("Changed-cost control failed on an unexpected declaration")
            print(f"PASS negative control {name}: exit {result.returncode}; {expected}", flush=True)
    finally:
        # Only files created in the exclusively owned generated directory.
        shutil.rmtree(generated)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Comparator verification failed: {error}", file=sys.stderr)
        sys.exit(1)
