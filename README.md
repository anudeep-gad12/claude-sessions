# claude-sessions

Browse, search, and resume your Claude Code conversations — from the terminal.

A lightweight CLI that scans your actual session files (not just the index), so **every session shows up**. Uses `fzf` for interactive picking with a live conversation preview.

## Features

- **Finds all sessions** — scans raw JSONL files, not the incomplete `sessions-index.json`
- **Conversation preview** — see the full conversation as you scroll through sessions
- **Full-text search** — find sessions by what was discussed (`-s "auth bug"`)
- **Relative timestamps** — "2h ago", "3d ago" instead of dates
- **Smart caching** — mtime-based cache makes repeat runs instant (~30ms)
- **Zero dependencies** — just `python3` + `fzf` (both pre-installed or one command away)
- **Single script** — no build step, no runtime, no npm/cargo/pip install chain
- **Works everywhere** — macOS, Linux, WSL, SSH sessions, containers

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/anudeep-gad12/claude-sessions/main/install.sh | bash
```

Or manually:

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/anudeep-gad12/claude-sessions/main/bin/claude-sessions -o ~/.local/bin/claude-sessions
curl -fsSL https://raw.githubusercontent.com/anudeep-gad12/claude-sessions/main/bin/claude-sessions-preview -o ~/.local/bin/claude-sessions-preview
chmod +x ~/.local/bin/claude-sessions ~/.local/bin/claude-sessions-preview
```

Make sure `~/.local/bin` is in your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc  # or ~/.bashrc
```

### Requirements

- `python3` (included on macOS, most Linux distros)
- [`fzf`](https://github.com/junegunn/fzf) — `brew install fzf` / `apt install fzf`
- [`claude`](https://docs.anthropic.com/en/docs/claude-code) — Claude Code CLI (for resuming sessions)

## Usage

```bash
# Interactive picker with conversation preview
claude-sessions

# Search sessions by content
claude-sessions -s "authentication"

# Filter by project name
claude-sessions myproject

# Plain text list (no fzf needed)
claude-sessions --list

# Show more sessions
claude-sessions -n 50

# Resume a specific session by number
claude-sessions pick 3

# Clear the scan cache
claude-sessions --clear
```

### Keybindings (in fzf picker)

| Key | Action |
|-----|--------|
| `Enter` | Resume selected session |
| `Ctrl+P` | Toggle conversation preview |
| `Up/Down` | Navigate sessions |
| Type | Fuzzy filter the list |
| `Esc` | Quit |

## How it works

1. Scans all `.jsonl` files in `~/.claude/projects/`
2. Reads first ~15 lines of each file for metadata (project, branch, timestamp)
3. Reads last ~50KB for the most recent messages
4. Caches results by file mtime — only rescans changed files
5. Pipes everything into `fzf` with a preview pane that renders the conversation

## Alias

Add to your shell config for a shorter command:

```bash
alias cs="claude-sessions"
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/anudeep-gad12/claude-sessions/main/uninstall.sh | bash
```

Or manually:

```bash
rm ~/.local/bin/claude-sessions ~/.local/bin/claude-sessions-preview
```

## License

MIT
