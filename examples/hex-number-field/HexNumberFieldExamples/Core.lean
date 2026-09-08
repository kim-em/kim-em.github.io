import Hex

open Hex

-- ANCHOR: numbers
-- An algebraic number is a root of an integer polynomial, named by an
-- approximation: the nearest root wins.
def s2 : AlgebraicNumber := ZPoly.rootNear #p[-2, 0, 1] 1.4
def s3 : AlgebraicNumber := ZPoly.rootNear #p[-3, 0, 1] 1.7
-- All the roots at once, real ones first in increasing order:
#guard (ZPoly.algebraicRoots #p[-2, 0, 1]) == #[-s2, s2]

-- Arithmetic:
#guard (s2 + s3).p = #p[1, 0, -10, 0, 1]   -- the minimal polynomial of √2 + √3
-- Equality (without importing the Mathlib theory library,
-- you need to use `==`, but with it `=` is allowed too):
#guard (s2 + s3)⁻¹ == s3 - s2

/-- info: ZPoly.rootNear #p[1, 0, -10, 0, 1] 3.146264369 -/
#guard_msgs in
#eval s2 + s3
-- ANCHOR_END: numbers

-- ANCHOR: qadjoin
-- If you're working in a fixed number field, use `QAdjoin`: the field ℚ(a)
-- of a canonical number, whose elements are rational polynomials in it.
def cbrt2 : AlgebraicNumber := ZPoly.rootNear #p[-2, 0, 0, 1] 1.26
def c : QAdjoin cbrt2 := cbrt2.toQAdjoin

-- Arithmetic and equality are efficient in `QAdjoin`,
-- and inverses are calculated with extended GCDs.
#guard c ^ 3 == 2
#guard c⁻¹ == c * c / 2

-- Elements print as the expression that rebuilds them: the generating
-- number and the coordinates.
/-- info: QAdjoin.ofCoeffs (ZPoly.rootNear #p[-2, 0, 0, 1] 1.25992) #p[0, 0, 2] -/
#guard_msgs in
#eval c ^ 5
-- ANCHOR_END: qadjoin

open Hex.NumberTower

-- ANCHOR: tower
-- `NumberTower.rat` is ℚ. `adjoin T a` extends the tower `T` by a root `a`;
-- the result carries the new tower, the adjoined generator `gen`, and the
-- inclusion `embed` of `T`, which is why its type names `T`.
def Q2 : Extension NumberTower.rat := adjoin NumberTower.rat s2.toRoot
def Q23 : Extension Q2.tower := adjoin Q2.tower s3.toRoot

def quartic (T : NumberTower) : Poly T := liftZPoly T #p[1, 0, -10, 0, 1]

-- Over ℚ(√2) the quartic splits into two quadratics; over ℚ(√2, √3) into
-- four linear factors. A factorization pairs each factor with its
-- multiplicity; here we read off the degrees.
#guard (factor Q2.tower (quartic Q2.tower)).factors.map
  (fun (g, _) => g.size - 1) = #[2, 2]
#guard (factor Q23.tower (quartic Q23.tower)).factors.map
  (fun (g, _) => g.size - 1) = #[1, 1, 1, 1]
-- ANCHOR_END: tower

-- ANCHOR: flatten
-- `flatten T : Flattening T` is the primitive element theorem as a function:
-- a single algebraic number generating the whole tower, with the coordinate
-- changes between the tower and ℚ(root). Here root is ±√2 ± √3, and
-- √2 = (root³ − 9·root)/2.
def F : Flattening Q23.tower := flatten Q23.tower

#guard F.root.p = #p[1, 0, -10, 0, 1]
#guard (F.toPrimitive (Q23.embed Q2.gen)).coeffs = #p[0, -9 / 2, 0, 1 / 2]
-- ANCHOR_END: flatten

-- ANCHOR: coords
-- Arithmetic in a tower is coordinate arithmetic: a power of √2 + √3 costs a
-- few multiplications of coordinate vectors, over the basis 1, √2, √3, √6.
def gamma : Elem Q23.tower := Q23.embed Q2.gen + Q23.gen

#guard coeffs (gamma ^ 10) = #[47525, 0, 0, 19402]   -- 47525 + 19402·√6

-- The same power as an `AlgebraicNumber` recomputes a minimal polynomial at
-- every step, and agrees. Its minimal polynomial is only quadratic, since the
-- power lies in ℚ(√6).
#guard (F.toPrimitive (gamma ^ 10)).toAlgebraicNumber == (s2 + s3) ^ 10

/-- info: ZPoly.rootNear #p[1, -95050, 1] 95049.99998947 -/
#guard_msgs in
#eval (s2 + s3) ^ 10
-- ANCHOR_END: coords
