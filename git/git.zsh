# git aliases
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gba='git branch -a'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gdc='git diff --cached'
alias gs='git status'
alias gss='git stash save'
alias gsp='git stash pop'
alias gmv='git mv'
alias grm='git rm'
alias grn='git-rename'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

# Get a list of authors for this git repo with their commit count,
# sorted in decreasing order by the commit count
alias git-authors='git log | grep "Author: " | sort | uniq -c | sort -rn'

# Get a count of the number of authors for this git repo
alias git-author-count='git log | grep "Author: " | sort | uniq | wc -l'

# alias git-amend='git commit --amend -C HEAD'
alias git-undo='git reset --soft HEAD~1'
alias git-count='git shortlog -sn'
alias git-undopush="git push -f origin HEAD^:master"
# git root
alias gr='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'

alias sub-pull='git submodule foreach git pull origin master'

function give-credit() {
    git commit --amend --author $1 <$2> -C HEAD
}

# a simple git rename file function
# git does not track case-sensitive changes to a filename.
function git-rename() {
    git mv $1 "${2}-"
    git mv "${2}-" $2
}

# determine the number of pending commits on the current branch
# if on master, then do:
# $ git cherry
# if on some branch, branch1, then do:
# $ git cherry master branch1
function git-branch-commit-count() {
    if [ "$(git currbranch)" = "master" ]
    then
        git cherry origin/master 2>/dev/null | wc -l | tr -d " "
    else
        git cherry master $(git currbranch) 2>/dev/null | wc -l | tr -d " "
    fi
}

