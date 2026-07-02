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

kim — Lean & Mathlib. I build tactics and try to get the theorem prover to carry more of the work — most recently a linear-programming solver and a sum-of-squares tactic.

Recent posts:

* [Verified linear programming](/blog/2026-6-14-verified-linear-programming/) — a proof-carrying LP solver and a `lp` tactic, with no dependency on Mathlib.
* [A sum of squares tactic](/blog/2026-5-13-a-sum-of-squares-tactic/) — discharging nonlinear real inequalities via Harrison's sum-of-squares algorithm.

The full archive lives at [/blog](/blog/).
