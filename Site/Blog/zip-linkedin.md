Is Lean faster than Rust?

lean-zip compresses the standard Silesia corpus in 5.24s, while miniz_oxide, the standard pure-Rust implementation, takes 5.77.
And lean-zip produces a smaller file!

https://lnkd.in/ei9Kwt5y

lean-zip is a DEFLATE implementation written in Lean, and it's proved correct:

    inflate (deflateRaw data level) = .ok data

That theorem explains how we can make lean-zip so fast. We turned AI agents (Claude and Codex) loose on the optimisation problem,
insisting that the theorem above stays true. The theorem lets us move quickly, and confidently, as the AIs explore aggressive optimisations.

DEFLATE has a level knob that trades compression against speed, so the real comparison is the whole frontier, not a single point. 
At level 6, the usual default, lean-zip sits above and to the left of miniz_oxide: fast and smaller. The story just gets better at higher levels.
The blog post provides the same comparison against zlib, zlib-ng, libdeflate, Go, Zig, JavaScript and OCaml.

#Lean
