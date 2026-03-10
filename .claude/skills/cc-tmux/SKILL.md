---
name: cc-tmux
description: Set up persistent tmux sessions for AI coding CLIs like Claude Code, Codex, etc. Use when the user wants to configure tmux, set up persistent terminal sessions, or asks about cc/ccl commands.
disable-model-invocation: true
allowed-tools: Bash, Read
---

# cc-tmux: Persistent tmux sessions for AI coding CLIs

Set up tmux with persistent sessions so terminal closures don't kill your AI coding sessions.

## What this does

1. Installs `tmux` and `fzf` (Homebrew on macOS, apt on Linux)
2. Configures `~/.tmux.conf` with mouse scrolling and 200k line history
3. Adds two shell functions to the user's rc file:
   - `cc` — jump into a default tmux session named "claude" (creates if needed)
   - `ccl` — interactive session picker via fzf (attach existing or create new)

## Instructions

Run the setup script:

```bash
curl -fsSL https://raw.githubusercontent.com/JingxuanKang/cc-tmux/main/setup.sh | bash
```

After the script completes, remind the user to reload their shell:

```bash
source ~/.zshrc   # or ~/.bashrc
```

Then verify the installation:

```bash
type cc
type ccl
```

If any step fails, read the error output and help the user troubleshoot. Common issues:
- **Homebrew not installed** (macOS): guide them to install Homebrew first
- **Not an apt-based Linux**: the script currently only supports apt — help them install tmux and fzf manually, then run the script again or manually add the shell functions
