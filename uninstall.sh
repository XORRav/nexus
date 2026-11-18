#!/bin/bash
# ============================================================
# Nexus — Uninstall / Cleanup
# Reverses what install.sh set up. Safe to run multiple times.
# Usage: ./uninstall.sh [--force] [--apt] [--all]
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[-]${NC} $1"; }
section() { echo -e "\n${CYAN}[===]${NC} $1 ${CYAN}[===]${NC}\n"; }

TOOLS_DIR="$HOME/htb/tools"
FORCE=false
REMOVE_APT=false
REMOVE_ALL=false

for arg in "$@"; do
    case "$arg" in
        --force|-f) FORCE=true ;;
        --apt)      REMOVE_APT=true ;;
        --all)      REMOVE_ALL=true; REMOVE_APT=true ;;
        --help|-h)
            echo "Usage: ./uninstall.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --force, -f   Skip confirmation prompt"
            echo "  --apt         Also remove APT packages installed by Nexus"
            echo "  --all         Remove everything including APT packages and ~/htb/"
            echo "  --help, -h    Show this help"
            exit 0
            ;;
        *)
            error "Unknown option: $arg"
            echo "Run ./uninstall.sh --help for usage."
            exit 1
            ;;
    esac
done

echo -e "${CYAN}"
echo "  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗"
echo "  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝"
echo "  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗"
echo "  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║"
echo "  ██║ ╚████║███████╗██╔╝ ╚██╗╚██████╔╝███████║"
echo "  ╚═╝  ╚═══╝╚══════╝╚═╝   ╚═╝ ╚═════╝ ╚══════╝"
echo -e "${NC}"
echo -e "${RED}  Uninstall — Remove Nexus Toolkit${NC}"
echo ""

if [ "$EUID" -eq 0 ]; then
    error "Don't run as root. The script uses sudo where needed."
    exit 1
fi

if [ "$FORCE" != true ]; then
    echo -e "${YELLOW}This will remove:${NC}"
    echo "  - ~/htb/tools/ (all downloaded tools, clones, binaries)"
    echo "  - pipx packages (certipy, bloodyad, coercer, etc.)"
    echo "  - Rust toolchain (~/.cargo, ~/.rustup)"
    echo "  - Sliver C2"
    echo "  - JetBrainsMono Nerd Font"
    echo "  - Nexus additions from ~/.zshrc (aliases, fzf bindings)"
    echo "  - ~/.tmux.conf"
    echo "  - OneRuleToRuleThemAll hashcat rule"
    if [ "$REMOVE_APT" = true ]; then
        echo "  - APT packages: rlwrap, jq, fzf, bat, ripgrep, gvm, xsel"
    fi
    if [ "$REMOVE_ALL" = true ]; then
        echo "  - ~/htb/ entirely (including scripts/ and vpn/)"
    fi
    echo ""
    echo -e "${YELLOW}This will NOT remove:${NC}"
    if [ "$REMOVE_ALL" != true ]; then
        echo "  - ~/htb/scripts/ and ~/htb/vpn/ (your work)"
    fi
    if [ "$REMOVE_APT" != true ]; then
        echo "  - APT packages (use --apt to include them)"
    fi
    echo "  - zsh as default shell (change manually: chsh -s /bin/bash)"
    echo "  - Docker group membership"
    echo "  - Metasploit database"
    echo ""
    read -rp "Continue? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# ============================================================
# pipx packages
# ============================================================
section "Removing pipx packages"

PIPX_PACKAGES=(
    certipy-ad
    bloodyad
    adidnsdump
    ldapdomaindump
    coercer
    pypykatz
    wesng
    droopescan
)

if command -v pipx &>/dev/null; then
    for pkg in "${PIPX_PACKAGES[@]}"; do
        if pipx list 2>/dev/null | grep -qi "$pkg"; then
            info "Removing $pkg..."
            pipx uninstall "$pkg" || warn "Failed to uninstall $pkg"
        else
            info "$pkg: not installed"
        fi
    done
else
    info "pipx not found, skipping"
fi

# ============================================================
# Tools directory
# ============================================================
section "Removing tools directory"

if [ -d "$TOOLS_DIR" ]; then
    info "Removing $TOOLS_DIR..."
    rm -rf "$TOOLS_DIR"
else
    info "$TOOLS_DIR: does not exist"
fi

if [ "$REMOVE_ALL" = true ]; then
    if [ -d "$HOME/htb" ]; then
        info "Removing ~/htb/ entirely..."
        rm -rf "$HOME/htb"
    fi
else
    if [ -d "$HOME/htb" ]; then
        info "Keeping ~/htb/scripts/ and ~/htb/vpn/ (your work)"
        rmdir "$HOME/htb" 2>/dev/null && info "Removed empty ~/htb/" || true
    fi
fi

# ============================================================
# Rust toolchain
# ============================================================
section "Removing Rust toolchain"

if [ -f "$HOME/.cargo/bin/rustup" ]; then
    info "Uninstalling Rust via rustup..."
    "$HOME/.cargo/bin/rustup" self uninstall -y
elif [ -d "$HOME/.cargo" ] || [ -d "$HOME/.rustup" ]; then
    info "Removing leftover Rust directories..."
    rm -rf "$HOME/.cargo" "$HOME/.rustup"
else
    info "Rust: not installed"
fi

# ============================================================
# Sliver C2
# ============================================================
section "Removing Sliver C2"

if command -v sliver &>/dev/null; then
    info "Removing Sliver binary..."
    sudo rm -f "$(command -v sliver)"
    sudo rm -f "$(command -v sliver-server)" 2>/dev/null
    if [ -d "$HOME/.sliver-client" ]; then
        rm -rf "$HOME/.sliver-client"
        info "Removed ~/.sliver-client"
    fi
    if [ -d "/root/.sliver" ]; then
        sudo rm -rf /root/.sliver
        info "Removed /root/.sliver"
    fi
else
    info "Sliver: not installed"
fi

# ============================================================
# JetBrainsMono Nerd Font
# ============================================================
section "Removing JetBrainsMono Nerd Font"

FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
if [ -d "$FONT_DIR" ]; then
    info "Removing $FONT_DIR..."
    rm -rf "$FONT_DIR"
    fc-cache -f 2>/dev/null
else
    info "JetBrainsMono Nerd Font: not installed"
fi

# ============================================================
# zshrc additions
# ============================================================
section "Cleaning ~/.zshrc additions"

ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    CHANGED=false

    # Remove fzf keybindings block
    if grep -qF "fzf/examples/key-bindings.zsh" "$ZSHRC"; then
        sed -i '/^# fzf keybindings$/d' "$ZSHRC"
        sed -i '/fzf\/examples\/key-bindings\.zsh/d' "$ZSHRC"
        info "Removed fzf keybindings"
        CHANGED=true
    fi

    # Remove bat alias block
    if grep -qF "alias bat='batcat'" "$ZSHRC"; then
        sed -i '/^# bat alias$/d' "$ZSHRC"
        sed -i "/alias bat='batcat'/d" "$ZSHRC"
        info "Removed bat alias"
        CHANGED=true
    fi

    # Remove pentesting aliases block
    if grep -qF "alias listen=" "$ZSHRC"; then
        sed -i '/^# Pentesting aliases$/d' "$ZSHRC"
        sed -i "/alias listen='rlwrap nc -lvnp'/d" "$ZSHRC"
        sed -i "/alias serve='python3 -m http.server 80'/d" "$ZSHRC"
        info "Removed pentesting aliases"
        CHANGED=true
    fi

    # Clean up leftover blank lines (collapse multiple consecutive blank lines to one)
    if [ "$CHANGED" = true ]; then
        sed -i '/^$/N;/^\n$/d' "$ZSHRC"
        info "Cleaned up blank lines in .zshrc"
    fi
else
    info ".zshrc: not found"
fi

# ============================================================
# tmux config
# ============================================================
section "Removing tmux config"

if [ -f "$HOME/.tmux.conf" ]; then
    info "Removing ~/.tmux.conf..."
    rm -f "$HOME/.tmux.conf"
else
    info "~/.tmux.conf: does not exist"
fi

# ============================================================
# Hashcat rule
# ============================================================
section "Removing custom hashcat rule"

RULE="/usr/share/hashcat/rules/OneRuleToRuleThemAll.rule"
if [ -f "$RULE" ]; then
    info "Removing OneRuleToRuleThemAll.rule..."
    sudo rm -f "$RULE"
else
    info "OneRuleToRuleThemAll.rule: not present"
fi

# ============================================================
# APT packages (optional)
# ============================================================
if [ "$REMOVE_APT" = true ]; then
    section "Removing APT packages"

    APT_PACKAGES=(rlwrap jq fzf bat ripgrep seclists gvm xsel)

    for pkg in "${APT_PACKAGES[@]}"; do
        if dpkg -s "$pkg" &>/dev/null; then
            info "Removing $pkg..."
            sudo apt remove -y -qq "$pkg"
        else
            info "$pkg: not installed"
        fi
    done

    info "Running apt autoremove..."
    sudo apt autoremove -y -qq
else
    section "Skipping APT packages (use --apt to remove)"
fi

# ============================================================
# Summary
# ============================================================
section "Uninstall Complete"

info "Nexus toolkit has been removed."
echo ""
warn "Manual steps you may want to take:"
echo "  1. Switch shell back to bash: chsh -s /bin/bash"
echo "  2. Remove docker group: sudo gpasswd -d $USER docker"
echo "  3. Reset Metasploit DB: sudo msfdb delete"
echo "  4. Log out and back in for group changes to take effect"
echo ""
info "Done."
