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

# Download a GitHub release binary. Cleans up partial files on failure.
download_release() {
    local name="$1"
    local dest="$2"
    local repo="$3"
    local pattern="$4"
    local make_exec="${5:-false}"

    local url
    url=$(get_release_url "$repo" "$pattern")

    if [ -z "$url" ]; then
        echo -e "  ${RED}[✗]${NC} $name: GitHub release not found"
        _log "[✗] $name: release URL not found ($repo / $pattern)"
        track_failed
        return 1
    fi

    if run_install "$name" wget -q "$url" -O "$dest"; then
        [ "$make_exec" = true ] && chmod +x "$dest"
        return 0
    else
        rm -f "$dest"
        return 1
    fi
}

# ============================================================
# AD Tools — ~/htb/tools/ad/
# ============================================================

# BloodHound CE (Docker Compose file only)
if [ ! -f "$TOOLS_DIR/ad/bloodhound-ce/docker-compose.yml" ]; then
    mkdir -p "$TOOLS_DIR/ad/bloodhound-ce"
    run_install "BloodHound CE (compose)" curl -fsSL https://ghst.ly/getbhce \
        -o "$TOOLS_DIR/ad/bloodhound-ce/docker-compose.yml"
else
    skip_ok "BloodHound CE"
fi

# Kerbrute
if [ ! -f "$TOOLS_DIR/ad/kerbrute" ]; then
    download_release "Kerbrute" "$TOOLS_DIR/ad/kerbrute" "ropnop/kerbrute" "linux_amd64" true
else
    skip_ok "Kerbrute"
fi

# windapsearch
if [ ! -f "$TOOLS_DIR/ad/windapsearch" ]; then
    download_release "windapsearch" "$TOOLS_DIR/ad/windapsearch" "ropnop/go-windapsearch" "linux-amd64" true
else
    skip_ok "windapsearch"
fi

# PKINITtools
if [ ! -d "$TOOLS_DIR/ad/PKINITtools" ]; then
    run_install "PKINITtools" git clone --quiet https://github.com/dirkjanm/PKINITtools.git "$TOOLS_DIR/ad/PKINITtools"
else
    skip_ok "PKINITtools"
fi

# krbrelayx
if [ ! -d "$TOOLS_DIR/ad/krbrelayx" ]; then
    run_install "krbrelayx" git clone --quiet https://github.com/dirkjanm/krbrelayx.git "$TOOLS_DIR/ad/krbrelayx"
else
    skip_ok "krbrelayx"
fi

# SharpHound
if ! ls "$TOOLS_DIR/ad"/SharpHound*.zip &>/dev/null; then
    download_release "SharpHound" "$TOOLS_DIR/ad/SharpHound.zip" "SpecterOps/SharpHound" "windows"
else
    skip_ok "SharpHound"
fi

# Ghostpack compiled binaries (Rubeus, Seatbelt, Certify)
GHOSTPACK_BASE="https://raw.githubusercontent.com/r3motecontrol/Ghostpack-CompiledBinaries/master"
for binary in Rubeus.exe Seatbelt.exe Certify.exe; do
    if [ ! -f "$TOOLS_DIR/ad/$binary" ]; then
        if ! run_install "$binary" wget -q "$GHOSTPACK_BASE/$binary" -O "$TOOLS_DIR/ad/$binary"; then
            rm -f "$TOOLS_DIR/ad/$binary"
        fi
    else
        skip_ok "$binary"
    fi
done

# Snaffler
if [ ! -f "$TOOLS_DIR/ad/Snaffler.exe" ]; then
    download_release "Snaffler" "$TOOLS_DIR/ad/Snaffler.exe" "SnaffCon/Snaffler" "Snaffler.exe"
else
    skip_ok "Snaffler"
fi

# Inveigh
if ! ls "$TOOLS_DIR/ad"/Inveigh*.zip &>/dev/null; then
    download_release "Inveigh" "$TOOLS_DIR/ad/Inveigh-net4.6.2.zip" "Kevin-Robertson/Inveigh" "net4.6.2"
else
    skip_ok "Inveigh"
fi

# ============================================================
# Exploitation Tools — ~/htb/tools/exploit/
# ============================================================

# noPac
if [ ! -d "$TOOLS_DIR/exploit/noPac" ]; then
    run_install "noPac" git clone --quiet https://github.com/Ridter/noPac.git "$TOOLS_DIR/exploit/noPac"
else
    skip_ok "noPac"
fi

# PrintNightmare
if [ ! -d "$TOOLS_DIR/exploit/PrintNightmare" ]; then
    run_install "PrintNightmare" git clone --quiet https://github.com/cube0x0/CVE-2021-1675.git "$TOOLS_DIR/exploit/PrintNightmare"
else
    skip_ok "PrintNightmare"
fi

# ============================================================
# Post-Exploitation — ~/htb/tools/postex/
# ============================================================

# pspy64
if [ ! -f "$TOOLS_DIR/postex/pspy64" ]; then
    download_release "pspy64" "$TOOLS_DIR/postex/pspy64" "DominicBreuker/pspy" "pspy64$" true
else
    skip_ok "pspy64"
fi

# ============================================================
# Pivoting — ~/htb/tools/ligolo/
# ============================================================

if [ ! -f "$TOOLS_DIR/ligolo/proxy" ]; then
    PROXY_URL=$(get_release_url "nicocha30/ligolo-ng" "linux_amd64.*\.tar\.gz")
    AGENT_URL=$(get_release_url "nicocha30/ligolo-ng" "windows_amd64.*\.exe")

    if [ -n "$PROXY_URL" ]; then
        if run_install "Ligolo-ng proxy" wget -q "$PROXY_URL" -O /tmp/ligolo-proxy.tar.gz; then
            tar xzf /tmp/ligolo-proxy.tar.gz -C "$TOOLS_DIR/ligolo/"
            find "$TOOLS_DIR/ligolo/" -name "*proxy*" -type f ! -name "proxy" \
                -exec mv {} "$TOOLS_DIR/ligolo/proxy" \; 2>/dev/null
            chmod +x "$TOOLS_DIR/ligolo/proxy"
            rm -f /tmp/ligolo-proxy.tar.gz
        else
            rm -f /tmp/ligolo-proxy.tar.gz
        fi
    else
        echo -e "  ${RED}[✗]${NC} Ligolo-ng proxy: GitHub release not found"
        track_failed
    fi

    if [ -n "$AGENT_URL" ]; then
        if ! run_install "Ligolo-ng agent" wget -q "$AGENT_URL" -O "$TOOLS_DIR/ligolo/agent.exe"; then
            rm -f "$TOOLS_DIR/ligolo/agent.exe"
        fi
    else
        echo -e "  ${RED}[✗]${NC} Ligolo-ng agent: GitHub release not found"
        track_failed
    fi
else
    skip_ok "Ligolo-ng"
fi

# ============================================================
# Web Tools — ~/htb/tools/web/
# ============================================================

# Username Anarchy
if [ ! -d "$TOOLS_DIR/web/username-anarchy" ]; then
    run_install "Username Anarchy" git clone --quiet https://github.com/urbanadventurer/username-anarchy.git "$TOOLS_DIR/web/username-anarchy"
else
    skip_ok "Username Anarchy"
fi

# cupp
if [ ! -d "$TOOLS_DIR/web/cupp" ]; then
    run_install "cupp" git clone --quiet https://github.com/Mebus/cupp.git "$TOOLS_DIR/web/cupp"
else
    skip_ok "cupp"
fi
