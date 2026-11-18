#!/bin/bash
# GitHub clones, binary downloads, and release assets

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

TOOLS_DIR="$HOME/htb/tools"

# ---- Helper: get latest GitHub release asset URL ----
get_release_url() {
    local repo="$1"
    local pattern="$2"
    curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | grep "browser_download_url" \
        | grep -i "$pattern" \
        | head -1 \
        | cut -d '"' -f 4
}

# ============================================================
# AD Tools — ~/htb/tools/ad/
# ============================================================

# BloodHound CE (Docker Compose file only)
if [ ! -f "$TOOLS_DIR/ad/bloodhound-ce/docker-compose.yml" ]; then
    info "Downloading BloodHound CE docker-compose.yml..."
    mkdir -p "$TOOLS_DIR/ad/bloodhound-ce"
    if curl -fsSL https://ghst.ly/getbhce -o "$TOOLS_DIR/ad/bloodhound-ce/docker-compose.yml"; then
        info "BloodHound CE ready — start with: cd ~/htb/tools/ad/bloodhound-ce && docker compose up"
        track_installed
    else
        warn "Failed to download BloodHound CE compose file"
        track_failed
    fi
else
    info "BloodHound CE: docker-compose.yml already present"
    track_skipped
fi

# Kerbrute
if [ ! -f "$TOOLS_DIR/ad/kerbrute" ]; then
    info "Downloading Kerbrute..."
    URL=$(get_release_url "ropnop/kerbrute" "linux_amd64")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/kerbrute"
        chmod +x "$TOOLS_DIR/ad/kerbrute"
        track_installed
    else
        warn "Could not find Kerbrute release URL"
        track_failed
    fi
else
    info "Kerbrute: already downloaded"
    track_skipped
fi

# windapsearch
if [ ! -f "$TOOLS_DIR/ad/windapsearch" ]; then
    info "Downloading windapsearch..."
    URL=$(get_release_url "ropnop/go-windapsearch" "linux-amd64")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/windapsearch"
        chmod +x "$TOOLS_DIR/ad/windapsearch"
        track_installed
    else
        warn "Could not find windapsearch release URL"
        track_failed
    fi
else
    info "windapsearch: already downloaded"
    track_skipped
fi

# PKINITtools
if [ ! -d "$TOOLS_DIR/ad/PKINITtools" ]; then
    info "Cloning PKINITtools..."
    if git clone --quiet https://github.com/dirkjanm/PKINITtools.git "$TOOLS_DIR/ad/PKINITtools"; then
        track_installed
    else
        warn "Failed to clone PKINITtools"
        track_failed
    fi
else
    info "PKINITtools: already cloned"
    track_skipped
fi

# krbrelayx
if [ ! -d "$TOOLS_DIR/ad/krbrelayx" ]; then
    info "Cloning krbrelayx..."
    if git clone --quiet https://github.com/dirkjanm/krbrelayx.git "$TOOLS_DIR/ad/krbrelayx"; then
        track_installed
    else
        warn "Failed to clone krbrelayx"
        track_failed
    fi
else
    info "krbrelayx: already cloned"
    track_skipped
fi

# SharpHound
if ! ls "$TOOLS_DIR/ad"/SharpHound*.zip &>/dev/null; then
    info "Downloading SharpHound..."
    URL=$(get_release_url "SpecterOps/SharpHound" "windows")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/SharpHound.zip"
        track_installed
    else
        warn "Could not find SharpHound release URL"
        track_failed
    fi
else
    info "SharpHound: already downloaded"
    track_skipped
fi

# Ghostpack compiled binaries (Rubeus, Seatbelt, Certify)
GHOSTPACK_BASE="https://raw.githubusercontent.com/r3motecontrol/Ghostpack-CompiledBinaries/master"
for binary in Rubeus.exe Seatbelt.exe Certify.exe; do
    if [ ! -f "$TOOLS_DIR/ad/$binary" ]; then
        info "Downloading $binary..."
        if wget -q "$GHOSTPACK_BASE/$binary" -O "$TOOLS_DIR/ad/$binary"; then
            track_installed
        else
            warn "Failed to download $binary"
            track_failed
        fi
    else
        info "$binary: already downloaded"
        track_skipped
    fi
done

# Snaffler
if [ ! -f "$TOOLS_DIR/ad/Snaffler.exe" ]; then
    info "Downloading Snaffler..."
    URL=$(get_release_url "SnaffCon/Snaffler" "Snaffler.exe")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/Snaffler.exe"
        track_installed
    else
        warn "Could not find Snaffler release URL"
        track_failed
    fi
else
    info "Snaffler.exe: already downloaded"
    track_skipped
fi

# Inveigh
if ! ls "$TOOLS_DIR/ad"/Inveigh*.zip &>/dev/null; then
    info "Downloading Inveigh..."
    URL=$(get_release_url "Kevin-Robertson/Inveigh" "net4.6.2")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/Inveigh-net4.6.2.zip"
        track_installed
    else
        warn "Could not find Inveigh release URL"
        track_failed
    fi
else
    info "Inveigh: already downloaded"
    track_skipped
fi

# ============================================================
# Exploitation Tools — ~/htb/tools/exploit/
# ============================================================

# noPac
if [ ! -d "$TOOLS_DIR/exploit/noPac" ]; then
    info "Cloning noPac..."
    if git clone --quiet https://github.com/Ridter/noPac.git "$TOOLS_DIR/exploit/noPac"; then
        track_installed
    else
        warn "Failed to clone noPac"
        track_failed
    fi
else
    info "noPac: already cloned"
    track_skipped
fi

# PrintNightmare
if [ ! -d "$TOOLS_DIR/exploit/PrintNightmare" ]; then
    info "Cloning PrintNightmare..."
    if git clone --quiet https://github.com/cube0x0/CVE-2021-1675.git "$TOOLS_DIR/exploit/PrintNightmare"; then
        track_installed
    else
        warn "Failed to clone PrintNightmare"
        track_failed
    fi
else
    info "PrintNightmare: already cloned"
    track_skipped
fi

# ============================================================
# Post-Exploitation — ~/htb/tools/postex/
# ============================================================

# pspy64
if [ ! -f "$TOOLS_DIR/postex/pspy64" ]; then
    info "Downloading pspy64..."
    URL=$(get_release_url "DominicBreuker/pspy" "pspy64$")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/postex/pspy64"
        chmod +x "$TOOLS_DIR/postex/pspy64"
        track_installed
    else
        warn "Could not find pspy64 release URL"
        track_failed
    fi
else
    info "pspy64: already downloaded"
    track_skipped
fi

# ============================================================
# Pivoting — ~/htb/tools/ligolo/
# ============================================================

# Ligolo-ng proxy (Linux) + agent (Windows)
if [ ! -f "$TOOLS_DIR/ligolo/proxy" ]; then
    info "Downloading Ligolo-ng..."
    PROXY_URL=$(get_release_url "nicocha30/ligolo-ng" "linux_amd64.*\.tar\.gz")
    AGENT_URL=$(get_release_url "nicocha30/ligolo-ng" "windows_amd64.*\.exe")

    if [ -n "$PROXY_URL" ]; then
        wget -q "$PROXY_URL" -O /tmp/ligolo-proxy.tar.gz
        tar xzf /tmp/ligolo-proxy.tar.gz -C "$TOOLS_DIR/ligolo/"
        find "$TOOLS_DIR/ligolo/" -name "*proxy*" -type f ! -name "proxy" -exec mv {} "$TOOLS_DIR/ligolo/proxy" \; 2>/dev/null
        chmod +x "$TOOLS_DIR/ligolo/proxy"
        rm -f /tmp/ligolo-proxy.tar.gz
        track_installed
    else
        warn "Could not find Ligolo proxy release URL"
        track_failed
    fi

    if [ -n "$AGENT_URL" ]; then
        wget -q "$AGENT_URL" -O "$TOOLS_DIR/ligolo/agent.exe"
        track_installed
    else
        warn "Could not find Ligolo agent release URL"
        track_failed
    fi
else
    info "Ligolo-ng: already downloaded"
    track_skipped
fi

# ============================================================
# Web Tools — ~/htb/tools/web/
# ============================================================

# Username Anarchy
if [ ! -d "$TOOLS_DIR/web/username-anarchy" ]; then
    info "Cloning Username Anarchy..."
    if git clone --quiet https://github.com/urbanadventurer/username-anarchy.git "$TOOLS_DIR/web/username-anarchy"; then
        track_installed
    else
        warn "Failed to clone Username Anarchy"
        track_failed
    fi
else
    info "Username Anarchy: already cloned"
    track_skipped
fi

# cupp
if [ ! -d "$TOOLS_DIR/web/cupp" ]; then
    info "Cloning cupp..."
    if git clone --quiet https://github.com/Mebus/cupp.git "$TOOLS_DIR/web/cupp"; then
        track_installed
    else
        warn "Failed to clone cupp"
        track_failed
    fi
else
    info "cupp: already cloned"
    track_skipped
fi

info "GitHub tools done."
