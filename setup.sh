#!/usr/bin/env bash
set -euo pipefail
# Install tmux + fzf, configure tmux scrolling/history,
# and add cc/ccl helpers to the current shell rc file.

log() {
  printf "[setup] %s\n" "$1"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "mac" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

detect_shell_rc() {
  local shell_name
  shell_name="$(basename "${SHELL:-}")"
  case "$shell_name" in
    zsh)
      echo "$HOME/.zshrc"
      ;;
    bash)
      if [[ "$(detect_os)" == "mac" ]]; then
        if [[ -f "$HOME/.bashrc" ]]; then
          echo "$HOME/.bashrc"
        else
          echo "$HOME/.bash_profile"
        fi
      else
        echo "$HOME/.bashrc"
      fi
      ;;
    *)
      echo "$HOME/.zshrc"
      ;;
  esac
}

install_packages() {
  local os
  os="$(detect_os)"

  if [[ "$os" == "mac" ]]; then
    if ! have_cmd brew; then
      echo "Homebrew not found. Install Homebrew first, then rerun this script."
      echo 'Official install command:'
      echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
      exit 1
    fi
    log "Installing tmux and fzf with brew"
    brew install tmux fzf
  elif [[ "$os" == "linux" ]]; then
    if have_cmd apt-get; then
      log "Installing tmux and fzf with apt"
      sudo apt-get update
      sudo apt-get install -y tmux fzf
    else
      echo "Unsupported Linux package manager. This installer currently supports apt-based systems only."
      exit 1
    fi
  else
    echo "Unsupported OS: $(uname -s)"
    exit 1
  fi
}

ensure_projects_dir() {
  local projects_dir="$HOME/Claude"
  if [[ ! -d "$projects_dir" ]]; then
    log "Creating $projects_dir"
    mkdir -p "$projects_dir"
  fi
}

write_tmux_conf() {
  local tmux_conf="$HOME/.tmux.conf"
  log "Writing $tmux_conf"
  cat > "$tmux_conf" <<'EOF'
set -g mouse on
set -g history-limit 200000
EOF
  if [[ -n "${TMUX:-}" ]]; then
    tmux source-file "$tmux_conf" || true
  fi
}

append_shell_functions() {
  local rc_file="$1"
  log "Updating $rc_file"
  touch "$rc_file"

  # Remove previous managed block if present
  python3 - "$rc_file" <<'PY'
import re, sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()
pattern = re.compile(r'\n?# >>> tmux-cc-ccl >>>.*?# <<< tmux-cc-ccl <<<\n?', re.S)
text = re.sub(pattern, '\n', text).rstrip() + '\n'
with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
PY

  cat >> "$rc_file" <<'BLOCK'

# >>> tmux-cc-ccl >>>
cc() {
    tmux new-session -A -s claude -c ~/Claude
}

ccl() {
    local target
    local name
    target=$(
        {
            echo "[new]"
            tmux ls 2>/dev/null | cut -d: -f1
        } | fzf --prompt="Select tmux session: " --height=40% --reverse
    )
    [ -z "$target" ] && return

    if [ "$target" = "[new]" ]; then
        printf "New session name: "
        read name
        [ -z "$name" ] && return
        name="${name// /_}"
        name="${name//:/_}"
        name="${name//./_}"
        tmux new-session -A -s "$name" -c ~/Claude
    else
        tmux attach -t "$target"
    fi
}
# <<< tmux-cc-ccl <<<
BLOCK
}

print_next_steps() {
  local rc_file="$1"
  cat <<EOF

Done.

Config written to:
  - $HOME/.tmux.conf
  - $rc_file

Run this to apply shell changes now:

  source "$rc_file"

Usage:
  cc      # enter default tmux session "claude"
  ccl     # pick an existing session or create a new one

Verification:
  type cc
  type ccl
  tmux ls
EOF
}

main() {
  local rc_file
  rc_file="$(detect_shell_rc)"

  log "Detected OS: $(detect_os)"
  log "Detected shell: $(basename "${SHELL:-unknown}")"
  log "Using rc file: $rc_file"

  install_packages
  ensure_projects_dir
  write_tmux_conf
  append_shell_functions "$rc_file"
  print_next_steps "$rc_file"
}

main "$@"
