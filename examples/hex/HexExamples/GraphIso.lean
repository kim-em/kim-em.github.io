-- `import Hex` below is the released aggregate's umbrella, deliberately
-- matching what the post tells a reader to write; `examples/hex` requires
-- `leanprover/hex` so that this is the same import a reader would get.
--
-- Do not paper over a breakage by importing a library directly here while the
-- post shows `import Hex`.
--
-- The code between the anchor fences must stay character-for-character
-- identical to the block in `Site/Blog/GraphIso.lean`.

-- ANCHOR: petersen
import Hex

open Hex Hex.GraphIso

-- The Petersen graph as G(5,2), and as the Kneser graph K(5,2):
-- two presentations of the same graph on ten vertices.
def petersen : Graph 10 := Families.gpetersen 5 2
def kneser52 : Graph 10 := Families.kneser 5 2

example : Graph.Isomorphic petersen kneser52 := by graph_iso

-- The pentagonal prism G(5,1) also has ten vertices,
-- each of degree three.
def prism5 : Graph 10 := Families.gpetersen 5 1

example : ¬ Graph.Isomorphic petersen prism5 := by graph_iso
-- ANCHOR_END: petersen
