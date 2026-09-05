import VersoBlog

/-!
# Loading pre-generated example highlighting

Verso's external-code support (`{anchor}`, `{anchorName}`, `{anchorTerm}`, ...) reads a module's
highlighting data from `<project>/.lake/build/highlighted/<Module>.json`, and gets there by shelling
out to `elan run --install <toolchain> lake build +<Module>:highlighted` inside the example project.
That is the right thing locally -- edit an example, rebuild the site, see the change -- but in CI it
serialises five independent Lean builds behind the site build.

So CI builds those projects as separate jobs, uploads just the JSON, and unpacks it back into
`<project>/.lake/build/highlighted/` before building the site. The `load_examples` command below
seeds Verso's module cache from those files, which means the shell-out never happens: Verso finds
the module already loaded and reads no further.

The command only does anything when `SITE_PREBUILT_EXAMPLES` is set, so a plain local `lake build`
still builds examples on demand and can never serve stale JSON. When the variable *is* set, every
module listed for the project in `examples/examples.json` must be present and well-formed; anything
missing, unparseable, or extracted under a different suppressed-namespace configuration is an error
rather than a silent fallback to a 30-minute rebuild.
-/

open Lean Elab Command
open SubVerso.Module (Module)
open Verso.Code.External

namespace Site.Examples

/--
Setting this environment variable switches the site build over to pre-generated highlighting data.
-/
def prebuiltEnvVar : String := "SITE_PREBUILT_EXAMPLES"

/-- The manifest shared by the site build, `examples/build-highlighted.sh`, and the Pages workflow. -/
def manifestPath : System.FilePath := "examples" / "examples.json"

/-- The part of an `examples/examples.json` entry that the site build cares about. -/
structure ProjectSpec where
  /-- The project's short name, as `examples/build-highlighted.sh` takes it. -/
  name : String
  /-- The project directory, relative to the repository root, as written in `verso.exampleProject`. -/
  dir : String
  /-- Every module extracted for this project. -/
  modules : Array String
  /-- The value of `SUBVERSO_SUPPRESS_NAMESPACES` the data was extracted with. -/
  suppressNamespaces : String

def ProjectSpec.fromJson? (json : Json) : Except String ProjectSpec := do
  let name ← json.getObjValAs? String "name"
  let dir ← json.getObjValAs? String "dir"
  let modules ← json.getObjValAs? (Array String) "modules"
  let suppressNamespaces ← json.getObjValAs? String "suppressNamespaces"
  return {name, dir, modules, suppressNamespaces}

def readManifest : IO (Array ProjectSpec) := do
  unless ← manifestPath.pathExists do
    throw <| .userError s!"{manifestPath} does not exist (is the site being built from the repository root?)"
  let json ←
    match Json.parse (← IO.FS.readFile manifestPath) with
    | .ok j => pure j
    | .error e => throw <| .userError s!"Invalid JSON in {manifestPath}: {e}"
  match json.getArr? >>= (·.mapM ProjectSpec.fromJson?) with
  | .ok specs => pure specs
  | .error e => throw <| .userError s!"Could not read {manifestPath}: {e}"

/-- Where `lake build +mod:highlighted` writes a module's JSON, and so where we read it from. -/
def highlightedPath (dir : String) (mod : String) : System.FilePath :=
  (mod.splitOn ".").foldl (init := (dir : System.FilePath) / ".lake" / "build" / "highlighted") (· / ·)
    |>.addExtension "json"

/--
Loads the pre-generated highlighting data for an example project into Verso's module cache, so that
elaborating this file's anchors never invokes Lake in that project.

Does nothing unless the `SITE_PREBUILT_EXAMPLES` environment variable is set.
-/
elab "load_examples " projectStx:str : command => do
  if (← IO.getEnv prebuiltEnvVar).isNone then return
  let project := projectStx.getString
  let specs ← readManifest
  let some spec := specs.find? (·.dir == project)
    | throwErrorAt projectStx m!"No entry for project '{project}' in {manifestPath}"

  -- Verso keys its cache on the suppressed namespaces in force here, and the extractor bakes them
  -- into the JSON. A mismatch would mean serving data that was generated for a different
  -- configuration, so refuse rather than guess.
  let suppress ← getSuppress
  let suppressStr := " ".intercalate suppress
  unless suppressStr == spec.suppressNamespaces do
    throwErrorAt projectStx
      m!"Suppressed namespaces for '{project}' are {repr suppressStr} here, but the pre-generated \
         data was extracted with {repr spec.suppressNamespaces}."

  for mod in spec.modules do
    let path := highlightedPath spec.dir mod
    unless ← path.pathExists do
      throwErrorAt projectStx
        m!"{prebuiltEnvVar} is set, but {path} does not exist. Run \
           `examples/build-highlighted.sh {spec.name}`, or unset {prebuiltEnvVar} to build examples on demand."
    let json ←
      match Json.parse (← IO.FS.readFile path) with
      | .ok j => pure j
      | .error e => throwErrorAt projectStx m!"Invalid JSON syntax in {path}: {e}"
    let items ←
      match Module.fromJson? json with
      | .ok m => pure m.items
      | .error e => throwErrorAt projectStx m!"Could not deserialize the module data in {path}: {e}"
    let modName := mod.toName
    modifyEnv fun env =>
      loadedModulesExt.modifyState env fun st =>
        st.alter spec.dir fun mods =>
          let mods := mods.getD {}
          let forMod := (mods.find? modName).getD {}
          some (mods.insert modName (forMod.insert suppress items))
