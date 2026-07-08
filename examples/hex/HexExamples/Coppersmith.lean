import HexMatrix
import HexLLL
import HexBerlekampZassenhaus

/-!
A Coppersmith-style attack on RSA, driven by the project's LLL layer. The toy
instance needs only `HexLLL`; the full 2048-bit instance also uses
`ZPoly.factorize` (Berlekamp-Zassenhaus, not yet released as a standalone package) to
read the secret off a linear factor. Each `#guard` runs when the page is built.
-/

namespace HexExamples.Coppersmith.Toy
open Hex

-- ANCHOR: coppersmithToy
-- A courier RSA-encrypts a templated message m = a + x₀ with exponent 3 and no
-- padding; a is the known template, x₀ a two-digit code with 0 ≤ x₀ < X. The
-- ciphertext is c = m³ mod N. Only N, a, c, X are public; recover x₀.

-- Public data the attacker starts from.
def N : Nat := 10_000_004_400_000_259
def X : Nat := 100
def a : Int := 55_555_500
def c : Int := 6_804_005_608_230_644

-- Coefficients of f(x) = (a + x)³ − c, reduced mod N.
def a0 := (a ^ 3 - c).bmod N
def a1 := (3 * a ^ 2).bmod N
def a2 := (3 * a).bmod N

-- The Coppersmith lattice: one polynomial per row, degree-j column scaled by
-- Xʲ, so "small coefficients" becomes "short vector". Rows N, N·x, N·x², f.
def B : Matrix Int 4 4 :=
  #m[(N : Int), 0,      0,          0;
     0,         N * X,  0,          0;
     0,         0,      N * X * X,  0;
     a0,        a1 * X, a2 * X * X, X * X * X]

-- LLL-reduce with the default δ = 3/4.
def reduced : Matrix Int 4 4 := lll B

-- De-scale a reduced row back to integer polynomial coefficients.
def descale (r : Vector Int 4) : Option (Vector Int 4) :=
  if r[1] % X == 0 && r[2] % (X * X) == 0 && r[3] % (X * X * X) == 0 then
    some #v[r[0], r[1] / X, r[2] / (X * X), r[3] / (X * X * X)]
  else
    none

-- Horner evaluation of a degree-3 integer polynomial.
def evalPoly (g : Vector Int 4) (x : Int) : Int :=
  ((g[3] * x + g[2]) * x + g[1]) * x + g[0]

-- Scan the reduced rows for an integer root that reproduces the ciphertext.
def recover : Option Int := Id.run do
  for row in reduced.rows do
    match descale row with
    | none => pure ()
    | some g =>
      for x in [0:100] do
        if evalPoly g x == 0 && (a + x) ^ 3 % N == c then
          return some x
  return none

-- LLL genuinely reduced the basis, and the recovered code is 37,
-- perhaps no surprise given we're working in Lean!
#guard lllReduced reduced == true
#guard recover == some 37
-- ANCHOR_END: coppersmithToy

end HexExamples.Coppersmith.Toy

namespace HexExamples.Coppersmith.Full
open Hex

-- ANCHOR: coppersmithFull
-- A 2048-bit RSA modulus N = p * q, with p and q the primes
-- just below 2^1024. Exponent e = 3, no padding.
def p : Nat := 2 ^ 1024 - 105
def q : Nat := 2 ^ 1024 - 179
def N : Nat := p * q

-- The known 1202-bit template a and unknown 400-bit secret
-- x0 give c = (a + x0)^3 mod N. The attacker sees only the
-- public data N, a, c, and the bound X.
def a  : Int := 3 ^ 758
def x0 : Int := 2 ^ 399 + 271828182
def X  : Nat := 2 ^ 400
def c  : Int := (a + x0) ^ 3 % N

-- f(x) = (a + x)^3 - c, reduced mod N to small coeffs, as a Hex polynomial.
def f : ZPoly :=
  DensePoly.ofCoeffs #[(a ^ 3 - c).bmod N, (3 * a ^ 2).bmod N, (3 * a).bmod N, 1]

-- Nine polynomials N^(2-j) · xⁱ · f(x)ʲ (j, i in 0,1,2). Each vanishes at x0
-- mod N²; the added shift polynomials push the recoverable bound from ~N^(1/6)
-- toward N^(1/3), covering a 400-bit root.
def rows : Array ZPoly := Id.run do
  let mut rs : Array ZPoly := #[]
  let mut fj : ZPoly := 1
  for j in [0:3] do
    for i in [0:3] do
      rs := rs.push (DensePoly.monomial i ((N : Int) ^ (2 - j)) * fj)
    fj := fj * f
  return rs

-- The lattice basis: row i, column k is the degree-k coefficient scaled by X^k.
def B : Matrix Int 9 9 :=
  Matrix.ofFn fun i k => (rows.getD i.val 0).coeff k.val * X ^ k.val

def reduced : Matrix Int 9 9 := lll B

-- De-scale a reduced row into a Hex polynomial: coefficient k divides by X^k.
def descale (r : Vector Int 9) : ZPoly :=
  DensePoly.ofCoeffs (Array.ofFn fun k : Fin 9 => r[k] / X ^ k.val)

-- LLL sorts the shortest vector into the first row; de-scale it to `g`.
def g : ZPoly := descale (reduced.row 0)

-- Factor g over Z with Berlekamp-Zassenhaus. The secret is
-- the root of its linear factor x - x0. Scanning x below
-- X ~ 2^400 is hopeless; factoring degree-8 g is instant.
def recovered : Option Int := Id.run do
  for (fac, _) in g.factors do
    match fac.toArray with
    | #[q, p] => -- a linear factor `p * X + q`
      if q % p == 0 then
        let r := -q / p
        if 0 ≤ r && r < X && (a + r) ^ 3 % N == c then
          return some r
    | _ => continue
  return none

-- The modulus is 2048 bits; the secret is about 400 bits.
#guard N > 2 ^ 2047 && N < 2 ^ 2048
#guard x0 > 2 ^ 399

-- LLL reduces the basis; factoring g gives back x0.
#guard lllReduced reduced == true
#guard recovered == some x0
-- ANCHOR_END: coppersmithFull

end HexExamples.Coppersmith.Full
