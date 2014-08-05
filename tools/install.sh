echo "cloning repo to ~/.dotfiles"
git clone https://github.com/jbranchaud/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
echo "initializing git submodules"
git submodule init
git submodule update
echo "running backup"
rake backup
echo "creating symlinks"
rake install
