#!/bin/bash
# APT package installs

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

APT_PACKAGES=(
    rlwrap
    jq
    fzf
    bat
    ripgrep
    seclists
    gvm
)

info "Updating apt cache..."
sudo apt update -qq

for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -s "$pkg" &>/dev/null; then
        info "$pkg: already installed"
        track_skipped
    else
        info "Installing $pkg..."
        if sudo apt install -y -qq "$pkg"; then
            track_installed
        else
            warn "Failed to install $pkg"
            track_failed
        fi
    fi
done

# Decompress rockyou.txt if still gzipped
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
    info "Decompressing rockyou.txt..."
    sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
    track_installed
else
    info "rockyou.txt: already decompressed"
    track_skipped
fi

# Download OneRuleToRuleThemAll if missing
if [ ! -f /usr/share/hashcat/rules/OneRuleToRuleThemAll.rule ]; then
    info "Downloading OneRuleToRuleThemAll hashcat rule..."
    if sudo wget -q -P /usr/share/hashcat/rules/ \
        https://raw.githubusercontent.com/NotSoSecure/password_cracking_rules/master/OneRuleToRuleThemAll.rule; then
        track_installed
    else
        warn "Failed to download OneRuleToRuleThemAll.rule"
        track_failed
    fi
else
    info "OneRuleToRuleThemAll.rule: already present"
    track_skipped
fi

info "APT tools done."
