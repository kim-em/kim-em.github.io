import Lake
open Lake DSL

require subverso from git "https://github.com/kim-em/subverso" @ "sos-load-dynlibs"

-- The released aggregate, at the version the post tells readers to install.
-- Pinning a tag rather than `main` keeps the post reproducible: the code here
-- is exactly what a reader who follows the instructions will get.
require hex from git
  "https://github.com/leanprover/hex.git" @ "v0.4.0"

package «hex-number-field-examples» where

@[default_target]
lean_lib «HexNumberFieldExamples» where
  globs := #[.andSubmodules `HexNumberFieldExamples]
