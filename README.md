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
native dependencies those projects require. `examples/examples.json` lists them,
along with each project's modules and anything else its build needs; it is the
one place CI, the build script and the site build all read.

Those subprojects are slow. `examples/hex` and `examples/tauceti` pull in
Mathlib, and `examples/zip`'s single anchor is lean-zip's DEFLATE roundtrip
capstone, so extracting it compiles the whole verification. Build each one once
up front, rather than waiting for the top-level `lake build` to shell into it:

```
examples/build-highlighted.sh hex
examples/build-highlighted.sh tauceti
examples/build-highlighted.sh zip
```

That fetches the Mathlib cache where there is one, builds the project, and
writes each module's highlighting data to
`<project>/.lake/build/highlighted/<Module>.json`, the same file Verso would
have produced by shelling out.

Since the data is just those JSON files, CI does not need the projects at all.
It builds each one in its own job, caches the JSON on the project's exact
inputs, and unpacks it back into place before building the site. Setting

```
export SITE_PREBUILT_EXAMPLES=1
```

makes the site build read that data instead of invoking Lake, and fail if any
of it is missing or malformed. Leave it unset locally and examples are built on
demand, as before, so an edit to an example is always picked up.

If `pkg-config` can't find zlib on your machine, set `ZLIB_LDFLAGS`:
lean-zip's zlib probe otherwise falls through to `xcrun`, which throws on Linux
and leaves behind a Lake configuration that the *next* invocation rejects
("compiled configuration is invalid"). `examples/build-highlighted.sh` sets it
from the manifest, but a bare `lake build` in `examples/zip` needs it too.

```
export ZLIB_LDFLAGS=-lz
```

Layout
------

- `Main.lean`, `Site.lean`, `Site/` — the Verso site (theme, front page, posts).
- `Site/Theme.lean` + `Site/theme.css` — the terminal styling.
- `Site/LinkTargets.lean` — turns identifiers in highlighted code into links to
  the sources they come from (the example projects live in other repositories).
- `examples/lp`, `examples/sos`, `examples/hex`, `examples/zip`, `examples/tauceti` — standalone example projects,
  one per post. Post sections can pull code from different modules (with
  different imports) of the same project via `anchor NAME (module := ...)`;
  `examples/hex` uses this to keep its Mathlib-free and Mathlib sections apart.
- `examples/examples.json` — what each example project contributes and what its
  build needs, read by `examples/build-highlighted.sh`, `Site/Examples.lean` and
  the Pages workflow.
