import HexMatrix
import HexRowReduce
import HexDeterminant
import HexGramSchmidt
import HexLLL

/-!
Each `ANCHOR` region is pulled into the blog post by Verso.
-/

namespace HexExamples.Core.Arithmetic
open Hex Hex.Matrix

-- ANCHOR: arithmetic
-- A 3×3 integer matrix.
def A : Matrix Int 3 3 :=
  #m[2, 0, 1;
     1, 3, 2;
     0, 1, 1]

#guard A.getRow 1 = #v[1, 3, 2]
#guard A.mulVec #v[1, 1, 1] = #v[3, 6, 2]
#guard (A + 2 • Matrix.identity 3)[(1, 1)] = 5
-- ANCHOR_END: arithmetic

end HexExamples.Core.Arithmetic

namespace HexExamples.Core.Det
open Hex Hex.Matrix

-- ANCHOR: determinant
-- A matrix of rationals.
def B : Matrix Rat 3 3 :=
  #m[2, 0,   1;
     1, 3/7, 2;
     0, 1,   1]

#guard det B = -15/7
#guard det (transpose B) = -15/7
#guard det (rowSwap B 0 1) = 15/7

-- A matrix with linearly dependent rows is singular.
def S : Matrix Int 2 2 :=
  #m[1, 2;
     2, 4]
#guard det S = 0
-- ANCHOR_END: determinant

end HexExamples.Core.Det

namespace HexExamples.Core.RowReduce
open Hex Hex.Matrix

-- ANCHOR: rowreduce
def M : Matrix Rat 2 3 :=
  #m[1, 2, 3;
     2, 4, 6]

#guard (rowReduce M).rank = 1

#guard (nullspace M).toList = [#v[-2, 1, 0], #v[-3, 0, 1]]

#guard spanContains M #v[3, 6, 9] = true
#guard spanContains M #v[1, 0, 0] = false
-- ANCHOR_END: rowreduce

end HexExamples.Core.RowReduce

namespace HexExamples.Core.GramSchmidtRat
open Hex Hex.GramSchmidt

-- ANCHOR: gramschmidt
-- A 3×3 rational matrix, orthogonalized row by row (left to right).
def m : Hex.Matrix Rat 3 3 := #m[1, 1, 0; 1, 0, 1; 0, 1, 1]

-- Each row has its projection onto the earlier rows subtracted off.
#guard basisMatrix m = #m[  1,    1,   0;
                          1/2, -1/2,   1;
                         -2/3,  2/3, 2/3]

-- The resulting rows are pairwise orthogonal.
#guard ((basisMatrix m).row 0).dotProduct ((basisMatrix m).row 1) = 0
#guard ((basisMatrix m).row 0).dotProduct ((basisMatrix m).row 2) = 0
#guard ((basisMatrix m).row 1).dotProduct ((basisMatrix m).row 2) = 0
-- ANCHOR_END: gramschmidt

end HexExamples.Core.GramSchmidtRat

namespace HexExamples.Core.GramSchmidtInt
open Hex Hex.GramSchmidt Hex.GramSchmidt.Int

-- ANCHOR: gramdet
-- Over the integers, the leading Gram determinants d₀..d₃ (the squared volumes
-- of the prefix sublattices) are computed exactly, without any division.
def m : Hex.Matrix Int 3 3 := #m[1, 1, 0; 1, 0, 1; 0, 1, 1]

#guard gramDet m 0 = 1
#guard gramDet m 1 = 2
#guard gramDet m 2 = 3
#guard gramDet m 3 = 4
-- ANCHOR_END: gramdet

end HexExamples.Core.GramSchmidtInt

namespace HexExamples.Core.LLL
open Hex Hex.Matrix

-- ANCHOR: lll
-- A skewed rank-2 basis: the first row is far from orthogonal.
def B : Hex.Matrix Int 2 2 := #m[1, 12; 0, 1]

-- Reduction returns the two unit vectors: same lattice, as short as possible.
#guard lll B (3 / 4) = #m[0, 1; 1, 0]

-- The verified integer checker rejects the input (not size-reduced) and
-- accepts the output.
#guard lllReduced B (3 / 4) (11 / 20) = false
#guard lllReduced (#m[0, 1; 1, 0] : Hex.Matrix Int 2 2) (3 / 4) (11 / 20) = true
-- ANCHOR_END: lll

end HexExamples.Core.LLL

namespace HexExamples.Core.MinPoly
open Hex Hex.Matrix

-- ANCHOR: minpoly
-- We recover the minimal polynomial of α = 1.220744…, knowing only
-- that α is a root of some integer polynomial of degree ≤ 4.
-- We form one lattice row for each power of α:
-- eᵢ in the first five columns, and ⌊10⁶·αⁱ⌋ in the last.
def L : Hex.Matrix Int 5 6 :=
  #m[1, 0, 0, 0, 0, 1000000;
     0, 1, 0, 0, 0, 1220744;
     0, 0, 1, 0, 0, 1490216;
     0, 0, 0, 1, 0, 1819173;
     0, 0, 0, 0, 1, 2220744]

-- The shortest reduced row reads off (a₀,a₁,a₂,a₃,a₄) = (−1,−1,0,0,1) with a
-- zero last coordinate: the relation −1 − α + α⁴ = 0.
#guard (lll L (3 / 4)).row 0 = #v[-1, -1, 0, 0, 1, 0]
-- ANCHOR_END: minpoly

end HexExamples.Core.MinPoly

namespace HexExamples.Core.Glossary
open Hex Hex.Matrix Hex.GramSchmidt.Int

/-!
A glossary of names and types referenced inline in the prose. It is never shown
as a code block; the post pulls individual tokens out of it with
`{anchorName glossary}` / `{anchorTerm glossary}`, so an inline mention like
`Matrix.det` carries the same type information and hover as the code samples.
-/

-- ANCHOR: glossary
section
variable {R : Type} {n m : Nat}

example : Type := Matrix R n m
example : Type := Vector (Vector R m) n
example : Type := Vector R (n * m)

#check @Matrix.det
#check @Matrix.transpose
#check @Matrix.rowReduce
#check @Matrix.RowEchelonData
#check @RowEchelonData
#check @Matrix.nullspace
#check @Matrix.spanContains
#check @gramDet
#check @lll
#check @lllNative
end
-- ANCHOR_END: glossary

end HexExamples.Core.Glossary
