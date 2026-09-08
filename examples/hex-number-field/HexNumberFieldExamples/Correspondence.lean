import HexNumberFieldMathlib

open Hex

-- The companion interprets each `AlgebraicNumber` as a complex number, and
-- proves that interpretation injective and arithmetic-preserving.
-- ANCHOR: correspondence
example (a b : AlgebraicNumber) (h : a.toComplex = b.toComplex) : a = b :=
  AlgebraicNumber.toComplex_injective h

example (a b : AlgebraicNumber) :
    (a + b).toComplex = a.toComplex + b.toComplex :=
  AlgebraicNumber.add_toComplex a b
-- ANCHOR_END: correspondence
