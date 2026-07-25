import Lake
open Lake DSL

require subverso from git "https://github.com/kim-em/subverso" @ "sos-load-dynlibs"

-- The verified DEFLATE implementation. Pinned to a known SHA: the post quotes
-- the roundtrip capstone, and the anchor below is checked against the real
-- theorem, so the pin is what keeps the quote honest.
require «lean-zip» from git
  "https://github.com/kim-em/lean-zip" @ "463bf48ef3dc51769014c48eec17aadcb81b441b"

package «zip-examples» where

@[default_target]
lean_lib «ZipExamples» where
