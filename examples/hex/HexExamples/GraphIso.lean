-- This module does not compile yet, and is not meant to. `import Hex` below is
-- the released aggregate's umbrella, deliberately matching what the post tells
-- a reader to write. Three things have to happen, in this order, before it
-- resolves:
--
--   1. `leanprover/hex-graph-iso` and `leanprover/hex-graph-iso-mathlib` are
--      published by the hex-dev release sync;
--   2. both libraries are added to the hand-maintained umbrella `Hex.lean` in
--      released `leanprover/hex`;
--   3. `examples/hex` is pointed at a source where `import Hex` resolves to
--      that umbrella. It currently requires `kim-em/hex-dev`, pinned at a SHA
--      predating `HexGraphIso`, and hex-dev's own `Hex.lean` is a different
--      file, the shared oracle and bench helper library.
--
-- Do not paper over this by importing an unreleased library here while the post
-- shows `import Hex`, or by repointing the example project ahead of the release.

-- ANCHOR: petersen
import Hex

open Hex Hex.GraphIso

-- The Petersen graph as G(5,2), and as the Kneser graph K(5,2):
-- two presentations of the same graph on ten vertices.
def petersen : Graph 10 := Families.gpetersen 5 2
def kneser52 : Graph 10 := Families.kneser 5 2

example : Graph.Isomorphic petersen kneser52 := by graph_iso

-- The pentagonal prism G(5,1) also has ten vertices,
-- each of degree three, so degree refinement isn't enough.
def prism5 : Graph 10 := Families.gpetersen 5 1

example : ¬ Graph.Isomorphic petersen prism5 := by graph_iso
-- ANCHOR_END: petersen
