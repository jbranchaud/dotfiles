# Script Kit Personal Kenv

This is a secondary kenv for [Script Kit](https://www.scriptkit.com/) containing custom scripts.

## Structure

- `scripts/` - Your custom Script Kit scripts (TypeScript/JavaScript)
- `lib/` - Shared utilities and helper functions
- `package.json` - Dependencies (versioned)
- `node_modules/` - Installed packages (git-ignored)

## Setup

After cloning dotfiles to a new machine:

1. The kenv will be symlinked to `~/.kenv/kenvs/dotfiles` automatically
2. Install dependencies:
   ```bash
   cd ~/dev/jbranchaud/dotfiles/scriptkit
   npm install
   # or: pnpm install
   ```

## How It Works

This directory gets symlinked to `~/.kenv/kenvs/dotfiles` during dotfiles installation.
Script Kit will automatically detect and load scripts from this kenv.

## Usage

Create new scripts in the `scripts/` directory. Script Kit will automatically:

- Build and watch for changes
- Make scripts available in the Script Kit UI
- Generate executables in the `bin/` directory (git-ignored)

## Resources

- [Script Kit Documentation](https://github.com/johnlindquist/kit)
- [Kenv Documentation](https://johnlindquist.github.io/kit-docs/kenvs)
