#!/bin/bash
set -e

# Configuration
UPSTREAM_REMOTE="upstream"
ORIGIN_REMOTE="origin"
MAIN_BRANCH="master"
CUSTOM_BRANCH="my-dotfiles"

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

# Check if we're in the middle of a rebase
if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
  print_warning "Rebase in progress detected"

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
    print_info "To abort: git rebase --abort"
    exit 1
  fi

  # No conflicts, continue the rebase
  print_info "Continuing rebase..."
  git rebase --continue

  # Check if rebase completed successfully
  if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
    print_error "Rebase still in progress after continue. Check status:"
    git status
    exit 1
  fi

  print_success "Rebase completed successfully"

  # Push the rebased branch
  print_info "Force-pushing ${CUSTOM_BRANCH} to ${ORIGIN_REMOTE}..."
  git push ${ORIGIN_REMOTE} ${CUSTOM_BRANCH} --force-with-lease
  print_success "Push completed"

  print_success "Sync process complete!"
  exit 0
fi

# Normal flow - not in the middle of a rebase

# Fetch latest changes from upstream
print_info "Fetching from ${UPSTREAM_REMOTE}..."
git fetch ${UPSTREAM_REMOTE}

# Switch to main branch
print_info "Switching to ${MAIN_BRANCH} branch..."
git checkout ${MAIN_BRANCH}

# Check if main is behind upstream
UPSTREAM_MAIN="${UPSTREAM_REMOTE}/${MAIN_BRANCH}"
if git merge-base --is-ancestor ${UPSTREAM_MAIN} HEAD; then
  print_success "Main branch is up to date with upstream"
else
  print_info "Merging ${UPSTREAM_MAIN} into ${MAIN_BRANCH}..."
  if ! git merge ${UPSTREAM_MAIN}; then
    print_error "Merge conflict in ${MAIN_BRANCH} branch"
    print_info "This shouldn't happen if you keep ${MAIN_BRANCH} pristine"
    print_info "Resolve conflicts and run the script again"
    git status
    exit 1
  fi
  print_success "Main branch updated"
fi

# Push updated main to origin
print_info "Pushing ${MAIN_BRANCH} to ${ORIGIN_REMOTE}..."
git push ${ORIGIN_REMOTE} ${MAIN_BRANCH}
print_success "Main branch pushed"

# Switch to custom branch
print_info "Switching to ${CUSTOM_BRANCH} branch..."
if ! git checkout ${CUSTOM_BRANCH}; then
  print_error "Failed to checkout ${CUSTOM_BRANCH}"
  print_info "Does the branch exist? Create it with:"
  print_info "  git checkout -b ${CUSTOM_BRANCH}"
  exit 1
fi

# Check if custom branch needs rebasing
if git merge-base --is-ancestor ${MAIN_BRANCH} HEAD; then
  print_success "${CUSTOM_BRANCH} is already up to date with ${MAIN_BRANCH}"
  print_success "Sync process complete - no changes needed!"
  exit 0
fi

# Perform the rebase
print_info "Rebasing ${CUSTOM_BRANCH} onto ${MAIN_BRANCH}..."
if ! git rebase ${MAIN_BRANCH}; then
  print_error "Rebase conflicts detected"
  echo ""
  git status
  echo ""
  print_info "To resolve:"
  print_info "  1. Edit the conflicting files"
  print_info "  2. Stage resolved files: git add <files>"
  print_info "  3. Run this script again"
  echo ""
  print_info "To abort: git rebase --abort"
  exit 1
fi

print_success "Rebase completed successfully"

# Push the rebased branch
print_info "Force-pushing ${CUSTOM_BRANCH} to ${ORIGIN_REMOTE}..."
git push ${ORIGIN_REMOTE} ${CUSTOM_BRANCH} --force-with-lease
print_success "Push completed"

print_success "Sync process complete!"
