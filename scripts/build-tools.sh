#!/bin/bash
# Build tools that require compilation (Rust/Cargo)

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

TOOLS_DIR="$HOME/htb/tools"

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

# ---- RustHound-CE ----
if [ ! -d "$TOOLS_DIR/ad/RustHound-CE" ]; then
    info "Cloning RustHound-CE..."
    if run_cmd git clone --quiet https://github.com/NH-RED-TEAM/RustHound-CE.git "$TOOLS_DIR/ad/RustHound-CE"; then
        cd "$TOOLS_DIR/ad/RustHound-CE"
        source "$HOME/.cargo/env" 2>/dev/null
        run_install "RustHound-CE (compiling — takes a while)" cargo build --release
    else
        warn "Failed to clone RustHound-CE"
        track_failed
    fi
elif [ ! -f "$TOOLS_DIR/ad/RustHound-CE/target/release/rusthound-ce" ]; then
    cd "$TOOLS_DIR/ad/RustHound-CE"
    source "$HOME/.cargo/env" 2>/dev/null
    run_install "RustHound-CE (compiling — takes a while)" cargo build --release
else
    skip_ok "RustHound-CE"
fi
