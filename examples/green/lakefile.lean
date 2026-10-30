import Lake
open Lake DSL

require subverso from git "https://github.com/leanprover/subverso" @ "892d6dc520270b5fb8c1291dd1b131e8c16255ed"

-- The revision used by the Tau Ceti documentation linked from the post.
require TauCeti from git
  "https://github.com/TauCetiProject/TauCeti" @ "36f24f5d94ccf25e167520cf4c0f1a028c064fb0"

package «green-examples» where

@[default_target]
lean_lib GreenExamples where
