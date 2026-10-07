module

public import Mathlib.Basic.Real.Basic
public import Mathlib.Tactic

public section

@[expose] section

namespace OAI

/-!
# Exact growth of the product in Section 6

The paper's sequence starts at `G₁ = 1`. Here `growthProduct n` denotes
`Gₙ₊₁`. Cubing each factor gives an elementary lower bound, so no logarithmic
asymptotics are needed for this part of the argument.
-/

namespace MatrixMultiplication.AuxiliarySeparation

/-- The product sequence from Section 6, indexed from zero. -/
noncomputable def growthProduct : ℕ → ℝ
  | 0 => 1
  | n + 1 => growthProduct n * (1 + 1 / (3 * ((n : ℝ) + 1)))

@[simp] theorem growthProduct_zero : growthProduct 0 = 1 := rfl

@[simp] theorem growthProduct_succ (n : ℕ) :
    growthProduct (n + 1) = growthProduct n * (1 + 1 / (3 * ((n : ℝ) + 1))) := rfl

theorem growthProduct_pos (n : ℕ) : 0 < growthProduct n := by
  induction n with
  | zero => norm_num
  | succ n ih =>
    rw [growthProduct_succ]
    exact mul_pos ih (by positivity)

/-- Cubing one product factor dominates the corresponding telescoping factor. -/
theorem one_add_recip_three_cube_lower {a : ℝ} (ha : 0 < a) :
    1 + 1 / a ≤ (1 + 1 / (3 * a)) ^ 3 := by
  have hnonneg : 0 ≤ 1 / (3 * a) := by positivity
  have hdiv : 1 / a = 3 * (1 / (3 * a)) := by
    field_simp
  rw [hdiv]
  nlinarith [sq_nonneg (1 / (3 * a)),
    mul_nonneg (sq_nonneg (1 / (3 * a))) hnonneg]

/-- The exact lower bound `Gₙ₊₁³ ≥ n + 1`. -/
theorem growthProduct_cube_lower (n : ℕ) :
    (n : ℝ) + 1 ≤ growthProduct n ^ 3 := by
  induction n with
  | zero => norm_num
  | succ n ih =>
    have ha : 0 < (n : ℝ) + 1 := by positivity
    have hfactor := one_add_recip_three_cube_lower ha
    have hfactor_nonneg : 0 ≤ (1 + 1 / (3 * ((n : ℝ) + 1))) ^ 3 := by
      positivity
    have hfirst := mul_le_mul_of_nonneg_right ih hfactor_nonneg
    have hsecond := mul_le_mul_of_nonneg_left hfactor (le_of_lt ha)
    have htelescoping : ((n : ℝ) + 1) * (1 + 1 / ((n : ℝ) + 1)) =
        (n : ℝ) + 2 := by
      field_simp
      ring
    rw [growthProduct_succ, mul_pow]
    push_cast
    linarith

end MatrixMultiplication.AuxiliarySeparation

end OAI
