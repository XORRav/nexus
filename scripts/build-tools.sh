#!/bin/bash
# Build tools that require compilation (Rust/Cargo)

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ---- Install Rust if missing ----
if ! command -v cargo &>/dev/null; then
    [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
fi

if ! command -v cargo &>/dev/null; then
    run_install "Rust toolchain" bash -c \
        'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
    source "$HOME/.cargo/env" 2>/dev/null
else
    skip_ok "Rust toolchain"
fi

# ---- RustHound-CE (install via cargo, no git clone needed) ----
if command -v rusthound-ce &>/dev/null; then
    skip_ok "RustHound-CE"
elif command -v cargo &>/dev/null; then
    source "$HOME/.cargo/env" 2>/dev/null
    run_install "RustHound-CE (compiling — takes a while)" cargo install rusthound-ce
else
    warn "Cannot install RustHound-CE — Rust toolchain not available"
    track_failed
fi
