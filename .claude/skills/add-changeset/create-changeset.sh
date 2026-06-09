#!/usr/bin/env bash
# Create a knope changeset file under .changeset/.
#
# Usage: create-changeset.sh <severity> <summary>
#   <severity>  one of: patch | minor | major
#   <summary>   short description of the change (becomes the CHANGELOG entry)
#
# Example:
#   create-changeset.sh minor "Add dark mode toggle to settings"
#
# Writes .changeset/<slugified-summary>.md in the format knope expects:
#   ---
#   default: <severity>
#   ---
#
#   # <summary>

set -euo pipefail

severity="${1:-}"
summary="${2:-}"

if [[ -z "$severity" || -z "$summary" ]]; then
    echo "usage: create-changeset.sh <patch|minor|major> <summary>" >&2
    exit 2
fi

case "$severity" in
    patch|minor|major) ;;
    *)
        echo "error: severity must be patch, minor, or major (got '$severity')" >&2
        exit 2
        ;;
esac

# Locate the repo root so the script works from any cwd.
repo_root="$(git rev-parse --show-toplevel)"
changeset_dir="$repo_root/.changeset"
mkdir -p "$changeset_dir"

# Slugify the summary into a filename: lowercase, non-alphanumeric -> _, trim.
slug="$(printf '%s' "$summary" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//')"
slug="${slug:-change}"

file="$changeset_dir/$slug.md"

# Avoid clobbering an existing changeset; append a numeric suffix.
if [[ -e "$file" ]]; then
    i=2
    while [[ -e "$changeset_dir/${slug}_${i}.md" ]]; do
        i=$((i + 1))
    done
    file="$changeset_dir/${slug}_${i}.md"
fi

cat > "$file" <<EOF
---
default: $severity
---

# $summary
EOF

echo "Created changeset: ${file#"$repo_root"/}"
