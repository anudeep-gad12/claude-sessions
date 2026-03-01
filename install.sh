#!/bin/bash
# claude-sessions installer
# curl -fsSL https://raw.githubusercontent.com/anudeep-gad12/claude-sessions/main/install.sh | bash
set -euo pipefail

REPO="anudeep-gad12/claude-sessions"
INSTALL_DIR="$HOME/.local/bin"
CYAN='\033[36m'
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

ask() {
    local prompt="$1"
    local default="${2:-y}"
    if [ "$default" = "y" ]; then
        printf "${BOLD}${prompt}${RESET} ${DIM}(Y/n)${RESET} "
    else
        printf "${BOLD}${prompt}${RESET} ${DIM}(y/N)${RESET} "
    fi
    read -r answer </dev/tty
    answer="${answer:-$default}"
    [[ "$answer" =~ ^[Yy] ]]
}

detect_pkg_manager() {
    if command -v brew &>/dev/null; then
        echo "brew"
    elif command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v apk &>/dev/null; then
        echo "apk"
    else
        echo ""
    fi
}

echo ""
echo -e "  ${BOLD}${CYAN}claude-sessions${RESET} ${DIM}v1.0.0${RESET}"
echo -e "  ${DIM}Browse & resume Claude Code conversations${RESET}"
echo ""

# ── Check python3 ──────────────────────────────────────────

if ! command -v python3 &>/dev/null; then
    echo -e "  ${RED}✗${RESET} python3 not found"
    echo ""
    echo -e "  python3 is required. Install it first:"
    PKG=$(detect_pkg_manager)
    case "$PKG" in
        brew)   echo -e "    ${DIM}brew install python3${RESET}" ;;
        apt)    echo -e "    ${DIM}sudo apt install python3${RESET}" ;;
        dnf)    echo -e "    ${DIM}sudo dnf install python3${RESET}" ;;
        pacman) echo -e "    ${DIM}sudo pacman -S python${RESET}" ;;
        *)      echo -e "    ${DIM}https://www.python.org/downloads/${RESET}" ;;
    esac
    exit 1
fi
echo -e "  ${GREEN}✓${RESET} python3"

# ── Check claude CLI ───────────────────────────────────────

if command -v claude &>/dev/null; then
    echo -e "  ${GREEN}✓${RESET} claude"
else
    echo -e "  ${YELLOW}○${RESET} claude ${DIM}(not found — needed to resume sessions)${RESET}"
fi

# ── Check fzf ──────────────────────────────────────────────

if command -v fzf &>/dev/null; then
    echo -e "  ${GREEN}✓${RESET} fzf"
else
    echo -e "  ${YELLOW}○${RESET} fzf ${DIM}(not found — needed for interactive picker)${RESET}"
    echo ""

    PKG=$(detect_pkg_manager)
    if [ -n "$PKG" ]; then
        if ask "  Install fzf?"; then
            echo ""
            case "$PKG" in
                brew)   echo -e "  ${DIM}Running: brew install fzf${RESET}"; brew install fzf ;;
                apt)    echo -e "  ${DIM}Running: sudo apt install -y fzf${RESET}"; sudo apt install -y fzf ;;
                dnf)    echo -e "  ${DIM}Running: sudo dnf install -y fzf${RESET}"; sudo dnf install -y fzf ;;
                pacman) echo -e "  ${DIM}Running: sudo pacman -S --noconfirm fzf${RESET}"; sudo pacman -S --noconfirm fzf ;;
                apk)    echo -e "  ${DIM}Running: sudo apk add fzf${RESET}"; sudo apk add fzf ;;
            esac

            if command -v fzf &>/dev/null; then
                echo -e "  ${GREEN}✓${RESET} fzf installed"
            else
                echo -e "  ${YELLOW}○${RESET} fzf install failed — continuing without it"
                echo -e "  ${DIM}  You can still use: claude-sessions --list${RESET}"
            fi
        else
            echo -e "  ${DIM}  Skipped. You can still use: claude-sessions --list${RESET}"
        fi
    else
        echo -e "  ${DIM}  Install manually: https://github.com/junegunn/fzf#installation${RESET}"
        echo -e "  ${DIM}  You can still use: claude-sessions --list${RESET}"
    fi
fi

echo ""

# ── Install ────────────────────────────────────────────────

mkdir -p "$INSTALL_DIR"

echo -e "  ${DIM}Downloading...${RESET}"

curl -fsSL "https://raw.githubusercontent.com/$REPO/main/bin/claude-sessions" \
    -o "$INSTALL_DIR/claude-sessions"
curl -fsSL "https://raw.githubusercontent.com/$REPO/main/bin/claude-sessions-preview" \
    -o "$INSTALL_DIR/claude-sessions-preview"

chmod +x "$INSTALL_DIR/claude-sessions"
chmod +x "$INSTALL_DIR/claude-sessions-preview"

echo -e "  ${GREEN}✓${RESET} Installed to ${DIM}$INSTALL_DIR${RESET}"

# ── PATH check ─────────────────────────────────────────────

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""

    SHELL_NAME="$(basename "$SHELL")"
    case "$SHELL_NAME" in
        zsh)  RC_FILE="$HOME/.zshrc" ;;
        bash) RC_FILE="$HOME/.bashrc" ;;
        fish) RC_FILE="$HOME/.config/fish/config.fish" ;;
        *)    RC_FILE="" ;;
    esac

    if [ -n "$RC_FILE" ]; then
        if ask "  Add ~/.local/bin to your PATH?"; then
            if [ "$SHELL_NAME" = "fish" ]; then
                echo "fish_add_path $INSTALL_DIR" >> "$RC_FILE"
            else
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
            fi
            echo -e "  ${GREEN}✓${RESET} Added to ${DIM}${RC_FILE}${RESET}"
            echo -e "  ${DIM}  Run: source ${RC_FILE}${RESET}"
        else
            echo -e "  ${DIM}  Add manually: export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
        fi
    else
        echo -e "  ${BOLD}Add to your PATH:${RESET}"
        echo -e "  ${DIM}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
    fi
fi

# ── Alias suggestion ───────────────────────────────────────

echo ""

SHELL_NAME="$(basename "$SHELL")"
case "$SHELL_NAME" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bashrc" ;;
    fish) RC_FILE="$HOME/.config/fish/config.fish" ;;
    *)    RC_FILE="" ;;
esac

if [ -n "$RC_FILE" ]; then
    if ask "  Add alias 'cs' for quick access?" "n"; then
        if [ "$SHELL_NAME" = "fish" ]; then
            echo "alias cs='claude-sessions'" >> "$RC_FILE"
        else
            echo 'alias cs="claude-sessions"' >> "$RC_FILE"
        fi
        echo -e "  ${GREEN}✓${RESET} Added ${DIM}alias cs=claude-sessions${RESET} to ${DIM}${RC_FILE}${RESET}"
    fi
fi

# ── Done ───────────────────────────────────────────────────

echo ""
echo -e "  ${GREEN}${BOLD}Done!${RESET} Run ${CYAN}claude-sessions${RESET} to get started."
echo ""
