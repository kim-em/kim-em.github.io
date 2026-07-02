import Lake
open Lake DSL

-- A fork of SubVerso that loads the module's native dynlibs/plugins in the
-- highlight extractor, so `by sos` (which calls CSDP via FFI during
-- elaboration) can be extracted live. See kim-em/subverso#sos-load-dynlibs.
require subverso from git "https://github.com/kim-em/subverso" @ "sos-load-dynlibs"

require sos from git "https://github.com/leanprover/sos" @ "main"

package «sos-examples» where

@[default_target]
lean_lib «SosExamples» where
