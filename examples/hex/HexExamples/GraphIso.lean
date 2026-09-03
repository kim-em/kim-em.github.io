-- TODO (draft): re-check this example against the final HexGraphIso API
-- before publication. It is written against `HexGraphIso/Families.lean` as it
-- stands on the hex-dev `nauty` branch, where the one-cell colouring is
-- `Families.plain`. An in-flight change may rename that to
-- `Graph.singleColor` and may add an uncoloured API, in which case both the
-- text below and `Site/Blog/GraphIso.lean` need updating together.
--
-- This module has not been compiled, for two reasons. `examples/hex/lakefile.lean`
-- still pins hex-dev at a SHA that predates `HexGraphIso`. And `import Hex`
-- below is the released aggregate's umbrella, which re-exports every released
-- library and will gain `HexGraphIso` when the release sync publishes it; the
-- `Hex.lean` in hex-dev is a different file, the shared oracle and bench
-- helper library, so this import will not reach `Hex.GraphIso` while
-- `examples/hex` requires hex-dev rather than released `hex`.
-- ANCHOR: petersen
import Hex

open Hex Hex.GraphIso

-- `Colored n k` is a graph on `n` vertices with an ordered `k`-colouring,
-- and `Families.plain` gives a graph the trivial one-colour colouring.
-- The Petersen graph as G(5,2), and as the Kneser graph K(5,2):
-- two presentations of the same graph on ten vertices.
def petersen : Colored 10 1 := Families.plain (Families.gpetersen 5 2)
def kneser52 : Colored 10 1 := Families.plain (Families.kneser 5 2)

-- The pentagonal prism G(5,1) is the interesting negative companion:
-- ten vertices, every one of degree three, so degree refinement alone
-- does not settle the question.
def prism5 : Colored 10 1 := Families.plain (Families.gpetersen 5 1)

example : Isomorphic petersen kneser52 := by graph_iso
example : ¬ Isomorphic petersen prism5 := by graph_iso
-- ANCHOR_END: petersen
