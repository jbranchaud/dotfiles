autoload colors && colors

PROMPT='
%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%} in %{$fg_bold[green]%}$(collapse_pwd)%{$reset_color%}$(hg_prompt_info)$(adv_git_prompt)
$(prompt_char) '

function collapse_pwd {
    echo $(pwd | sed -e "s,^$HOME,~,")
}

function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    hg root >/dev/null 2>/dev/null && echo '☿' && return
    echo '○'
}

# this function wraps zsh's git_prompt_info function so that whenever
# we are in a git repo, it will append the number of local commits that
# exist (in parentheses). Currently, it relies on a git alias I created
# called outcountall which counts the number of outgoing commits.
function adv_git_prompt {
    gitprompt=$(git_prompt_info)
    if [ "$gitprompt" != "" ]
    then
        #gitoutcountcurr=$(git-branch-commit-count 2>/dev/null)
        #gitoutcountall=$(git outcountall 2>/dev/null)
        git_outgoing_on_curr=$(git outgoing-count 2>/dev/null)
        git_outgoing_on_master=$(git rev-list master@{u}..master --count 2>/dev/null)
        echo "$gitprompt"
        #if [ "$git_outgoing_on_master" != "" ]
        #then
        #    if [ "$git_outgoing_on_curr" != "" ]
        #    then
        #        echo "$gitprompt ($git_outgoing_on_curr/$git_outgoing_on_master)"
        #    else
        #        echo "$gitprompt ($git_outgoing_on_master)"
        #    fi
        #else
        #    echo "$gitprompt"
        #fi
    else
        echo ''
    fi
}

function hg_prompt_info {
    hg prompt --angle-brackets "\
< on %{$fg[magenta]%}<branch>%{$reset_color%}>\
< at %{$fg[yellow]%}<tags|%{$reset_color%}, %{$fg[yellow]%}>%{$reset_color%}>\
%{$fg[green]%}<status|modified|unknown><update>%{$reset_color%}<
patches: <patches|join( → )|pre_applied(%{$fg[yellow]%})|post_applied(%{$reset_color%})|pre_unapplied(%{$fg_bold[black]%})|post_unapplied(%{$reset_color%})>>" 2>/dev/null
}

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

git_branch() {
  echo $(/usr/bin/git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  st=$(/usr/bin/git status 2>/dev/null | tail -n 1)
  if [[ $st == "" ]]
  then
    echo ""
  else
    if [[ $st == "nothing to commit (working directory clean)" ]]
    then
      echo "%{$fg_bold[green]%}✔ $(git_prompt_info)%{$reset_color%}"
    else
      echo "%{$fg_bold[red]%}✗ $(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

unpushed() {
  /usr/bin/git cherry -v @{upstream} 2>/dev/null
}

#git_prompt_info() {
# ref=$(/usr/bin/git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
# echo "${ref#refs/heads/}"
#}

need_push() {
  if [[ $(unpushed) == "" ]]
  then
    echo " "
  else
    echo " %{$fg_bold[magenta]%}☁%{$reset_color%} "
  fi
}

suspended_jobs() {
    sj=$(jobs 2>/dev/null | tail -n 1)
    if [[ $sj == "" ]]; then
        echo ""
    else
        echo "%{$FG[208]%}✱%{$reset_color%}"
    fi
}

directory_name(){
  echo "%{$fg_bold[cyan]%}%1/%\/%{$reset_color%}"
}

#export PROMPT=$'%{$FG[199]%}♥%{$reset_color%} $(directory_name) %{$fg_bold[magenta]%}➜%{$reset_color%} '
#export RPROMPT=$'$(git_dirty)$(need_push)$(suspended_jobs)'
