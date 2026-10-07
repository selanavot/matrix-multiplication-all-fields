import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Main

/-! Proofs for the separately frozen Comparator challenge.
This file must not import `ComparatorAudit.Challenge`. -/

namespace ComparatorChecks

universe u
open OAI.MatrixMultiplication

theorem omega_bound (F : Type u) [Field F] :
    Arithmetic.omega F ≤ (9 : ℝ) / 4 :=
  AuxiliarySeparation.omega_le_nine_quarters F

theorem admissible_bddBelow (F : Type u) [Field F] :
    BddBelow {τ : ℝ | Arithmetic.AdmissibleExponent F τ} :=
  Arithmetic.admissibleExponent_bddBelow F

theorem admissible_nonempty (F : Type u) [Field F] :
    Set.Nonempty {τ : ℝ | Arithmetic.AdmissibleExponent F τ} :=
  Arithmetic.admissibleExponent_nonempty (F := F)

theorem omega_lower (F : Type u) [Field F] :
    (2 : ℝ) ≤ Arithmetic.omega F :=
  Arithmetic.omega_two_le (F := F)

theorem epsilon_cost (F : Type u) [Field F] (ε : ℝ) (hε : 0 < ε) :
    ∃ C : ℝ, 0 < C ∧ ∀ n : ℕ, 1 ≤ n →
      ∃ P : Arithmetic.MatrixAlgorithm F n n n,
        P.Correct ∧ (P.cost : ℝ) ≤
          C * (n : ℝ) ^ ((9 : ℝ) / 4 + ε) :=
  AuxiliarySeparation.matrix_multiplication_cost_le F ε hε

end ComparatorChecks
