import Lake
open Lake DSL

require subverso from git "https://github.com/kim-em/subverso" @ "sos-load-dynlibs"

-- The hex monorepo (kim-em/hex-dev) provides the full library set: the released
-- Mathlib-free computational libraries, the Berlekamp-Zassenhaus factorizer that
-- the Coppersmith and factorization examples need, and the HexXMathlib
-- correspondence layer (with Mathlib) for sections that want it. Pinned to a
-- known SHA. Each example module imports only the slice its section uses, so a
-- Mathlib-free section never compiles Mathlib.
require Hex from git
  "https://github.com/kim-em/hex-dev" @ "b31ebade9b7e58ac513ef4582bb324e5e09d215c"

package «hex-examples» where

@[default_target]
lean_lib «HexExamples» where
  globs := #[.andSubmodules `HexExamples]
