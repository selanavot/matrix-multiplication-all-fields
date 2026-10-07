import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Main

/-!
# The all-fields matrix multiplication bound

This module exports the all-fields theorem and its complex specialization
without importing the other upstream results re-exported by `Main`, so the
core result can be built and kernel-checked on its own.
-/

namespace OAI

namespace MatrixMultiplication

/-- The square matrix multiplication exponent over every field is at most `9/4`. -/
theorem omega_le_nine_quarters (F : Type*) [Field F] :
    Arithmetic.omega F ≤ (9 : ℝ) / 4 :=
  AuxiliarySeparation.omega_le_nine_quarters F

/-- The complex square matrix multiplication exponent is at most `9/4`. -/
theorem complex_omega_le_nine_quarters :
    Arithmetic.omega ℂ ≤ (9 : ℝ) / 4 :=
  omega_le_nine_quarters ℂ

end MatrixMultiplication

end OAI
