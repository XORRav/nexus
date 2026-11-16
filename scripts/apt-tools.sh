#!/bin/bash
# APT package installs

source "$(dirname "${BASH_SOURCE[0]}")/../install.sh" 2>/dev/null || true

info() { echo -e "\033[0;32m[+]\033[0m $1"; }
warn() { echo -e "\033[1;33m[!]\033[0m $1"; }

APT_PACKAGES=(
    # Utilities
    rlwrap
    jq
    fzf
    bat
    ripgrep
    # Wordlists
    seclists
    # Scanners
    gvm
)

info "Updating apt cache..."
sudo apt update -qq

for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -l "$pkg" &>/dev/null; then
        info "$pkg: already installed"
    else
        info "Installing $pkg..."
        sudo apt install -y -qq "$pkg"
    fi
done

# Decompress rockyou.txt if still gzipped
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
    info "Decompressing rockyou.txt..."
    sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
else
    info "rockyou.txt: already decompressed"
fi

# Download OneRuleToRuleThemAll if missing
if [ ! -f /usr/share/hashcat/rules/OneRuleToRuleThemAll.rule ]; then
    info "Downloading OneRuleToRuleThemAll hashcat rule..."
    sudo wget -q -P /usr/share/hashcat/rules/ \
        https://raw.githubusercontent.com/NotSoSecure/password_cracking_rules/master/OneRuleToRuleThemAll.rule
else
    info "OneRuleToRuleThemAll.rule: already present"
fi

info "APT tools done."
