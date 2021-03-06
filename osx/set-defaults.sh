## These are a work in progress

# show hidden files by default
defaults write com.apple.Finder AppleShowAllFiles -bool true

# only use UTF-8 ub Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# expand save dialog by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# show the ~/Library folder in Finder
chflags nohidden ~/Library

# disable resume system wide
# defaults write NSGlobalDomainNSQuitAlwaysKeepWindows -bool false
