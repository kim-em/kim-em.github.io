import HexBerlekampZassenhausMathlib

/-!
Certified integer polynomial factorization. `factor_poly` and `irreducibility`
run the compiled Berlekamp-Zassenhaus factorizer during elaboration and emit a
proof term containing only reified data and checked certificates, so the
factorizer itself never enters the trusted base.

This module imports the Mathlib correspondence layer, so the tactics apply to
`Polynomial ℤ` as well as to the executable `Hex.ZPoly`.
-/

namespace HexExamples.Factor

open Polynomial

-- ANCHOR: irreducible
example : Irreducible (X ^ 4 + 8 * X + 12 : Polynomial ℤ) := by
  irreducibility
-- ANCHOR_END: irreducible

-- ANCHOR: cyclotomic
-- Φ₅ · Φ₇, written out, so nothing in the input gives the answer away.
noncomputable def cyclo :=
  factor_poly (X^10+2*X^9+3*X^8+4*X^7+5*X^6+5*X^5+5*X^4+4*X^3+3*X^2+2*X+1 : Polynomial ℤ)

-- The two factors it found are Φ₅ and Φ₇.
example : cyclo.factors = [1+X+X^2+X^3+X^4, 1+X+X^2+X^3+X^4+X^5+X^6] := by
  simp [cyclo, Finset.sum_range_succ]
-- ANCHOR_END: cyclotomic

-- ANCHOR: certificate
-- The result is not just a list. It carries the proofs.
example : ∀ q ∈ cyclo.factors, Irreducible q := cyclo.factors_irred

example : C cyclo.scalar * cyclo.factors.prod =
    X^10+2*X^9+3*X^8+4*X^7+5*X^6+5*X^5+5*X^4+4*X^3+3*X^2+2*X+1 := cyclo.factors_mul
-- ANCHOR_END: certificate

-- ANCHOR: swinnertonDyer
-- The degree-8 Swinnerton-Dyer polynomial, the minimal polynomial of
-- √2 + √3 + √5. It is irreducible over ℤ but factors modulo every prime,
-- so no modular witness certifies it (even with multiple primes).
-- `irreducibility!` re-runs the factorizer in the kernel instead.
example : Irreducible
    (X ^ 8 - 40 * X ^ 6 + 352 * X ^ 4 - 960 * X ^ 2 + 576 : Polynomial ℤ) := by
  irreducibility!
-- ANCHOR_END: swinnertonDyer

end HexExamples.Factor
