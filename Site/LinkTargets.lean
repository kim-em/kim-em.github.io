import VersoBlog

open Verso Code
open Lean (Name)

namespace Site

/-- The `lean-zip` commit that `examples/zip` is pinned to (see its `lakefile.lean`).
Because the pin is a SHA, the line numbers below are stable; if you bump the pin,
re-check them. -/
def leanZipRev : String := "463bf48ef3dc51769014c48eec17aadcb81b441b"

/-- Constants from `lean-zip` that appear in the code on the blog, and where they
are declared. Anything not listed here simply gets no source link. -/
private def leanZipDecls : List (Name × String × Nat) :=
  [(`Zip.Native.Inflate.inflate, "Zip/Native/InflateTreeFree.lean", 633),
   (`Zip.Native.Deflate.deflateRaw, "Zip/Native/DeflateDynamic.lean", 2476),
   (`Zip.Native.Deflate.inflate_deflateRaw, "Zip/Spec/DeflateRoundtripProduction.lean", 28)]

private def leanZipLink (name : Name) : Array CodeLink :=
  match leanZipDecls.find? (·.1 == name) with
  | none => #[]
  | some (_, path, line) =>
    #[{ shortDescription := "src"
        description := s!"{name} in the lean-zip sources"
        href := s!"https://github.com/kim-em/lean-zip/blob/{leanZipRev}/{path}#L{line}" }]

/-- Turn the identifiers in highlighted code into links to the sources they come
from. The example projects live outside this repository, so the code on a page
is the only place a reader meets them; a hover tells you the type, and this
tells you where it is written. -/
def linkTargets : LinkTargets Genre.Blog.TraverseContext where
  const name _ := leanZipLink name
  definition name _ := leanZipLink name
