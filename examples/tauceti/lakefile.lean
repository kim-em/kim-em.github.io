import Lake
open Lake DSL

require subverso from git "https://github.com/leanprover/subverso" @ "main"

-- Keep the displayed declarations tied to the exact Tau Ceti revision linked
-- from the post. SubVerso elaborates every anchor against this dependency.
require TauCeti from git
  "https://github.com/TauCetiProject/TauCeti" @ "f93736047d51931862e138b4c097099c8d1168a6"

package «tauceti-examples» where

@[default_target]
lean_lib «TauCetiExamples» where
