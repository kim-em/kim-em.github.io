import Lake
open Lake DSL

require subverso from git "https://github.com/leanprover/subverso" @ "main"

-- Use the pure-Lean backend (a two-phase rational simplex, no native
-- dependencies) so that `by lp` runs entirely in Lean. This lets Verso's
-- SubVerso extractor elaborate the examples without loading a solver FFI.
require LPTactic from git "https://github.com/leanprover/lp-tactic" @ "main"
require LPBackendPure from git "https://github.com/leanprover/lp-backend-pure" @ "main"

package «lp-examples» where

@[default_target]
lean_lib «LpExamples» where
