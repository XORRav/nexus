#!/bin/bash
# GitHub clones, binary downloads, and release assets

info() { echo -e "\033[0;32m[+]\033[0m $1"; }
warn() { echo -e "\033[1;33m[!]\033[0m $1"; }

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

# BloodHound CE (Docker)
if [ ! -d "$TOOLS_DIR/ad/BloodHound" ]; then
    info "Cloning BloodHound CE..."
    git clone https://github.com/SpecterOps/BloodHound.git "$TOOLS_DIR/ad/BloodHound"
else
    info "BloodHound CE: already cloned"
fi

# Kerbrute
if [ ! -f "$TOOLS_DIR/ad/kerbrute" ]; then
    info "Downloading Kerbrute..."
    URL=$(get_release_url "ropnop/kerbrute" "linux_amd64")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/kerbrute"
        chmod +x "$TOOLS_DIR/ad/kerbrute"
    else
        warn "Could not find Kerbrute release URL"
    fi
else
    info "Kerbrute: already downloaded"
fi

# windapsearch
if [ ! -f "$TOOLS_DIR/ad/windapsearch" ]; then
    info "Downloading windapsearch..."
    URL=$(get_release_url "ropnop/go-windapsearch" "linux-amd64")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/windapsearch"
        chmod +x "$TOOLS_DIR/ad/windapsearch"
    else
        warn "Could not find windapsearch release URL"
    fi
else
    info "windapsearch: already downloaded"
fi

# PKINITtools
if [ ! -d "$TOOLS_DIR/ad/PKINITtools" ]; then
    info "Cloning PKINITtools..."
    git clone https://github.com/dirkjanm/PKINITtools.git "$TOOLS_DIR/ad/PKINITtools"
else
    info "PKINITtools: already cloned"
fi

# krbrelayx
if [ ! -d "$TOOLS_DIR/ad/krbrelayx" ]; then
    info "Cloning krbrelayx..."
    git clone https://github.com/dirkjanm/krbrelayx.git "$TOOLS_DIR/ad/krbrelayx"
else
    info "krbrelayx: already cloned"
fi

# SharpHound
if ! ls "$TOOLS_DIR/ad"/SharpHound*.zip &>/dev/null; then
    info "Downloading SharpHound..."
    URL=$(get_release_url "SpecterOps/SharpHound" "windows")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/SharpHound.zip"
    else
        warn "Could not find SharpHound release URL"
    fi
else
    info "SharpHound: already downloaded"
fi

# Ghostpack compiled binaries (Rubeus, Seatbelt, Certify)
GHOSTPACK_BASE="https://raw.githubusercontent.com/r3motecontrol/Ghostpack-CompiledBinaries/master"
for binary in Rubeus.exe Seatbelt.exe Certify.exe; do
    if [ ! -f "$TOOLS_DIR/ad/$binary" ]; then
        info "Downloading $binary..."
        wget -q "$GHOSTPACK_BASE/$binary" -O "$TOOLS_DIR/ad/$binary" || warn "Failed to download $binary"
    else
        info "$binary: already downloaded"
    fi
done

# Snaffler
if [ ! -f "$TOOLS_DIR/ad/Snaffler.exe" ]; then
    info "Downloading Snaffler..."
    URL=$(get_release_url "SnaffCon/Snaffler" "Snaffler.exe")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/Snaffler.exe"
    else
        warn "Could not find Snaffler release URL"
    fi
else
    info "Snaffler.exe: already downloaded"
fi

# Inveigh
if ! ls "$TOOLS_DIR/ad"/Inveigh*.zip &>/dev/null; then
    info "Downloading Inveigh..."
    URL=$(get_release_url "Kevin-Robertson/Inveigh" "net4.6.2")
    if [ -n "$URL" ]; then
        wget -q "$URL" -O "$TOOLS_DIR/ad/Inveigh-net4.6.2.zip"
    else
        warn "Could not find Inveigh release URL"
    fi
else
    info "Inveigh: already downloaded"
fi

# ============================================================
# Exploitation Tools — ~/htb/tools/exploit/
# ============================================================

# noPac
if [ ! -d "$TOOLS_DIR/exploit/noPac" ]; then
    info "Cloning noPac..."
    git clone https://github.com/Ridter/noPac.git "$TOOLS_DIR/exploit/noPac"
else
    info "noPac: already cloned"
fi

# PrintNightmare
if [ ! -d "$TOOLS_DIR/exploit/PrintNightmare" ]; then
    info "Cloning PrintNightmare..."
    git clone https://github.com/cube0x0/CVE-2021-1675.git "$TOOLS_DIR/exploit/PrintNightmare"
else
    info "PrintNightmare: already cloned"
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
    else
        warn "Could not find pspy64 release URL"
    fi
else
    info "pspy64: already downloaded"
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
        # Rename to clean name if needed
        find "$TOOLS_DIR/ligolo/" -name "*proxy*" -type f ! -name "proxy" -exec mv {} "$TOOLS_DIR/ligolo/proxy" \; 2>/dev/null
        chmod +x "$TOOLS_DIR/ligolo/proxy"
        rm -f /tmp/ligolo-proxy.tar.gz
    else
        warn "Could not find Ligolo proxy release URL"
    fi

    if [ -n "$AGENT_URL" ]; then
        wget -q "$AGENT_URL" -O "$TOOLS_DIR/ligolo/agent.exe"
    else
        warn "Could not find Ligolo agent release URL"
    fi
else
    info "Ligolo-ng: already downloaded"
fi

# ============================================================
# Web Tools — ~/htb/tools/web/
# ============================================================

# Username Anarchy
if [ ! -d "$TOOLS_DIR/web/username-anarchy" ]; then
    info "Cloning Username Anarchy..."
    git clone https://github.com/urbanadventurer/username-anarchy.git "$TOOLS_DIR/web/username-anarchy"
else
    info "Username Anarchy: already cloned"
fi

# cupp
if [ ! -d "$TOOLS_DIR/web/cupp" ]; then
    info "Cloning cupp..."
    git clone https://github.com/Mebus/cupp.git "$TOOLS_DIR/web/cupp"
else
    info "cupp: already cloned"
fi

info "GitHub tools done."
