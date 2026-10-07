module

public import OAI.LinearAlgebra.MatrixMultiplication.Tensor.ComplexMatrixTensor

public section

@[expose] section

namespace OAI.MatrixMultiplication.AuxiliarySeparation

open Foundation

variable {K : Type*} [CommSemiring K]

/-- The matrix multiplication coefficient tensor over an arbitrary scalar field.
At `K = ℂ` this is definitionally the repository's original
`Foundation.Tensor.matrixMultiplication`. -/
def matrixMultiplicationTensor (a b c : ℕ) :
    Tensor K (Fin a × Fin b) (Fin b × Fin c) (Fin c × Fin a) :=
  fun x y z => if x.2 = y.1 ∧ y.2 = z.1 ∧ z.2 = x.1 then 1 else 0

@[simp] theorem matrixMultiplicationTensor_matching (a b c : ℕ)
    (i : Fin a) (j : Fin b) (k : Fin c) :
    matrixMultiplicationTensor (K := K) a b c (i, j) (j, k) (k, i) = 1 := by
  simp [matrixMultiplicationTensor]

theorem matrixMultiplicationTensor_eq_matrixCoefficients (a b c : ℕ) :
    matrixMultiplicationTensor (K := K) a b c =
      Tensor.matrixCoefficients (K := K) (Fin a) (Fin b) (Fin c) := rfl

end OAI.MatrixMultiplication.AuxiliarySeparation
