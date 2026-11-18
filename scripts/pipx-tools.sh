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
    info "Installing pipx..."
    sudo apt install -y -qq pipx
    pipx ensurepath
fi

for pkg in "${PIPX_PACKAGES[@]}"; do
    if pipx list 2>/dev/null | grep -qi "$pkg"; then
        info "$pkg: already installed (pipx)"
        track_skipped
    else
        info "Installing $pkg via pipx..."
        if pipx install "$pkg"; then
            track_installed
        else
            warn "Failed to install $pkg"
            track_failed
        fi
    fi
done

info "pipx tools done."
