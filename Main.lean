import VersoBlog
import Site.Theme
import Site.FrontPage
import Site.Feed
import Site.Blog
import Site.Blog.Sos
import Site.Blog.Lp

open Verso Genre Blog Site Syntax

def mySite : Site := site Site.FrontPage /
  static "papers" ← "papers"
  "blog" Site.Blog with
    Site.Blog.Sos
    Site.Blog.Lp

def main (args : List String) : IO UInt32 := do
  let status ← blogMain Site.theme mySite (linkTargets := {}) args
  if status != 0 then return status
  let dest := Site.parseDestination args
  Site.writeFeed
    "https://kim-em.github.io"
    "Kim Morrison"
    "Notes on Lean, tactics, and making the theorem prover do more work."
    dest mySite
  IO.println s!"Generated RSS feed at {dest}/feed.xml"
  return 0
