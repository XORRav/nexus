#!/bin/bash
# ============================================================
# Nexus — Kali Linux Pentesting Toolkit Bootstrap
# Run: chmod +x install.sh && ./install.sh
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$HOME/htb/tools"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

banner() {
    echo -e "${CYAN}"
    echo "  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗"
    echo "  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝"
    echo "  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗"
    echo "  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║"
    echo "  ██║ ╚████║███████╗██╔╝ ╚██╗╚██████╔╝███████║"
    echo "  ╚═╝  ╚═══╝╚══════╝╚═╝   ╚═╝ ╚═════╝ ╚══════╝"
    echo -e "${NC}"
    echo -e "${YELLOW}  Kali Linux Pentesting Toolkit Bootstrap${NC}"
    echo ""
}

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[-]${NC} $1"; }
section() { echo -e "\n${CYAN}[===]${NC} $1 ${CYAN}[===]${NC}\n"; }

banner

# Check running as normal user (not root)
if [ "$EUID" -eq 0 ]; then
    error "Don't run as root. The script uses sudo where needed."
    exit 1
fi

# ---- Directory Structure ----
section "Creating directory structure"
mkdir -p "$HOME/htb"/{scripts,vpn}
mkdir -p "$TOOLS_DIR"/{ad,exploit,postex,ligolo,pivot,web,wordlists}
info "Created ~/htb/tools/ structure"

# ---- Run each module ----
section "APT Tools"
bash "$SCRIPT_DIR/scripts/apt-tools.sh"

section "Terminal Setup"
bash "$SCRIPT_DIR/scripts/terminal-setup.sh"

section "pipx Tools"
bash "$SCRIPT_DIR/scripts/pipx-tools.sh"

section "GitHub Tools & Binaries"
bash "$SCRIPT_DIR/scripts/github-tools.sh"

section "Build Tools (Rust)"
bash "$SCRIPT_DIR/scripts/build-tools.sh"

section "C2 & Framework Setup"
bash "$SCRIPT_DIR/scripts/c2-setup.sh"

# ---- Summary ----
section "Setup Complete"
info "Tools installed to: ~/htb/tools/"
info "Shell: zsh (log out and back in if still on bash)"
info "Font: JetBrainsMono Nerd Font (set in QTerminal)"
echo ""
warn "Manual steps remaining:"
echo "  1. Log out and back in (for zsh + docker group)"
echo "  2. Set font in QTerminal: File > Preferences > Appearance"
echo "     Font: JetBrainsMono Nerd Font, Size: 11"
echo "  3. Run 'sudo gvm-setup' if you need OpenVAS (takes a long time)"
echo "  4. Register for Nessus at https://www.tenable.com/products/nessus/nessus-essentials"
echo "  5. Take a VMware snapshot!"
echo ""
info "Done. Happy hacking!"
