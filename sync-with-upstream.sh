#!/bin/bash
set -e

# Configuration
UPSTREAM_REMOTE="upstream"
ORIGIN_REMOTE="origin"
UPSTREAM_BRANCH="master"          # The branch name in the upstream repo
TRACKING_BRANCH="upstream-master" # Your local tracking branch for upstream
MAIN_BRANCH="main"                # Your customized branch

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  print_error "Not in a git repository"
  exit 1
fi

# Check if upstream remote exists
if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
  print_error "Upstream remote '${UPSTREAM_REMOTE}' not found"
  print_info "Add it with: git remote add ${UPSTREAM_REMOTE} <upstream-url>"
  exit 1
fi

print_info "Starting dotfiles sync process..."

# Check if we're in the middle of a merge
if [ -f .git/MERGE_HEAD ]; then
  print_warning "Merge in progress detected"

  # Check if there are conflicts
  if git status --porcelain | grep -q '^UU\|^AA\|^DD\|^AU\|^UA\|^DU\|^UD'; then
    print_error "Conflicts detected. Please resolve them:"
    echo ""
    git status
    echo ""
    print_info "To resolve:"
    print_info "  1. Edit the conflicting files"
    print_info "  2. Stage resolved files: git add <files>"
    print_info "  3. Run this script again"
    echo ""
    print_info "To abort: git merge --abort"
    exit 1
  fi

  # No conflicts, complete the merge
  print_info "Completing merge..."
  git commit --no-edit

  print_success "Merge completed successfully"

  # Push the merged branch
  print_info "Pushing ${MAIN_BRANCH} to ${ORIGIN_REMOTE}..."
  git push ${ORIGIN_REMOTE} ${MAIN_BRANCH}
  print_success "Push completed"

  print_success "Sync process complete!"
  exit 0
fi

# Normal flow - not in the middle of a merge

# Save current branch to return to it later if needed
# CURRENT_BRANCH=$(git branch --show-current)

# Fetch latest changes from upstream
print_info "Fetching from ${UPSTREAM_REMOTE}..."
git fetch ${UPSTREAM_REMOTE}
print_success "Fetched latest upstream changes"

# Switch to tracking branch
print_info "Updating ${TRACKING_BRANCH} from ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}..."
git checkout ${TRACKING_BRANCH}

# Update tracking branch with upstream (should be fast-forward)
if ! git merge --ff-only ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}; then
  print_error "Cannot fast-forward ${TRACKING_BRANCH}"
  print_warning "This branch should always cleanly track upstream"
  print_info "You may need to reset it: git reset --hard ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"
  exit 1
fi

print_success "Updated ${TRACKING_BRANCH}"

# Push tracking branch to origin (optional but useful for visibility)
print_info "Pushing ${TRACKING_BRANCH} to ${ORIGIN_REMOTE}..."
git push ${ORIGIN_REMOTE} ${TRACKING_BRANCH}
print_success "Tracking branch pushed"

# Switch to main branch
print_info "Switching to ${MAIN_BRANCH}..."
if ! git checkout ${MAIN_BRANCH}; then
  print_error "Failed to checkout ${MAIN_BRANCH}"
  print_info "Does the branch exist? It should be your primary customization branch."
  exit 1
fi

# Check if main needs updating
if git merge-base --is-ancestor ${TRACKING_BRANCH} HEAD; then
  print_success "${MAIN_BRANCH} is already up to date with upstream"
  print_success "Sync process complete - no changes needed!"
  exit 0
fi

# Merge tracking branch into main
print_info "Merging ${TRACKING_BRANCH} into ${MAIN_BRANCH}..."
MERGE_MSG="chore(sync): merge upstream changes from $(date +%Y-%m-%d)"

if ! git merge ${TRACKING_BRANCH} -m "${MERGE_MSG}"; then
  print_error "Merge conflicts detected"
  echo ""
  git status
  echo ""
  print_info "To resolve:"
  print_info "  1. Edit the conflicting files listed above"
  print_info "  2. Stage resolved files: git add <files>"
  print_info "  3. Run this script again to complete the merge"
  echo ""
  print_info "To see conflicts: git diff"
  print_info "To abort: git merge --abort"
  exit 1
fi

print_success "Merge completed successfully"

# Push the updated main branch
print_info "Pushing ${MAIN_BRANCH} to ${ORIGIN_REMOTE}..."
git push ${ORIGIN_REMOTE} ${MAIN_BRANCH}
print_success "Push completed"

print_success "Sync process complete!"
print_info "Your customizations in '${MAIN_BRANCH}' now include the latest upstream changes"
