module

/-
Upstream source and modification notice
Modified from OpenAI's matrix-multiplication sources to support arbitrary fields.
See UPSTREAM.md for provenance and changes; Apache-2.0 license retained in LICENSE.
-/

public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Arithmetic.Exponent
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Arithmetic.RankBound
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Arithmetic.FieldExtension
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Convolution.RankLowerBound
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Determinant.Bounds
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Growth.Floor

public section

@[expose] section

namespace OAI

/-!
# Matrix multiplication via auxiliary separation and polynomial multiplication

Theorem 1.1 gives a uniform arithmetic-operation bound for square
matrix multiplication, and consequently an upper bound of `9/4` on its exponent.
The separation argument is applied over the algebraic closure of the scalar
field; algebraic-extension rank descent then gives the result over every field.
The two conclusions use the repository's existing arithmetic model.
-/

namespace MatrixMultiplication.AuxiliarySeparation

/-- Algebraic closure and fixed-overhead descent remove the scalar-field
restriction from the exact-rank exponent bound. -/
theorem exactRankExponent_le_nine_quarters_allFields (F : Type*) [Field F] :
    exactRankExponent F ≤ (9 : ℝ) / 4 :=
  (exactRankExponent_le_algebraicClosure F).trans
    (exactRankExponent_le_nine_quarters (K := AlgebraicClosure F))

/-- For every positive exponent slack, one constant bounds the cost of correct
matrix multiplication programs over `F` at every positive size. -/
theorem matrix_multiplication_cost_le (F : Type*) [Field F] (ε : ℝ) (hε : 0 < ε) :
    ∃ C : ℝ, 0 < C ∧ ∀ n : ℕ, 1 ≤ n →
      ∃ P : Arithmetic.MatrixAlgorithm F n n n,
        P.Correct ∧ (P.cost : ℝ) ≤ C * (n : ℝ) ^ ((9 : ℝ) / 4 + ε) :=
  arithmeticComplexity_of_exactRankExponent_le
    (exactRankExponent_le_nine_quarters_allFields F) ε hε

/-- The arithmetic matrix multiplication exponent over every field is at most `9/4`. -/
theorem omega_le_nine_quarters (F : Type*) [Field F] :
    Arithmetic.omega F ≤ (9 : ℝ) / 4 :=
  omega_le_exactRankExponent.trans (exactRankExponent_le_nine_quarters_allFields F)

end MatrixMultiplication.AuxiliarySeparation

end OAI
