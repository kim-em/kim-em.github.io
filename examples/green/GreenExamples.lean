import TauCeti.Analysis.Green.IndexOne

/-!
The statement from Tau Ceti, elaborated and proved by the library theorem.
Verso displays only the anchored statement, with semantic highlighting and hovers.
-/

noncomputable section

open MeasureTheory Set TauCeti TauCeti.Green

namespace GreenExamples

-- ANCHOR: green
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
-- ANCHOR_END: green
    :=
  TauCeti.Green.green_ac_index_one hab hγ hclosed hU hregion hP hQ hindex

end GreenExamples
