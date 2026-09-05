#!/usr/bin/env bash
#
# Build one example project's SubVerso highlighting data.
#
# Everything the build needs -- which modules to extract, whether the project
# has a Mathlib cache to fetch, which environment variables it wants -- comes
# from examples/examples.json, so CI and a local run stay in step. The output
# lands in <dir>/.lake/build/highlighted/, exactly where Verso's external-code
# support looks for it.
#
# Usage: examples/build-highlighted.sh <project-name>
set -euo pipefail

cd "$(dirname "$0")/.."

name="${1:-}"
if [[ -z "$name" ]]; then
  echo "usage: examples/build-highlighted.sh <project-name>" >&2
  echo "available: $(jq -r '[.[].name] | join(" ")' examples/examples.json)" >&2
  exit 2
fi

spec=$(jq -ce --arg n "$name" 'map(select(.name == $n)) | first // empty' examples/examples.json)
if [[ -z "$spec" ]]; then
  echo "no project named '$name' in examples/examples.json" >&2
  exit 2
fi

dir=$(jq -r '.dir' <<<"$spec")
mathlib_cache=$(jq -r '.mathlibCache' <<<"$spec")
mapfile -t modules < <(jq -r '.modules[]' <<<"$spec")

# The extractor bakes the suppressed namespaces into its output, so the value
# used here has to match the one the site elaboration expects. Site/Examples.lean
# checks that against the same manifest field.
export SUBVERSO_SUPPRESS_NAMESPACES="$(jq -r '.suppressNamespaces' <<<"$spec")"
while IFS= read -r assignment; do
  [[ -n "$assignment" ]] && export "${assignment?}"
done < <(jq -r '.env[]' <<<"$spec")

cd "$dir"

if [[ "$mathlib_cache" == "true" ]]; then
  lake exe cache get
fi

# Build the library first. The `highlighted` facet only depends on the module's
# olean, but the extractor elaborates the module for real, so anything the
# examples need at elaboration time (native shared libraries, in particular)
# has to exist -- `by sos` calls CSDP through an FFI while being highlighted.
lake build
lake build subverso-extract-mod

for mod in "${modules[@]}"; do
  lake build "+${mod}:highlighted"
done
