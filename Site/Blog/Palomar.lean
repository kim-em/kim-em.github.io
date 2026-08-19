import VersoBlog
import Site.Categories
open Verso Genre Blog

set_option linter.verso.markup.emph false

#doc (Post) "Announcing the Palomar Registry" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 8, day := 19}
categories := [Site.lean]
%%%

Today we're launching the [Palomar Registry](https://palomar-registry.org/), an index of formalized mathematics repositories with a valid [#comparator](https://github.com/leanprover/comparator) setup and [#formalization.yaml](https://github.com/mathlib-initiative/formalization.yaml) metadata. Limited automatic review rejects submissions with obvious discrepancies between the informal and formal statements, and errors in the metadata.

This is jointly incubated by the [Lean FRO](https://lean-lang.org/fro/) and [ICARM](https://icarm.io/), and the initial advisory board consists of [Jeremy Avigad](https://www.andrew.cmu.edu/user/avigad/), [Matthew Ballard](https://www.matthewrobertballard.com/), [Jaume de Dios](https://jaume.dedios.cat/), [Nestor Guillen](https://www.ndguillen.com/), [Bryna Kra](https://en.wikipedia.org/wiki/Bryna_Kra), [Kim Morrison](https://tqft.net/), [Terence Tao](https://www.math.ucla.edu/~tao/), [Ravi Vakil](https://math.stanford.edu/~vakil/) and [Akshay Venkatesh](https://www.math.ias.edu/~akshay/).

Please read our [Palomar Statement](https://palomar-registry.org/statement), explaining the motivation behind this registry, and our [About](https://palomar-registry.org/about) page to understand the mechanism. Terry has also written about Palomar on his [blog](https://terrytao.wordpress.com/2026/08/18/palomar-a-registry-of-lean-verified-mathematics/).

Palomar doesn't have any opinions about use of AI: there are already entries ranging from no-AI-at-all to autonomously formalized. What we do expect is that this is explained clearly in your [#formalization.yaml](https://github.com/mathlib-initiative/formalization.yaml) file.

If you have a repository with at least one of a [#comparator](https://github.com/leanprover/comparator) setup or a [#formalization.yaml](https://github.com/mathlib-initiative/formalization.yaml) metadata, we'd encourage you to fulfill the requirements and submit. You can find detailed instructions at [https://palomar-registry.org/how-to-submit](https://palomar-registry.org/how-to-submit), or just get started at [https://submit.palomar-registry.org/](https://submit.palomar-registry.org/) (it's a fairly interactive process that should help you identify problems with your submission: bug reports are very welcome). (There's also an [llms.txt](https://submit.palomar-registry.org/llms.txt) if you'd like to have an agent help you submit.)

There is a new public Zulip channel [#Palomar](https://leanprover.zulipchat.com/#narrow/channel/621638-Palomar) for discussion. You can link to individual entries from Zulip using the identifiers: [PALOMAR-2026-08-13-000001](https://palomar-registry.org/entry.html?id=PALOMAR-2026-08-13-000001), and link to the main page using [#palomar](https://palomar-registry.org/).

(Oh, and please reply to all future announcements of maths results on social media with "But is it on Palomar?" :-)
