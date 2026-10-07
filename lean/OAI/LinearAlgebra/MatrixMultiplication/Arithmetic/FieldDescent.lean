module

public import Mathlib.FieldTheory.IsAlgClosed.AlgebraicClosure
public import Mathlib.LinearAlgebra.FiniteDimensional.Basic
public import Mathlib.RingTheory.IntegralClosure.IsIntegral.Basic
public import OAI.LinearAlgebra.MatrixMultiplication.Tensor.ComplexTensor

public section

@[expose] section

namespace OAI.MatrixMultiplication.Foundation.Tensor

noncomputable section
open scoped BigOperators

variable {F E X Y Z : Type*} [Field F] [CommRing E] [Algebra F E]

/-- Applying a base-field linear functional to coefficients increases exact
tensor rank by at most the square of the extension dimension. -/
theorem RankAtMost.project_basis {ι : Type*} [Fintype ι]
    (basis : Module.Basis ι F E) (π : E →ₗ[F] F)
    {T : Tensor E X Y Z} {r : ℕ} (h : RankAtMost T r) :
    RankAtMost (fun x y z => π (T x y z))
      (r * Fintype.card ι * Fintype.card ι) := by
  classical
  rcases h with ⟨a, b, c, rfl⟩
  let aa : Fin r × (ι × ι) → X → F :=
    fun q x => basis.repr (a q.1 x) q.2.1
  let bb : Fin r × (ι × ι) → Y → F :=
    fun q y => basis.repr (b q.1 y) q.2.2
  let cc : Fin r × (ι × ι) → Z → F :=
    fun q z => π (basis q.2.1 * basis q.2.2 * c q.1 z)
  have hexp (v w t : E) :
      π (v * w * t) = ∑ i, ∑ j,
        basis.repr v i * basis.repr w j * π (basis i * basis j * t) := by
    calc
      π (v * w * t) =
          π ((∑ i, basis.repr v i • basis i) *
            (∑ j, basis.repr w j • basis j) * t) := by
        rw [basis.sum_repr, basis.sum_repr]
      _ = _ := by
        simp only [Finset.sum_mul, Finset.mul_sum, map_sum, smul_mul_assoc,
          mul_smul_comm, map_smul, smul_eq_mul]
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl
        intro i hi
        apply Finset.sum_congr rfl
        intro j hj
        ring
  have heq : (fun x y z => π (∑ q, rankOne (a q) (b q) (c q) x y z)) =
      fun x y z => ∑ q, rankOne (aa q) (bb q) (cc q) x y z := by
    funext x y z
    simp only [map_sum, Fintype.sum_prod_type, rankOne]
    apply Finset.sum_congr rfl
    intro q hq
    exact hexp (a q x) (b q y) (c q z)
  rw [heq]
  simpa only [Fintype.card_prod, Fintype.card_fin, Nat.mul_assoc] using
    rankAtMost_sum_rankOne aa bb cc

/-- A nonzero finite algebra has a linear functional taking its unit to one. -/
theorem exists_unit_linear_functional [Nontrivial E] [Module.Finite F E] :
    ∃ π : E →ₗ[F] F, π 1 = 1 := by
  classical
  let basis := Module.finBasis F E
  have hex : ∃ i, basis.repr (1 : E) i ≠ 0 := by
    by_contra h
    have hz : basis.repr (1 : E) = 0 := by
      ext i
      by_contra hi
      exact h ⟨i, hi⟩
    have h10 : (1 : E) = 0 := basis.repr.injective (by rw [hz, map_zero])
    exact one_ne_zero h10
  obtain ⟨i, hi⟩ := hex
  refine ⟨(basis.repr (1 : E) i)⁻¹ • basis.coord i, ?_⟩
  simp [Module.Basis.coord_apply, hi]

/-- Exact rank descent through a fixed finite algebra. -/
theorem RankAtMost.descend_finite [Nontrivial E] [Module.Finite F E]
    {T : Tensor F X Y Z} {r : ℕ}
    (h : RankAtMost (fun x y z => algebraMap F E (T x y z)) r) :
    RankAtMost T (r * Module.finrank F E * Module.finrank F E) := by
  obtain ⟨π, hπ⟩ := exists_unit_linear_functional (F := F) (E := E)
  have ha (v : F) : π (algebraMap F E v) = v := by
    rw [Algebra.algebraMap_eq_smul_one, map_smul, hπ, smul_eq_mul, mul_one]
  simpa only [ha, Fintype.card_fin] using
    h.project_basis (Module.finBasis F E) π

/-- One finite exact decomposition over an algebraic extension descends with
a fixed multiplicative overhead at every tensor power. The finite algebra
and its dimension are chosen before the power varies. -/
theorem RankAtMost.descend_algebraic_powers [Nontrivial E]
    [Algebra.IsAlgebraic F E] [Fintype X] [Fintype Y] [Fintype Z]
    {T : Tensor F X Y Z} {r : ℕ}
    (h : RankAtMost (fun x y z => algebraMap F E (T x y z)) r) :
    ∃ d : ℕ, 0 < d ∧ ∀ n : ℕ,
      RankAtMost (Tensor.power T n) (r ^ n * d * d) := by
  classical
  rcases h with ⟨a, b, c, h⟩
  let coeff : (Fin r × X) ⊕ ((Fin r × Y) ⊕ (Fin r × Z)) → E :=
    fun q => match q with
    | .inl q => a q.1 q.2
    | .inr (.inl q) => b q.1 q.2
    | .inr (.inr q) => c q.1 q.2
  let S := Algebra.adjoin F (Set.range coeff)
  let : Module.Finite F S :=
    Algebra.finite_adjoin_of_finite_of_isIntegral (Set.finite_range coeff)
      (fun x _ => (Algebra.IsAlgebraic.isAlgebraic x).isIntegral)
  let aa : Fin r → X → S := fun i x =>
    ⟨a i x, Algebra.subset_adjoin ⟨.inl (i, x), rfl⟩⟩
  let bb : Fin r → Y → S := fun i y =>
    ⟨b i y, Algebra.subset_adjoin ⟨.inr (.inl (i, y)), rfl⟩⟩
  let cc : Fin r → Z → S := fun i z =>
    ⟨c i z, Algebra.subset_adjoin ⟨.inr (.inr (i, z)), rfl⟩⟩
  have hS : RankAtMost (fun x y z => algebraMap F S (T x y z)) r := by
    refine ⟨aa, bb, cc, ?_⟩
    funext x y z
    apply Subtype.ext
    simpa [rankOne, aa, bb, cc] using congrFun (congrFun (congrFun h x) y) z
  refine ⟨Module.finrank F S, Module.finrank_pos, ?_⟩
  intro n
  have hp : RankAtMost
      (fun x y z => algebraMap F S (Tensor.power T n x y z)) (r ^ n) := by
    convert hS.power n using 1
    funext x y z
    simp only [Foundation.Tensor.power, map_prod]
  exact hp.descend_finite (F := F)

/-- The algebraic-closure instance of rank descent applies to every field,
without a characteristic or separability hypothesis. -/
theorem RankAtMost.descend_algebraicClosure_powers
    [Fintype X] [Fintype Y] [Fintype Z]
    {T : Tensor F X Y Z} {r : ℕ}
    (h : RankAtMost
      (fun x y z => algebraMap F (AlgebraicClosure F) (T x y z)) r) :
    ∃ d : ℕ, 0 < d ∧ ∀ n : ℕ,
      RankAtMost (Tensor.power T n) (r ^ n * d * d) :=
  h.descend_algebraic_powers

end
end OAI.MatrixMultiplication.Foundation.Tensor
