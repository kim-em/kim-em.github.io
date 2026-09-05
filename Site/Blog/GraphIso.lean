import VersoBlog
import Site.Categories
import Site.Examples
open Verso Genre Blog
open Verso.Code.External

set_option linter.verso.markup.emph false

set_option verso.exampleProject "examples/hex"
set_option verso.exampleModule "HexExamples.GraphIso"

-- Seed Verso's cache from pre-generated highlighting data. Does nothing unless
-- SITE_PREBUILT_EXAMPLES is set, in which case CI's artifacts must be in place.
load_examples "examples/hex"


#doc (Post) "Certified graph isomorphism in Lean" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 9, day := 5}
categories := [Site.algebra, Site.lean, Site.tactics]
%%%

I'm very excited to release [`HexGraphIso`](https://github.com/leanprover/hex-graph-iso), a new sublibrary of [`Hex`](https://github.com/leanprover/hex), which implements (a subset of) Brendan McKay's [`nauty`](https://users.cecs.anu.edu.au/~bdm/nauty/) in Lean, proves it correct, and provides a tactic layer.

`nauty` is one of my favourite pieces of software. It takes a decision problem, graph isomorphism, which is meant to be really hard, and uses a clever algorithm and heuristics to make it rather fast in practice! I didn't fully understand the beauty of `nauty` until I co-supervised one of Brendan's students, and could appreciate just how many combinatorial problems can be encoded into graph isomorphism problems, and then solved very efficiently with `nauty`.

The `HexGraphIso` library is a re-implementation of the dense graph algorithm from `nauty`, into Lean. Right now it only supports the default mode of operation, but I anticipate supporting further options from `nauty` later. We don't attempt to prove that the re-implementation is faithful (in practice, it is!), except via conformance tests. But we *do* prove that the Lean implementation is correct: two graphs are assigned the same "canonical form" if and only if they are isomorphic. Moreover we return efficient kernel checkable certificates for the canonical labelling.

In fact, most of the proof work goes into showing that the search pruning that `nauty` performs is all correct: that it never causes us to miss finding the canonical labelling.

This enables us to provide a `graph_iso` tactic, which solves both pairwise isomorphism and non-isomorphism goals, both without Mathlib (where graphs are represented using [`Hex.Graph`](https://leanprover.github.io/hex/docs), or `Hex.GraphIso.Colored` when you want ordered vertex colours) and [with Mathlib](https://kim-em.github.io/hex-dev/find/?domain=Verso.Genre.Manual.section&name=hex-graph-iso-mathlib), where the tactic gains the ability to process many ground terms representing `SimpleGraph`s.

Add to your `lakefile.toml`:

```
[[require]]
name = "hex"
git = "https://github.com/leanprover/hex.git"
rev = "main"
```

and then:

```anchor petersen
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
```

(This example is drawn from the [Hex manual page for `HexGraphIso`](https://kim-em.github.io/hex-dev/find/?domain=Verso.Genre.Manual.section&name=hex-graph-iso).)

You might think that this is "only" about graphs. The real power of `nauty` and hence `HexGraphIso`
comes from the fact that a huge range of combinatorial objects can be encoded as graphs, moreover reflecting isomorphisms.
This then allows us to solve the isomorphism problem in many domains. In fact, the encoding doesn't need to be at all efficient,
because `nauty` is typically so efficient that the blowup doesn't matter much.

We illustrate this idea by taking the Latin square example from the [`nauty` introduction](https://pallini.di.uniroma1.it/Introduction.html)
and implementing it using `HexGraphIso`.
Consider the Latin square whose rows are `0 2 1`, `1 0 2`, and `2 1 0`.

The encoding has a vertex for each row, column,
symbol, and position, each kind receiving a different "color". Each position is
joined to its row, its column, and the symbol written there. A
colour-preserving graph isomorphism therefore restricts to three permutations,
and the three edges at every position force precisely the isotopy equation.
Once that correspondence is proved, the actual isotopy proof is just the
reduction followed by `graph_iso`:

```anchor latinencoding (module := HexExamples.GraphIso.Latin)
open Hex.GraphIso.Mathlib

namespace LatinSquareExample

structure LatinSquare where
  entry : Fin 3 → Fin 3 → Fin 3
  rows : ∀ i, Function.Bijective (entry i)
  columns : ∀ j, Function.Bijective (fun i => entry i j)

def Isotopic (L M : LatinSquare) : Prop :=
  ∃ r c s : Equiv.Perm (Fin 3),
    ∀ i j, M.entry (r i) (c j) = s (L.entry i j)

def nautySquare : LatinSquare where
  entry
    | 0, 0 => 0 | 0, 1 => 2 | 0, 2 => 1
    | 1, 0 => 1 | 1, 1 => 0 | 1, 2 => 2
    | 2, 0 => 2 | 2, 1 => 1 | 2, 2 => 0
  rows := by decide
  columns := by decide

def cyclicSquare : LatinSquare where
  entry i j := ⟨(i + j) % 3, by omega⟩
  rows := by decide
  columns := by decide

inductive Vertex
  | row : Fin 3 → Vertex
  | column : Fin 3 → Vertex
  | symbol : Fin 3 → Vertex
  | position : Fin 3 × Fin 3 → Vertex
  deriving DecidableEq, Fintype

private def incidence (L : LatinSquare)
    (x y : Vertex) : Prop :=
  match x, y with
  | .position (i, _), .row i' => i = i'
  | .position (_, j), .column j' => j = j'
  | .position (i, j), .symbol k => L.entry i j = k
  | _, _ => False

private instance (L : LatinSquare) :
    DecidableRel (incidence L) :=
  fun x y => by
    cases x <;> cases y <;>
      simp only [incidence] <;> infer_instance

private def graph (L : LatinSquare) :
    SimpleGraph Vertex :=
  SimpleGraph.fromRel (incidence L)

private def color : Vertex → Fin 4
  | .row _ => 0
  | .column _ => 1
  | .symbol _ => 2
  | .position _ => 3

def encode (L : LatinSquare) :
    Hex.GraphIso.Mathlib.Colored Vertex 4 where
  graph := graph L
  color := color
  onto := by decide

private instance (L : LatinSquare) :
    DecidableRel (encode L).graph.Adj :=
  fun x y => by
    change Decidable
      (x ≠ y ∧ (incidence L x y ∨ incidence L y x))
    infer_instance
```

and then the correspondence itself, which is where the work is:

```anchor latincorrespondence (module := HexExamples.GraphIso.Latin)
variable {L M : LatinSquare}

private def component : Fin 3 → Fin 3 → Vertex
  | 0 => Vertex.row
  | 1 => Vertex.column
  | 2 => Vertex.symbol

private def index : Vertex → Fin 3
  | .row i | .column i | .symbol i => i
  | .position _ => 0

private def componentMap
    (f : (encode L).Iso (encode M))
    (kind i : Fin 3) : Fin 3 :=
  index (f.graphIso (component kind i))

private theorem map_component
    (f : (encode L).Iso (encode M))
    (kind i : Fin 3) :
    f.graphIso (component kind i) =
      component kind (componentMap f kind i) := by
  have hc := f.map_color (component kind i)
  generalize h : f.graphIso (component kind i) = v
    at hc ⊢
  fin_cases kind <;> cases v <;>
    simp_all [component, componentMap, index,
      encode, color]

private noncomputable def componentPerm
    (f : (encode L).Iso (encode M)) (kind : Fin 3) :
    Equiv.Perm (Fin 3) :=
  Equiv.ofBijective (componentMap f kind) <| by
    apply Function.Injective.bijective_of_finite
    intro i j h
    have hc : component kind i = component kind j := by
      apply f.graphIso.injective
      rw [map_component, map_component, h]
    fin_cases kind <;> simpa [component] using hc

private theorem map_entry
    (f : (encode L).Iso (encode M)) (i j : Fin 3) :
    M.entry (componentMap f 0 i) (componentMap f 1 j) =
      componentMap f 2 (L.entry i j) := by
  obtain ⟨p, hp⟩ : ∃ p,
      f.graphIso (Vertex.position (i, j)) =
        Vertex.position p := by
    have hc := f.map_color (Vertex.position (i, j))
    generalize h : f.graphIso (Vertex.position (i, j)) = v
      at hc
    cases v <;> simp_all [encode, color]
  have hr := f.graphIso.map_adj_iff.mpr
    (show (graph L).Adj (.position (i, j)) (.row i) by
      simp [graph, incidence])
  have hc := f.graphIso.map_adj_iff.mpr
    (show (graph L).Adj (.position (i, j)) (.column j) by
      simp [graph, incidence])
  have hs := f.graphIso.map_adj_iff.mpr
    (show (graph L).Adj
        (.position (i, j)) (.symbol (L.entry i j)) by
      simp [graph, incidence])
  rw [hp,
    show Vertex.row i = component 0 i from rfl,
    map_component] at hr
  rw [hp,
    show Vertex.column j = component 1 j from rfl,
    map_component] at hc
  rw [hp,
    show Vertex.symbol (L.entry i j) =
      component 2 (L.entry i j) from rfl,
    map_component] at hs
  simp [encode, graph, incidence, component] at hr hc hs
  simpa [hr, hc] using hs

theorem isotopic_of_isomorphic :
    (encode L).Isomorphic (encode M) → Isotopic L M := by
  rintro ⟨f⟩
  exact ⟨componentPerm f 0, componentPerm f 1,
    componentPerm f 2, map_entry f⟩

example : Isotopic nautySquare cyclicSquare := by
  apply isotopic_of_isomorphic
  graph_iso

end LatinSquareExample
```

For now, we do not provide functions, verified or otherwise, that return generators for the automorphism group of a graph, but this will hopefully arrive [soon](https://github.com/kim-em/hex-dev/issues/9959).

Right now, `HexGraphIso` is about 5 to 12 times slower than `nauty`, and the non-isomorphism tactic, which replays the decision through the kernel, is about 5000 times slower again. (Already I'm very happy with these numbers: `nauty` is fast! We'll get a bit better with some further AI-driven optimization, but don't expect catching up!)

The first chart here shows canonical labelling over some standard families: a cactus plot of `nauty` 2.9.3 against the compiled `canonicalize`, and beside it the same two broken down per family against the number of vertices. Every family lands approximately an order of magnitude slower than `nauty`, with the Kneser and Johnson graphs the slowest and the grids and random graphs the quickest.

![Canonical labelling over the deterministic families: a cactus plot of nauty 2.9.3 against the compiled canonicalize, and a per-family breakdown of the same two against vertex count](/figures/hexgraphiso-canon-cactus.svg)

The second chart shows non-isomorphism proof obligations, which adds a third curve for the `graph_iso` tactic itself, timed end to end as a kernel-checked proof:

![Non-isomorphism proof obligations: a cactus plot of nauty 2.9.3, the compiled isIso, and the graph_iso tactic](/figures/hexgraphiso-pairs-cactus.svg)

(Both measured on `chungus2`, an AMD EPYC 9455, on 2026-09-05. These charts also appear in the [Hex manual page for `HexGraphIso`](https://kim-em.github.io/hex-dev/find/?domain=Verso.Genre.Manual.section&name=hex-graph-iso-performance).)

Some other goodies associated with this release:

* A [specification](https://kim-em.github.io/hex-dev/find/?domain=Verso.Genre.Manual.section&name=nauty-algorithm) of what the default dense mode of `nauty` 2.9.3 is actually doing!
* [`leanprover/nauty-ffi`](https://github.com/leanprover/nauty-ffi), a Lean FFI wrapper around `nauty` itself, if you don't care about verification and just want to run the original C code, fast. We don't use this in `HexGraphIso` except for conformance testing.

Unreleased libraries, and all future development, live at [github.com/kim-em/hex-dev](https://github.com/kim-em/hex-dev).
Contributions and pull requests are welcome, but specs must be updated *before* any new features or substantial changes, as separately reviewed PRs.
