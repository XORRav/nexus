#!/bin/bash
# C2 frameworks and vulnerability scanner setup

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ---- Sliver C2 ----
if command -v sliver &>/dev/null; then
    skip_ok "Sliver C2"
else
    if curl -fsSL https://sliver.sh/install -o /tmp/sliver-install.sh 2>/dev/null; then
        run_install "Sliver C2" sudo bash /tmp/sliver-install.sh
        rm -f /tmp/sliver-install.sh
    else
        echo -e "  ${RED}[✗]${NC} Sliver C2: download failed"
        _log "[✗] Sliver C2: failed to download installer"
        track_failed
    fi
fi

# ---- Metasploit DB init ----
if sudo -n msfdb status 2>/dev/null | grep -q "running"; then
    skip_ok "Metasploit DB"
else
    run_install "Metasploit DB (init)" sudo msfdb init
fi

# ---- Docker group ----
if groups "$USER" | grep -q docker; then
    skip_ok "docker group"
else
    info "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    warn "Log out and back in for docker group to take effect"
    track_installed
fi
