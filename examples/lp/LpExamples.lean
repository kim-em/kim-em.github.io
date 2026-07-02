import LPTactic
import LPBackendPure  -- registers the pure-Lean backend at priority 100

/-!
Example code for the "Verified linear programming" blog post. Each
`ANCHOR` region is pulled into the post by Verso via SubVerso, so the
code shown there is exactly the code that is elaborated here.

These are elaborated with the pure-Lean backend (no SoPlex FFI) so the
extractor can run `by lp` in-process; the examples are small enough that
the exact-rational simplex handles them instantly.
-/

-- A basic linear bound over `Rat`.
-- ANCHOR: basic
example (x : Rat) (_h₁ : 0 ≤ x) (_h₂ : x ≤ 4) : 3 * x + 7 ≤ 19 := by lp
-- ANCHOR_END: basic

-- The textbook LP: maximize 3x₀ + 5x₁ subject to the constraints below.
-- The optimum is 36, and `lp` proves the bound directly.
-- ANCHOR: optimum
example (x₀ x₁ : Rat)
    (_ : x₀ ≤ 4) (_ : 2 * x₁ ≤ 12) (_ : 3 * x₀ + 2 * x₁ ≤ 18)
    (_ : 0 ≤ x₀) (_ : 0 ≤ x₁) :
    3 * x₀ + 5 * x₁ ≤ 36 := by lp
-- ANCHOR_END: optimum

-- A goal with an inner `∀` that `linarith` cannot touch.
-- ANCHOR: quantified
example : ∃ x : Rat, 1 ≤ x ∧ x ≤ 2 ∧ ∀ y : Rat, 0 ≤ y → y ≤ 1/2 → y ≤ x := by lp
-- ANCHOR_END: quantified

-- `maximize e` computes a certified upper bound for `e` and adds it as
-- the hypothesis `hbound`.
-- ANCHOR: maximize
example (x₀ x₁ : Rat) (_h₁ : 0 ≤ x₀) (_h₂ : 0 ≤ x₁) (_h₃ : x₀ ≤ 4)
    (_h₄ : 2 * x₁ ≤ 12) (_h₅ : 3 * x₀ + 2 * x₁ ≤ 18) :
    3 * x₀ + 5 * x₁ ≤ 36 := by
  maximize 3 * x₀ + 5 * x₁
  exact hbound
-- ANCHOR_END: maximize
