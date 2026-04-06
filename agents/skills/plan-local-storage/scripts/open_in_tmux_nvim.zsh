#!/usr/bin/env zsh
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: zsh ~/.agents/skills/plan-local-storage/scripts/open_in_tmux_nvim.zsh <absolute-path>" >&2
  exit 2
fi

plan_file="$1"

if [[ $plan_file != /* ]]; then
  echo "Path must be absolute: $plan_file" >&2
  exit 2
fi

if [[ ! -f $plan_file ]]; then
  echo "File not found: $plan_file" >&2
  exit 1
fi

if [[ -z ${TMUX:-} ]]; then
  echo "Skipped: not running inside tmux"
  exit 0
fi

current_window_id="$(tmux display-message -p '#{window_id}')"

target_pane_id="$({
  tmux list-panes -t "$current_window_id" -F '#{pane_id} #{pane_current_command}' \
    | while IFS=' ' read -r pane_id pane_cmd; do
      case "$pane_cmd" in
        nvim | vim | vi)
          printf '%s\n' "$pane_id"
          break
          ;;
      esac
    done
} || true)"

if [[ -z $target_pane_id ]]; then
  echo "Skipped: no nvim/vim pane in current tmux window"
  exit 0
fi

vim_path="$plan_file"
vim_path="${vim_path//\\/\\\\}"
vim_path="${vim_path// /\\ }"

tmux send-keys -t "$target_pane_id" Escape ":edit $vim_path" Enter

echo "Opened in pane $target_pane_id"
