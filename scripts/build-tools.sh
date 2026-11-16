#!/bin/bash
# Build tools that require compilation (Rust/Cargo)

info() { echo -e "\033[0;32m[+]\033[0m $1"; }
warn() { echo -e "\033[1;33m[!]\033[0m $1"; }

TOOLS_DIR="$HOME/htb/tools"

# ---- Install Rust if missing ----
if ! command -v cargo &>/dev/null; then
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
fi

if ! command -v cargo &>/dev/null; then
    info "Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    info "Rust: already installed"
fi

# ---- RustHound-CE ----
if [ ! -d "$TOOLS_DIR/ad/RustHound-CE" ]; then
    info "Cloning and building RustHound-CE..."
    git clone https://github.com/NH-RED-TEAM/RustHound-CE.git "$TOOLS_DIR/ad/RustHound-CE"
    cd "$TOOLS_DIR/ad/RustHound-CE"
    source "$HOME/.cargo/env"
    cargo build --release
    info "RustHound-CE built at: $TOOLS_DIR/ad/RustHound-CE/target/release/rusthound-ce"
elif [ ! -f "$TOOLS_DIR/ad/RustHound-CE/target/release/rusthound-ce" ]; then
    info "Building RustHound-CE..."
    cd "$TOOLS_DIR/ad/RustHound-CE"
    source "$HOME/.cargo/env"
    cargo build --release
else
    info "RustHound-CE: already built"
fi

info "Build tools done."
