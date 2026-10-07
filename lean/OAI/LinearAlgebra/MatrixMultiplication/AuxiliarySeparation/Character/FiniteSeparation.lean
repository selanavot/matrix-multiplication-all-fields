module

/-
Upstream source and modification notice
Modified from OpenAI's matrix-multiplication sources to support arbitrary fields.
See UPSTREAM.md for provenance and changes; Apache-2.0 license retained in LICENSE.
-/

public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Separation.Basic
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Character.Degeneration
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Character.Dot
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Tensor.CharacterBounds

public section

@[expose] section

namespace OAI

/-!
# The character bound from finite separation

The explicit Fourier and square-weight construction gives a polynomial tensor
whose nonzero evaluations restrict from at most `6M` complete source copies.
Character monotonicity follows by interpolation and tensor powering; it does
not require continuity of the character.
-/

noncomputable section

open MatrixMultiplication.Foundation
open scoped BigOperators

namespace MatrixMultiplication.AuxiliarySeparation

variable {K : Type*} [Field K]

variable {M : ℕ} {X Y Z : Type}
variable [Fintype X] [Fintype Y] [Fintype Z]

omit [Fintype Z] in
theorem polynomial_rank_bound
    (P : Tensor (Polynomial K) X Y Z) :
    Tensor.RankAtMost P (Fintype.card (X × Y)) := by
  classical
  let a : X × Y → X → Polynomial K := fun i x => if i.1 = x then 1 else 0
  let b : X × Y → Y → Polynomial K := fun i y => if i.2 = y then 1 else 0
  let c : X × Y → Z → Polynomial K := fun i z => P i.1 i.2 z
  have heq : P = fun x y z => ∑ i, Tensor.rankOne (a i) (b i) (c i) x y z := by
    funext x y z
    simp [Tensor.rankOne, a, b, c, Fintype.sum_prod_type, ite_mul, mul_ite]
  rw [heq]
  exact Tensor.rankAtMost_sum_rankOne a b c

/-- The explicit separation polynomial, viewed as a polynomial approximation
to its constant tensor. Its rank bound is supplied by a coordinate expansion. -/
def separationPolynomialApproximation {ζ : K} {L : ℕ} (hM : 0 < M)
    (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0) (hζ : IsPrimitiveRoot ζ L) (B : Fin M → Tensor K X Y Z) :
    Tensor.PolynomialApproximation (separationTarget B)
      (Fintype.card ((X × Fin M) × ((Fin M × Y) × Fin M))) 0 ((M - 1) ^ 2) where
  polynomial := separationPolynomial ζ L B
  rank_bound := polynomial_rank_bound _
  vanishes := by
    intro _ _ _ k hk
    exact (Nat.not_lt_zero k hk).elim
  leading := by
    intro x y z
    exact congrFun (congrFun (congrFun (separationPolynomial_coeff_zero hM hL hLcast hζ B) x) y) z
  degree_bound := separationPolynomial_degree hM hL hLcast hζ B

namespace Character

variable (χ : (Character K))

/-- The separated constant tensor costs at most the character of the `6M`
source copies. This uses the explicit polynomial, not topological continuity. -/
theorem value_separationTarget_le [IsAlgClosed K] (hM : 0 < M) (B : Fin M → Tensor K X Y Z) :
    χ.value (separationTarget B) ≤
      6 * (M : ℝ) * χ.value (sharedFirstTensor B) := by
  classical
  let L := separationPeriod K M
  obtain ⟨ζ, hζ⟩ := exists_separationPrimitiveRoot (K := K) M
  have hL : 5 * M ≤ L := separationPeriod_lower (K := K) M
  have hLcast : (L : K) ≠ 0 := separationPeriod_cast_ne_zero (K := K) M
  have hbound : χ.value (separationTarget B) ≤
      χ.value (Tensor.directSum (fun _ : Fin L => sharedFirstTensor B)) := by
    apply χ.value_le_of_polynomialApproximation
      (separationPolynomialApproximation hM hL hLcast hζ B) (χ.nonneg _)
    intro t ht
    change χ.value (fun x y z => (separationPolynomial ζ L B x y z).eval t) ≤ _
    rw [separationPolynomial_eval hM hL hLcast hζ B t ht]
    exact χ.monotone _ _ _ _
  calc
    χ.value (separationTarget B) ≤ (L : ℝ) * χ.value (sharedFirstTensor B) := by
      simpa only [χ.value_copies] using hbound
    _ ≤ 6 * (M : ℝ) * χ.value (sharedFirstTensor B) := by
      have hupper : (L : ℝ) ≤ 6 * (M : ℝ) := by
        exact_mod_cast separationPeriod_upper (K := K) hM
      exact mul_le_mul_of_nonneg_right hupper (χ.nonneg _)

/-- Character accounting for the genuine direct sum in the separated tensor. -/
theorem value_separationTarget (hM : 0 < M) (B : Fin M → Tensor K X Y Z) :
    χ.value (separationTarget B) =
      (∑ h, χ.value (B h)) * (M : ℝ) ^ χ.pX := by
  classical
  rw [separationTarget_eq_directSum, χ.value_reindex, χ.map_directSum]
  simp only [χ.map_product, χ.value_cyclic_cyclic_dotPairing hM, Finset.sum_mul]

/-- Exact finite character separation: the common first coordinate can be
separated at a cost of `6M`, retaining an `M`-dimensional first-leg dot factor. -/
theorem finiteSeparation_bound [IsAlgClosed K] (hM : 0 < M) (B : Fin M → Tensor K X Y Z) :
    (∑ h, χ.value (B h)) * (M : ℝ) ^ χ.pX ≤
      6 * (M : ℝ) * χ.value (sharedFirstTensor B) := by
  rw [← χ.value_separationTarget hM B]
  exact χ.value_separationTarget_le hM B

end Character
end MatrixMultiplication.AuxiliarySeparation

end

end OAI
