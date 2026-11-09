#!/usr/bin/env bash
# A change inside a plugin that doesn't bump its version never reaches an
# installed copy: the self-update hook runs `claude plugin update`, which
# compares version numbers. This makes the CONTRIBUTING rule executable.
# Usage: check-bump.sh [base-ref]   (default origin/main)
set -u

BASE="${1:-origin/main}"
fail=0

version () { sed -n 's/.*"version": *"\([^"]*\)".*/\1/p'; }

# Portable "is $1 strictly greater than $2", field by field — sort -V is a
# GNUism and this script also runs on a maintainer's macOS.
gt () {
  a1=${1%%.*}; a_rest=${1#*.}; a2=${a_rest%%.*}; a3=${a_rest#*.}
  b1=${2%%.*}; b_rest=${2#*.}; b2=${b_rest%%.*}; b3=${b_rest#*.}
  [ "$a1" -gt "$b1" ] 2>/dev/null && return 0
  [ "$a1" -lt "$b1" ] 2>/dev/null && return 1
  [ "$a2" -gt "$b2" ] 2>/dev/null && return 0
  [ "$a2" -lt "$b2" ] 2>/dev/null && return 1
  [ "${a3:-0}" -gt "${b3:-0}" ] 2>/dev/null
}

for manifest in skills/*/.claude-plugin/plugin.json; do
  dir=${manifest%/.claude-plugin/plugin.json}
  changed=$(git diff --name-only "$BASE"...HEAD -- "$dir" | wc -l | tr -d ' ')
  old=$(git show "$BASE:$manifest" 2>/dev/null | version)
  new=$(version < "$manifest")
  if [ "$changed" -eq 0 ]; then
    printf '%-28s ok (changed=0, %s)\n' "$dir:" "$new"
  elif [ "$old" = "$new" ]; then
    printf '%-28s %s file(s) changed, version still %s — bump it\n' "$dir:" "$changed" "$new"
    fail=1
  elif [ -n "$old" ] && ! gt "$new" "$old"; then
    # An installed copy never moves backwards: `claude plugin update` compares
    # version numbers, so a lower one is a release that reaches nobody.
    printf '%-28s version went %s -> %s — must increase\n' "$dir:" "$old" "$new"
    fail=1
  else
    printf '%-28s ok (changed=%s, %s -> %s)\n' "$dir:" "$changed" "${old:-?}" "$new"
  fi
done

exit $fail
