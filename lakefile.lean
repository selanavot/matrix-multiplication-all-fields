import Lake
open Lake DSL

package matrixMultiplicationAllFields where
  version := v!"0.1.0"
  description := "OpenAI matrix-multiplication proof extended to arbitrary fields"
  license := "Apache-2.0"
  srcDir := "lean"
  fixedToolchain := true
  leanOptions := #[⟨`autoImplicit, false⟩]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "065356127b1dc0016f66b7283ce0ce2c4055aa55"

@[default_target]
lean_lib OAI

lean_lib FixedPointTheorems

-- Independent environments for the frozen Comparator challenge and its solution.
-- The challenge intentionally contains theorem holes and is never imported by OAI.
lean_lib ComparatorAudit
