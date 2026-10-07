import Lake
open Lake DSL

package matrixMultiplicationAllFields where
  version := v!"0.1.0"
  fixedToolchain := true
  leanOptions := #[⟨`autoImplicit, false⟩]

require «fixed-point-theorems» from git
  "https://github.com/harfe/fixed-point-theorems-lean4.git" @ "770940ddf9878cf61952ed53d910b92bca841838"
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "d13f23b723b8a846827a245b89c10fc7d3f11612"

lean_lib OAI

-- Independent environments for the frozen Comparator challenge and its solution.
-- The challenge intentionally contains theorem holes and is never imported by OAI.
lean_lib ComparatorAudit

post_update pkg do
  let some dep ← findPackageByName? `«fixed-point-theorems»
    | error "Missing fixed-point-theorems dependency."
  let patch := pkg.dir / "patches" / "fixed-point-theorems-lean4341.patch"
  let reverse ← IO.Process.output {
    cmd := "git", args := #["-C", dep.dir.toString, "apply", "--reverse", "--check", patch.toString]
  }
  if reverse.exitCode == 0 then
    logInfo "fixed-point-theorems: compatibility patch already applied"
  else
    let checked ← IO.Process.output {
      cmd := "git", args := #["-C", dep.dir.toString, "apply", "--check", patch.toString]
    }
    unless checked.exitCode == 0 do
      error s!"Compatibility patch conflicts with dependency changes: {checked.stderr}"
    let applied ← IO.Process.output {
      cmd := "git", args := #["-C", dep.dir.toString, "apply", patch.toString]
    }
    unless applied.exitCode == 0 do
      error s!"Compatibility patch failed: {applied.stderr}"
    logInfo "fixed-point-theorems: applied upstream Lean 4.34.1 compatibility patch"
