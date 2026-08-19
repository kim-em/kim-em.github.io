import TauCeti.AlgebraicGeometry.AffineGroupScheme.CartierDuality.FiniteLocallyFree
import TauCeti.AlgebraicGeometry.EllipticCurve.Isogeny.Frobenius
import TauCeti.Analysis.Bochner.BochnerTheorem
import TauCeti.Analysis.PDE.Harnack.Planar
import TauCeti.Analysis.PDE.Harnack.StrongPrinciple
import TauCeti.Analysis.Semigroups.Generation.HilleYosida.Generation
import TauCeti.LinearAlgebra.RootSystem.FiniteType.Classification
import TauCeti.Probability.DeFinetti.Representation
import TauCeti.Probability.DeFinetti.Theorem
import TauCeti.RepresentationTheory.Compact.PeterWeyl
import TauCeti.RepresentationTheory.Compact.RepresentativeDensity
import TauCeti.RepresentationTheory.Induction.Artin
import TauCeti.RingTheory.KrullSchmidt.Uniqueness

/-!
These restatements are pulled into the Tau Ceti first-month blog post by
Verso. Each is elaborated against the exact Tau Ceti revision linked from the
post and proved by the corresponding library declaration.
-/

noncomputable section

namespace TauCetiExamples

open MeasureTheory Set

section

open Complex Filter InnerProductSpace Metric Real Topology
open TauCeti

-- ANCHOR: harnack
theorem harnack_inequality_center
    {f : ℂ → ℝ} {c w : ℂ} {R : ℝ} (hf : HarmonicOnNhd f (ball c R))
    (hnonneg : ∀ z ∈ ball c R, 0 ≤ f z) (hw : w ∈ ball c R) :
    (R - ‖w - c‖) / (R + ‖w - c‖) * f c ≤ f w ∧
      f w ≤ (R + ‖w - c‖) / (R - ‖w - c‖) * f c
-- ANCHOR_END: harnack
    :=
  TauCeti.harnack_inequality_center hf hnonneg hw

end

section

open Function InnerProductSpace Metric Set Topology
open TauCeti

-- ANCHOR: strongMaximum
theorem eqOn_const_of_harmonicOnNhd_of_isLocalMax
    {f : ℂ → ℝ} {Ω : Set ℂ} {a : ℂ}
    (hΩa : Ω ∈ 𝓝 a) (hΩconn : IsPreconnected Ω) (hf : HarmonicOnNhd f Ω)
    (hmax : IsLocalMax f a) : EqOn f (const ℂ (f a)) Ω
-- ANCHOR_END: strongMaximum
    :=
  TauCeti.eqOn_const_of_harmonicOnNhd_of_isLocalMax hΩa hΩconn hf hmax

end

section

open MeasureTheory Set TauCeti
open scoped InnerProductSpace

-- ANCHOR: peterWeyl
noncomputable def stdPeterWeylBasis
    (𝕜 G : Type*) [RCLike 𝕜] [IsAlgClosed 𝕜] [Group G] [TopologicalSpace G]
    [IsTopologicalGroup G] [CompactSpace G] [MeasurableSpace G] [BorelSpace G] :
    HilbertBasis (Σ i : IrrepClass 𝕜 G,
      Fin (IrrepClass.model i).dim × Fin (IrrepClass.model i).dim)
      𝕜 (Lp 𝕜 2 (haarProb G))
-- ANCHOR_END: peterWeyl
    :=
  TauCeti.stdPeterWeylBasis 𝕜 G

end

section

open TauCeti

-- ANCHOR: representativeDensity
theorem representativeStarSubalgebra_dense
    (𝕜 G : Type*) [RCLike 𝕜] [Group G] [TopologicalSpace G]
    [IsTopologicalGroup G] [CompactSpace G] :
    (representativeStarSubalgebra 𝕜 G).topologicalClosure = ⊤
-- ANCHOR_END: representativeDensity
    :=
  TauCeti.representativeStarSubalgebra_dense 𝕜 G

end

section

open TauCeti

-- ANCHOR: krullSchmidt
theorem exists_equiv_linearEquiv_of_iSupIndep
    {A M : Type*} [Ring A] [AddCommGroup M] [Module A M]
    [IsNoetherian A M] [IsArtinian A M]
    {ι κ : Type*} [Finite ι] [Finite κ] {P : ι → Submodule A M}
    {Q : κ → Submodule A M} (hP : iSupIndep P) (hPt : ⨆ i, P i = ⊤)
    (hPind : ∀ i, IsIndecomposableModule A (P i)) (hQ : iSupIndep Q)
    (hQt : ⨆ j, Q j = ⊤) (hQind : ∀ j, IsIndecomposableModule A (Q j)) :
    ∃ e : ι ≃ κ, ∀ i, Nonempty (P i ≃ₗ[A] Q (e i))
-- ANCHOR_END: krullSchmidt
    :=
  TauCeti.exists_equiv_linearEquiv_of_iSupIndep hP hPt hPind hQ hQt hQind

end

section

open Filter NormedSpace TauCeti TauCeti.Semigroups
open scoped NNReal Topology

-- ANCHOR: hilleYosida
theorem hilleYosida_generation_iff
    {X : Type*} [NormedAddCommGroup X] [NormedSpace ℝ X] [CompleteSpace X]
    (A : X →ₗ.[ℝ] X) (M omega : ℝ) :
    (∃ S : StronglyContinuousSemigroup X,
      S.generator = A ∧ S.HasGrowthBound omega M) ↔
      1 ≤ M ∧ Dense (A.domain : Set X) ∧
        (∀ lambda : ℝ, omega < lambda → lambda ∈ LinearPMap.resolventSet A) ∧
        ∀ n : ℕ, 1 ≤ n → ∀ lambda : ℝ, omega < lambda →
          ‖LinearPMap.resolvent A lambda ^ n‖ ≤ M / (lambda - omega) ^ n
-- ANCHOR_END: hilleYosida
    :=
  TauCeti.Semigroups.hilleYosida_generation_iff A M omega

end

section

open TauCeti.Probability

-- ANCHOR: deFinettiEquivalence
theorem deFinetti_RyllNardzewski_equivalence
    {Ω α : Type*} [MeasurableSpace Ω] [MeasurableSpace α]
    [StandardBorelSpace α] [Nonempty α]
    {μ : Measure Ω} [IsFiniteMeasure μ] {X : ℕ → Ω → α}
    (hX_meas : ∀ n, AEMeasurable (X n) μ) :
    Contractable μ X ↔ Exchangeable μ X ∧ ConditionallyIID μ X
-- ANCHOR_END: deFinettiEquivalence
    :=
  TauCeti.Probability.deFinetti_RyllNardzewski_equivalence hX_meas

end

section

open TauCeti.Probability

-- ANCHOR: deFinettiMixture
theorem deFinetti_mixture
    {Ω α : Type*} [MeasurableSpace Ω] [MeasurableSpace α]
    [StandardBorelSpace α] {μ : Measure Ω}
    [IsProbabilityMeasure μ] {X : ℕ → Ω → α} (hX : Exchangeable μ X)
    (hX_meas : ∀ n, AEMeasurable (X n) μ) :
    ∃! π : ProbabilityMeasure (ProbabilityMeasure α),
      pathLaw μ X = (π : Measure (ProbabilityMeasure α)).bind
        fun P => Measure.infinitePi fun _ : ℕ => (P : Measure α)
-- ANCHOR_END: deFinettiMixture
    :=
  TauCeti.Probability.deFinetti_mixture hX hX_meas

end

section

open TauCeti.Isogeny

-- ANCHOR: frobenius
@[simp]
theorem degree_frobeniusIsogeny
    {F : Type*} [Field F] [Finite F] (W : WeierstrassCurve.Affine F) :
    (frobeniusIsogeny W).degree = Nat.card F
-- ANCHOR_END: frobenius
    :=
  TauCeti.Isogeny.degree_frobeniusIsogeny W

end

section

open TauCeti TauCeti.ClassFunction

-- ANCHOR: artin
theorem natCard_nsmul_mem_indVirtualCharacters_isCyclic
    {k G : Type*} [Field k] [Group G] [Finite G] {f : G → k}
    (hf : f ∈ virtualCharacters k G) :
    Nat.card G • f ∈ indVirtualCharacters k G (fun C ↦ IsCyclic C)
-- ANCHOR_END: artin
    :=
  TauCeti.ClassFunction.natCard_nsmul_mem_indVirtualCharacters_isCyclic hf

end

section

open TauCeti

-- ANCHOR: cartanKilling
theorem existsUnique_dynkinType
    {ι R M N : Type*} [CommRing R] [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N] {P : RootPairing ι R M N} [Finite ι]
    [CharZero R] [IsDomain R] [P.IsRootSystem] [P.IsCrystallographic]
    [P.IsReduced] [P.IsIrreducible] [Nonempty ι] (b : P.Base) :
    ∃! t : DynkinType, t.Valid ∧ HasCartanType P b t
-- ANCHOR_END: cartanKilling
    :=
  TauCeti.existsUnique_dynkinType b

end

section

open CategoryTheory AlgebraicGeometry Opposite
open scoped CategoryTheory.MonObj
open TauCeti

-- ANCHOR: cartierDuality
noncomputable def cartierDuality (R : Type*) [CommRing R] :
    (FiniteLocallyFreeCommAffineGroupSchemeCat (CommRingCat.of R))ᵒᵖ ≌
      FiniteLocallyFreeCommAffineGroupSchemeCat (CommRingCat.of R)
-- ANCHOR_END: cartierDuality
    :=
  TauCeti.FiniteLocallyFreeCommAffineGroupSchemeCat.cartierDuality R

end

section

open Filter
open scoped ComplexOrder FourierTransform Topology
open TauCeti

-- ANCHOR: bochner
theorem bochner
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    [FiniteDimensional ℝ V] [MeasurableSpace V] [BorelSpace V] (F : V → ℂ) :
    (Continuous F ∧ IsPositiveDefiniteSub F) ↔
      ∃! μ : Measure V,
        IsFiniteMeasure μ ∧ ∀ v, F v = ∫ q, fourierAtom v q ∂μ
-- ANCHOR_END: bochner
    :=
  TauCeti.bochner F

end

end TauCetiExamples
