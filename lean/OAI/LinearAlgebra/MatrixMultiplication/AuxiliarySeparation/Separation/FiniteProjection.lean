module

/-
Upstream source and modification notice
Modified from OpenAI's matrix-multiplication sources to support arbitrary fields.
See UPSTREAM.md for provenance and changes; Apache-2.0 license retained in LICENSE.
-/

public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Separation.Fourier
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Separation.NoWrap
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Separation.SquareWeights
public import Mathlib.Algebra.Polynomial.Degree.Lemmas

public section

@[expose] section

namespace OAI

/-!
# Exact finite Fourier projection and square filtering

A Fourier average with period at least `5 * M` is applied to an arbitrary branch coefficient.
The label bounds eliminate modular wrap. The weights on the three tensor legs
then give a nonnegative square degree on every surviving branch. Taking the
constant coefficient retains exactly the branches with `g = h` and `u = v`.

The finite-family statements permit arbitrary coefficients and arbitrary
repetitions of labels; they use only linearity of the Fourier projection and
coefficient extraction, without assumptions on an ambient tensor.
-/

open scoped BigOperators Classical

namespace MatrixMultiplication.AuxiliarySeparation

variable {K : Type*} [Field K]

/-- A normalized finite Fourier average of one branch coefficient. -/
noncomputable def finiteFourierCoefficient (ζ : K) (L : ℕ) (e : ℤ) (c : K) : K :=
  (L : K)⁻¹ * ∑ r ∈ Finset.range L, ζ ^ ((r : ℤ) * e) * c

/-- The Fourier average is a scalar support indicator, for every coefficient. -/
theorem finiteFourierCoefficient_eq_ite {ζ : K} {L : ℕ}
    (hL : (L : K) ≠ 0) (hζ : IsPrimitiveRoot ζ L) (e : ℤ) (c : K) :
    finiteFourierCoefficient ζ L e c = if (L : ℤ) ∣ e then c else 0 := by
  unfold finiteFourierCoefficient
  rw [← Finset.sum_mul, ← mul_assoc, normalized_sum_zpow_primitive_root hL hζ]
  split_ifs <;> simp

/-- Averaging a finite family of branches agrees with averaging each branch. -/
theorem finiteFourierCoefficient_sum {ι : Type*} (s : Finset ι)
    (ζ : K) (L : ℕ) (e : ι → ℤ) (c : ι → K) :
    (L : K)⁻¹ * (∑ r ∈ Finset.range L, ∑ i ∈ s, ζ ^ ((r : ℤ) * e i) * c i) =
      ∑ i ∈ s, finiteFourierCoefficient ζ L (e i) (c i) := by
  rw [Finset.sum_comm, Finset.mul_sum]
  rfl

/-- Any invertible period at least `5 * M` selects the integer support equation. -/
theorem fiveMFourierCoefficient_eq_ite {ζ : K} {M L : ℕ} {g h u v : ℤ}
    (hM : 0 < M) (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0)
    (hζ : IsPrimitiveRoot ζ L)
    (hg : 1 ≤ g ∧ g ≤ M) (hh : 1 ≤ h ∧ h ≤ M)
    (hu : 1 ≤ u ∧ u ≤ M) (hv : 1 ≤ v ∧ v ≤ M) (c : K) :
    finiteFourierCoefficient ζ L (phase g h u v) c =
      if phase g h u v = 0 then c else 0 := by
  rw [finiteFourierCoefficient_eq_ite hLcast hζ]
  have he : |phase g h u v| < (L : ℤ) := by
    have hp := fourierPhase_abs_lt (M := (M : ℤ)) (by omega) hh hg hu hv
    have hL' : (5 : ℤ) * M ≤ L := by exact_mod_cast hL
    exact lt_of_lt_of_le hp hL'
  simp only [int_dvd_iff_eq_zero_of_abs_lt he]

/-- A projected branch, recorded as an ordinary polynomial after Fourier averaging. -/
noncomputable def projectedBranchPolynomial (ζ : K) (L : ℕ)
    (g h u v : ℤ) (c : K) : Polynomial K :=
  Polynomial.monomial (totalDegree g h u v)
    (finiteFourierCoefficient ζ L (phase g h u v) c)

/-- The surviving polynomial weight is the square `(g - h)^2`. -/
theorem projectedBranchPolynomial_eq_ite {ζ : K} {M L : ℕ} {g h u v : ℤ}
    (hM : 0 < M) (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0)
    (hζ : IsPrimitiveRoot ζ L)
    (hg : 1 ≤ g ∧ g ≤ M) (hh : 1 ≤ h ∧ h ≤ M)
    (hu : 1 ≤ u ∧ u ≤ M) (hv : 1 ≤ v ∧ v ≤ M) (c : K) :
    projectedBranchPolynomial ζ L g h u v c =
      if phase g h u v = 0 then Polynomial.monomial ((g - h) ^ 2).toNat c else 0 := by
  unfold projectedBranchPolynomial
  rw [fiveMFourierCoefficient_eq_ite hM hL hLcast hζ hg hh hu hv]
  split_ifs with hp
  · rw [totalDegree, totalWeight_eq_sq_of_phase_eq_zero hp]
  · simp

/-- A coefficient occurs exactly on the Fourier support at its integer total weight. -/
theorem projectedBranchPolynomial_coeff {ζ : K} {M L n : ℕ} {g h u v : ℤ}
    (hM : 0 < M) (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0)
    (hζ : IsPrimitiveRoot ζ L)
    (hg : 1 ≤ g ∧ g ≤ M) (hh : 1 ≤ h ∧ h ≤ M)
    (hu : 1 ≤ u ∧ u ≤ M) (hv : 1 ≤ v ∧ v ≤ M) (c : K) :
    (projectedBranchPolynomial ζ L g h u v c).coeff n =
      if phase g h u v = 0 ∧ totalWeight g h u v = (n : ℤ) then c else 0 := by
  unfold projectedBranchPolynomial
  rw [fiveMFourierCoefficient_eq_ite hM hL hLcast hζ hg hh hu hv]
  by_cases hp : phase g h u v = 0
  · have hd : totalDegree g h u v = n ↔ totalWeight g h u v = (n : ℤ) := by
      have hcast := totalDegree_cast_of_phase_eq_zero hp
      omega
    simp only [hp, ↓reduceIte, Polynomial.coeff_monomial, hd, true_and]
  · simp [hp]

/-- Each projected branch has no polynomial coefficient above `(M - 1)^2`. -/
theorem projectedBranchPolynomial_coeff_eq_zero_of_lt
    {ζ : K} {M L n : ℕ} {g h u v : ℤ}
    (hM : 0 < M) (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0)
    (hζ : IsPrimitiveRoot ζ L)
    (hg : 1 ≤ g ∧ g ≤ M) (hh : 1 ≤ h ∧ h ≤ M)
    (hu : 1 ≤ u ∧ u ≤ M) (hv : 1 ≤ v ∧ v ≤ M)
    (hn : (M - 1) ^ 2 < n) (c : K) :
    (projectedBranchPolynomial ζ L g h u v c).coeff n = 0 := by
  unfold projectedBranchPolynomial
  rw [fiveMFourierCoefficient_eq_ite hM hL hLcast hζ hg hh hu hv]
  split_ifs with hp
  · have hd := totalDegree_le_of_labels hg hh hp
    exact Polynomial.coeff_monomial_of_ne c (by omega)
  · simp

/-- Constant coefficient extraction is the exact square filter, with no restriction
on the original field coefficient. -/
theorem projectedBranchPolynomial_coeff_zero {ζ : K} {M L : ℕ} {g h u v : ℤ}
    (hM : 0 < M) (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0)
    (hζ : IsPrimitiveRoot ζ L)
    (hg : 1 ≤ g ∧ g ≤ M) (hh : 1 ≤ h ∧ h ≤ M)
    (hu : 1 ≤ u ∧ u ≤ M) (hv : 1 ≤ v ∧ v ≤ M) (c : K) :
    (projectedBranchPolynomial ζ L g h u v c).coeff 0 =
      if g = h ∧ u = v then c else 0 := by
  unfold projectedBranchPolynomial
  rw [fiveMFourierCoefficient_eq_ite hM hL hLcast hζ hg hh hu hv]
  by_cases hp : phase g h u v = 0
  · simp only [hp, ↓reduceIte, Polynomial.coeff_monomial,
      totalDegree_eq_zero_iff_of_phase_eq_zero hp]
  · have hlabels : ¬ (g = h ∧ u = v) := by
      rintro ⟨rfl, rfl⟩
      exact hp (by simp [phase])
    simp [hp, hlabels]

/-- Apply the finite Fourier projection and square weights branch by branch. -/
noncomputable def projectedPolynomial {ι : Type*} (s : Finset ι)
    (ζ : K) (L : ℕ) (g h u v : ι → ℤ) (c : ι → K) : Polynomial K :=
  ∑ i ∈ s, projectedBranchPolynomial ζ L (g i) (h i) (u i) (v i) (c i)

/-- Every coefficient of the projected polynomial has the exact integer support. -/
theorem projectedPolynomial_coeff {ι : Type*} (s : Finset ι)
    {ζ : K} {M L n : ℕ} (g h u v : ι → ℤ) (c : ι → K)
    (hM : 0 < M) (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0)
    (hζ : IsPrimitiveRoot ζ L)
    (hg : ∀ i ∈ s, 1 ≤ g i ∧ g i ≤ M) (hh : ∀ i ∈ s, 1 ≤ h i ∧ h i ≤ M)
    (hu : ∀ i ∈ s, 1 ≤ u i ∧ u i ≤ M) (hv : ∀ i ∈ s, 1 ≤ v i ∧ v i ≤ M) :
    (projectedPolynomial s ζ L g h u v c).coeff n =
      ∑ i ∈ s, if phase (g i) (h i) (u i) (v i) = 0 ∧
        totalWeight (g i) (h i) (u i) (v i) = (n : ℤ) then c i else 0 := by
  classical
  unfold projectedPolynomial
  simp only [Polynomial.finsetSum_coeff]
  apply Finset.sum_congr rfl
  intro i hi
  exact projectedBranchPolynomial_coeff hM hL hLcast hζ (hg i hi) (hh i hi)
    (hu i hi) (hv i hi) (c i)

/-- Exact finite filtering for an arbitrary finite family of branch coefficients. -/
theorem projectedPolynomial_coeff_zero {ι : Type*} (s : Finset ι)
    {ζ : K} {M L : ℕ} (g h u v : ι → ℤ) (c : ι → K)
    (hM : 0 < M) (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0)
    (hζ : IsPrimitiveRoot ζ L)
    (hg : ∀ i ∈ s, 1 ≤ g i ∧ g i ≤ M) (hh : ∀ i ∈ s, 1 ≤ h i ∧ h i ≤ M)
    (hu : ∀ i ∈ s, 1 ≤ u i ∧ u i ≤ M) (hv : ∀ i ∈ s, 1 ≤ v i ∧ v i ≤ M) :
    (projectedPolynomial s ζ L g h u v c).coeff 0 =
      ∑ i ∈ s, if g i = h i ∧ u i = v i then c i else 0 := by
  classical
  unfold projectedPolynomial
  simp only [Polynomial.finsetSum_coeff]
  apply Finset.sum_congr rfl
  intro i hi
  exact projectedBranchPolynomial_coeff_zero hM hL hLcast hζ (hg i hi) (hh i hi)
    (hu i hi) (hv i hi) (c i)

/-- The finite projected polynomial has support only in degrees at most `(M - 1)^2`. -/
theorem projectedPolynomial_coeff_eq_zero_of_lt {ι : Type*} (s : Finset ι)
    {ζ : K} {M L n : ℕ} (g h u v : ι → ℤ) (c : ι → K)
    (hM : 0 < M) (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0)
    (hζ : IsPrimitiveRoot ζ L)
    (hg : ∀ i ∈ s, 1 ≤ g i ∧ g i ≤ M) (hh : ∀ i ∈ s, 1 ≤ h i ∧ h i ≤ M)
    (hu : ∀ i ∈ s, 1 ≤ u i ∧ u i ≤ M) (hv : ∀ i ∈ s, 1 ≤ v i ∧ v i ≤ M)
    (hn : (M - 1) ^ 2 < n) :
    (projectedPolynomial s ζ L g h u v c).coeff n = 0 := by
  classical
  unfold projectedPolynomial
  simp only [Polynomial.finsetSum_coeff]
  apply Finset.sum_eq_zero
  intro i hi
  exact projectedBranchPolynomial_coeff_eq_zero_of_lt hM hL hLcast hζ (hg i hi) (hh i hi)
    (hu i hi) (hv i hi) hn (c i)

/-- The degree bound is independent of the number or values of the coefficients. -/
theorem projectedPolynomial_natDegree_le {ι : Type*} (s : Finset ι)
    {ζ : K} {M L : ℕ} (g h u v : ι → ℤ) (c : ι → K)
    (hM : 0 < M) (hL : 5 * M ≤ L) (hLcast : (L : K) ≠ 0)
    (hζ : IsPrimitiveRoot ζ L)
    (hg : ∀ i ∈ s, 1 ≤ g i ∧ g i ≤ M) (hh : ∀ i ∈ s, 1 ≤ h i ∧ h i ≤ M)
    (hu : ∀ i ∈ s, 1 ≤ u i ∧ u i ≤ M) (hv : ∀ i ∈ s, 1 ≤ v i ∧ v i ≤ M) :
    (projectedPolynomial s ζ L g h u v c).natDegree ≤ (M - 1) ^ 2 := by
  rw [Polynomial.natDegree_le_iff_coeff_eq_zero]
  intro n hn
  exact projectedPolynomial_coeff_eq_zero_of_lt s g h u v c hM hL hLcast hζ hg hh hu hv hn

end MatrixMultiplication.AuxiliarySeparation

end OAI
