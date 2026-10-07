module

public import OAI.LinearAlgebra.MatrixMultiplication.AllFieldsAudit

public section

@[expose] section

/-! Proofs for the separately frozen Comparator challenge.
This file must not import `ComparatorAudit.Challenge`. -/

namespace ComparatorChecks

open scoped BigOperators

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

/-- Exact coefficient identities for matrix multiplication, over every field.
For every positive exponent slack there is a block of size at least two whose
rank-one decomposition has at most n^(9/4 + ε) terms. Equality is coordinatewise,
so it is stronger than equality of functions on finite-field inputs. -/
theorem exact_coefficients (F : Type u) [Field F] (ε : ℝ) (hε : 0 < ε) :
    ∃ n R : ℕ, 2 ≤ n ∧ (R : ℝ) ≤ (n : ℝ) ^ ((9 : ℝ) / 4 + ε) ∧
      ∃ (a : Fin R → (Fin n × Fin n) → F)
        (b : Fin R → (Fin n × Fin n) → F)
        (c : Fin R → (Fin n × Fin n) → F),
        ∀ x y z : Fin n × Fin n,
          (if x.2 = y.1 ∧ y.2 = z.1 ∧ z.2 = x.1 then 1 else 0 : F) =
            ∑ i, a i x * b i y * c i z :=
  by
    obtain ⟨n, R, hn, hRank, hR⟩ :=
      AuxiliarySeparation.exists_rankAtMost_of_exponent_slack (K := F) hε
    have hBound : (R : ℝ) ≤ (n : ℝ) ^ ((9 : ℝ) / 4 + ε) := by
      apply hR.trans
      apply Real.rpow_le_rpow_of_exponent_le
      · exact_mod_cast (show 1 ≤ n by omega)
      · linarith [AuxiliarySeparation.exactRankExponent_le_nine_quarters_allFields F]
    obtain ⟨a, b, c, h⟩ := hRank
    refine ⟨n, R, hn, hBound, a, b, c, ?_⟩
    intro x y z
    exact congrFun (congrFun (congrFun h x) y) z

end ComparatorChecks
