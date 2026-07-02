import SOS

/-!
Example code for the "A sum of squares tactic" blog post. Each `ANCHOR`
region is pulled into the post by Verso via SubVerso, so the code shown
there is exactly the code that is elaborated here. These mirror the
curated showcase in `leanprover/sos`.
-/

-- Cauchy–Schwarz (rank 1, degree 4, 4 variables).
-- ANCHOR: cauchy
example (a b c d : ℝ) :
    0 ≤ (a^2 + b^2) * (c^2 + d^2) - (a*c + b*d)^2 := by sos
-- ANCHOR_END: cauchy

-- Cyclic Schur, 3 variables.
-- ANCHOR: schur
example (a b c : ℝ) : 0 ≤ a^2 + b^2 + c^2 - a*b - b*c - a*c := by sos
-- ANCHOR_END: schur

-- Strict positivity, multivariate.
-- ANCHOR: strict
example (x y : ℝ) : 0 < x^2 + y^2 + 1 := by sos
-- ANCHOR_END: strict

-- Equality constraint: the discriminant of a real-rooted quadratic is
-- nonnegative. The search discovers the cofactor `-4a`.
-- ANCHOR: discriminant
example (a b c x : ℝ) (_h : a*x^2 + b*x + c = 0) :
    0 ≤ b^2 - 4*a*c := by sos
-- ANCHOR_END: discriminant

-- A discrete goal, refuted through ℝ.
-- ANCHOR: nat
example : ∀ n : ℕ, n ≤ n * n := by sos
-- ANCHOR_END: nat
