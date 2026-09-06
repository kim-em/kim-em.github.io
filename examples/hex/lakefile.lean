import Lake
open Lake DSL

require subverso from git "https://github.com/kim-em/subverso" @ "sos-load-dynlibs"

-- The released aggregate (leanprover/hex) provides the full library set: the
-- Mathlib-free computational libraries, the Berlekamp-Zassenhaus factorizer that
-- the Coppersmith and factorization examples need, and the HexXMathlib
-- correspondence layer (with Mathlib) for sections that want it. This is the
-- same `require` the posts tell a reader to write. Pinned to a known SHA. Each
-- example module imports only the slice its section uses, so a Mathlib-free
-- section never compiles Mathlib.
require Hex from git
  "https://github.com/leanprover/hex" @ "134b04c059d0"

package «hex-examples» where

@[default_target]
lean_lib «HexExamples» where
  globs := #[.andSubmodules `HexExamples]
