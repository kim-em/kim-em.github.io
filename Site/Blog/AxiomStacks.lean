import VersoBlog
import Site.Categories
open Verso Genre Blog

set_option linter.verso.markup.emph false

#doc (Post) "Axiom's formalization of the Stacks project" =>

%%%
authors := ["Kim Morrison"]
date := {year := 2026, month := 11, day := 5}
categories := [Site.lean]
%%%

Axiom Math [announced today](https://axiommath.ai/research/the-stacks-project-formalized/) that they've formalized the entire [Stacks project](https://stacks.math.columbia.edu/) in Lean.

This is really awesome. The Stacks project is a beautiful contribution to modern mathematics, that a generation of algebraic geometers have used for learning and for reference. Having the whole thing formalized (but see below!) in Lean will unlock lots of new work, and help accelerate research.

I want to talk about ways in which we can do even better. Axiom's announcement of the project says "it is the largest integrated, reusable library of formalized mathematics ever built". If we're going to make claims about AI formalizations being "libraries", and moreover "reusable", we better make sure they are really good enough.

Unfortunately, I think that Axiom's release actually falls short in some significant ways, and I'm going to point these out here. I hope this is construed constructively: I want to encourage everyone doing formalization work to do it really well, in ways that benefit the community and build valuable reusable artefacts. I hope that by explaining the problems I see, we can all learn to do better. I appreciate that many of the problems are readily fixable --- but key to any claim that you're building a reusable library is demonstrating that you actually fix problems like these, and the fewer of them you have at launch day the more confidence downstream users can have in building on it.

* There are **many** places where the release reproves something that is already done in Mathlib. Again, here's [a non-exhaustive list](https://gist.github.com/kim-em/e079cc9aae4ab78b88941e13c223d6cd). I think it's really important to put in the effort to avoid these duplications. It's not expensive for the AIs to generate these unnecessary steps, so a naive view says they don't really matter. But they do: duplication makes auditing and reuse more expensive. A commitment to doing this properly is valuable.
* There are places where the actual Stacks statement is not what has been proved; although to Axiom's credit I want to emphasize that I haven't found any that are not explicitly flagged in comments in the source. (Their [website](https://stacks.axiommath.ai/library) marks some results as partial or conditional, but these labels do not cover all the gaps acknowledged in the source.) I've posted [a non-exhaustive list](https://gist.github.com/kim-em/a6f3cdf0dbd8afcebe2bdc7a07798315). These sorts of problems were not hard to find, so I suspect there are still many more.

  For a substantive example, [Stacks constructs a particular Hom-stack and proves that it is not algebraic](https://stacks.math.columbia.edu/tag/0AF8).
  This is a counterexample both to Theorem 1.1 of [Aoki's paper *Hom stacks*](https://doi.org/10.1007/s00229-005-0602-1) and to Case I of [its erratum](https://link.springer.com/content/pdf/10.1007/s00229-006-0029-3.pdf).

  In the Axiom development, that Hom-stack is not even defined. The [accompanying cohomological argument](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksFrontier/Examples/Stacks/NonAlgebraicHomStack.lean#L342) assumes the three geometric facts on which the counterexample depends, including the existence of a non-torsion torsor and the deformation-theoretic lifting result. The [theorem tagged with the final non-algebraicity statement](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksFrontier/Examples/Stacks/NonAlgebraicHomStack.lean#L382) instead proves a general implication, assuming its two main inputs. These omissions are acknowledged in the source, but in any case it's a significant gap.

* The library uses the Lean toolchain `v4.34.0-rc2`; we're currently on `v4.36.0-rc2`. For a library to be reusable, it needs to use recent versions of Lean and Mathlib. Obviously there's no need to be using the latest release candidate, but `v4.34.0` and `v4.35.0` have both been out for a while now, with matching Mathlib releases. To establish credibility that you'll keep things up to date, you have to do it on day one!
* The `lake build` has many warnings that could easily be cleaned up. Having a "clean build" is really useful for potential downstream users who want to build on top of your library. (Mathlib and [Tau Ceti](https://taucetiproject.org/), for example, both require clean builds in their CI.)
* We recently published a (very naive!) [quality audit using AI judges](https://taucetiproject.org/blog/2026-10-28-simple-quality-indicators-for-lean-libraries/) against Mathlib, Tau Ceti, [Formal Frontier](https://github.com/FormalFrontier), [Lean Pool](https://github.com/Vilin97/lean-pool), [Anthropic's FLT proof](https://github.com/anthropics/fermats-last-theorem), [the OpenAI dump](https://github.com/openai/math), and [AxiomMath's CFSG repo](https://github.com/AxiomMath/CFSG). It found moderately strong evidence that Tau Ceti and Formal Frontier cluster pretty close to Mathlib, with a big gap to the other releases. I've re-run this audit on the Stacks library. It has a slightly higher observed flag rate for Mathlib duplicates than Tau Ceti and Formal Frontier (6.4%, vs 5.0% and 4.6%), is significantly behind on unnecessary theorem hypotheses (10.3% flagged, vs 3.1–6.8% for Mathlib, Tau Ceti, and Formal Frontier), and further behind Mathlib and Tau Ceti on "repeated proof machinery" (31.7% vs 16.1–17.2%).

Finally, I don't intend this next point as criticism, because the Stacks library does not depend on Tau Ceti, and this is a perfectly fine decision to make. However *if* they wanted to do this (I think it would be a good idea!) then there would be many opportunities for re-use, as there are many places where Tau Ceti and Stacks already have overlapping material. I've posted [a non-exhaustive list](https://gist.github.com/kim-em/2bb29a393210d05fd4ed39c7eb72e021), with some AI-written judgements about the relative value of the two versions (each library has examples that are better!).

I hope that some of the problems outlined here get fixed (and some serious auditing is done to make sure that agents can't easily find further mis-formalizations or failures to use Mathlib). I'd be very happy to open some pull requests to the library fixing these things, and I think generally this would be a good thing for the community to try. A key part of building a reusable library is being open to community feedback! Both Axiom, and the community, should try to work collaboratively. But most of all I hope that the points above help guide future large formalization releases, so we all end up with lovely reusable libraries that we can build on, and go do some amazing new mathematics!
