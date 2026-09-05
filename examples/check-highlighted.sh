#!/usr/bin/env bash
#
# Check that the pre-generated highlighting data for the named example projects
# is present and parses. With no arguments it checks every project, and also
# checks that the posts and the manifest agree about which projects and modules
# exist.
#
# The site build fails on missing or malformed data too, but by then a CI run
# has already spent minutes compiling Verso. Running this first turns those
# failures into an immediate, obvious one. The manifest/post cross-check catches
# the one case the site build cannot: a project or module a post uses but the
# manifest does not know about, which would send Verso back to building it.
#
# Usage: examples/check-highlighted.sh [project-name ...]
set -uo pipefail

cd "$(dirname "$0")/.."

manifest=examples/examples.json

names=("$@")
check_posts=false
if [[ ${#names[@]} -eq 0 ]]; then
  check_posts=true
  names_text=$(jq -r '.[].name' "$manifest") || exit 1
  mapfile -t names <<<"$names_text"
fi

status=0

for name in "${names[@]}"; do
  spec=$(jq -c --arg n "$name" 'map(select(.name == $n)) | first // empty' "$manifest") || { status=1; continue; }
  if [[ -z "$spec" ]]; then
    echo "no project named '$name' in $manifest" >&2
    status=1
    continue
  fi
  dir=$(jq -r '.dir' <<<"$spec")
  modules_text=$(jq -r '.modules[]' <<<"$spec") || { status=1; continue; }
  if [[ -z "$modules_text" ]]; then
    echo "project '$name' lists no modules in $manifest" >&2
    status=1
    continue
  fi
  while IFS= read -r mod; do
    path="$dir/.lake/build/highlighted/${mod//.//}.json"
    if [[ ! -f "$path" ]]; then
      echo "missing highlighting data for $mod: $path" >&2
      status=1
    elif ! jq -e 'has("items") and has("data")' "$path" >/dev/null 2>&1; then
      echo "malformed highlighting data for $mod: $path" >&2
      status=1
    else
      echo "ok: $path"
    fi
  done <<<"$modules_text"
done

if [[ "$check_posts" == true ]]; then
  while IFS= read -r file; do
    projects=$(sed -n 's/^set_option verso\.exampleProject "\([^"]*\)".*/\1/p' "$file" | sort -u)
    [[ -n "$projects" ]] || continue
    if [[ $(wc -l <<<"$projects") -ne 1 ]]; then
      echo "$file sets verso.exampleProject more than once; this check assumes one project per file" >&2
      status=1
      continue
    fi
    if ! jq -e --arg d "$projects" 'any(.dir == $d)' "$manifest" >/dev/null; then
      echo "$file uses project '$projects', which has no entry in $manifest" >&2
      status=1
      continue
    fi
    # Without the `load_examples` call the site build would silently shell out
    # to Lake in that project instead of reading the generated data.
    if ! sed -n 's/^load_examples "\([^"]*\)".*/\1/p' "$file" | grep -qxF "$projects"; then
      echo "$file uses project '$projects' but never calls load_examples \"$projects\"" >&2
      status=1
      continue
    fi
    # Every module the post pulls code from, whether by the file-level default
    # or by `(module := ...)` on an individual block, has to be one the manifest
    # tells CI to extract.
    while IFS= read -r mod; do
      [[ -n "$mod" ]] || continue
      if ! jq -e --arg d "$projects" --arg m "$mod" \
           'any(.dir == $d and (.modules | index($m) != null))' "$manifest" >/dev/null; then
        echo "$file uses module '$mod' of '$projects', which $manifest does not list" >&2
        status=1
      fi
    done < <( { sed -n 's/^set_option verso\.exampleModule "\([^"]*\)".*/\1/p' "$file"
                sed -n 's/.*(module := \([A-Z][A-Za-z0-9_.]*\)).*/\1/p' "$file"; } | sort -u )
  done < <(find Site -name '*.lean' | sort)
fi

exit $status
