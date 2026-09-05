import VersoBlog
import Site.Categories
import Site.Examples
open Verso Genre Blog
open Verso.Code.External

set_option linter.verso.markup.emph false

set_option verso.exampleProject "examples/sos"
set_option verso.exampleModule "SosExamples"

-- Seed Verso's cache from pre-generated highlighting data. Does nothing unless
-- SITE_PREBUILT_EXAMPLES is set, in which case CI's artifacts must be in place.
load_examples "examples/sos"

#doc (Post) "A sum of squares tactic" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 5, day := 13}
categories := [Site.tactics, Site.lean]
%%%

I've put together an `sos` tactic: a sum-of-squares decision procedure for nonlinear real arithmetic, closely following [John Harrison's implementation](https://link.springer.com/chapter/10.1007/978-3-540-74591-4_9) in HOL Light. It closes a range of polynomial-inequality goals over the reals that we don't otherwise have good tactics for.

Every example below is elaborated by Lean when this page is built — the tactic really runs, CSDP and all.

# What it does

The idea is old and lovely: to show a polynomial is nonnegative, write it as a sum of squares. Finding that decomposition is a semidefinite program, and once you have it, the certificate is checkable by hand. Here's Cauchy–Schwarz, degree 4 in 4 variables:

```anchor cauchy
example (a b c d : ℝ) :
    0 ≤ (a^2 + b^2) * (c^2 + d^2) - (a*c + b*d)^2 := by sos
```

Cyclic Schur in three variables:

```anchor schur
example (a b c : ℝ) : 0 ≤ a^2 + b^2 + c^2 - a*b - b*c - a*c := by sos
```

Strict inequalities are fine too:

```anchor strict
example (x y : ℝ) : 0 < x^2 + y^2 + 1 := by sos
```

Hypotheses become constraints. With an equality constraint, the search finds the cofactor it needs — here `-4a`, giving the discriminant of a real-rooted quadratic:

```anchor discriminant
example (a b c x : ℝ) (_h : a*x^2 + b*x + c = 0) :
    0 ≤ b^2 - 4*a*c := by sos
```

And with a few tricks it reaches beyond the reals. A goal over `Nat` gets negated and refuted over `Real`:

```anchor nat
example : ∀ n : ℕ, n ≤ n * n := by sos
```

# How it works

End to end: reify the goal, encode a semidefinite program, call [CSDP](https://github.com/coin-or/Csdp), round the floating-point Gram matrix back to rationals, decompose it via LDLᵀ plus Lagrange's four-square identity, and dispatch the matching verifier-soundness lemma. The rounding regime — try small integers first, then some powers of two — is lifted straight from Harrison's HOL Light code. I tried some variations, but none of them were justified by the test suite, so I reverted to copying Harrison exactly.

# What it is not (yet)

Treat this as a prototype. It's not ready to become Mathlib PRs, let alone a `grind` plugin, because:

- It depends on [`csdp-ffi`](https://github.com/leanprover/csdp-ffi), an FFI wrapper around the CSDP library. We'd need to decide whether that's a Mathlib dependency or a runtime-only one (with Mathlib committing only witnesses produced by `sos?`).
- It depends on a computable multivariable-polynomial library, `CompPoly`, which itself depends on Mathlib.
- The code still needs cleanup and review.

None of that changes what it can prove today, which is already more than I expected when I started.

# Getting started

```
[[require]]
name = "sos"
git = "https://github.com/leanprover/sos"
rev = "main"
```

Then `import SOS` and use `by sos`. You'll need the system BLAS/LAPACK runtime installed; see [the README](https://github.com/leanprover/sos) for the full showcase and native-dependency notes. There's also `sos?`, which prints the certificate it found so you can commit the witness directly instead of re-running the solver.
