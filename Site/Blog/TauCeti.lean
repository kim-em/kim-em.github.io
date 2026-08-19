import VersoBlog
import Site.Categories
open Verso Genre Blog
open Verso.Code.External

set_option linter.verso.markup.emph false

set_option verso.exampleProject "examples/tauceti"
set_option verso.exampleModule "TauCetiExamples"

#doc (Post) "Tau Ceti: ten theorems from the first month" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 8, day := 19}
categories := [Site.lean]
%%%

It's been a month since we launched, so I'd like to make a brief post highlighting some of the results that have landed in Tau Ceti.

We're ready for more contributors at this point. Please come to the
[#Tau Ceti channel](https://leanprover.zulipchat.com/#narrow/channel/610393-Tau-Ceti)
to discuss contributing to the roadmaps, or if you have existing material you would like to
migrate into Tau Ceti.

If you'd just like to point your AI at Tau Ceti, it can be as simple as

```
uv tool install git+https://github.com/kim-em/TauCetiWorker.git
tauceti --loop
```

(if you would like to run this inside a Docker container, please read, or have your AI read,
[https://github.com/kim-em/TauCetiWorker/blob/main/docs/docker.md](https://github.com/kim-em/TauCetiWorker/blob/78c4969bd8803d920050108e4e851546a08eeceb/docs/docker.md))

# 1. Planar Harnack inequality and strong maximum principle

A nonnegative harmonic function on a planar disk satisfies the sharp two-sided Harnack bounds
relative to its value at the center; consequently, a harmonic function on a connected planar
domain that attains an interior local extremum is constant.

```anchor harnack
theorem harnack_inequality_center
    {f : ℂ → ℝ} {c w : ℂ} {R : ℝ} (hf : HarmonicOnNhd f (ball c R))
    (hnonneg : ∀ z ∈ ball c R, 0 ≤ f z) (hw : w ∈ ball c R) :
    (R - ‖w - c‖) / (R + ‖w - c‖) * f c ≤ f w ∧
      f w ≤ (R + ‖w - c‖) / (R - ‖w - c‖) * f c
```

```anchor strongMaximum
theorem eqOn_const_of_harmonicOnNhd_of_isLocalMax
    {f : ℂ → ℝ} {Ω : Set ℂ} {a : ℂ}
    (hΩa : Ω ∈ 𝓝 a) (hΩconn : IsPreconnected Ω) (hf : HarmonicOnNhd f Ω)
    (hmax : IsLocalMax f a) : EqOn f (const ℂ (f a)) Ω
```

Harnack inequality: [source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/Analysis/PDE/Harnack/Planar.lean#L265) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/Analysis/PDE/Harnack/Planar.html#TauCeti.harnack_inequality_center) · [PR #1299](https://github.com/TauCetiProject/TauCeti/pull/1299)  
Strong maximum principle: [source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/Analysis/PDE/Harnack/StrongPrinciple.lean#L132) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/Analysis/PDE/Harnack/StrongPrinciple.html#TauCeti.eqOn_const_of_harmonicOnNhd_of_isLocalMax) · [PR #1724](https://github.com/TauCetiProject/TauCeti/pull/1724)

# 2. Peter–Weyl theorem

For a compact group, the normalized matrix coefficients of its irreducible unitary
representations form a Hilbert basis of `L²(G)`, and the representative functions are uniformly
dense in `C(G)`.

```anchor peterWeyl
noncomputable def stdPeterWeylBasis
    (𝕜 G : Type*) [RCLike 𝕜] [IsAlgClosed 𝕜] [Group G] [TopologicalSpace G]
    [IsTopologicalGroup G] [CompactSpace G] [MeasurableSpace G] [BorelSpace G] :
    HilbertBasis (Σ i : IrrepClass 𝕜 G,
      Fin (IrrepClass.model i).dim × Fin (IrrepClass.model i).dim)
      𝕜 (Lp 𝕜 2 (haarProb G))
```

```anchor representativeDensity
theorem representativeStarSubalgebra_dense
    (𝕜 G : Type*) [RCLike 𝕜] [Group G] [TopologicalSpace G]
    [IsTopologicalGroup G] [CompactSpace G] :
    (representativeStarSubalgebra 𝕜 G).topologicalClosure = ⊤
```

Hilbert basis: [source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/RepresentationTheory/Compact/PeterWeyl.lean#L692) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/RepresentationTheory/Compact/PeterWeyl.html#TauCeti.stdPeterWeylBasis) · [PR #2677](https://github.com/TauCetiProject/TauCeti/pull/2677)  
Representative density: [source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/RepresentationTheory/Compact/RepresentativeDensity.lean#L142) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/RepresentationTheory/Compact/RepresentativeDensity.html#TauCeti.representativeStarSubalgebra_dense) · [PR #2640](https://github.com/TauCetiProject/TauCeti/pull/2640)

# 3. Krull–Schmidt theorem

Any two decompositions of a finite-length module into finitely many indecomposable summands have
isomorphic summands after reindexing.

```anchor krullSchmidt
theorem exists_equiv_linearEquiv_of_iSupIndep
    {A M : Type*} [Ring A] [AddCommGroup M] [Module A M]
    [IsNoetherian A M] [IsArtinian A M]
    {ι κ : Type*} [Finite ι] [Finite κ] {P : ι → Submodule A M}
    {Q : κ → Submodule A M} (hP : iSupIndep P) (hPt : ⨆ i, P i = ⊤)
    (hPind : ∀ i, IsIndecomposableModule A (P i)) (hQ : iSupIndep Q)
    (hQt : ⨆ j, Q j = ⊤) (hQind : ∀ j, IsIndecomposableModule A (Q j)) :
    ∃ e : ι ≃ κ, ∀ i, Nonempty (P i ≃ₗ[A] Q (e i))
```

[Source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/RingTheory/KrullSchmidt/Uniqueness.lean#L203) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/RingTheory/KrullSchmidt/Uniqueness.html#TauCeti.exists_equiv_linearEquiv_of_iSupIndep) · [PR #2082](https://github.com/TauCetiProject/TauCeti/pull/2082)

# 4. Hille–Yosida generation theorem

An operator on a real Banach space generates a strongly continuous semigroup with a prescribed
growth bound exactly when its domain is dense and its resolvent satisfies the corresponding
Hille–Yosida power bounds.

```anchor hilleYosida
theorem hilleYosida_generation_iff
    {X : Type*} [NormedAddCommGroup X] [NormedSpace ℝ X] [CompleteSpace X]
    (A : X →ₗ.[ℝ] X) (M omega : ℝ) :
    (∃ S : StronglyContinuousSemigroup X,
      S.generator = A ∧ S.HasGrowthBound omega M) ↔
      1 ≤ M ∧ Dense (A.domain : Set X) ∧
        (∀ lambda : ℝ, omega < lambda → lambda ∈ LinearPMap.resolventSet A) ∧
        ∀ n : ℕ, 1 ≤ n → ∀ lambda : ℝ, omega < lambda →
          ‖LinearPMap.resolvent A lambda ^ n‖ ≤ M / (lambda - omega) ^ n
```

[Source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/Analysis/Semigroups/Generation/HilleYosida/Generation.lean#L217) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/Analysis/Semigroups/Generation/HilleYosida/Generation.html#TauCeti.Semigroups.hilleYosida_generation_iff) · [PR #3492](https://github.com/TauCetiProject/TauCeti/pull/3492)

# 5. De Finetti–Ryll-Nardzewski theorem

For standard-Borel-valued sequences, contractability, exchangeability, and conditional
independence with identical distributions coincide; every exchangeable law has a unique
representation as a mixture of i.i.d. product laws.

```anchor deFinettiEquivalence
theorem deFinetti_RyllNardzewski_equivalence
    {Ω α : Type*} [MeasurableSpace Ω] [MeasurableSpace α]
    [StandardBorelSpace α] [Nonempty α]
    {μ : Measure Ω} [IsFiniteMeasure μ] {X : ℕ → Ω → α}
    (hX_meas : ∀ n, AEMeasurable (X n) μ) :
    Contractable μ X ↔ Exchangeable μ X ∧ ConditionallyIID μ X
```

```anchor deFinettiMixture
theorem deFinetti_mixture
    {Ω α : Type*} [MeasurableSpace Ω] [MeasurableSpace α]
    [StandardBorelSpace α] {μ : Measure Ω}
    [IsProbabilityMeasure μ] {X : ℕ → Ω → α} (hX : Exchangeable μ X)
    (hX_meas : ∀ n, AEMeasurable (X n) μ) :
    ∃! π : ProbabilityMeasure (ProbabilityMeasure α),
      pathLaw μ X = (π : Measure (ProbabilityMeasure α)).bind
        fun P => Measure.infinitePi fun _ : ℕ => (P : Measure α)
```

Equivalence: [source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/Probability/DeFinetti/Theorem.lean#L189) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/Probability/DeFinetti/Theorem.html#TauCeti.Probability.deFinetti_RyllNardzewski_equivalence) · [PR #891](https://github.com/TauCetiProject/TauCeti/pull/891)  
Unique mixture: [source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/Probability/DeFinetti/Representation.lean#L65) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/Probability/DeFinetti/Representation.html#TauCeti.Probability.deFinetti_mixture) · [PR #1462](https://github.com/TauCetiProject/TauCeti/pull/1462)

# 6. Frobenius isogeny

For a Weierstrass curve over a finite field with `q` elements, the `q`-power Frobenius defines an
isogeny of degree `q`.

```anchor frobenius
@[simp]
theorem degree_frobeniusIsogeny
    {F : Type*} [Field F] [Finite F] (W : WeierstrassCurve.Affine F) :
    (frobeniusIsogeny W).degree = Nat.card F
```

[Source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/AlgebraicGeometry/EllipticCurve/Isogeny/Frobenius.lean#L147) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/AlgebraicGeometry/EllipticCurve/Isogeny/Frobenius.html#TauCeti.Isogeny.degree_frobeniusIsogeny) · [PR #2926](https://github.com/TauCetiProject/TauCeti/pull/2926)

# 7. Artin induction theorem

For a finite group `G`, induction from cyclic subgroups spans the rationalized group of virtual
characters; explicitly, `|G|` times every virtual character lies in the induced integral span.

```anchor artin
theorem natCard_nsmul_mem_indVirtualCharacters_isCyclic
    {k G : Type*} [Field k] [Group G] [Finite G] {f : G → k}
    (hf : f ∈ virtualCharacters k G) :
    Nat.card G • f ∈ indVirtualCharacters k G (fun C ↦ IsCyclic C)
```

[Source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/RepresentationTheory/Induction/Artin.lean#L199) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/RepresentationTheory/Induction/Artin.html#TauCeti.ClassFunction.natCard_nsmul_mem_indVirtualCharacters_isCyclic) · [PR #2258](https://github.com/TauCetiProject/TauCeti/pull/2258)

# 8. Cartan–Killing classification

Every irreducible reduced crystallographic finite root system has a unique valid Dynkin type:
`Aₙ`, `Bₙ`, `Cₙ`, `Dₙ`, `E₆`, `E₇`, `E₈`, `F₄`, or `G₂`.

```anchor cartanKilling
theorem existsUnique_dynkinType
    {ι R M N : Type*} [CommRing R] [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N] {P : RootPairing ι R M N} [Finite ι]
    [CharZero R] [IsDomain R] [P.IsRootSystem] [P.IsCrystallographic]
    [P.IsReduced] [P.IsIrreducible] [Nonempty ι] (b : P.Base) :
    ∃! t : DynkinType, t.Valid ∧ HasCartanType P b t
```

[Source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/LinearAlgebra/RootSystem/FiniteType/Classification.lean#L127) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/LinearAlgebra/RootSystem/FiniteType/Classification.html#TauCeti.existsUnique_dynkinType) · [PR #3378](https://github.com/TauCetiProject/TauCeti/pull/3378)

# 9. Cartier duality over a general base

Over any commutative ring, Cartier duality is an involutive anti-equivalence on finite locally
free commutative affine group schemes.

```anchor cartierDuality
noncomputable def cartierDuality (R : Type*) [CommRing R] :
    (FiniteLocallyFreeCommAffineGroupSchemeCat (CommRingCat.of R))ᵒᵖ ≌
      FiniteLocallyFreeCommAffineGroupSchemeCat (CommRingCat.of R)
```

[Source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/AlgebraicGeometry/AffineGroupScheme/CartierDuality/FiniteLocallyFree.lean#L232) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/AlgebraicGeometry/AffineGroupScheme/CartierDuality/FiniteLocallyFree.html#TauCeti.FiniteLocallyFreeCommAffineGroupSchemeCat.cartierDuality) · [PR #3356](https://github.com/TauCetiProject/TauCeti/pull/3356)

# 10. Bochner's theorem

A function on a finite-dimensional real inner-product space is continuous and positive definite
exactly when it is the Fourier transform of a unique finite positive Borel measure.

```anchor bochner
theorem bochner
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    [FiniteDimensional ℝ V] [MeasurableSpace V] [BorelSpace V] (F : V → ℂ) :
    (Continuous F ∧ IsPositiveDefiniteSub F) ↔
      ∃! μ : Measure V,
        IsFiniteMeasure μ ∧ ∀ v, F v = ∫ q, fourierAtom v q ∂μ
```

[Source](https://github.com/TauCetiProject/TauCeti/blob/f93736047d51931862e138b4c097099c8d1168a6/TauCeti/Analysis/Bochner/BochnerTheorem.lean#L263) · [documentation](https://taucetiproject.github.io/TauCeti/docs/TauCeti/Analysis/Bochner/BochnerTheorem.html#TauCeti.bochner) · [PR #2611](https://github.com/TauCetiProject/TauCeti/pull/2611)
