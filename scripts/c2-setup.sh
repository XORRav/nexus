#!/bin/bash
# C2 frameworks and vulnerability scanner setup

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ---- Sliver C2 ----
if command -v sliver &>/dev/null; then
    info "Sliver: already installed"
    track_skipped
else
    info "Installing Sliver C2..."
    if curl -fsSL https://sliver.sh/install -o /tmp/sliver-install.sh; then
        if sudo bash /tmp/sliver-install.sh; then
            track_installed
        else
            warn "Sliver install script failed"
            track_failed
        fi
        rm -f /tmp/sliver-install.sh
    else
        warn "Failed to download Sliver installer — check internet connection"
        track_failed
    fi
fi

# ---- Metasploit DB init ----
if sudo -n msfdb status 2>/dev/null | grep -q "running"; then
    info "Metasploit DB: already initialized"
    track_skipped
else
    info "Initializing Metasploit database..."
    if sudo msfdb init; then
        track_installed
    else
        warn "Failed to initialize Metasploit DB"
        track_failed
    fi
fi

# ---- Docker group ----
if groups "$USER" | grep -q docker; then
    info "User already in docker group"
    track_skipped
else
    info "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    warn "Log out and back in for docker group to take effect"
    track_installed
fi

info "C2 setup done."
