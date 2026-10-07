module

public import OAI.LinearAlgebra.MatrixMultiplication.Arithmetic.FieldDescent
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Arithmetic.RankExponent
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Growth.PolynomialOverhead

public section

@[expose] section

namespace OAI.MatrixMultiplication.AuxiliarySeparation

noncomputable section
open Foundation
open scoped BigOperators

variable {F E : Type*} [Field F] [Field E] [Algebra F E]

/-- Relabel the coordinates of a tensor power as one matrix dimension. -/
theorem rankAtMost_matrixMultiplication_of_power {K : Type*} [Field K]
    {u j r : ℕ}
    (h : Tensor.RankAtMost
      (Tensor.power (matrixMultiplicationTensor (K := K) u u u) j) r) :
    Tensor.RankAtMost
      (matrixMultiplicationTensor (K := K) (u ^ j) (u ^ j) (u ^ j)) r := by
  classical
  let e : Fin (u ^ j) ≃ (Fin j → Fin u) := Fintype.equivOfCardEq (by simp)
  let f : Fin (u ^ j) × Fin (u ^ j) → Fin j → Fin u × Fin u :=
    fun x i => (e x.1 i, e x.2 i)
  have hp := h.pullback f f f
  have heq : Tensor.pullback f f f
      (Tensor.power (matrixMultiplicationTensor (K := K) u u u) j) =
      matrixMultiplicationTensor (K := K) (u ^ j) (u ^ j) (u ^ j) := by
    funext x y z
    simp only [Tensor.pullback, Tensor.power, matrixMultiplicationTensor, f,
      Fintype.prod_boole, forall_and, ← funext_iff, e.injective.eq_iff]
  rwa [heq] at hp

/-- A finite block over an algebraic extension bounds the base-field exponent.
The coefficients of this one block generate a finite algebra. Its dimension
is fixed while tensor powers remove the descent overhead. -/
theorem exactRankExponent_le_algebraic_extension_logb
    [Algebra.IsAlgebraic F E] {u : ℕ} (hu : 2 ≤ u) :
    exactRankExponent F ≤ Real.logb u (exactMatrixRank E u) := by
  have hext : Tensor.RankAtMost
      (fun x y z => algebraMap F E
        (matrixMultiplicationTensor (K := F) u u u x y z))
      (exactMatrixRank E u) := by
    have heq : (fun x y z => algebraMap F E
        (matrixMultiplicationTensor (K := F) u u u x y z)) =
        matrixMultiplicationTensor (K := E) u u u := by
      funext x y z
      unfold matrixMultiplicationTensor
      split_ifs <;> simp
    rw [heq]
    exact exactMatrixRank_spec (K := E) u
  obtain ⟨d, hd, hpow⟩ := hext.descend_algebraic_powers
  have hu0 : 0 < u := by omega
  have hu1 : 1 < (u : ℝ) := by exact_mod_cast (show 1 < u by omega)
  have hr0 : 0 < (exactMatrixRank E u : ℝ) := by
    exact_mod_cast (exactMatrixRank_pos (K := E) hu0)
  apply (Real.le_logb_iff_rpow_le hu1 hr0).mpr
  apply le_of_pow_le_const_mul_pow
    (a := (exactMatrixRank E u : ℝ)) (C := (d : ℝ) * d) (Nat.cast_nonneg _)
  intro j
  have hupper : exactMatrixRank F (u ^ j) ≤
      exactMatrixRank E u ^ j * d * d :=
    exactRank_le (rankAtMost_matrixMultiplication_of_power (hpow j))
  calc
    ((u : ℝ) ^ exactRankExponent F) ^ j =
        ((u ^ j : ℕ) : ℝ) ^ exactRankExponent F := by
      rw [Real.rpow_pow_comm (Nat.cast_nonneg u), Nat.cast_pow]
    _ ≤ (exactMatrixRank F (u ^ j) : ℝ) :=
      exactMatrixRank_rpow_lower_of_pos (K := F) (pow_pos hu0 j)
    _ ≤ ((exactMatrixRank E u ^ j * d * d : ℕ) : ℝ) := by
      exact_mod_cast hupper
    _ = ((d : ℝ) * d) * (exactMatrixRank E u : ℝ) ^ j := by
      push_cast
      ring

/-- Algebraic scalar extension preserves the exact-rank exponent in the
descent direction. No separability or characteristic hypothesis is needed. -/
theorem exactRankExponent_le_algebraic_extension [Algebra.IsAlgebraic F E] :
    exactRankExponent F ≤ exactRankExponent E := by
  apply le_csInf (exactRankExponentSet_nonempty (K := E))
  rintro τ ⟨u, hu, rfl⟩
  exact exactRankExponent_le_algebraic_extension_logb (F := F) (E := E) hu

/-- Every field can use its own algebraic closure and then descend the
exponent, with no restriction on its characteristic. -/
theorem exactRankExponent_le_algebraicClosure (F : Type*) [Field F] :
    exactRankExponent F ≤ exactRankExponent (AlgebraicClosure F) :=
  exactRankExponent_le_algebraic_extension (F := F) (E := AlgebraicClosure F)

end
end OAI.MatrixMultiplication.AuxiliarySeparation
