#!/usr/bin/env bash
set -euo pipefail

# Markdown policy checker for agent-seed.
# Enforces size limits, frontmatter requirements, index linking, and todo schema.
# Run locally or in CI: ./scripts/check-markdown-policy.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

errors=0
warnings=0

error() {
  printf 'ERROR: %s\n' "$1"
  errors=$((errors + 1))
}

warn() {
  printf 'WARN: %s\n' "$1"
  warnings=$((warnings + 1))
}

section() {
  printf '\n[%s]\n' "$1"
}

# ---------------------------------------------------------------------------
# Tooling check
# ---------------------------------------------------------------------------
require_tooling() {
  if ! command -v grep >/dev/null 2>&1; then
    printf 'ERROR: grep is required to run this checker.\n'
    exit 2
  fi
}

# ---------------------------------------------------------------------------
# Size limits
# ---------------------------------------------------------------------------
check_size_limits() {
  section "Size Limits"

  local file lines limit

  # Context and memory files
  while IFS= read -r file; do
    lines="$(wc -l < "$file" | tr -d ' ')"

    # Check frontmatter for max_lines override
    limit=""
    if head -1 "$file" | grep -q '^---'; then
      limit="$(sed -n '2,/^---$/p' "$file" | sed '$d' | grep '^max_lines:' | head -1 | awk '{print $2}' || true)"
    fi

    # Default limits by type
    if [[ -z "$limit" ]]; then
      if [[ "$file" == memory/* ]]; then
        limit=200
      elif [[ "$(basename "$file")" == "index.md" ]]; then
        limit=150
      else
        limit=250
      fi
    fi

    if (( lines > limit )); then
      error "$file has $lines lines (limit: $limit)"
    fi
  done < <(find context memory -type f -name '*.md' 2>/dev/null | sort)
}

# ---------------------------------------------------------------------------
# Frontmatter validation
# ---------------------------------------------------------------------------
has_frontmatter() {
  head -1 "$1" | grep -q '^---'
}

has_frontmatter_key() {
  local file="$1"
  local key="$2"
  if ! has_frontmatter "$file"; then
    return 1
  fi
  local fm
  fm="$(sed -n '2,/^---$/p' "$file" | sed '$d')"
  if [[ -z "$fm" ]]; then
    return 1
  fi
  printf '%s' "$fm" | grep -q "^${key}:"
}

check_frontmatter() {
  section "Frontmatter"

  local file

  # Agents: require model, tools, permissionMode
  while IFS= read -r file; do
    # Skip index.md — it's a registry, not an agent definition
    [[ "$(basename "$file")" == "index.md" ]] && continue

    if ! has_frontmatter "$file"; then
      error "$file is missing frontmatter entirely"
      continue
    fi
    for key in model tools permissionMode; do
      if ! has_frontmatter_key "$file" "$key"; then
        error "$file is missing required frontmatter key: $key"
      fi
    done
  done < <(find .claude/agents -type f -name '*.md' 2>/dev/null | sort)

  # Skills: require description
  while IFS= read -r file; do
    if ! has_frontmatter "$file"; then
      error "$file is missing frontmatter entirely"
      continue
    fi
    if ! has_frontmatter_key "$file" "description"; then
      error "$file is missing required frontmatter key: description"
    fi
  done < <(find .claude/skills -type f -name 'SKILL.md' 2>/dev/null | sort)

  # Rules: require paths
  while IFS= read -r file; do
    if ! has_frontmatter "$file"; then
      error "$file is missing frontmatter entirely"
      continue
    fi
    if ! has_frontmatter_key "$file" "paths"; then
      error "$file is missing required frontmatter key: paths"
    fi
  done < <(find .claude/rules -type f -name '*.md' 2>/dev/null | sort)
}

# ---------------------------------------------------------------------------
# Todo schema
# ---------------------------------------------------------------------------
check_todo_schema() {
  section "Todo Schema"

  local required_headers=(
    "## High Priority"
    "## Medium Priority"
  )

  local file header

  while IFS= read -r file; do
    for header in "${required_headers[@]}"; do
      if ! grep -qF -- "$header" "$file"; then
        error "$file is missing required section: $header"
      fi
    done

    # Check ordering: High before Medium before Low
    local high_line medium_line low_line
    high_line="$(grep -n '^## High Priority' "$file" | head -1 | cut -d: -f1 || true)"
    medium_line="$(grep -n '^## Medium Priority' "$file" | head -1 | cut -d: -f1 || true)"
    low_line="$(grep -n '^## Low Priority' "$file" | head -1 | cut -d: -f1 || true)"

    if [[ -n "$high_line" && -n "$medium_line" ]]; then
      if ! (( high_line < medium_line )); then
        error "$file has High Priority after Medium Priority"
      fi
    fi

    if [[ -n "$medium_line" && -n "$low_line" ]]; then
      if ! (( medium_line < low_line )); then
        error "$file has Medium Priority after Low Priority"
      fi
    fi
  done < <(find todos -type f -name 'todos.md' 2>/dev/null | sort)
}

# ---------------------------------------------------------------------------
# Index linking: every detail page should be referenced from its parent index
# ---------------------------------------------------------------------------
check_index_links() {
  section "Index Linking"

  local file parent basename_file

  while IFS= read -r file; do
    # Skip index.md files themselves
    [[ "$(basename "$file")" == "index.md" ]] && continue
    # Skip _template files
    [[ "$(basename "$file")" == _* ]] && continue

    # Check if there's a parent index.md in the same directory
    local dir
    dir="$(dirname "$file")"
    local index_file="$dir/index.md"

    if [[ -f "$index_file" ]]; then
      basename_file="$(basename "$file")"
      if ! grep -q "$basename_file" "$index_file"; then
        warn "$file is not linked from $index_file"
      fi
    fi
  done < <(find context memory -type f -name '*.md' 2>/dev/null | sort)
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print_summary() {
  section "Summary"
  printf 'Errors: %d\n' "$errors"
  printf 'Warnings: %d\n' "$warnings"
}

main() {
  require_tooling
  check_size_limits
  check_frontmatter
  check_todo_schema
  check_index_links
  print_summary

  if (( errors > 0 )); then
    exit 1
  fi
}

main "$@"
