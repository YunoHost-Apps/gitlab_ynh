#!/bin/bash

# Script to process a full GitLab upgrade path
# Usage: ./upgrade-path.sh <starting_version>
# Example: ./upgrade-path.sh 16.11.10

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <starting_version>"
    echo ""
    echo "Example: $0 16.11.10"
    echo ""
    echo "This fetches the upgrade path from https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/"
    exit 1
fi

STARTING_VERSION="$1"

# Fetch the upgrade path JSON
echo "Fetching upgrade path data..."
JSON_URL="https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/path.json"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    exit 1
fi

# Fetch and parse JSON to build the upgrade path
# We use the "all" field to get all versions >= starting version
JSON_DATA=$(curl -s "$JSON_URL")

if [ -z "$JSON_DATA" ]; then
    echo "Error: Failed to fetch upgrade path data from $JSON_URL"
    exit 1
fi

# Find the first available version >= starting version
# If exact version exists, use it; otherwise find the next higher version
echo "Looking for upgrade path from version $STARTING_VERSION..."

# Get all available versions
mapfile -t all_available_versions < <(echo "$JSON_DATA" | jq -r '.all[]')

# Find first version >= STARTING_VERSION using version comparison
actual_start_version=""
for ver in "${all_available_versions[@]}"; do
    # Use sort -V to compare versions properly
    if printf '%s\n%s' "$STARTING_VERSION" "$ver" | sort -V -C 2>/dev/null; then
        actual_start_version="$ver"
        break
    fi
done

# Check if we found a valid starting version
if [ -z "$actual_start_version" ]; then
    echo "Error: No available version found >= $STARTING_VERSION"
    echo "Latest available version is: ${all_available_versions[-1]}"
    exit 1
fi

# Inform user if we're using a different version than requested
if [ "$actual_start_version" != "$STARTING_VERSION" ]; then
    echo "Version $STARTING_VERSION not found in available versions."
    echo "Using next available version: $actual_start_version"
    echo ""
fi

# Build upgrade path:
# 1. Get all versions from "all" field
# 2. Find the index of actual starting version
# 3. Take all versions after (and including) that version
mapfile -t versions_array < <(echo "$JSON_DATA" | jq -r --arg v "$actual_start_version" '
  .all as $all |
  ($all | index($v)) as $start_idx |
  $all[$start_idx:] | .[]
')

# If no versions found in upgrade path, error
if [ ${#versions_array[@]} -eq 0 ]; then
    echo "Error: No upgrade path found from version $STARTING_VERSION"
    echo "Starting version may already be the latest."
    exit 1
fi

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
