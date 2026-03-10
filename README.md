# cc-tmux

One-command setup for persistent tmux sessions — designed for AI coding CLIs like [Claude Code](https://docs.anthropic.com/en/docs/claude-code), OpenAI Codex, and similar tools.

## Why?

AI coding CLIs run in your terminal. If the terminal closes, you lose your session. `cc-tmux` fixes this with two shell commands:

| Command | What it does |
|---------|-------------|
| `cc`    | Jump into a default tmux session named `claude` (creates it if needed) |
| `ccl`   | Interactive picker (via fzf) — attach to an existing session or create a new one |

It also configures tmux with sensible defaults: mouse scrolling and 200k line history.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/JingxuanKang/cc-tmux/main/setup.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/JingxuanKang/cc-tmux.git
cd cc-tmux
bash setup.sh
```

Then reload your shell:

```bash
source ~/.zshrc   # or ~/.bashrc
```

## What the installer does

1. Installs `tmux` and `fzf` (via Homebrew on macOS, apt on Linux)
2. Writes a minimal `~/.tmux.conf` (mouse on, 200k history)
3. Adds `cc` and `ccl` shell functions to your rc file (`~/.zshrc` or `~/.bashrc`)

## Supported platforms

- macOS (Homebrew)
- Linux (apt-based: Ubuntu, Debian, etc.)

## Uninstall

Remove the managed block from your shell rc file (between `# >>> tmux-cc-ccl >>>` and `# <<< tmux-cc-ccl <<<`), then optionally delete `~/.tmux.conf`.

## License

MIT
