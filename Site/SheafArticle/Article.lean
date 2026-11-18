import Verso
import VersoBlog

open Verso Doc Elab ArgParse
open Lean (quote)

namespace SheafArticle

instance : FromArgs String DocElabM where
  fromArgs := .positional `name .string

structure Metadata where
  authors : List String
  date : Verso.Genre.Blog.Date
  deriving TypeName

inductive BlockKind where
  | abstract
  | epigraph
  | attribution
  | theorem (name : String)
  | bibliography
  | reference (key : String)
  deriving Repr

inductive InlineKind where
  | cite (key : String)
  | isabelle (name : String)
  deriving Repr

def Article : Genre where
  PartMetadata := Metadata
  Block := BlockKind
  Inline := InlineKind
  TraverseContext := Unit
  TraverseState := Unit

instance : Repr Article.Block := inferInstanceAs (Repr BlockKind)
instance : Repr Article.Inline := inferInstanceAs (Repr InlineKind)

instance : TypeName Article.PartMetadata := inferInstanceAs (TypeName Metadata)

def abstract (content : Array (Block Article)) : Block Article := .other .abstract content
def «theorem» (name : String) (content : Array (Block Article)) : Block Article := .other (.theorem name) content
def bibliography (content : Array (Block Article)) : Block Article := .other .bibliography content
def reference (key : String) (content : Array (Block Article)) : Block Article := .other (.reference key) content
def cite (key : String) (content : Array (Inline Article)) : Inline Article := .other (.cite key) content

def epigraph (content : Array (Block Article)) : Block Article := .other .epigraph content
def attribution (content : Array (Block Article)) : Block Article := .other .attribution content

@[directive epigraph]
meta def epigraphDirective : DirectiveExpanderOf Unit := fun () content => do
  let content ← content.mapM elabBlock
  ``(Block.other (genre := Article) BlockKind.epigraph #[$content,*])

@[directive attribution]
meta def attributionDirective : DirectiveExpanderOf Unit := fun () content => do
  let content ← content.mapM elabBlock
  ``(Block.other (genre := Article) BlockKind.attribution #[$content,*])

@[directive abstract]
meta def abstractDirective : DirectiveExpanderOf Unit := fun () content => do
  let content ← content.mapM elabBlock
  ``(Block.other (genre := Article) BlockKind.abstract #[$content,*])

@[directive «theorem»]
meta def theoremDirective : DirectiveExpanderOf String := fun name content => do
  let content ← content.mapM elabBlock
  ``(Block.other (genre := Article) (BlockKind.theorem $(quote name)) #[$content,*])

@[directive bibliography]
meta def bibliographyDirective : DirectiveExpanderOf Unit := fun () content => do
  let content ← content.mapM elabBlock
  ``(Block.other (genre := Article) BlockKind.bibliography #[$content,*])

@[directive reference]
meta def referenceDirective : DirectiveExpanderOf String := fun key content => do
  let content ← content.mapM elabBlock
  ``(Block.other (genre := Article) (BlockKind.reference $(quote key)) #[$content,*])

@[role cite]
meta def citeRole : RoleExpanderOf String := fun key content => do
  let content ← content.mapM elabInline
  ``(Inline.other (genre := Article) (InlineKind.cite $(quote key)) #[$content,*])

def isabelle (name : String) (content : Array (Inline Article)) : Inline Article := .other (.isabelle name) content

@[role isabelle]
meta def isabelleRole : RoleExpanderOf String := fun name _ =>
  ``(Inline.other (genre := Article) (InlineKind.isabelle $(quote name)) #[])

end SheafArticle
