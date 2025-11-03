#!/bin/bash

# Script to process a full GitLab upgrade path
# Usage: ./upgrade-path.sh "version1 => version2 => ... => versionN"
# Example: ./upgrade-path.sh "16.11.10 => 17.1.8 => 17.3.7 => 18.5.1"

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 \"<version> => <version> => ... => <version>\""
    echo ""
    echo "Example: $0 \"16.11.10 => 17.1.8 => 17.3.7 => 18.5.1\""
    echo ""
    echo "This processes an upgrade path from https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/"
    exit 1
fi

# Parse upgrade path and remove empty elements
IFS='=>' read -ra temp_array <<< "$1"
versions_array=()
for v in "${temp_array[@]}"; do
    # Trim whitespace
    v=$(echo "$v" | xargs)
    if [ -n "$v" ]; then
        versions_array+=("$v")
    fi
done

echo "========================================"
echo "Processing upgrade path from GitLab Upgrade Path Tool"
echo "https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/"
echo "========================================="
echo ""
echo "Versions in path:"
for v in "${versions_array[@]}"; do
    echo "  - $v"
done
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MANIFEST_FILE="$SCRIPT_DIR/manifest.toml"

echo "Cleaning up old versioned sources from manifest.toml..."
# Remove all versioned sources (v*_*_*) from manifest, keeping only latest_* entries
# Find the line with the first versioned source comment
first_versioned_line=$(grep -n "^\s*# GitLab [0-9]" "$MANIFEST_FILE" | head -n1 | cut -d: -f1)

if [ -n "$first_versioned_line" ]; then
    # Keep everything before the first versioned source comment
    head -n $((first_versioned_line - 1)) "$MANIFEST_FILE" > "${MANIFEST_FILE}.tmp"
    mv "${MANIFEST_FILE}.tmp" "$MANIFEST_FILE"
    echo "Removed all versioned sources"
else
    echo "No versioned sources to remove"
fi
echo ""

# Process all versions
total=${#versions_array[@]}
for i in "${!versions_array[@]}"; do
    ver="${versions_array[$i]}"

    if [ $i -eq $((total - 1)) ]; then
        # Last version: update latest
        echo "========================================="
        echo "[$((i+1))/$total] Processing final version: $ver (updating latest)"
        echo "========================================="
        "$SCRIPT_DIR/upgrade-versions.sh" "$ver"
    else
        # Intermediate version: add-only
        echo "========================================="
        echo "[$((i+1))/$total] Processing intermediate version: $ver (add-only)"
        echo "========================================="
        "$SCRIPT_DIR/upgrade-versions.sh" "$ver" --add-only
    fi

    echo ""
done

echo "========================================="
echo "✓ Upgrade path processing complete!"
echo "========================================="
echo ""
echo "All versions have been processed:"
for v in "${versions_array[@]}"; do
    echo "  ✓ $v"
done
echo ""
echo "Please review the changes:"
echo "  git diff manifest.toml conf/gitlab.rb"
