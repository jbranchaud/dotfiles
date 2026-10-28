#!/bin/bash
set -e

# Configuration
UPSTREAM_REMOTE="upstream"
ORIGIN_REMOTE="origin"
UPSTREAM_BRANCH="master"
OLD_CUSTOM_BRANCH="my-dotfiles"
NEW_MAIN_BRANCH="main"
TRACKING_BRANCH="upstream-master"

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

print_step() {
  echo ""
  echo -e "${BLUE}▶${NC} $1"
  echo ""
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

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Dotfiles Branch Structure Migration                   ║"
echo "║                                                            ║"
echo "║  This will set up a merge-based workflow:                 ║"
echo "║  • ${TRACKING_BRANCH} - tracks upstream/${UPSTREAM_BRANCH}                     ║"
echo "║  • ${NEW_MAIN_BRANCH} - your customizations (default branch)         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
  print_error "You have uncommitted changes. Please commit or stash them first."
  git status
  exit 1
fi

# Step 1: Fetch latest from upstream
print_step "Step 1: Fetching latest changes from upstream"
git fetch ${UPSTREAM_REMOTE}
print_success "Fetched upstream changes"

# Step 2: Create upstream tracking branch
print_step "Step 2: Creating ${TRACKING_BRANCH} to track upstream"
if git show-ref --verify --quiet refs/heads/${TRACKING_BRANCH}; then
  print_warning "${TRACKING_BRANCH} already exists"
  git checkout ${TRACKING_BRANCH}
  git reset --hard ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}
  print_success "Reset ${TRACKING_BRANCH} to upstream/${UPSTREAM_BRANCH}"
else
  git checkout -b ${TRACKING_BRANCH} ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}
  print_success "Created ${TRACKING_BRANCH}"
fi

git push ${ORIGIN_REMOTE} ${TRACKING_BRANCH} --force
print_success "Pushed ${TRACKING_BRANCH} to origin"

# Step 3: Create main branch from your custom branch
print_step "Step 3: Creating ${NEW_MAIN_BRANCH} from ${OLD_CUSTOM_BRANCH}"
git checkout ${OLD_CUSTOM_BRANCH}

if git show-ref --verify --quiet refs/heads/${NEW_MAIN_BRANCH}; then
  print_warning "${NEW_MAIN_BRANCH} already exists"
  read -p "Overwrite with ${OLD_CUSTOM_BRANCH}? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git branch -D ${NEW_MAIN_BRANCH}
    git checkout -b ${NEW_MAIN_BRANCH}
    print_success "Recreated ${NEW_MAIN_BRANCH}"
  else
    git checkout ${NEW_MAIN_BRANCH}
    print_info "Keeping existing ${NEW_MAIN_BRANCH}"
  fi
else
  git checkout -b ${NEW_MAIN_BRANCH}
  print_success "Created ${NEW_MAIN_BRANCH}"
fi

git push ${ORIGIN_REMOTE} ${NEW_MAIN_BRANCH} --force
print_success "Pushed ${NEW_MAIN_BRANCH} to origin"

# Step 4: Set main as default branch (requires gh CLI)
print_step "Step 4: Setting ${NEW_MAIN_BRANCH} as default branch on GitHub"
if command -v gh &>/dev/null; then
  if gh repo edit --default-branch ${NEW_MAIN_BRANCH} 2>/dev/null; then
    print_success "Set ${NEW_MAIN_BRANCH} as default branch on GitHub"
  else
    print_warning "Could not set default branch automatically"
    print_info "Set it manually: https://github.com/settings"
    print_info "Or run: gh repo edit --default-branch ${NEW_MAIN_BRANCH}"
  fi
else
  print_warning "GitHub CLI (gh) not found"
  print_info "To set ${NEW_MAIN_BRANCH} as default, go to your repo on GitHub:"
  print_info "Settings → Branches → Default branch → Switch to ${NEW_MAIN_BRANCH}"
fi

# Step 5: Optional cleanup
print_step "Step 5: Cleanup old branch"
echo ""
print_warning "You can now delete the old ${OLD_CUSTOM_BRANCH} branch"
print_info "Local:  git branch -d ${OLD_CUSTOM_BRANCH}"
print_info "Remote: git push ${ORIGIN_REMOTE} --delete ${OLD_CUSTOM_BRANCH}"
echo ""
read -p "Delete ${OLD_CUSTOM_BRANCH} now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git branch -d ${OLD_CUSTOM_BRANCH}
  git push ${ORIGIN_REMOTE} --delete ${OLD_CUSTOM_BRANCH}
  print_success "Deleted ${OLD_CUSTOM_BRANCH}"
else
  print_info "Keeping ${OLD_CUSTOM_BRANCH} for now"
fi

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                  Migration Complete! ✓                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
print_success "New branch structure:"
echo "  • ${TRACKING_BRANCH} - clean mirror of upstream"
echo "  • ${NEW_MAIN_BRANCH} - your customizations (default)"
echo ""
print_info "To sync with upstream in the future, run:"
echo "  ./sync-with-upstream.sh"
echo ""
print_info "To see your customizations:"
echo "  git log ${TRACKING_BRANCH}..${NEW_MAIN_BRANCH}"
echo "  git diff ${TRACKING_BRANCH}...${NEW_MAIN_BRANCH}"
echo ""
