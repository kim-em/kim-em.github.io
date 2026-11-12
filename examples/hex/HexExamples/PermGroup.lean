-- Keep the m11 anchor identical to Site/Blog/PermGroup.lean.

-- ANCHOR: m11
import HexPermGroupTheory
import Mathlib.GroupTheory.Perm.Cycle.Concrete

def M11 : Subgroup (Equiv.Perm (Fin 11)) :=
  Subgroup.closure
    {c[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      c[2, 6, 10, 7] * c[3, 9, 4, 5]}

example : Nat.card M11 = 7920 := by
  perm_group

example : c[0, 1] ∉ M11 := by
  perm_group
-- ANCHOR_END: m11
