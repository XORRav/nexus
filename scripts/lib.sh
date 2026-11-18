#!/bin/bash
# Nexus — Shared functions for module scripts
# Sourced by each script; do not run directly.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

_log() { [ -n "${NEXUS_LOG_FILE:-}" ] && echo "$1" >> "$NEXUS_LOG_FILE"; }

info()  { echo -e "  ${GREEN}[+]${NC} $1"; _log "[+] $1"; }
warn()  { echo -e "  ${YELLOW}[!]${NC} $1"; _log "[!] $1"; }
error() { echo -e "  ${RED}[-]${NC} $1"; _log "[-] $1"; }

# Run a command, suppressing output in quiet mode (goes to log only)
run_cmd() {
    if [ "${NEXUS_VERBOSE:-false}" = true ]; then
        "$@" 2>&1
        return $?
    else
        "$@" >> "${NEXUS_LOG_FILE:-/dev/null}" 2>&1
    fi
}

# Install a tool: shows "Installing name..." then ✓ or ✗
# Handles tracking automatically. Returns the command's exit code.
run_install() {
    local name="$1"
    shift

    if [ "${NEXUS_VERBOSE:-false}" = true ]; then
        info "Installing $name..."
        "$@" 2>&1
        local rc=$?
        if [ $rc -eq 0 ]; then
            _log "[+] $name: done"
            track_installed
        else
            warn "Failed to install $name"
            _log "[-] $name: FAILED"
            track_failed
        fi
        return $rc
    fi

    printf "  ${GREEN}[+]${NC} Installing %s... " "$name"

    if "$@" >> "${NEXUS_LOG_FILE:-/dev/null}" 2>&1; then
        echo -e "${GREEN}✓${NC}"
        _log "[+] $name: done"
        track_installed
        return 0
    else
        echo -e "${RED}✗${NC}"
        _log "[-] $name: FAILED"
        track_failed
        return 1
    fi
}

# Mark a tool as already present (dimmed, tracks as skipped)
skip_ok() {
    echo -e "  ${DIM}[○] $1${NC}"
    _log " ○  $1"
    track_skipped
}

# Stat tracking — install.sh reads the stats file after each module
_track() { [ -n "${NEXUS_STATS_FILE:-}" ] && echo "$1" >> "$NEXUS_STATS_FILE"; }
track_installed() { _track "installed"; }
track_skipped()   { _track "skipped"; }
track_failed()    { _track "failed"; }
