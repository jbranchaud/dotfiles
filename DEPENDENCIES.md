# Dependencies

This document notes the dependencies of certain parts of this
dotfiles project. These dependencies may need to be satisfied
when this project is installed on a machine for the first time.

## Installation

Installing the set of dotfiles on the current machine uses Rake which
is Ruby.

- [Ruby](http://www.ruby-lang.org/en/) - this is standard on most
    machines
- [Rake](http://rake.rubyforge.org/) - Ruby Make is used to install,
    backup, restore, and uninstall this project

## tmux

[tmux](http://tmux.sourceforge.net/) is a terminal multiplexer.

- [tmux](http://tmux.sourceforge.net/) - if you don't have it already,
    you are going to need tmux itself
- [libevent](http://libevent.org/) - tmux depends on libevent
- reattach to user namespace - this is common tmux feature that requires
    installation of reattach-to-user-namespace which can easily be installed
    with homebrew: `brew install reattach-to-user-namespace`.

