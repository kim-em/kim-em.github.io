#!/usr/bin/env bash
#
# Build the hex example modules for the blog.
#
# The HexExamples.Mathlib section imports HexRowReduceMathlib, so we fetch the
# Mathlib cache before building. The Core and Coppersmith sections are
# Mathlib-free (GMP for Berlekamp-Zassenhaus, so the host needs libgmp).
set -euo pipefail
cd "$(dirname "$0")"

lake exe cache get
lake build
