#!/bin/bash
# Terminal customization: zsh, Nerd Font, fzf, aliases, QTerminal config

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/../configs"

# ---- Set zsh as default shell ----
if [ "$(basename "$SHELL")" = "zsh" ]; then
    info "zsh: already default shell"
    track_skipped
elif [ -x /usr/bin/zsh ]; then
    info "Setting zsh as default shell..."
    chsh -s /usr/bin/zsh
    warn "Log out and back in for zsh to take effect"
    track_installed
else
    warn "zsh not found at /usr/bin/zsh — skipping shell change"
    track_failed
fi

# ---- Install JetBrains Mono Nerd Font ----
if fc-list | grep -qi "JetBrainsMono Nerd"; then
    info "JetBrainsMono Nerd Font: already installed"
    track_skipped
else
    info "Installing JetBrainsMono Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    if wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -O /tmp/JetBrainsMono.zip; then
        unzip -qo /tmp/JetBrainsMono.zip -d "$FONT_DIR/JetBrainsMono"
        rm -f /tmp/JetBrainsMono.zip
        fc-cache -f
        info "Font installed"
        track_installed
    else
        warn "Failed to download JetBrainsMono Nerd Font — check internet connection"
        track_failed
    fi
fi

# ---- Seed .zshrc from defaults if missing ----
ZSHRC="$HOME/.zshrc"
if [ ! -f "$ZSHRC" ]; then
    if [ -f /etc/skel/.zshrc ]; then
        info "Seeding .zshrc from /etc/skel defaults..."
        cp /etc/skel/.zshrc "$ZSHRC"
    else
        touch "$ZSHRC"
    fi
fi

# ---- Add zshrc additions (idempotent) ----

# fzf keybindings
FZF_LINE='[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh'
if ! grep -qF "fzf/examples/key-bindings.zsh" "$ZSHRC" 2>/dev/null; then
    info "Adding fzf keybindings to .zshrc..."
    echo "" >> "$ZSHRC"
    echo "# fzf keybindings" >> "$ZSHRC"
    echo "$FZF_LINE" >> "$ZSHRC"
else
    info "fzf keybindings: already in .zshrc"
fi

# bat alias
if ! grep -qF "alias bat='batcat'" "$ZSHRC" 2>/dev/null; then
    info "Adding bat alias to .zshrc..."
    echo "" >> "$ZSHRC"
    echo "# bat alias" >> "$ZSHRC"
    echo "alias bat='batcat'" >> "$ZSHRC"
else
    info "bat alias: already in .zshrc"
fi

# Pentesting aliases
if ! grep -qF "alias listen=" "$ZSHRC" 2>/dev/null; then
    info "Adding pentesting aliases to .zshrc..."
    echo "" >> "$ZSHRC"
    echo "# Pentesting aliases" >> "$ZSHRC"
    echo "alias listen='rlwrap nc -lvnp'" >> "$ZSHRC"
    echo "alias serve='python3 -m http.server 80'" >> "$ZSHRC"
else
    info "Pentesting aliases: already in .zshrc"
fi

# ---- QTerminal config ----
QTERMINAL_INI="$HOME/.config/qterminal.org/qterminal.ini"
if [ -f "$QTERMINAL_INI" ]; then
    info "Updating QTerminal config..."
    sed -i 's/^fontFamily=.*/fontFamily=JetBrainsMono Nerd Font/' "$QTERMINAL_INI"
    sed -i 's/^fontSize=.*/fontSize=11/' "$QTERMINAL_INI"
    if grep -q "^ApplicationTransparency=" "$QTERMINAL_INI"; then
        sed -i 's/^ApplicationTransparency=.*/ApplicationTransparency=0/' "$QTERMINAL_INI"
    fi
elif [ -f "$CONFIGS_DIR/qterminal.ini" ]; then
    info "Copying QTerminal config..."
    mkdir -p "$(dirname "$QTERMINAL_INI")"
    cp "$CONFIGS_DIR/qterminal.ini" "$QTERMINAL_INI"
else
    warn "QTerminal config not found — set font manually in Preferences"
fi

# ---- tmux config ----
if [ ! -f "$HOME/.tmux.conf" ]; then
    if [ -f "$CONFIGS_DIR/tmux.conf" ]; then
        info "Installing tmux config..."
        cp "$CONFIGS_DIR/tmux.conf" "$HOME/.tmux.conf"
        track_installed
    fi
else
    info "tmux config: already exists"
    track_skipped
fi

# ---- xsel for tmux clipboard support ----
if ! command -v xsel &>/dev/null; then
    info "Installing xsel (tmux clipboard support)..."
    if sudo apt install -y -qq xsel; then
        track_installed
    else
        warn "Failed to install xsel"
        track_failed
    fi
else
    info "xsel: already installed"
    track_skipped
fi

info "Terminal setup done."
