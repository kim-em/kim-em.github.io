import VersoBlog
import Site.Categories
open Verso Genre Blog
open Verso.Code.External

set_option linter.verso.markup.emph false

set_option verso.exampleProject "examples/hex"
set_option verso.exampleModule "HexExamples.GraphIso"

/-
DRAFT. Do not publish until `HexGraphIso` is actually released.

The prose is the Zulip announcement draft (`zulip.md` in hex-dev), reused
as-is. Open items:

* `date` below is today's date, not a decided publication date. The published
  URL is generated from the date and the title (un-zero-padded), so changing
  either changes the permalink.
* The title is a guess, parallel to "Certified integer polynomial
  factorization in Lean".
* `categories` copies the Factor post. `Site.performance` is also defined and
  would fit, given the comparison charts.
* `XXX` and `YYY` below are the two ratios the Zulip draft leaves open.
* The anchor example says `import HexGraphIso`, not the `import Hex` of the
  Zulip draft: in hex-dev, `Hex` is the shared oracle/bench helper library and
  does not re-export `Hex.GraphIso`. It must be re-checked against the final
  API; see the TODO in `examples/hex/HexExamples/GraphIso.lean`.
* `examples/hex/lakefile.lean` still pins hex-dev at a SHA that predates
  `HexGraphIso`, so the anchor cannot be extracted yet.
* `https://github.com/leanprover/hex-graph-iso` is not yet published by the
  hex-dev release sync, and the `leanprover.github.io/hex/docs` link is
  unverified.
-/

#doc (Post) "Certified graph isomorphism in Lean" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 9, day := 3}
categories := [Site.algebra, Site.lean, Site.tactics]
%%%

I'm very excited to release [`HexGraphIso`](https://github.com/leanprover/hex-graph-iso), a new sublibrary of [`Hex`](https://github.com/leanprover/hex), which implements (a subset of) Brendan McKay's [`nauty`](https://users.cecs.anu.edu.au/~bdm/nauty/) in Lean, proves it correct, and provides a tactic layer.

`nauty` is one of my favourite pieces of software. It takes a decision problem, graph isomorphism, which is meant to be really hard, and uses a clever algorithm and heuristics to make it rather fast in practice! I didn't fully understand the beauty of `nauty` until I co-supervised one of Brendan's students, and could appreciate just how many combinatorial problems can be encoded into graph isomorphism problems, and then solved very efficiently with `nauty`.

The `HexGraphIso` library is a re-implementation of the dense graph algorithm from `nauty`, into Lean. Right now it only supports the default mode of operation, but I anticipate supporting further options from `nauty` later. We don't attempt to prove that the re-implementation is faithful, except via conformance tests. But we *do* prove that the Lean implementation is correct: two graphs are assigned the same "canonical form" if and only if they are isomorphic. Moreover we return efficient kernel checkable certificates for the canonical labelling.

This enables us to provide a `graph_iso` tactic, which solves both pairwise isomorphism and non-isomorphism goals, both without Mathlib (where graphs are represented using [`Hex.GraphIso.Colored`](https://leanprover.github.io/hex/docs)) and [with Mathlib](https://kim-em.github.io/hex-dev/find/?domain=Verso.Genre.Manual.section&name=hex-graph-iso-mathlib), where the tactic gains the ability to process many ground terms representing `SimpleGraph`s.

Add to your `lakefile.toml`:

```
[[require]]
name = "hex"
git = "https://github.com/leanprover/hex.git"
rev = "main"
```

and then:

```anchor petersen
import HexGraphIso

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
```

(This example is drawn from the [Hex manual page for `HexGraphIso`](https://kim-em.github.io/hex-dev/find/?domain=Verso.Genre.Manual.section&name=hex-graph-iso).)

For now, we do not provide functions, verified or otherwise, that return generators for the automorphism group of a graph, but this will hopefully arrive [soon](https://github.com/kim-em/hex-dev/issues/9959).

Some other goodies associated with this release:

* A [specification](https://kim-em.github.io/hex-dev/find/?domain=Verso.Genre.Manual.section&name=nauty-algorithm) of what the default dense mode of `nauty` 2.9.3 is actually doing!
* [`leanprover/nauty-ffi`](https://github.com/leanprover/nauty-ffi), a Lean FFI wrapper around `nauty` itself, if you don't care about verification and just want to run the original C code, fast. We don't use this in `HexGraphIso` except for conformance testing.
* [Comparison charts](https://kim-em.github.io/hex-dev/find/?domain=Verso.Genre.Manual.section&name=hex-graph-iso-performance) showing the relative performance of `HexGraphIso` and `nauty`: at present, the compiled canonical labelling is about XXX times slower than `nauty`, and the non-isomorphism tactic, which replays the decision through the kernel, is about YYY times slower again. (Already I'm very happy with these numbers: `nauty` is fast! We'll get a bit better with some further AI-driven optimization, but don't expect catching up!)

Here are those charts. The first is canonical labelling over the deterministic families, comparing `nauty` 2.9.3, the fast compiled `canonicalize`, and `canonicalizeChecked`, which additionally validates every answer through the proven certificate checker:

![Canonical labelling: a cactus plot over the family instances, and a per-family breakdown of nauty, canonicalize, and canonicalizeChecked](/figures/hexgraphiso-canon-cactus.svg)

The second is isomorphism proof obligations of known polarity, and adds the `graph_iso` tactic itself, timed end to end as a kernel-checked proof:

![Isomorphism proof obligations: nauty, the compiled isIso decision, isIsoChecked, and the graph_iso tactic, as a cactus plot](/figures/hexgraphiso-pairs-cactus.svg)

(Both measured on `chungus2`, an AMD EPYC 9455, on 2026-09-03.)

Unreleased libraries, and all future development, live at [github.com/kim-em/hex-dev](https://github.com/kim-em/hex-dev).
Contributions and pull requests are welcome, but specs must be updated *before* any new features or substantial changes, as separately reviewed PRs.
