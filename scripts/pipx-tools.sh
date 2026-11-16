#!/bin/bash
# pipx Python tool installs (isolated environments, no --break-system-packages)

info() { echo -e "\033[0;32m[+]\033[0m $1"; }

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
    info "Installing pipx..."
    sudo apt install -y -qq pipx
    pipx ensurepath
fi

for pkg in "${PIPX_PACKAGES[@]}"; do
    if pipx list 2>/dev/null | grep -qi "$pkg"; then
        info "$pkg: already installed (pipx)"
    else
        info "Installing $pkg via pipx..."
        pipx install "$pkg"
    fi
done

info "pipx tools done."
