import VersoBlog
open Verso Genre Blog

#doc (Page) "Kim Morrison" =>

%%%
showInNav := false
htmlId := some "frontpage"
%%%

:::htmlDiv (class := "prompt-line")
{htmlSpan (class := "prompt")}[kim@lean:~\$ ]whoami
:::

kim morrison — programming mathematics & mathematics for programming.

I work at the [Lean Focused Research Organization](https://lean-lang.org/fro).
I am a maintainer of the [Mathlib formal mathematics library](https://leanprover-community.github.io/), which aims to curate and perfect mathematical knowledge as a coherent formal library.
Mathlib is a large open-source community project, which serves as the foundation for all mathematical formalization in the Lean ecosystem.
I helped found the [Mathlib Initiative](https://mathlib-initiative.org/), and am a member of the strategic advisor board there.
I'm the founder and maintainer of [Tau Ceti](https://github.com/TauCetiProject/TauCeti), a library of reusable formalized mathematics which uses AI implementors and reviewers to follow human curated roadmaps.

I build automation for the Lean language, making it easier for humans and AIs to write difficult proofs.
I also have time for experiments building Lean libraries and tactics using AI,
to demonstrate what is possible when we combine the power of generative AI,
the Lean language for automation, and the Lean kernel for reliable verification.

Recent posts:

* [Verified linear programming](/blog/2026-6-14-verified-linear-programming/) — a proof-carrying LP solver and a `lp` tactic, with no dependency on Mathlib.
* [A sum of squares tactic](/blog/2026-5-13-a-sum-of-squares-tactic/) — discharging nonlinear real inequalities via Harrison's sum-of-squares algorithm.

The full archive lives at [/blog](/blog/).

# Papers about Lean

* [grind: An SMT-Inspired Tactic for Lean 4](/papers/grind/) — a Verso rendering of the `grind` system description, published at IJCAR 2026.
* [The Lean mathematical library](https://arxiv.org/abs/1910.09336) — the mathlib paper (CPP 2020).
* [Schemes in Lean](https://arxiv.org/abs/2101.02602) — formalizing schemes three ways (Experimental Mathematics, 2022).
