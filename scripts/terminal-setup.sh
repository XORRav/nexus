#!/bin/bash
# Terminal customization: zsh, Nerd Font, fzf, aliases, QTerminal config

info() { echo -e "\033[0;32m[+]\033[0m $1"; }
warn() { echo -e "\033[1;33m[!]\033[0m $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/../configs"

# ---- Set zsh as default shell ----
if [ "$(basename "$SHELL")" = "zsh" ]; then
    info "zsh: already default shell"
else
    info "Setting zsh as default shell..."
    chsh -s /usr/bin/zsh
    warn "Log out and back in for zsh to take effect"
fi

# ---- Install JetBrains Mono Nerd Font ----
if fc-list | grep -qi "JetBrainsMono Nerd"; then
    info "JetBrainsMono Nerd Font: already installed"
else
    info "Installing JetBrainsMono Nerd Font..."
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -qo JetBrainsMono.zip -d JetBrainsMono
    rm -f JetBrainsMono.zip
    fc-cache -f
    info "Font installed. Set it in QTerminal: File > Preferences > Appearance"
fi

# ---- Add zshrc additions (idempotent) ----
ZSHRC="$HOME/.zshrc"

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
    # Ensure no transparency
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

info "Terminal setup done."
