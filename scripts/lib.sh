#!/bin/bash
# Nexus — Shared functions for module scripts
# Sourced by each script; do not run directly.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "  ${GREEN}[+]${NC} $1"; }
warn()  { echo -e "  ${YELLOW}[!]${NC} $1"; }
error() { echo -e "  ${RED}[-]${NC} $1"; }

# Stat tracking — install.sh reads the stats file after each module
_track() { [ -n "${NEXUS_STATS_FILE:-}" ] && echo "$1" >> "$NEXUS_STATS_FILE"; }
track_installed() { _track "installed"; }
track_skipped()   { _track "skipped"; }
track_failed()    { _track "failed"; }
