import OAI.LinearAlgebra.MatrixMultiplication.AllFields
import Mathlib.Data.ZMod.Basic

/-!
# Checks of the all-fields theorem and its specification

The generic example below has only `[Field F]`, in an arbitrary universe.
The small-characteristic examples also exercise the finite fields for which
the original fixed Fourier period or integer interpolation nodes can fail.
The cost example retains the upstream program correctness and cost model.
-/

namespace OAI.MatrixMultiplication.AllFieldsAudit

universe u

local instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩

example (F : Type u) [Field F] : Arithmetic.omega F ≤ (9 : ℝ) / 4 :=
  omega_le_nine_quarters F

example : Arithmetic.omega (ZMod 2) ≤ (9 : ℝ) / 4 :=
  omega_le_nine_quarters (ZMod 2)

example : Arithmetic.omega (ZMod 3) ≤ (9 : ℝ) / 4 :=
  omega_le_nine_quarters (ZMod 3)

example : Arithmetic.omega (ZMod 5) ≤ (9 : ℝ) / 4 :=
  omega_le_nine_quarters (ZMod 5)

example : Arithmetic.omega ℚ ≤ (9 : ℝ) / 4 := omega_le_nine_quarters ℚ

example : Arithmetic.omega ℝ ≤ (9 : ℝ) / 4 := omega_le_nine_quarters ℝ

example : Arithmetic.omega ℂ ≤ (9 : ℝ) / 4 := complex_omega_le_nine_quarters

-- Infinite positive characteristic; no perfectness assumption is supplied.
example : Arithmetic.omega (RatFunc (ZMod 2)) ≤ (9 : ℝ) / 4 :=
  omega_le_nine_quarters (RatFunc (ZMod 2))

-- This stronger intermediate statement concerns exact tensor coefficients,
-- not just equality of functions on the finite set of field-valued inputs.
example (F : Type u) [Field F] (ε : ℝ) (hε : 0 < ε) :
    ∃ n R : ℕ, 2 ≤ n ∧
      Foundation.Tensor.RankAtMost
        (AuxiliarySeparation.matrixMultiplicationTensor (K := F) n n n) R ∧
      (R : ℝ) ≤ (n : ℝ) ^ ((9 : ℝ) / 4 + ε) := by
  obtain ⟨n, R, hn, hRank, hR⟩ :=
    AuxiliarySeparation.exists_rankAtMost_of_exponent_slack (K := F) hε
  refine ⟨n, R, hn, hRank, hR.trans ?_⟩
  apply Real.rpow_le_rpow_of_exponent_le
  · exact_mod_cast (show 1 ≤ n by omega)
  · linarith [AuxiliarySeparation.exactRankExponent_le_nine_quarters_allFields F]

-- Regression witnesses for the distinction in the original Model.Correct:
-- x^2 = x as functions on F₂, but not as formal polynomials over F₂.
example : ∀ x : ZMod 2, x ^ 2 = x := by decide

example : (Polynomial.X : Polynomial (ZMod 2)) ^ 2 ≠ Polynomial.X := by
  intro h
  have hcoeff := congrArg (fun p : Polynomial (ZMod 2) => p.coeff 2) h
  norm_num [Polynomial.coeff_X] at hcoeff

example (F : Type u) [Field F] (ε : ℝ) (hε : 0 < ε) :
    ∃ C : ℝ, 0 < C ∧ ∀ n : ℕ, 1 ≤ n →
      ∃ P : Arithmetic.MatrixAlgorithm F n n n,
        P.Correct ∧ (P.cost : ℝ) ≤ C * (n : ℝ) ^ ((9 : ℝ) / 4 + ε) :=
  AuxiliarySeparation.matrix_multiplication_cost_le F ε hε

#check @OAI.MatrixMultiplication.omega_le_nine_quarters

/- The guarded messages make any new axiom dependency a build failure. -/

/-- info: 'OAI.MatrixMultiplication.omega_le_nine_quarters' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.omega_le_nine_quarters

/-- info: 'OAI.MatrixMultiplication.AuxiliarySeparation.exactRankExponent_le_nine_quarters_allFields' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.AuxiliarySeparation.exactRankExponent_le_nine_quarters_allFields

/-- info: 'OAI.MatrixMultiplication.complex_omega_le_nine_quarters' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.complex_omega_le_nine_quarters

/-- info: 'OAI.MatrixMultiplication.AuxiliarySeparation.matrix_multiplication_cost_le' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.AuxiliarySeparation.matrix_multiplication_cost_le

/-- info: 'OAI.MatrixMultiplication.AuxiliarySeparation.exactRankExponent_le_algebraicClosure' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.AuxiliarySeparation.exactRankExponent_le_algebraicClosure

/-- info: 'OAI.MatrixMultiplication.AuxiliarySeparation.exists_detecting_character' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.AuxiliarySeparation.exists_detecting_character

/-- info: 'OAI.MatrixMultiplication.Foundation.Tensor.RankAtMost.descend_algebraicClosure_powers' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.Foundation.Tensor.RankAtMost.descend_algebraicClosure_powers

/-- info: 'OAI.MatrixMultiplication.Foundation.Tensor.RankAtMost.descend_algebraic_powers' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.Foundation.Tensor.RankAtMost.descend_algebraic_powers

/-- info: 'OAI.MatrixMultiplication.AuxiliarySeparation.exactRankExponent_le_algebraic_extension' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.AuxiliarySeparation.exactRankExponent_le_algebraic_extension

/-- info: 'OAI.MatrixMultiplication.Arithmetic.admissibleExponent_of_rankAtMost' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in
#print axioms OAI.MatrixMultiplication.Arithmetic.admissibleExponent_of_rankAtMost

end OAI.MatrixMultiplication.AllFieldsAudit
