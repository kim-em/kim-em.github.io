-- ANCHOR: factoring
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
-- ANCHOR_END: factoring
