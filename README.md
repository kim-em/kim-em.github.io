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
toolchain for `lp`'s SoPlex backend). See `.github/workflows/deploy.yml`.

Layout
------

- `Main.lean`, `Site.lean`, `Site/` — the Verso site (theme, front page, posts).
- `Site/Theme.lean` + `Site/theme.css` — the terminal styling.
- `examples/lp`, `examples/sos` — standalone example projects, one per post.
