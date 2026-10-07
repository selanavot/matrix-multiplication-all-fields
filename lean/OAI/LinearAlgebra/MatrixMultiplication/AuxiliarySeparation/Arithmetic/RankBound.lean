module

/-
Upstream source and modification notice
Modified from OpenAI's matrix-multiplication sources to support arbitrary fields.
See UPSTREAM.md for provenance and changes; Apache-2.0 license retained in LICENSE.
-/

public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Character.Existence
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Arithmetic.CharacterRounding
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Polynomial.Inequalities

public section

@[expose] section

namespace OAI

/-!
# The exact-rank exponent bound

Detecting characters exist by Appendix A. The determinant and three-sector
polynomial constructions bound the sum of their dot-product exponents by
`9/4`. Integer rounding then gives the same bound for the exact-rank exponent.
-/

namespace MatrixMultiplication.AuxiliarySeparation

variable {K : Type*} [Field K]

/-- The polynomial inequalities bound the actual exact-rank exponent. -/
theorem exactRankExponent_le_nine_quarters [IsAlgClosed K] : (exactRankExponent K) ≤ (9 : ℝ) / 4 := by
  apply exactRankExponent_le_nine_quarters_of_characters
  · intro d hd k hk
    exact exists_detecting_character hd hk
  · intro χ d hd
    rw [χ.value_matrixMultiplication (by omega)]
    exact Real.rpow_le_rpow_of_exponent_le
      (by exact_mod_cast (show 1 ≤ d by omega)) χ.exponent_sum_le_nine_quarters

end MatrixMultiplication.AuxiliarySeparation

end OAI
