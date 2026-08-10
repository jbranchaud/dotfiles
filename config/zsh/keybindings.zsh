# emacs mode
bindkey -e

bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^K" kill-line
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word

# Bind Option-left-right to previous-next word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

bindkey "^[f" forward-word
bindkey "^[b" backward-word

bindkey '^r' history-incremental-search-backward

# Edit current command line in $EDITOR
# zsh-vi-mode resets keymaps after init, so bind via its hook (array form, so we
# don't clobber the zvm_after_init function defined in tv.zsh)
autoload -Uz edit-command-line
zle -N edit-command-line
zvm_after_init_commands+=("bindkey -M viins '^X^E' edit-command-line"
  "bindkey -M vicmd '^X^E' edit-command-line")
