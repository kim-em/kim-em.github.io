kim@lean — blog
===============

My blog, at [kim-em.github.io/blog](https://kim-em.github.io/blog). Built with
[Verso](https://verso.lean-lang.org): written in Lean, checked by Lean.

The code examples in the posts are live: each is elaborated by the real tactic
at build time. Because the tactics live on different Lean toolchains from Verso,
their example code sits in standalone Lake projects under `examples/`, each
pinned to its own `lean-toolchain`. Verso pulls in the highlighted code across
the version boundary via [SubVerso](https://github.com/leanprover/subverso).

Building
--------

```
lake build
.lake/build/bin/generate-site --output _site
```

The first `lake build` also drives the `examples/*` subprojects under their own
toolchains (installed automatically by elan), so it needs network access and the
native dependencies those projects require (BLAS/LAPACK for `sos`; a C++
toolchain for `lp`'s SoPlex backend; GMP for `hex`). See
`.github/workflows/deploy.yml`.

`examples/hex` depends on the hex monorepo, and its `HexExamples.Mathlib`
section pulls in Mathlib, so build it through its `build-examples.sh` (which
fetches the Mathlib cache first) *before* the top-level `lake build` extracts
its anchors. Run it once after cloning:

```
(cd examples/hex && ./build-examples.sh)
```

Layout
------

- `Main.lean`, `Site.lean`, `Site/` — the Verso site (theme, front page, posts).
- `Site/Theme.lean` + `Site/theme.css` — the terminal styling.
- `examples/lp`, `examples/sos`, `examples/hex` — standalone example projects,
  one per post. Post sections can pull code from different modules (with
  different imports) of the same project via `anchor NAME (module := ...)`;
  `examples/hex` uses this to keep its Mathlib-free and Mathlib sections apart.
