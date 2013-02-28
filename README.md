# dotfiles

These are my dotfiles, which contain my custom system configuration
preferences.
Thanks to [Nick Nisi](https://github.com/nicknisi) for providing such a
well crafted [dotfiles](https://github.com/nicknisi/dotfiles) framework.

## Contents

- zsh configuration
- vim configuration
- tmux configuration
- git configuration
- hg configuration
- osx configuration
- bash configuration

## Install

### Automatic Installation

	curl -L https://raw.github.com/jbranchaud/dotfiles/master/tools/install.sh | sh

### Manual Installation

#### Clone

First, clone the repository to your home directory and name it ".dotfiles"

	git clone git@github.com:jbranchaud/dotfiles.git ~/.dotfiles

Then cd into that directory

	cd ~/.dotfiles

#### Init Submodules

The vim configuration relies on a couple of vim plugins, which are loaded in as git submodules.

	git submodule init
	git submodule update
	
#### Backup

A backup task is included. This will find all the files that will be replaced and make a backup of them. For example, if you currently have a ".zshrc" file, it will be moved to ".zshrc.backup"
	
	rake backup
	
#### Install

Symlink the necessary files. The task will perform a search  for all files in the *.dotfiles* directory that have the ".symlink" suffix and create a symbolic link in the home directory that drops the suffix and prefixes with a '.'

	rake install
	
## Uninstall

If you would like to bring back your previous configuration, run the uninstalll task. This will remove the created symlinks.

#### Uninstall

	rake uninstall
	
#### Restore
	
Then, if you would like to restore your previous configuration, run the restore task.
	
	rake restore
	
## ZSH Plugins

By default, the *.zshrc* file will source any file within .dotfiles that has the *".zsh"* suffix.

## Vim Per Machine and Per Project Configuration

The vimrc in this project will check for the existence of a `~/.vimrc.local`, as well as a `./.vimrc.project` allowing per-machine and per-project vim configurations.

## FIXMEs

- the `git outgoing` command that I have added as an alias gets an error
when it is used inside of a newly initialized repository. Figure out how
to make this more robust. It doesn't technically break anything, but there
is no need to have such an unnecessary error message displayed.
