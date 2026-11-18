import Lake
open Lake DSL

require subverso from git "https://github.com/leanprover/subverso" @ "892d6dc520270b5fb8c1291dd1b131e8c16255ed"
require schemes_audit from git "https://github.com/kim-em/sheaf-of-rings" @ "62b875f0c192f883303ba063b61036cf6dacb621" / "lean"

package «sheaf-examples» where

@[default_target]
lean_lib SheafExamples where
