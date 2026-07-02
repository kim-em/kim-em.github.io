import Lake
open Lake DSL

require subverso from git "https://github.com/leanprover/subverso" @ "main"

require LP from git "https://github.com/leanprover/lp" @ "main"

package «lp-examples» where

@[default_target]
lean_lib «LpExamples» where
