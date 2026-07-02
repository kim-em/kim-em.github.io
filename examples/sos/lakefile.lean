import Lake
open Lake DSL

require subverso from git "https://github.com/leanprover/subverso" @ "main"

require sos from git "https://github.com/leanprover/sos" @ "main"

package «sos-examples» where

@[default_target]
lean_lib «SosExamples» where
