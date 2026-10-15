#!/usr/bin/env bash
#
# Build the number-field example modules for the blog.
#
# `Core` is Mathlib-free; `Correspondence` imports HexNumberFieldTheory, so we
# fetch the Mathlib cache first.
set -euo pipefail
cd "$(dirname "$0")"

lake exe cache get
lake build
