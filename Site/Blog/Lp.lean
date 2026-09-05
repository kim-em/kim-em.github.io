import VersoBlog
import Site.Categories
import Site.Examples
open Verso Genre Blog
open Verso.Code.External

set_option linter.verso.markup.emph false

set_option verso.exampleProject "examples/lp"
set_option verso.exampleModule "LpExamples"

-- Seed Verso's cache from pre-generated highlighting data. Does nothing unless
-- SITE_PREBUILT_EXAMPLES is set, in which case CI's artifacts must be in place.
load_examples "examples/lp"

#doc (Post) "Verified linear programming" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 6, day := 14}
categories := [Site.tactics, Site.lean]
%%%

I've released [`leanprover/lp`](https://github.com/leanprover/lp): verified linear programming in Lean 4. It's two things at once — a proof-carrying solver you can call from your own algorithms, and a tactic frontend that behaves a bit like `linarith` but reaches some goals `linarith` can't.

The examples below are all elaborated by Lean when this page is built, using the actual tactic. Nothing here is a screenshot.

# The tactic

At its simplest, `lp` closes linear arithmetic goals over `Rat`:

```anchor basic
example (x : Rat) (_h₁ : 0 ≤ x) (_h₂ : x ≤ 4) : 3 * x + 7 ≤ 19 := by lp
```

It's happy with the full textbook linear program. Here the optimum of `3 x₀ + 5 x₁` is `36`, and `lp` proves the bound directly:

```anchor optimum
example (x₀ x₁ : Rat)
    (_ : x₀ ≤ 4) (_ : 2 * x₁ ≤ 12) (_ : 3 * x₀ + 2 * x₁ ≤ 18)
    (_ : 0 ≤ x₀) (_ : 0 ≤ x₁) :
    3 * x₀ + 5 * x₁ ≤ 36 := by lp
```

The part I'm most pleased with is the quantified fragment. `lp` handles a Π₂ (∃∀) slice of goals that `linarith` doesn't touch at all:

```anchor quantified
example : ∃ x : Rat, 1 ≤ x ∧ x ≤ 2 ∧ ∀ y : Rat, 0 ≤ y → y ≤ 1/2 → y ≤ x := by lp
```

There's also a forward-direction `maximize` tactic. `maximize e` computes a certified upper bound for `e` and adds it as a hypothesis (here called `hbound`):

```anchor maximize
example (x₀ x₁ : Rat) (_h₁ : 0 ≤ x₀) (_h₂ : 0 ≤ x₁) (_h₃ : x₀ ≤ 4)
    (_h₄ : 2 * x₁ ≤ 12) (_h₅ : 3 * x₀ + 2 * x₁ ≤ 18) :
    3 * x₀ + 5 * x₁ ≤ 36 := by
  maximize 3 * x₀ + 5 * x₁
  exact hbound
```

# How the proofs are built

The external LP solver is an untrusted oracle. It hands back an *exact rational certificate*, which a pure-Lean verifier checks; the tactic then rebuilds an ordinary kernel proof term from the Farkas multipliers. So the solver can be as fast and as hairy as it likes — if the certificate doesn't check, you get no proof, and if it does, the kernel is the thing you're trusting, not the solver.

There are no Lean dependencies beyond core. The default backend compiles a vendored [SoPlex](https://soplex.zib.de/), which is very capable on large problems. There's also a pure-Lean simplex backend with no native dependencies at all, and an experimental JSON backend for driving any external solver that speaks its documented wire contract.

`lp` handles `Rat`, `Int`, `Nat`, and `Dyadic` goals out of the box, and `Real` once Mathlib's instances are imported.

# What it is not

- It's **not a drop-in replacement for `linarith`**. `linarith` does a lot of convenient preprocessing that's hard to specify precisely, and I haven't tried to match all of it.
- It does **no integrality reasoning**. `lp` treats `Int` and `Nat` goals as linear problems over the rationals; if you need genuine integer arguments, reach for `cutsat`.

# Getting started

Add this to your `lakefile.toml`:

```
[[require]]
name = "LP"
git = "https://github.com/leanprover/lp"
rev = "main"
```

Then `import LP` and use `by lp`. See the README if you want a different backend.

On dense `Rat` problems `lp` is 2–3× faster than `linarith` (there's a benchmark suite), and the native carriers (`Int`, `Nat`, `Dyadic`) are faster still.
