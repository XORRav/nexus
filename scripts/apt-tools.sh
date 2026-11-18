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
run_cmd sudo apt update -qq

for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -s "$pkg" &>/dev/null; then
        skip_ok "$pkg"
    else
        run_install "$pkg" sudo apt install -y -qq "$pkg"
    fi
done

# Decompress rockyou.txt if still gzipped
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
    run_install "rockyou.txt (decompress)" sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
else
    skip_ok "rockyou.txt"
fi

# Download OneRuleToRuleThemAll if missing
if [ ! -f /usr/share/hashcat/rules/OneRuleToRuleThemAll.rule ]; then
    run_install "OneRuleToRuleThemAll.rule" sudo wget -q -P /usr/share/hashcat/rules/ \
        https://raw.githubusercontent.com/NotSoSecure/password_cracking_rules/master/OneRuleToRuleThemAll.rule
else
    skip_ok "OneRuleToRuleThemAll.rule"
fi
