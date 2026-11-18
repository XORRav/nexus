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
            echo "  --verbose   Show detailed output from each module"
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
    if [ "$VERBOSE" = true ]; then
        echo -e "  ${DIM}Verbose mode — showing all output${NC}"
    else
        echo -e "  ${DIM}Use --verbose for detailed output${NC}"
    fi
    echo ""
}

# ---- Spinner (quiet mode only) ----
_spinner_pid=""

start_spinner() {
    [ "$VERBOSE" = true ] && return
    local msg="$1"
    (
        local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        while true; do
            for (( i=0; i<${#chars}; i++ )); do
                printf "\r  ${CYAN}%s${NC} %s " "${chars:$i:1}" "$msg"
                sleep 0.08
            done
        done
    ) &
    _spinner_pid=$!
    tput civis 2>/dev/null
}

stop_spinner() {
    if [ -n "$_spinner_pid" ]; then
        kill "$_spinner_pid" 2>/dev/null
        wait "$_spinner_pid" 2>/dev/null
        _spinner_pid=""
        printf "\r\033[K"
        tput cnorm 2>/dev/null
    fi
}

cleanup() {
    stop_spinner
    tput cnorm 2>/dev/null
}
trap cleanup EXIT INT TERM

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

    local exit_code=0

    if [ "$VERBOSE" = true ]; then
        echo -e "\n  ${CYAN}━━━ [${num}/${TOTAL_MODULES}] ${name} ━━━${NC}\n"
        NEXUS_STATS_FILE="$stats_file" bash "$script" 2>&1 | tee -a "$LOG_FILE" || true
        exit_code=${PIPESTATUS[0]}
    else
        start_spinner "[${num}/${TOTAL_MODULES}] ${name}"
        NEXUS_STATS_FILE="$stats_file" bash "$script" >> "$LOG_FILE" 2>&1 || true
        exit_code=$?
        stop_spinner
    fi

    local mod_installed mod_skipped mod_failed
    mod_installed=$(grep -c "^installed$" "$stats_file" 2>/dev/null) || mod_installed=0
    mod_skipped=$(grep -c "^skipped$" "$stats_file" 2>/dev/null) || mod_skipped=0
    mod_failed=$(grep -c "^failed$" "$stats_file" 2>/dev/null) || mod_failed=0
    rm -f "$stats_file"

    TOTAL_INSTALLED=$((TOTAL_INSTALLED + mod_installed))
    TOTAL_SKIPPED=$((TOTAL_SKIPPED + mod_skipped))
    TOTAL_FAILED=$((TOTAL_FAILED + mod_failed))

    # Build status suffix
    local suffix=""
    [ "$mod_installed" -gt 0 ] && suffix="${mod_installed} installed"
    [ "$mod_skipped" -gt 0 ] && suffix="${suffix:+$suffix, }${mod_skipped} skipped"
    [ "$mod_failed" -gt 0 ] && suffix="${suffix:+$suffix, }${mod_failed} failed"
    [ -n "$suffix" ] && suffix=" ${DIM}(${suffix})${NC}"

    if [ "$mod_failed" -gt 0 ]; then
        echo -e "  ${YELLOW}!${NC} [${num}/${TOTAL_MODULES}] ${name}${suffix}"
    elif [ "$exit_code" -ne 0 ]; then
        echo -e "  ${RED}✗${NC} [${num}/${TOTAL_MODULES}] ${name}${suffix}"
    else
        echo -e "  ${GREEN}✓${NC} [${num}/${TOTAL_MODULES}] ${name}${suffix}"
    fi
}

# ---- Main ----
banner

if [ "$EUID" -eq 0 ]; then
    echo -e "  ${RED}[-]${NC} Don't run as root. The script uses sudo where needed."
    exit 1
fi

echo "=== Nexus install started: $(date) ===" > "$LOG_FILE"

# Directory structure
mkdir -p "$HOME/htb"/{scripts,vpn}
mkdir -p "$TOOLS_DIR"/{ad,exploit,postex,ligolo,pivot,web,wordlists}

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
