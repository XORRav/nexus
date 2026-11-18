#!/bin/bash
# Build tools that require compilation (Rust/Cargo)

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

TOOLS_DIR="$HOME/htb/tools"

# ---- Install Rust if missing ----
if ! command -v cargo &>/dev/null; then
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
fi

if ! command -v cargo &>/dev/null; then
    info "Installing Rust toolchain..."
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        source "$HOME/.cargo/env"
        track_installed
    else
        warn "Failed to install Rust"
        track_failed
    fi
else
    info "Rust: already installed"
    track_skipped
fi

# ---- RustHound-CE ----
if [ ! -d "$TOOLS_DIR/ad/RustHound-CE" ]; then
    info "Cloning and building RustHound-CE (this takes a while)..."
    if git clone --quiet https://github.com/NH-RED-TEAM/RustHound-CE.git "$TOOLS_DIR/ad/RustHound-CE"; then
        cd "$TOOLS_DIR/ad/RustHound-CE"
        source "$HOME/.cargo/env"
        if cargo build --release; then
            info "RustHound-CE built"
            track_installed
        else
            warn "RustHound-CE build failed"
            track_failed
        fi
    else
        warn "Failed to clone RustHound-CE"
        track_failed
    fi
elif [ ! -f "$TOOLS_DIR/ad/RustHound-CE/target/release/rusthound-ce" ]; then
    info "Building RustHound-CE (this takes a while)..."
    cd "$TOOLS_DIR/ad/RustHound-CE"
    source "$HOME/.cargo/env"
    if cargo build --release; then
        track_installed
    else
        warn "RustHound-CE build failed"
        track_failed
    fi
else
    info "RustHound-CE: already built"
    track_skipped
fi

info "Build tools done."
