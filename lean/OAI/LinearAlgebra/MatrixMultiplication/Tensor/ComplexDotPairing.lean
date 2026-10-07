module

public import OAI.LinearAlgebra.MatrixMultiplication.Tensor.ComplexTensor

public section

@[expose] section

namespace OAI

/-! Finite coefficient tensors and their algebraic transformations. -/

open scoped BigOperators

namespace MatrixMultiplication.Foundation
namespace Tensor

section Pairing

variable {K U : Type*} [CommSemiring K] [DecidableEq U]

def dotPairing (U : Type*) [DecidableEq U] : Tensor K U U Unit :=
  fun i j _ => if i = j then 1 else 0

@[simp] theorem dotPairing_matching (i : U) :
    dotPairing (K := K) U i i () = 1 := by
  simp [dotPairing]

theorem contract_dotPairing [Fintype U] (a b : U → K) :
    contract (dotPairing (K := K) U) a b () = ∑ i, a i * b i := by
  classical
  simp [contract, dotPairing, ite_mul]

end Pairing

end Tensor
end MatrixMultiplication.Foundation

end OAI
