import Site.SheafArticle.Article

open Verso Doc
namespace SheafArticle

structure Context where
  theoremUrls : Std.HashMap String String := {}
  referenceKeys : Array String := #[]

abbrev RenderM := ReaderT Context (Except String)

def escape (s : String) : String :=
  s.foldl (fun out c => out ++ match c with
    | '&' => "\\&" | '%' => "\\%" | '#' => "\\#" | '_' => "\\_"
    | '$' => "\\$" | '{' => "\\{" | '}' => "\\}"
    | '\\' => "\\textbackslash{}" | '^' => "\\textasciicircum{}"
    | '~' => "\\textasciitilde{}" | _ => String.singleton c) ""

def command (name text : String) := "\\" ++ name ++ "{" ++ text ++ "}"
def environment (name text : String) := "\\begin{" ++ name ++ "}\n" ++ text ++ "\n\\end{" ++ name ++ "}\n"
def join (xs : Array String) := String.join xs.toList

def referenceNumber (key : String) : RenderM Nat := do
  let ctx ← read
  match ctx.referenceKeys.toList.idxOf? key with
  | some n => pure (n + 1)
  | none => throw s!"Unknown citation: {key}"

partial def inlineTeX : Inline Article → RenderM String
  | .text s => pure (escape s)
  | .emph xs => do pure (command "emph" (join (← xs.mapM inlineTeX)))
  | .bold xs => do pure (command "textbf" (join (← xs.mapM inlineTeX)))
  | .code s => pure (command "texttt" (escape s))
  | .math .inline s => pure ("$" ++ s ++ "$")
  | .math .display s => pure ("\\[" ++ s ++ "\\]")
  | .linebreak _ => pure " "
  | .link xs url => do
    let body ← xs.mapM inlineTeX
    pure (command "href" (url.replace "#" "\\#" |>.replace "%" "\\%") ++ "{" ++ join body ++ "}")
  | .concat xs => join <$> xs.mapM inlineTeX
  | .other (.isabelle name) _ => do
    let some url := (← read).theoremUrls[name]? | throw s!"Missing theorem: {name}"
    pure (command "href" (url.replace "#" "\\#") ++ "{" ++ command "nolinkurl" name ++ "}")
  | .other (.cite key) xs => do
    let _ ← referenceNumber key
    let locator := join (← xs.mapM inlineTeX)
    pure ("\\cite" ++ (if locator.isEmpty then "" else "[" ++ locator ++ "]") ++ "{" ++ key ++ "}")
  | _ => throw "Unsupported inline element in article renderer"

partial def blockTeX : Block Article → RenderM String
  | .para xs => do pure (join (← xs.mapM inlineTeX) ++ "\n\n")
  | .concat xs => join <$> xs.mapM blockTeX
  | .code s => pure (environment "lstlisting" s.trimAsciiEnd.toString)
  | .blockquote xs => do pure (environment "quote" ("\\small\n" ++ join (← xs.mapM blockTeX)))
  | .other .epigraph xs => do pure (environment "quote" ("\\small\n" ++ join (← xs.mapM blockTeX)))
  | .other .attribution xs => do pure ("\\hfill " ++ join (← xs.mapM blockTeX))
  | .other .abstract xs => do pure (environment "abstract" (join (← xs.mapM blockTeX)))
  | .other (.theorem name) xs => do
    let some url := (← read).theoremUrls[name]? | throw s!"Missing theorem declaration: {name}"
    let caption := command "href" (url.replace "#" "\\#") ++ "{" ++ command "nolinkurl" name ++ "}"
    pure ("\\begin{theorem}[{" ++ (if name.length > 45 then "\\small" else "") ++ caption ++ "}]\n" ++
      join (← xs.mapM blockTeX) ++ "\\end{theorem}\n")
  | .other .bibliography xs => do
    pure ("\\begingroup\\small\n" ++ environment "thebibliography" ("{9}\n" ++ join (← xs.mapM blockTeX)) ++ "\\endgroup\n")
  | .other (.reference key) xs => do
    pure (command "bibitem" key ++ " " ++ (if key == "mathlib" then "\\begingroup\\raggedright\n" else "") ++
      join (← xs.mapM blockTeX) ++ (if key == "mathlib" then "\\par\\endgroup\n" else ""))
  | b => throw s!"Unsupported block element in article renderer: {repr b}"

partial def partTeX (p : Part Article) (level : Nat := 0) : RenderM String := do
  let heading ← if level == 0 then pure "" else do
    let some name := #["section", "subsection", "subsubsection"][level-1]? | throw "Too many heading levels"
    pure (command name (join (← p.title.mapM inlineTeX)) ++ "\n\n")
  return heading ++ join (← p.content.mapM blockTeX) ++ join (← p.subParts.mapM (partTeX · (level+1)))

-- Native AST conversion, not Markdown/HTML round-tripping. The existing Verso
-- blog remains responsible for routing, theme, mathematical rendering, and feeds.
partial def inlineBlog : Inline Article → RenderM (Inline Genre.Blog.Post)
  | .text s => pure (.text s)
  | .code s => pure (.code s)
  | .math m s => pure (.math m s)
  | .linebreak s => pure (.linebreak s)
  | .emph xs => .emph <$> xs.mapM inlineBlog
  | .bold xs => .bold <$> xs.mapM inlineBlog
  | .link xs url => do pure (.link (← xs.mapM inlineBlog) url)
  | .concat xs => .concat <$> xs.mapM inlineBlog
  | .other (.isabelle name) _ => do
    let some url := (← read).theoremUrls[name]? | throw s!"Missing theorem: {name}"
    pure (.link #[.code name] url)
  | .other (.cite key) xs => do
    let n ← referenceNumber key
    let locator ← xs.mapM inlineBlog
    pure (.link (#[.text s!"[{n}"] ++ (if xs.isEmpty then #[] else #[.text ", "] ++ locator) ++ #[.text "]"]) s!"#reference-{key}")
  | _ => throw "Unsupported inline element in blog projection"

partial def blockBlog (b : Block Article) : StateT Nat RenderM (Block Genre.Blog.Post) := do
  match b with
  | .para xs => return .para (← xs.mapM (fun x => liftM (inlineBlog x)))
  | .concat xs => return .concat (← xs.mapM blockBlog)
  | .code s => return .code s
  | .blockquote xs => return .blockquote (← xs.mapM blockBlog)
  | .other .epigraph xs => return .blockquote (← xs.mapM blockBlog)
  | .other .attribution xs => return .concat (← xs.mapM blockBlog)
  | .other .abstract xs => return .concat (← xs.mapM blockBlog)
  | .other (.theorem name) xs =>
    modify (·+1)
    let n ← get
    let some url := (← read).theoremUrls[name]? | throw s!"Missing theorem: {name}"
    return .concat (#[.para #[.bold #[.text s!"Theorem {n}"], .text " (", .link #[.code name] url, .text ")."]] ++ (← xs.mapM blockBlog))
  | .other .bibliography xs =>
    return .concat (#[.para #[.bold #[.text "References"]]] ++ (← xs.mapM blockBlog))
  | .other (.reference key) xs =>
    let n ← referenceNumber key
    let content : Array (Block Genre.Blog.Post) ← xs.mapM blockBlog
    match content[0]? with
    | some (Lean.Doc.Block.para first) => return .other (.htmlWrapper "div" #[("id", s!"reference-{key}")]) (#[.para (#[.text s!"[{n}] "] ++ first)] ++ content.extract 1 content.size)
    | _ => throw "Reference must start with a paragraph"
  | _ => throw "Unsupported block in blog projection"

partial def partBlog (p : Part Article) : StateT Nat RenderM (Part Genre.Blog.Post) := do
  let title ← p.title.mapM (fun x => liftM (inlineBlog x))
  let content ← p.content.mapM blockBlog
  let subParts ← p.subParts.mapM partBlog
  return Part.mk title p.titleString none content subParts


partial def collectReferences (p : Part Article) : Array String :=
  p.content.foldl (fun ks b => ks ++ blockKeys b) #[] ++ p.subParts.flatMap collectReferences
where
  blockKeys : Block Article → Array String
    | .other (.reference key) _ => #[key]
    | .other _ xs | .concat xs | .blockquote xs => xs.flatMap blockKeys
    | _ => #[]

end SheafArticle
