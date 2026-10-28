# Dotfiles Workflow Guide

This document describes how to manage your personal dotfiles customizations while staying in sync with the upstream repository.

## Branch Structure

```
upstream/master (original repo)
       ↓
upstream-master (clean tracking branch)
       ↓
     main (your customizations - default branch)
```

### Branches Explained

- **`upstream-master`** - A pristine copy of the upstream repo's master branch. Never commit directly to this branch.
- **`main`** - Your primary branch with all customizations. This is the default branch on GitHub.

## Initial Setup

Run the migration script once to set up the branch structure:

```bash
./migrate-to-main.sh
```

This will:

1. Create `upstream-master` tracking the original repo
2. Create `main` from your current customizations
3. Set `main` as the default branch on GitHub
4. Optionally clean up old branches

## Regular Workflow: Syncing with Upstream

When you want to pull in the latest changes from the upstream dotfiles:

```bash
./sync-with-upstream.sh
```

This script will:

1. Fetch latest changes from upstream
2. Update `upstream-master` (fast-forward only)
3. Merge `upstream-master` into `main`
4. Handle conflicts if any
5. Push everything to your fork

### Handling Conflicts

If conflicts occur during sync:

1. The script will show you which files have conflicts
2. Edit the conflicting files to resolve them
3. Stage the resolved files: `git add <files>`
4. Run `./sync-with-upstream.sh` again to complete the merge

To abort: `git merge --abort`

## Making Your Own Changes

Just work on the `main` branch as normal:

```bash
# Make changes to your dotfiles
vim zshrc

# Commit them
git add zshrc
git commit -m "Update zsh config"

# Push to your fork
git push origin main
```

## Viewing Your Customizations

### See all your custom commits

```bash
git log upstream-master..main
```

### See a diff of your changes

```bash
git diff upstream-master...main
```

### See which files you've customized

```bash
git diff --name-only upstream-master...main
```

## Benefits of This Approach

✅ **No Rebasing** - Merge conflicts only happen once per upstream change\
✅ **Preserved History** - You can see when you synced with upstream\
✅ **Faster** - Much quicker than rebasing many commits\
✅ **Easier Conflict Resolution** - Conflicts are isolated to new changes\
✅ **Clear Customizations** - Easy to see what you've changed from upstream

## Comparison with Old Rebase Workflow

### Old Way (Rebase)

```
upstream changes → master → rebase my-dotfiles onto master
```

- ❌ Rewrites history every time
- ❌ All commits need rebasing
- ❌ Conflicts compound over time
- ❌ Requires force pushing

### New Way (Merge)

```
upstream changes → upstream-master → merge into main
```

- ✅ Preserves history
- ✅ Only new conflicts to resolve
- ✅ Standard git workflow
- ✅ No force pushing needed

## Troubleshooting

### If `upstream-master` won't fast-forward

This means the branch has diverged from upstream (shouldn't happen in normal use). Reset it:

```bash
git checkout upstream-master
git reset --hard upstream/master
git push origin upstream-master --force
```

### If you accidentally commit to `upstream-master`

1. Checkout main: `git checkout main`
2. Cherry-pick your commits: `git cherry-pick <commit-hash>`
3. Reset upstream-master: `git checkout upstream-master && git reset --hard upstream/master`

### If you want to start fresh

```bash
# Backup your changes
git checkout main
git branch backup-main

# Re-run migration
./migrate-to-main.sh
```

## Advanced Tips

### Interactive staging for conflict resolution

```bash
git add -p <file>  # Stage changes interactively
```

### View merge history

```bash
git log --merges main
```

### Compare with a specific upstream version

```bash
git diff <commit-hash> main
```
