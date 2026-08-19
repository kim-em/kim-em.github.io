import VersoBlog
import Site.Theme
import Site.FrontPage
import Site.Feed
import Site.LinkTargets
import Site.Blog
import Site.Blog.TauCeti
import Site.Blog.Sos
import Site.Blog.Lp
import Site.Blog.Hex
import Site.Blog.Zip
import Site.Blog.Factor
import Site.Blog.Palomar

open Verso Genre Blog Site Syntax

def mySite : Site := site Site.FrontPage /
  static "papers" ← "papers"
  static "figures" ← "figures"
  "blog" Site.Blog with
    Site.Blog.Palomar
    Site.Blog.TauCeti
    Site.Blog.Factor
    Site.Blog.Zip
    Site.Blog.Hex
    Site.Blog.Lp
    Site.Blog.Sos

def main (args : List String) : IO UInt32 := do
  let status ← blogMain Site.theme mySite (linkTargets := Site.linkTargets) args
  if status != 0 then return status
  let dest := Site.parseDestination args
  Site.writeFeed
    "https://kim-em.github.io"
    "Kim Morrison"
    "Notes on Lean, tactics, and making the theorem prover do more work."
    dest mySite
  IO.println s!"Generated RSS feed at {dest}/feed.xml"
  return 0
