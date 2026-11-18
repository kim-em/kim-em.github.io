import Site.SheafArticle.Note
import Site.SheafArticle.SourceLinks
import Site.Categories

open Verso Doc Genre Blog
open SheafArticle

private def projection : Except String (Part Post) := do
  let doc := %doc Site.SheafArticle.Note
  let some metadata := doc.metadata | throw "Missing article metadata"
  let ctx : Context := {theoremUrls := sourceLinks, referenceKeys := collectReferences doc}
  let (post, _) ← ((partBlog doc).run 0).run ctx
  return {post with metadata := some {
    date := metadata.date
    authors := metadata.authors
    categories := [Site.lean]
  }}

-- Fail the build if a citation or theorem link cannot be resolved.
#eval show IO Unit from match projection with
  | .ok _ => pure ()
  | .error e => throw (IO.userError e)

def Site.Blog.Sheaves.«the canonical document object name» : Part Post :=
  match projection with
  | .ok post => post
  | .error e => panic! e
