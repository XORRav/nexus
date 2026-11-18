#!/bin/bash
# ============================================================
# Nexus — Kali Linux Pentesting Toolkit Bootstrap
# Run: chmod +x install.sh && ./install.sh
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$HOME/htb/tools"
LOG_FILE="$HOME/.nexus-install.log"
VERBOSE=false

for arg in "$@"; do
    case "$arg" in
        --verbose|-v) VERBOSE=true ;;
        --help|-h)
            echo "Usage: ./install.sh [--verbose|-v]"
            echo "  --verbose   Show full command output alongside tool status"
            exit 0
            ;;
    esac
done

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

banner() {
    echo ""
    echo -e "${CYAN}"
    echo "  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗"
    echo "  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝"
    echo "  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗"
    echo "  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║"
    echo "  ██║ ╚████║███████╗██╔╝ ╚██╗╚██████╔╝███████║"
    echo "  ╚═╝  ╚═══╝╚══════╝╚═╝   ╚═╝ ╚═════╝ ╚══════╝"
    echo -e "${NC}"
    echo -e "  ${BOLD}Kali Linux Pentesting Toolkit Bootstrap${NC}"
    if [ "$VERBOSE" != true ]; then
        echo -e "  ${DIM}Use --verbose for full command output${NC}"
    fi
    echo ""
}

cleanup() { tput cnorm 2>/dev/null; }
trap cleanup EXIT INT TERM

# ---- Pre-flight scan ----
precheck() {
    local found=()
    local missing=()
    local t="$TOOLS_DIR"

    # APT packages
    for pkg in rlwrap jq fzf bat ripgrep seclists gvm; do
        dpkg -s "$pkg" &>/dev/null && found+=("$pkg") || missing+=("$pkg")
    done

    # Wordlists / rules
    [ -f /usr/share/wordlists/rockyou.txt ] && found+=("rockyou.txt") || missing+=("rockyou.txt")
    [ -f /usr/share/hashcat/rules/OneRuleToRuleThemAll.rule ] && found+=("OneRuleToRuleThemAll") || missing+=("OneRuleToRuleThemAll")

    # Terminal
    [ "$(basename "$SHELL")" = "zsh" ] && found+=("zsh") || missing+=("zsh")
    fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd" && found+=("Nerd Font") || missing+=("Nerd Font")
    command -v xsel &>/dev/null && found+=("xsel") || missing+=("xsel")
    [ -f "$HOME/.tmux.conf" ] && found+=("tmux config") || missing+=("tmux config")

    # pipx packages (one pipx list call, check against it)
    local pipx_out=""
    command -v pipx &>/dev/null && pipx_out=$(pipx list 2>/dev/null)
    for pkg in certipy-ad bloodyad adidnsdump ldapdomaindump coercer pypykatz wesng droopescan; do
        echo "$pipx_out" | grep -qi "$pkg" && found+=("$pkg") || missing+=("$pkg")
    done

    # GitHub tools
    [ -f "$t/ad/bloodhound-ce/docker-compose.yml" ] && found+=("BloodHound CE") || missing+=("BloodHound CE")
    [ -f "$t/ad/kerbrute" ] && found+=("Kerbrute") || missing+=("Kerbrute")
    [ -f "$t/ad/windapsearch" ] && found+=("windapsearch") || missing+=("windapsearch")
    [ -d "$t/ad/PKINITtools" ] && found+=("PKINITtools") || missing+=("PKINITtools")
    [ -d "$t/ad/krbrelayx" ] && found+=("krbrelayx") || missing+=("krbrelayx")
    ls "$t/ad"/SharpHound*.zip &>/dev/null && found+=("SharpHound") || missing+=("SharpHound")
    [ -f "$t/ad/Rubeus.exe" ] && found+=("Rubeus") || missing+=("Rubeus")
    [ -f "$t/ad/Seatbelt.exe" ] && found+=("Seatbelt") || missing+=("Seatbelt")
    [ -f "$t/ad/Certify.exe" ] && found+=("Certify") || missing+=("Certify")
    [ -f "$t/ad/Snaffler.exe" ] && found+=("Snaffler") || missing+=("Snaffler")
    ls "$t/ad"/Inveigh*.zip &>/dev/null && found+=("Inveigh") || missing+=("Inveigh")
    [ -d "$t/exploit/noPac" ] && found+=("noPac") || missing+=("noPac")
    [ -d "$t/exploit/PrintNightmare" ] && found+=("PrintNightmare") || missing+=("PrintNightmare")
    [ -f "$t/postex/pspy64" ] && found+=("pspy64") || missing+=("pspy64")
    [ -f "$t/ligolo/proxy" ] && found+=("Ligolo-ng") || missing+=("Ligolo-ng")
    [ -d "$t/web/username-anarchy" ] && found+=("Username Anarchy") || missing+=("Username Anarchy")
    [ -d "$t/web/cupp" ] && found+=("cupp") || missing+=("cupp")

    # Build tools
    command -v cargo &>/dev/null && found+=("Rust") || missing+=("Rust")
    [ -f "$t/ad/RustHound-CE/target/release/rusthound-ce" ] && found+=("RustHound-CE") || missing+=("RustHound-CE")

    # C2
    command -v sliver &>/dev/null && found+=("Sliver C2") || missing+=("Sliver C2")
    groups "$USER" 2>/dev/null | grep -q docker && found+=("docker group") || missing+=("docker group")

    # Print summary
    local total=$(( ${#found[@]} + ${#missing[@]} ))

    echo -e "  ${CYAN}Pre-flight scan${NC}"
    echo -e "  ${DIM}$(printf '─%.0s' {1..40})${NC}"

    if [ ${#missing[@]} -eq 0 ]; then
        echo -e "  ${GREEN}${#found[@]}/${total}${NC} tools already installed — nothing new"
        echo -e "  ${DIM}Running anyway to verify...${NC}"
    elif [ ${#found[@]} -eq 0 ]; then
        echo -e "  Fresh system — ${YELLOW}${#missing[@]} tools${NC} to install"
    else
        echo -e "  ${GREEN}${#found[@]}${NC}/${total} already installed · ${YELLOW}${#missing[@]}${NC} to install"
    fi

    if [ ${#found[@]} -gt 0 ] && [ ${#found[@]} -lt "$total" ]; then
        local list
        if [ ${#found[@]} -gt 8 ]; then
            printf -v list '%s, ' "${found[@]:0:8}"
            list="${list%, } ... and $((${#found[@]} - 8)) more"
        else
            printf -v list '%s, ' "${found[@]}"
            list="${list%, }"
        fi
        echo -e "  ${DIM}Existing: ${list}${NC}"
    fi

    echo ""
}

# ---- Module runner ----
TOTAL_MODULES=6
TOTAL_INSTALLED=0
TOTAL_SKIPPED=0
TOTAL_FAILED=0

run_module() {
    local num="$1"
    local name="$2"
    local script="$SCRIPT_DIR/scripts/$3"

    local stats_file
    stats_file=$(mktemp /tmp/nexus-stats-XXXXXX)

    echo -e "\n  ${CYAN}[${num}/${TOTAL_MODULES}]${NC} ${BOLD}${name}${NC}"
    echo -e "  ${DIM}$(printf '─%.0s' {1..40})${NC}"

    local exit_code=0
    NEXUS_STATS_FILE="$stats_file" \
    NEXUS_VERBOSE="$VERBOSE" \
    NEXUS_LOG_FILE="$LOG_FILE" \
    GIT_TERMINAL_PROMPT=0 \
        bash "$script" || exit_code=$?

    local mod_installed mod_skipped mod_failed
    mod_installed=$(grep -c "^installed$" "$stats_file" 2>/dev/null) || mod_installed=0
    mod_skipped=$(grep -c "^skipped$" "$stats_file" 2>/dev/null) || mod_skipped=0
    mod_failed=$(grep -c "^failed$" "$stats_file" 2>/dev/null) || mod_failed=0
    rm -f "$stats_file"

    TOTAL_INSTALLED=$((TOTAL_INSTALLED + mod_installed))
    TOTAL_SKIPPED=$((TOTAL_SKIPPED + mod_skipped))
    TOTAL_FAILED=$((TOTAL_FAILED + mod_failed))
}

# ---- Main ----
banner

if [ "$EUID" -eq 0 ]; then
    echo -e "  ${RED}[-]${NC} Don't run as root. The script uses sudo where needed."
    exit 1
fi

echo "=== Nexus install started: $(date) ===" > "$LOG_FILE"

# Cache sudo credentials and keep them fresh for the full run
sudo -v
(while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 50; done) 2>/dev/null &

# Directory structure
mkdir -p "$HOME/htb"/{scripts,vpn}
mkdir -p "$TOOLS_DIR"/{ad,exploit,postex,ligolo,pivot,web,wordlists}

# Pre-flight check
precheck

# Run modules
run_module 1 "APT packages"             "apt-tools.sh"
run_module 2 "Terminal setup"            "terminal-setup.sh"
run_module 3 "Python tools (pipx)"       "pipx-tools.sh"
run_module 4 "GitHub tools & binaries"   "github-tools.sh"
run_module 5 "Build tools (Rust)"        "build-tools.sh"
run_module 6 "C2 & frameworks"           "c2-setup.sh"

# ---- Summary ----
echo ""
echo -e "  ${CYAN}───────────────────────────────────────────${NC}"

summary=""
[ "$TOTAL_INSTALLED" -gt 0 ] && summary="${GREEN}${TOTAL_INSTALLED} installed${NC}"
[ "$TOTAL_SKIPPED" -gt 0 ] && summary="${summary:+$summary · }${DIM}${TOTAL_SKIPPED} already present${NC}"
[ "$TOTAL_FAILED" -gt 0 ] && summary="${summary:+$summary · }${RED}${TOTAL_FAILED} failed${NC}"
[ -n "$summary" ] && echo -e "  $summary"

echo ""
echo -e "  ${DIM}Tools${NC}  ~/htb/tools/"
echo -e "  ${DIM}Log${NC}    ${LOG_FILE}"
echo ""

if [ "$TOTAL_FAILED" -gt 0 ]; then
    echo -e "  ${YELLOW}[!]${NC} Some tools failed — check the log for details"
fi

echo -e "  ${YELLOW}[!]${NC} Next steps:"
echo "      1. Log out and back in (for zsh + docker group)"
echo "      2. Take a VMware snapshot!"
echo ""

echo "=== Nexus install finished: $(date) ===" >> "$LOG_FILE"
