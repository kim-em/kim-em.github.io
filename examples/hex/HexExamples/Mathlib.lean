import HexRowReduceMathlib

/-!
Crossing into Mathlib. The computational libraries are Mathlib-free, but each has
a companion `HexXMathlib` library identifying the executable results with their
Mathlib analogues. This section imports one of them, so it does compile Mathlib
(fetched via `lake exe cache get`). The payoff: settle a fact about Mathlib's
*noncomputable* `Matrix.rank` by running the executable row reduction in the
kernel and rewriting through the correspondence theorem.
-/

namespace HexExamples.Mathlib.RankProof
open Hex Hex.Matrix HexMatrixMathlib

-- ANCHOR: mathlibRank
-- `A` is an ordinary Mathlib matrix; `A.rank` is Mathlib's noncomputable rank.
def A : _root_.Matrix (Fin 2) (Fin 3) Rat := !![1, 2, 3; 2, 4, 6]

theorem rank_eq_one : A.rank = 1 := by
  -- Rewrite the noncomputable rank into the executable one, then decide it in
  -- the kernel. No `native_decide`: the compiler is not in the trusted base.
  rw [← matrixEquiv.apply_symm_apply A,
      ← rank_eq (rowReduce_isRowReduced _)]
  decide +kernel
-- ANCHOR_END: mathlibRank

end HexExamples.Mathlib.RankProof
