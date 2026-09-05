#!/usr/bin/env bash
#
# Check that the pre-generated highlighting data for the named example projects
# (all of them, if none are named) is present and parses.
#
# The site build fails on missing or malformed data too, but by then a CI run
# has already spent minutes compiling Verso. Running this first turns those
# failures into an immediate, obvious one.
#
# Usage: examples/check-highlighted.sh [project-name ...]
set -uo pipefail

cd "$(dirname "$0")/.."

names=("$@")
if [[ ${#names[@]} -eq 0 ]]; then
  mapfile -t names < <(jq -r '.[].name' examples/examples.json)
fi

status=0
for name in "${names[@]}"; do
  spec=$(jq -ce --arg n "$name" 'map(select(.name == $n)) | first // empty' examples/examples.json)
  if [[ -z "$spec" ]]; then
    echo "no project named '$name' in examples/examples.json" >&2
    status=1
    continue
  fi
  dir=$(jq -r '.dir' <<<"$spec")
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
  done < <(jq -r '.modules[]' <<<"$spec")
done

exit $status
