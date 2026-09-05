-- This module targets the released aggregate described in GraphIso.lean, and
-- reaches the Mathlib correspondence layer through the same `import Hex`.

import Hex
import Mathlib.Data.Fintype.Sum
import Mathlib.Tactic.DeriveFintype
import Mathlib.Tactic.FinCases

-- ANCHOR: latin-isotopy
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
-- ANCHOR_END: latin-isotopy

