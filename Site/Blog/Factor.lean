import VersoBlog
import Site.Categories
open Verso Genre Blog
open Verso.Code.External

set_option linter.verso.markup.emph false

set_option verso.exampleProject "examples/hex"
set_option verso.exampleModule "HexExamples.Factor"

#doc (Post) "Certified integer polynomial factorization in Lean" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 8, day := 10}
categories := [Site.algebra, Site.lean, Site.tactics]
%%%

I'm happy to announce the release of further packages for [Hex](https://github.com/leanprover/hex), the computer algebra library for Lean.

Today we have an integer polynomial factorization library, including tactics for factorizing and irreducibility.

To get started, add to your `lakefile.toml`:

```
[[require]]
name = "hex"
git = "https://github.com/leanprover/hex.git"
rev = "main"
```

and then:

```anchor factoring
import HexBerlekampZassenhausMathlib

open Polynomial

example : Irreducible (X ^ 4 + 8 * X + 12 : Polynomial ℤ) := by
  irreducibility

-- Factor the product of two cyclotomic polynomials.
noncomputable def cyclo :=
  factor_poly (X^10+2*X^9+3*X^8+4*X^7+5*X^6+5*X^5+5*X^4+4*X^3+3*X^2+2*X+1 : Polynomial ℤ)

-- The two factors it found are Φ₅ and Φ₇.
example : cyclo.factors = [1+X+X^2+X^3+X^4, 1+X+X^2+X^3+X^4+X^5+X^6] := by
  simp [cyclo, Finset.sum_range_succ]

-- They are irreducible, and they multiply back to the input.
example : ∀ q ∈ cyclo.factors, Irreducible q := cyclo.factors_irred
example : C cyclo.scalar * cyclo.factors.prod =
    X^10+2*X^9+3*X^8+4*X^7+5*X^6+5*X^5+5*X^4+4*X^3+3*X^2+2*X+1 := cyclo.factors_mul

-- The degree-8 Swinnerton-Dyer polynomial, the minimal polynomial of
-- √2 + √3 + √5. It is irreducible over ℤ but factors modulo every prime,
-- so no modular witness certifies it (even with multiple primes).
-- `irreducibility!` re-runs the factorizer in the kernel instead.
example : Irreducible
    (X ^ 8 - 40 * X ^ 6 + 352 * X ^ 4 - 960 * X ^ 2 + 576 : Polynomial ℤ) := by
  irreducibility!
```

There's quite a lot going on here. We implement the Berlekamp algorithm for factoring mod `p`, Hensel lifting, and the Berlekamp-Zassenhaus algorithm, with efficient factor reconstruction using van Hoeij's knapsack method ([Factoring polynomials and the knapsack problem](https://www.math.fsu.edu/~hoeij/knapsack/paper/May16_2001/knapsack.pdf), J. Number Theory 95 (2002) 167-189).
The van Hoeij algorithm has never previously been formally verified! We build on top of the [previously released lattice basis reduction library](/blog/2026-7-7-lattice-basis-reduction-using-the-hex-lean-library/) in Hex.

(Isabelle has a lattice based reconstruction algorithm, but it is the original LLL algorithm, which is polynomial time but with poor constants.
The van Hoeij method is efficient in practice as well!)

Our performance numbers are quite good: we are consistently faster than Isabelle,
and appear to have similar asymptotic behaviour to the state-of-the-art unverified libraries, running about 5x slower than FLINT.

Two plots, both cumulative "cactus" plots of instances solved against time:

![a mixed sample drawn from the whole test corpus](/figures/hexbz-cactus-combined.svg)

![Swinnerton-Dyer polynomials, the classic hard case for Berlekamp-Zassenhaus recombination](/figures/hexbz-cactus-swinnerton-dyer.svg)

As usual for Hex, these libraries are split into purely computational libraries that do not depend on Mathlib, plus associated libraries that make the connection with Mathlib theory. (The irreducibility and factoring tactics work in the purely computational setting, and then gain capabilities to handle Mathlib polynomials once you import the Mathlib libraries.) In the medium term I am interested in merging the "with Mathlib" libraries into Mathlib (adding the computational libraries as dependencies), which would make these tactics available within Mathlib, and to all projects that import Mathlib without the need for further dependencies.

Unreleased libraries, and all future development, live at [github.com/kim-em/hex-dev](https://github.com/kim-em/hex-dev).
Contributions and pull requests are welcome, but specs must be updated *before* any new features or substantial changes, as separately reviewed PRs.
