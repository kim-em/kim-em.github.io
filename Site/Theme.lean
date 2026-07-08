import VersoBlog
open Verso Genre Blog

def siteCSS : String := include_str "theme.css"

namespace Site

/-- Two-digit zero padded. -/
private def pad2 (n : Nat) : String := (if n ≤ 9 then "0" else "") ++ toString n

/-- Render a date in the `2026·05·13` terminal style. -/
def fmtDate (d : Date) : String := s!"{d.year}·{pad2 d.month}·{pad2 d.day}"

open Output Html Template Theme in
def theme : Theme := { Theme.default with
  primaryTemplate := do
    let title ← param (α := String) "title"
    let postList :=
      match (← param? "posts") with
      | none => Html.empty
      | some html => {{
          <div class="prompt-line"><span class="prompt">"kim@lean:~$ "</span>"ls posts/ --sort=recent"</div>
          <ul class="posts">{{ html }}</ul>
        }}
    return {{
      <html>
        <head>
          <meta charset="utf-8"/>
          <meta name="viewport" content="width=device-width, initial-scale=1"/>
          <meta name="color-scheme" content="dark"/>
          <title>{{title}}" — kim@lean"</title>
          <meta name="author" content="Kim Morrison"/>
          <meta name="description" content="Notes on Lean, tactics, and making the theorem prover do more work."/>
          <link rel="preconnect" href="https://fonts.googleapis.com"/>
          <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="crossorigin"/>
          <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet" type="text/css"/>
          <link rel="alternate" type="application/rss+xml" title="kim@lean" href="/feed.xml"/>
          {{← builtinHeader}}
          <style>{{siteCSS}}</style>
        </head>
        <body>
          <div class="term">
            <div class="term-bar">
              <span class="term-path"><a href="/">"kim@lean"</a>" : ~/blog"</span>
              <span class="term-tty">
                <a class="nav" href="/">"home"</a>
                <a class="nav" href="/blog/">"posts"</a>
                <a class="nav" href="https://github.com/kim-em">"github"</a>
                <a class="nav" href="/feed.xml">"rss"</a>
              </span>
            </div>
            <main class="term-body">
              {{← param "content"}}
              {{postList}}
            </main>
            <div class="footer">
              <span class="prompt">"kim@lean:~$ "</span>"logout"<span class="cursor"></span>
            </div>
          </div>
        </body>
      </html>
    }}
  pageTemplate := do
    let path ← currentPath
    let title ← param (α := String) "title"
    let showTitle := !path.isEmpty
    return {{
      <article>
        {{ if showTitle then {{ <h1>{{title}}</h1> }} else Html.empty }}
        {{← param "content"}}
      </article>
    }}
  postTemplate := do
    let title ← param (α := String) "title"
    return {{
      <article class="post">
        {{ match (← param? "metadata") with
           | none => Html.empty
           | some (md : Post.PartMetadata) => {{
              <div class="prompt-line">
                <span class="prompt">"kim@lean:~$ "</span>
                "cat posts/" {{ Site.fmtDate md.date }} ".md"
              </div>
           }}
        }}
        <h1>{{title}}</h1>
        {{ match (← param? "metadata") with
           | none => Html.empty
           | some (md : Post.PartMetadata) => {{
              <div class="post-meta">
                <span class="date">{{ Site.fmtDate md.date }}</span>
                {{ md.categories.toArray.map fun c =>
                    {{ " " <span class="tag">"[" {{ Post.Category.name c }} "]"</span> }} }}
              </div>
           }}
        }}
        {{← param "content"}}
      </article>
    }}
  archiveEntryTemplate := do
    let post : BlogPost ← param "post"
    -- Absolute, root-relative link with a trailing slash so it resolves
    -- correctly whether the archive is viewed at /blog/ or /blog/<category>/.
    let target ← if let some p := (← param? "path") then
        pure <| "/" ++ p ++ "/" ++ (← post.postName') ++ "/"
      else pure <| "/" ++ (← post.postName') ++ "/"
    let dateStr := post.contents.metadata.map (fun md => Site.fmtDate md.date) |>.getD ""
    let cats := post.contents.metadata.map (·.categories) |>.getD []
    return #[{{
      <li class="post-row">
        <div class="post-meta-line">
          <span class="date">{{dateStr}}</span>
          {{ cats.toArray.map fun c =>
              {{ " · " <span class="tag">"[" {{ Post.Category.name c }} "]"</span> }} }}
        </div>
        <a class="post-title" href={{target}}>"> " {{post.contents.titleString}}</a>
      </li>
    }}]
}

end Site
