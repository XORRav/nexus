#!/bin/bash
# pipx Python tool installs (isolated environments, no --break-system-packages)

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

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

# Ensure pipx is available
if ! command -v pipx &>/dev/null; then
    run_install "pipx" sudo apt install -y -qq pipx
    pipx ensurepath >> "${NEXUS_LOG_FILE:-/dev/null}" 2>&1
fi

for pkg in "${PIPX_PACKAGES[@]}"; do
    if pipx list 2>/dev/null | grep -qi "$pkg"; then
        skip_ok "$pkg"
    else
        run_install "$pkg" pipx install "$pkg"
    fi
done
