#!/bin/bash
# C2 frameworks and vulnerability scanner setup

info() { echo -e "\033[0;32m[+]\033[0m $1"; }
warn() { echo -e "\033[1;33m[!]\033[0m $1"; }

# ---- Sliver C2 ----
if command -v sliver &>/dev/null; then
    info "Sliver: already installed"
else
    info "Installing Sliver C2..."
    curl https://sliver.sh/install | sudo bash
fi

# ---- Metasploit DB init ----
if sudo -n msfdb status 2>/dev/null | grep -q "running"; then
    info "Metasploit DB: already initialized"
else
    info "Initializing Metasploit database..."
    sudo msfdb init
fi

# ---- Docker group ----
if groups "$USER" | grep -q docker; then
    info "User already in docker group"
else
    info "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    warn "Log out and back in for docker group to take effect"
fi

info "C2 setup done."
