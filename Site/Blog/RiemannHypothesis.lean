import VersoBlog
import Site.Categories
open Verso Genre Blog

set_option linter.verso.markup.emph false

#doc (Post) "The Riemann hypothesis: what next for Lean?" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 11, day := 21}
categories := [Site.lean]
%%%

Now that we've finished the "let's check the Lean proof carefully" stage, and there are essentially no remaining doubts as to whether this is a correct proof, let's get organized making sure Lean is as useful as possible during the next stage of humans acquiring understanding of the proof.

This will surely proceed in several directions.

# Understanding the proof

Many people are running AIs to autoinformalize the proof, and will write up accounts of the overall structure and extract intermediate steps with stateable formulations. Here there's essentially no bottleneck: any interested mathematician has access to Fable and Astra, and the autoinformalization step works very well, once you get used to reading the AI text.

But I think Lean can assist here as well: as we start to identify interesting intermediate results, let's get clear formulations of these into Lean, so we all agree. I would love to see contributions adding such statements to [lean-lang.org/eval](https://lean-lang.org/eval); ping me if you make a PR! Similarly the community may want to create missions on prove2me.

# Adopting the repository

To date, the experience of the experts is that it's not actually that effective to try to refactor an "AI dump" Lean proof continuously into something nice, and often it's more practical to just take a good look at it and rewrite. But today is sufficiently exciting that we probably should try this anyway!

It's clear that the Lean proof is stylistically terrible right now. It's running on an old version of Lean and Mathlib. It's probably (although I haven't seen this quantified) redoing things already done in Mathlib (and likely Tau Ceti too). It probably has dead code that isn't used by the main result. It probably has internal duplication. And it almost certainly has extremely inefficient proofs, and places where intermediate lemmas can usefully be extracted.

What logistical questions do we need to sort out to have a community adoption of the repository? For example, Jack McCarthy's fork, perhaps even moved to leanprover-community? It seems the main question is actually providing resources to get builds done, and oleans published. This is somewhat expensive, but not inordinately so. Shall we just do it?

I'm happy to assist setting up CI, providing a mechanism for people to register external runners (we already do this for Tau Ceti), or we can probably just take donations to the Lean FRO or the Mathlib Initiative and run CI from that. Similarly for providing olean caches, I have experience setting this up on Cloudflare, but would love if someone wants to take the lead.

# Bringing the mathematics into our libraries

There's also the question of digestion of the proof not into human understanding, but into the existing community Lean libraries. I think anyone interested should be thinking about how to sprint! Formalization experts can be making beautiful human written and reviewed PRs to Mathlib for any relevant content. At the same time we can be rapidly condensing relevant material into [Tau Ceti](https://github.com/TauCetiProject/TauCeti).

It's not a problem that we want some of this material to later appear in Mathlib in more polished form: the AIs operating Tau Ceti automatically watch every commit to Mathlib, and relentlessly rip out old Tau Ceti versions of things in favour of reusing Mathlib.

I've probably said this too many times by now, but getting started moving this material into Tau Ceti is as simple as opening up your AI and writing:

> /goal Please make PRs to Tau Ceti formalizing anything in the intersection of Tau Ceti's roadmaps and the material necessary for the new proof of RH. Fix any CI problems and respond to reviews.
