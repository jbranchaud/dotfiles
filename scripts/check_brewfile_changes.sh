#!/bin/bash
#
# Check for upstream Brewfile changes
#
# This script helps you stay aware of changes to the upstream Brewfile when
# maintaining your own Brewfile.personal on a personal branch.
#
# Usage:
#   ./scripts/check_brewfile_changes.sh [upstream-remote] [upstream-branch]
#
# Examples:
#   ./scripts/check_brewfile_changes.sh              # Uses 'upstream/main'
#   ./scripts/check_brewfile_changes.sh origin main  # Uses 'origin/main'
#

set -e

# Default to 'upstream' remote and 'main' branch
UPSTREAM_REMOTE="${1:-upstream}"
UPSTREAM_BRANCH="${2:-main}"
UPSTREAM_REF="${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Checking for upstream Brewfile changes...${NC}"
echo ""

# Check if upstream remote exists
if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
  echo -e "${RED}Error: Remote '${UPSTREAM_REMOTE}' not found.${NC}"
  echo ""
  echo "Available remotes:"
  git remote -v
  echo ""
  echo "To add an upstream remote:"
  echo "  git remote add upstream <upstream-repo-url>"
  exit 1
fi

# Fetch from upstream (quietly)
echo -e "${BLUE}Fetching from ${UPSTREAM_REF}...${NC}"
if ! git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH" --quiet 2>/dev/null; then
  echo -e "${YELLOW}Warning: Could not fetch from ${UPSTREAM_REF}${NC}"
  echo "Checking against last known state..."
fi
echo ""

# Get the current Brewfile hash
CURRENT_HASH=$(git rev-parse HEAD:Brewfile 2>/dev/null || echo "")

# Get the upstream Brewfile hash
UPSTREAM_HASH=$(git rev-parse "${UPSTREAM_REF}:Brewfile" 2>/dev/null || echo "")

if [ -z "$UPSTREAM_HASH" ]; then
  echo -e "${RED}Error: Could not find Brewfile in ${UPSTREAM_REF}${NC}"
  exit 1
fi

# Compare hashes
if [ "$CURRENT_HASH" = "$UPSTREAM_HASH" ]; then
  echo -e "${GREEN}✓ Your Brewfile is up to date with ${UPSTREAM_REF}${NC}"
  echo ""
else
  echo -e "${YELLOW}⚠ Brewfile has changed in ${UPSTREAM_REF}${NC}"
  echo ""
  echo "To see what changed:"
  echo "  git diff HEAD:Brewfile ${UPSTREAM_REF}:Brewfile"
  echo ""

  # Show the diff
  echo -e "${BLUE}Changes in upstream Brewfile:${NC}"
  echo "─────────────────────────────────────────────────────────────"
  git diff --color=always "HEAD:Brewfile" "${UPSTREAM_REF}:Brewfile" || true
  echo "─────────────────────────────────────────────────────────────"
  echo ""
fi

# If Brewfile.personal exists, show diff between it and upstream
if [ -f "Brewfile.personal" ]; then
  echo -e "${BLUE}Comparing your Brewfile.personal with upstream Brewfile:${NC}"
  echo "─────────────────────────────────────────────────────────────"

  # Show a summary of differences
  if git diff --no-index --quiet "Brewfile.personal" <(git show "${UPSTREAM_REF}:Brewfile") 2>/dev/null; then
    echo -e "${GREEN}✓ Brewfile.personal matches upstream Brewfile${NC}"
  else
    echo -e "${YELLOW}Your Brewfile.personal differs from upstream:${NC}"
    echo ""
    git diff --no-index --color=always "Brewfile.personal" <(git show "${UPSTREAM_REF}:Brewfile") || true
  fi
  echo "─────────────────────────────────────────────────────────────"
  echo ""
  echo -e "${BLUE}Tip:${NC} Review the changes above and update Brewfile.personal as needed."
fi

echo ""
echo -e "${GREEN}Done!${NC}"
