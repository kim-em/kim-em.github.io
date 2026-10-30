import VersoBlog
import Site.Categories
import Site.Examples
open Verso Genre Blog
open Verso.Code.External

set_option linter.verso.markup.emph false

set_option verso.exampleProject "examples/green"
set_option verso.exampleModule "GreenExamples"

load_examples "examples/green"

#doc (Post) "All 100 theorems in Lean" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 10, day := 30}
categories := [Site.lean]
%%%

Freek Wiedijk has for many years maintained a [list of 100 significant theorems in mathematics](https://www.cs.ru.nl/F.Wiedijk/100/index.html), and kept track of which interactive theorem proving languages have checked proofs of these theorems.

For the first time, a single language now has proofs of all 100 theorems: *Lean*!

And I'm very pleased to report that the 100th theorem completed in Lean was a strong formulation of [Green's theorem](https://taucetiproject.org/docs/TauCeti/Analysis/Green/IndexOne.html#TauCeti.Green.green_ac_index_one), which landed in [Tau Ceti](https://taucetiproject.org/), the library of all mathematics that we're autoformalizing with the [Lean FRO](https://lean-lang.org/fro) and [Mathlib Initiative](https://mathlib-initiative.org/).

Here is the statement in Lean:

```anchor green
theorem green_ac_index_one {γ : ℝ → ℂ} {a b : ℝ} {U : Set ℂ} {P Q : ℂ → ℝ}
    (hab : a < b) (hγ : AbsolutelyContinuousOnInterval γ a b) (hclosed : γ a = γ b)
    (hU : IsOpen U) (hregion : filledHull (γ '' uIcc a b) ⊆ U)
    (hP : ContDiffOn ℝ 1 P U) (hQ : ContDiffOn ℝ 1 Q U)
    (hindex : ∀ z ∈ filledHull (γ '' uIcc a b) \ (γ '' uIcc a b),
      Contour.windingNumber γ a b z = 1) :
    IntervalIntegrable (circulationFun P Q γ) volume a b ∧
      IntegrableOn (curl P Q) (filledHull (γ '' uIcc a b) \ (γ '' uIcc a b)) ∧
      (∫ t in a..b, circulationFun P Q γ t) =
        ∫ z in filledHull (γ '' uIcc a b) \ (γ '' uIcc a b), curl P Q z
```

The curve is only required to be absolutely continuous and closed, with winding number one throughout the bounded complementary region. There is no simplicity or finite-component hypothesis, and integrability of both sides is part of the conclusion.

[Source](https://github.com/TauCetiProject/TauCeti/blob/36f24f5d94ccf25e167520cf4c0f1a028c064fb0/TauCeti/Analysis/Green/IndexOne.lean#L31) · [documentation](https://taucetiproject.org/docs/TauCeti/Analysis/Green/IndexOne.html#TauCeti.Green.green_ac_index_one)
