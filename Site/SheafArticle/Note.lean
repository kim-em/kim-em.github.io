import Site.SheafArticle.Article

open SheafArticle

set_option linter.verso.markup.emph false

#doc (Article) "An error in the Isabelle/HOL formalization of sheaves" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 11, day := 16}
%%%

:::abstract
The AFP entry _Grothendieck's Schemes in Algebraic Geometry_ states the sheaf axioms only for covers
indexed by sets of real numbers. As a consequence, the predicate `sheaf_of_rings` accepts a presheaf that fails gluing. Hartshorne's
Proposition II.1.1, that a morphism of sheaves inducing isomorphisms on all stalks is an
isomorphism, is false for these sheaves. The predicate `scheme` accepts an object whose structure
presheaf fails gluing, and another whose ring of global sections is not commutative. The repair is small.
This note was written by AIs (Claude and Codex) supervised by Kim Morrison.
:::

# The definition

A presheaf of rings $`\mathcal F` on a space $`X` is a sheaf if, for every open cover
$`U=\bigcup_{i\in I}U_i`, a section of $`\mathcal F(U)` vanishing on every $`U_i` is zero, and
every family $`s_i\in\mathcal F(U_i)` agreeing on overlaps is the restriction of some section of
$`\mathcal F(U)`. This is Hartshorne's definition {cite "hartshorne"}[II.1], the text the
formalization follows {cite "paper"}[]; the index set $`I` is arbitrary.

In the entry by Bordg, Paulson and Li {cite "afp"}[], covers are introduced by the locale
`cover_of_subset` in `Topological_Space.thy` (excerpt, including the source comment):

```
fixes X :: "'a set" and U :: "'a set"
  and index :: "real set" and cover :: "real => 'a set"
(* We use real instead of index::"'b set" otherwise we get some
   troubles with locale sheaf_of_rings in Comm_Ring_Theory.thy *)
```

The locality and gluing axioms of `sheaf_of_rings` quantify over these covers, so they are tested
only on covers with at most $`\mathfrak c=|\mathbb R|` members. The locales `ringed_space`,
`locally_ringed_space`, `affine_scheme` and `scheme` are built on `sheaf_of_rings`. The paper
displays the cover locale, with `real`, without comment, and describes its formalization of sheaves
of rings as “concise (10 lines), tidy and almost transparent with respect to the pen-and-paper
definition” {cite "paper"}[]. The two locales are unchanged from the first AFP revision (9 April 2021) to the current development version {cite "afp"}[].

We compared the entry's other definitions with Hartshorne's and found no further discrepancy of
this kind.

# Four consequences

The Isabelle theorems named below establish concrete instances of these constructions using the
entry's own predicates, with no changes to its definitions. The algebraic descriptions identify the
concrete rings used in the formalization up to isomorphism. Throughout, spaces are discrete, and a
set is _small_ if it has at most $`\mathfrak c` elements. A union of at most $`\mathfrak c` small
sets is small; this is why the weak axioms hold in each example.
:::theorem "counterexample_to_arbitrary_gluing"
Let $`A=\mathbb Z^{\mathbb R}`, let $`X=A` with the discrete topology, and let $`\mathcal F(U)`
be the ring of functions
$`U\to A` with small image. Then $`\mathcal F` satisfies `sheaf_of_rings`, but the sections
$`s_a=a` on the singletons $`\{a\}` have no gluing.
:::

A gluing would be the identity function of $`A`, and $`|A|>\mathfrak c` by Cantor's diagonal argument.
:::theorem "stalkwise_iso_not_iso"
With $`X` and $`\mathcal F` as above, let $`\mathcal G(U)` be the ring of all functions $`U\to A`.
Both satisfy `sheaf_of_rings`, the inclusion $`\mathcal F\to\mathcal G` is a
`morphism_sheaves_of_rings`, and the induced map on the stalk at every point is a ring isomorphism.
It is not an `iso_sheaves_of_rings`.
:::

Thus the analogue of Proposition II.1.1 of Hartshorne {cite "hartshorne"}[], the first proposition of his section on
sheaves, is false for the AFP predicate. A second checked statement uses the entry's own
`morphism_ringed_spaces`, `homeomorphism` and `induced_morphism` on stalks. The usual proof of the
proposition glues over a cover indexed by the points of $`U`, which need not admit a subcover of at
most $`\mathfrak c` members. In this example the singleton cover has no such subcover.
:::theorem "afp_scheme_without_gluing"
Let $`R=\mathbb R\oplus V` with $`V=\mathbb R^{\mathbb R}` and $`V^2=0`, a local ring whose only
prime ideal is $`V`. Let $`X=R` and let $`\mathcal O(U)` be the ring of functions $`U\to R` with
small image. Then $`(X,\mathcal O)` satisfies `scheme`, but the sections $`s_a=a` on the singletons
have no gluing.
:::

Every point is open with $`\mathcal O(\{x\})\cong R`, so every point has a neighbourhood isomorphic
to $`\operatorname{Spec}R`, and the stalks are local. In ordinary mathematics the scheme with these
charts is $`\coprod_{x\in X}\operatorname{Spec}R`, whose global sections are _all_ functions
$`X\to R`.
:::theorem "afp_scheme_with_noncommutative_global_sections"
Let $`T=\mathbb R\langle x,y\rangle/(x^2,y^2,yx)`, with $`\pi\colon T\to\mathbb R` killing $`x` and
$`y`. Let $`X` be a set with more than $`\mathfrak c` elements, and let $`\mathcal O(U)` be the
ring of functions $`g\colon U\to T` modulo the relation: $`g\sim h` if $`\pi g=\pi h` and $`g`,
$`h` differ on a small set. Then $`(X,\mathcal O)` satisfies `scheme`, and there are
$`u,v\in\mathcal O(X)` with $`uv\neq vu`.
:::

Here $`\mathcal O(\{p\})\cong\mathbb R`, so every point is a copy of
$`\operatorname{Spec}\mathbb R`. The constants $`x` and $`y` do not commute in $`\mathcal O(X)`:
their commutator is the constant $`xy`, which vanishes in every stalk and is not zero. For
completeness, the quotient relation is congruence modulo the ideal of small-support functions valued
in $`\ker\pi`. For a cover of size at most $`\mathfrak c`, choose representatives and at each
point use a representative from one covering member. Its disagreement with any other representative
is contained in a union of at most $`\mathfrak c` small overlap-error sets. This proves gluing in
the quotient; the same union bound proves locality. The entry's presheaves take values in rings that
need not be commutative; with the usual sheaf condition, commutativity of every $`\mathcal O(U)`
follows from commutativity on an affine cover by the locality axiom. With real-indexed covers it
does not.

The supporting result for Theorem 3 is
{isabelle "open_points_scheme"}[]:
a `sheaf_of_rings` on a discrete space satisfies `scheme` if its rings over singletons are
isomorphic to commutative local rings with a single prime ideal (with chart rings carried in a
common ambient type). Theorem 4 uses its field-valued special case,
{isabelle "open_points_scheme_field"}[]. Beyond the weak sheaf axioms, nothing is assumed about the rings over larger open sets.

# What Mathlib says

Mathlib's `TopCat.Presheaf.IsSheaf` quantifies over all covers. In Lean we define the presheaf of
Theorem 1 as a presheaf of commutative rings, prove unique gluing for every index type with at most
$`\mathfrak c` elements, and prove

```
theorem largeRing_not_isSheaf_commRing :
    ¬ (boundedRing (discreteSpace (ℝ → ℤ)) (ℝ → ℤ)).IsSheaf
```

Index sets and sections lie in `Type 0`, so no universe issue is
involved. Proposition II.1.1 is the Mathlib theorem `TopCat.Presheaf.isIso_of_stalkFunctor_map_iso`, and Mathlib's schemes carry a sheaf of commutative rings by definition {cite "mathlib"}[].

# Repair and validation

The repair is not hard. Indexing covers by sets of open sets, as the same theory file already does
for the union axiom of a topology, gives the usual condition, and the entry rebuilds after changing
about a hundred lines ([the repository](https://github.com/kim-em/sheaf-of-rings) contains the patch).

Simply replacing `real` by a type variable does not suffice: the locale predicate then acquires a
fixed index type as a parameter, rather than quantifying over index types in its sheaf axiom. In
Lean, one can quantify over index types within the condition itself. Our repair shows that dependent
types are not necessary to express the correct definition in Isabelle/HOL.

The counterexamples give a precise test that was missing: neither the stalkwise isomorphism
criterion nor the assertion that sections are determined by their germs can hold in this generality.
Theorem 2 refutes the former; the nonzero commutator in Theorem 4 refutes the latter. These are basic
consequences of the intended definition, and proving them would have required addressing the
restriction.

::::bibliography
:::reference "hartshorne"
R. Hartshorne. _Algebraic Geometry_. Springer, 1977. Section II.1.
:::
:::reference "afp"
A. Bordg, L. C. Paulson, W. Li.
[_Grothendieck's Schemes in Algebraic Geometry_](https://isa-afp.org/entries/Grothendieck_Schemes.html), Archive of Formal Proofs, 29 March 2021. Checked source: AFP release `afp-2026-11-15` for
Isabelle2026 ([mirror revision
aaa511aa2095](https://github.com/isabelle-prover/mirror-afp-2026/tree/aaa511aa20958abfed536c271dfd2fe115515d6c/thys/Grothendieck_Schemes)),
`Topological_Space.thy`, lines 77--82, and `Comm_Ring.thy`, lines 660--666. The same text is in
[development revision bda1576f4422](https://github.com/isabelle-prover/mirror-afp-devel/tree/bda1576f4422c042210bb7cc8406ef1335dcdfb5/thys/Grothendieck_Schemes)
of 14 November 2026.
:::
:::reference "paper"
A. Bordg, L. Paulson, W. Li. _Simple Type Theory is not too Simple: Grothendieck's Schemes Without
Dependent Types_. Experimental Mathematics 31(2), 364--382 (2022).
[doi:10.1080/10586458.2022.2062073](https://doi.org/10.1080/10586458.2022.2062073);
[arXiv:2104.09366](https://arxiv.org/abs/2104.09366).
:::
:::reference "mathlib"
Mathlib contributors.
[`Topology/Sheaves`](https://github.com/leanprover-community/mathlib4/tree/56a005855ea17e0b0958f73ec801ae140b0a1679/Mathlib/Topology/Sheaves), release `v4.35.0`: `Sheaf.lean`, `SheafCondition/UniqueGluing.lean`, `Stalks.lean`; and
`AlgebraicGeometry/Scheme.lean`.
:::
::::

Document prepared in [Verso](https://verso.lean-lang.org/).
