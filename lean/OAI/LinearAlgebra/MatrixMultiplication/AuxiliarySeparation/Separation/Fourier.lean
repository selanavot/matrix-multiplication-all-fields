module

/-
Upstream source and modification notice
Modified from OpenAI's matrix-multiplication sources to support arbitrary fields.
See UPSTREAM.md for provenance and changes; Apache-2.0 license retained in LICENSE.
-/

public import Mathlib.RingTheory.RootsOfUnity.AlgebraicallyClosed
public import Mathlib.Algebra.Ring.GeomSum
public import Mathlib.Algebra.Order.Group.Unbundled.Int
public import Lean.Elab.Tactic.Omega
public import Mathlib.RingTheory.RootsOfUnity.PrimitiveRoots

public section

@[expose] section

namespace OAI

/-!
# Finite root-of-unity filters

Averaging the integer powers of a primitive root over one period detects
exactly the exponents divisible by that period. This is the finite Fourier
filter used for auxiliary separation.
-/

open scoped BigOperators Classical

namespace MatrixMultiplication.AuxiliarySeparation

variable {K : Type*} [Field K]

/-- The sum over a complete period of a root of unity is zero unless the root is one. -/
lemma sum_pow_root_of_unity (z : K) (L : ℕ) (hz : z ^ L = 1) :
    (∑ r ∈ Finset.range L, z ^ r) = if z = 1 then (L : K) else 0 := by
  split_ifs with h
  · simp [h]
  · have hsum : (1 - z) * ∑ r ∈ Finset.range L, z ^ r = 0 := by
      rw [mul_neg_geom_sum, hz, sub_self]
    exact (mul_eq_zero.mp hsum).resolve_left (sub_ne_zero.mpr (Ne.symm h))

/-- An unnormalized finite Fourier filter, with an integer exponent. -/
theorem sum_zpow_primitive_root {ζ : K} {L : ℕ}
    (hζ : IsPrimitiveRoot ζ L) (e : ℤ) :
    (∑ r ∈ Finset.range L, ζ ^ ((r : ℤ) * e)) =
      if (L : ℤ) ∣ e then (L : K) else 0 := by
  have hpow : (ζ ^ e) ^ L = 1 := by
    rw [← zpow_natCast, ← zpow_mul, mul_comm, zpow_mul, hζ.zpow_eq_one, one_zpow]
  have hterm (r : ℕ) : ζ ^ ((r : ℤ) * e) = (ζ ^ e) ^ r := by
    rw [← zpow_natCast, ← zpow_mul, mul_comm]
  simp_rw [hterm]
  rw [sum_pow_root_of_unity _ _ hpow]
  simp only [hζ.zpow_eq_one_iff_dvd]

/-- Averaging over a primitive root's period selects exactly its divisible exponents. -/
theorem normalized_sum_zpow_primitive_root {ζ : K} {L : ℕ}
    (hL : (L : K) ≠ 0) (hζ : IsPrimitiveRoot ζ L) (e : ℤ) :
    (L : K)⁻¹ * (∑ r ∈ Finset.range L, ζ ^ ((r : ℤ) * e)) =
      if (L : ℤ) ∣ e then 1 else 0 := by
  rw [sum_zpow_primitive_root hζ e]
  split_ifs <;> simp [hL]

/-- Divisibility by a positive period is exact equality to zero inside one period. -/
lemma int_dvd_iff_eq_zero_of_abs_lt {L : ℕ} {e : ℤ} (he : |e| < (L : ℤ)) :
    (L : ℤ) ∣ e ↔ e = 0 := by
  constructor
  · intro hd
    apply abs_eq_zero.mp
    exact Int.eq_zero_of_dvd_of_nonneg_of_lt (abs_nonneg e) he
      ((dvd_abs (L : ℤ) e).mpr hd)
  · rintro rfl
    exact dvd_zero _

/-- Within one period, the finite Fourier filter selects exactly exponent zero. -/
theorem normalized_sum_zpow_primitive_root_of_abs_lt {ζ : K} {L : ℕ} {e : ℤ}
    (hL : (L : K) ≠ 0) (hζ : IsPrimitiveRoot ζ L) (he : |e| < (L : ℤ)) :
    (L : K)⁻¹ * (∑ r ∈ Finset.range L, ζ ^ ((r : ℤ) * e)) =
      if e = 0 then 1 else 0 := by
  rw [normalized_sum_zpow_primitive_root hL hζ e]
  simp only [int_dvd_iff_eq_zero_of_abs_lt he]


/-- A Fourier period at least `5M` whose scalar is invertible, in every characteristic. -/
noncomputable def separationPeriod (K : Type*) [Field K] (M : ℕ) : ℕ := by
  classical
  exact if ((5 * M : ℕ) : K) = 0 then 5 * M + 1 else 5 * M

theorem separationPeriod_lower (M : ℕ) : 5 * M ≤ separationPeriod K M := by
  classical
  unfold separationPeriod
  split_ifs <;> omega

theorem separationPeriod_upper {M : ℕ} (hM : 0 < M) :
    separationPeriod K M ≤ 6 * M := by
  classical
  unfold separationPeriod
  split_ifs <;> omega

theorem separationPeriod_cast_ne_zero (M : ℕ) : (separationPeriod K M : K) ≠ 0 := by
  classical
  unfold separationPeriod
  split_ifs with h
  · simp only [Nat.cast_add, Nat.cast_one, h, zero_add, ne_eq, one_ne_zero, not_false_eq_true]
  · exact h

theorem separationPeriod_ne_zero (M : ℕ) : separationPeriod K M ≠ 0 := by
  intro h
  have hn := separationPeriod_cast_ne_zero (K := K) M
  simp only [h, Nat.cast_zero, ne_eq, not_true_eq_false] at hn

/-- Algebraic closedness supplies the primitive root for the adjusted period. -/
theorem exists_separationPrimitiveRoot [IsAlgClosed K] (M : ℕ) :
    ∃ ζ : K, IsPrimitiveRoot ζ (separationPeriod K M) := by
  let : NeZero (separationPeriod K M : K) :=
    ⟨separationPeriod_cast_ne_zero (K := K) M⟩
  exact HasEnoughRootsOfUnity.exists_primitiveRoot K _

end MatrixMultiplication.AuxiliarySeparation

end OAI
