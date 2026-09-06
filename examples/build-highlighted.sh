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
root=$PWD

name="${1:-}"
if [[ -z "$name" ]]; then
  echo "usage: examples/build-highlighted.sh <project-name>" >&2
  echo "available: $(jq -r '[.[].name] | join(" ")' examples/examples.json)" >&2
  exit 2
fi

spec=$(jq -c --arg n "$name" 'map(select(.name == $n)) | first // empty' examples/examples.json)
if [[ -z "$spec" ]]; then
  echo "no project named '$name' in examples/examples.json" >&2
  exit 2
fi

dir=$(jq -r '.dir' <<<"$spec")
mathlib_cache=$(jq -r '.mathlibCache' <<<"$spec")
lake_cache=$(jq -r '.lakeCache' <<<"$spec")

# `mapfile < <(jq ...)` would swallow a jq failure and leave an empty list, so
# take the modules through a checked assignment first.
modules_text=$(jq -r '.modules[]' <<<"$spec")
mapfile -t modules <<<"$modules_text"
if [[ ${#modules[@]} -eq 0 || -z "${modules[0]}" ]]; then
  echo "project '$name' lists no modules in examples/examples.json" >&2
  exit 2
fi

# The extractor bakes the suppressed namespaces into its output, so the value
# used here has to match the one the site elaboration expects. Site/Examples.lean
# checks that against the same manifest field.
SUBVERSO_SUPPRESS_NAMESPACES=$(jq -r '.suppressNamespaces' <<<"$spec")
export SUBVERSO_SUPPRESS_NAMESPACES
env_text=$(jq -r '.env[]' <<<"$spec")
while IFS= read -r assignment; do
  [[ -n "$assignment" ]] && export "${assignment?}"
done <<<"$env_text"

# The cache key covers the checked-in lockfile, so generated data is only sound
# if the build leaves it alone. Lake rewrites it when it disagrees with the
# lakefile, and several of these projects `require` a moving branch.
manifest_before=$(sha256sum "$dir/lake-manifest.json")

cd "$dir"

# Hex publishes its compiled libraries to a public R2 bucket, and Lake can
# fetch them instead of compiling ~10k modules. Lake only sweeps a whole
# workspace for Reservoir services, so for a custom endpoint we ask per package.
#
# Every part of this is non-fatal. A package that has not published yet, or a
# pin predating the publishing, just means that library gets compiled as before.
if [[ "$lake_cache" == "true" ]]; then
  cache_config=$(mktemp)
  cat > "$cache_config" <<'TOML'
cache.defaultService = "hex-public"

[[cache.service]]
name = "hex-public"
kind = "s3"
artifactEndpoint = "https://pub-1ad7cebeb89e49d5afe6887b57e7956a.r2.dev/artifacts"
revisionEndpoint = "https://pub-1ad7cebeb89e49d5afe6887b57e7956a.r2.dev/revisions"
TOML
  export LAKE_CONFIG="$cache_config"
  export LAKE_CACHE_DIR="$PWD/.lake/cache"
  export LAKE_ARTIFACT_CACHE=true
  export LAKE_RESTORE_ARTIFACTS=true
  # The pins are the commits the release sync pushed to each mirror's main, so
  # the exact revision should be the one that published. A couple of revisions
  # of slack costs little; the default of 100 would mean 100 misses per
  # unpublished package.
  while IFS=$'\t' read -r pkg url; do
    case "$url" in
      https://github.com/leanprover/hex*) repo=${url#https://github.com/}; repo=${repo%.git} ;;
      *) continue ;;
    esac
    lake cache get --max-revs=5 --service hex-public --package "$pkg" --repo "$repo" \
      || echo "note: no published build outputs for $pkg ($repo); it will be compiled"
  done < <(jq -r '.packages[] | "\(.name)\t\(.url)"' lake-manifest.json)
fi

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

cd "$root"
if [[ "$(sha256sum "$dir/lake-manifest.json")" != "$manifest_before" ]]; then
  echo "Lake rewrote $dir/lake-manifest.json during the build." >&2
  echo "The generated data no longer matches the lockfile it would be cached against." >&2
  echo "Commit the updated lockfile and rebuild." >&2
  exit 1
fi
