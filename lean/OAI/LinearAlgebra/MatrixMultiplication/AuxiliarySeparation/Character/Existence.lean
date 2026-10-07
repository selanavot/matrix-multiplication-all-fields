module

/-
Upstream source and modification notice
Modified from OpenAI's matrix-multiplication sources to support arbitrary fields.
See UPSTREAM.md for provenance and changes; Apache-2.0 license retained in LICENSE.
-/

public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Spectrum.StateObstruction
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Spectrum.MultiplicativeStates
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Spectrum.Obstruction
public import OAI.LinearAlgebra.MatrixMultiplication.AuxiliarySeparation.Tensor.Characters

public section

@[expose] section

namespace OAI

/-!
# Detecting characters for matrix multiplication over any field

This proves Lemma 3.1, including Appendix A. Finite inconsistency would
produce a positive scalar-gain catalyst, ruled out by the exact-rank exponent.
A compact normalized state space then yields a multiplicative state, which
transfers to the concrete coefficient-level character interface.
-/

noncomputable section

namespace MatrixMultiplication.AuxiliarySeparation

variable {K : Type*} [Field K]

open MatrixMultiplication.Foundation

/-- Lemma 3.1: normalized, additive, multiplicative, restriction-monotone
characters detect every integer strictly below the exact-rank growth value. -/
theorem exists_detecting_character {d k : ℕ} (hd : 2 ≤ d)
    (hk : (k : ℝ) < (d : ℝ) ^ (exactRankExponent K)) :
    ∃ χ : (Character K), (k : ℝ) ≤ χ.value ((matrixMultiplicationTensor (K := K)) d d d) := by
  have hnonempty := normalizedStates_nonempty_of_no_catalyst
    TensorSemiring.rank ((TensorSemiring.matrixClass (K := K)) d) k
    TensorSemiring.zero_le TensorSemiring.le_rank
    (fun _ _ _ _ h₁ h₂ => TensorSemiring.add_mono h₁ h₂)
    (fun D s m hm hcat => no_tensor_catalytic_gain (by omega) hk ⟨D, s, m, hm, hcat⟩)
  have hdom (z x : (TensorSemiring.TensorClass K)) :
      z * x ≤ (TensorSemiring.rank x : (TensorSemiring.TensorClass K)) * z := by
    calc
      z * x ≤ z * (TensorSemiring.rank x : (TensorSemiring.TensorClass K)) :=
        TensorSemiring.mul_mono le_rfl (TensorSemiring.le_rank x)
      _ = (TensorSemiring.rank x : (TensorSemiring.TensorClass K)) * z := mul_comm _ _
  obtain ⟨φ, hφ, _, hdetect⟩ := exists_monotone_semiringHom_of_normalizedStates
    TensorSemiring.rank ((TensorSemiring.matrixClass (K := K)) d) (k : ℝ)
    (fun z hz => TensorSemiring.one_le_of_ne_zero hz)
    (fun _ _ _ h => TensorSemiring.mul_mono le_rfl h) hdom hnonempty
  exact ⟨Character.ofTensorClassHom φ hφ, hdetect⟩

end MatrixMultiplication.AuxiliarySeparation

end

end OAI
