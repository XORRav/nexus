# Nexus — Claude Code Context

## Project Overview
Nexus is a Kali Linux pentesting toolkit bootstrap script. It automates the setup of a fresh Kali VM for HackTheBox (HTB) penetration testing engagements. One command (`./install.sh`) takes a stock Kali 2025.4 VM to a fully configured attack box.

## Architecture
- `install.sh` — Main entry point. Runs each module script in order. Checks it's not run as root.
- `scripts/apt-tools.sh` — APT package installs (rlwrap, jq, fzf, bat, ripgrep, seclists, gvm)
- `scripts/pipx-tools.sh` — Python tools via pipx (certipy, bloodyad, coercer, etc.)
- `scripts/github-tools.sh` — Git clones, GitHub release binary downloads, compiled Windows binaries
- `scripts/build-tools.sh` — Rust toolchain install + cargo builds (RustHound-CE)
- `scripts/c2-setup.sh` — Sliver C2 install, Metasploit DB init, docker group setup
- `scripts/terminal-setup.sh` — zsh default shell, Nerd Font, fzf keybindings, aliases, QTerminal config
- `configs/qterminal.ini` — QTerminal appearance settings (font, colors, no transparency)
- `configs/zshrc-additions` — Lines appended to ~/.zshrc (fzf, bat alias, pentesting aliases)

## Key Conventions
- **Never use `pip3 install` or `--break-system-packages`** — always use `pipx` for Python tools
- **All tools install to `~/htb/tools/`** with subdirs: ad, exploit, postex, ligolo, pivot, web, wordlists
- **Scripts must be idempotent** — safe to run multiple times, check before installing
- **GitHub release downloads use the API** to find correct asset URLs (names include version numbers)
- **No interactive prompts** — scripts should run unattended (skip things needing registration like Nessus)
- **Run as normal user** — use `sudo` only where needed, never run entire script as root
- **Colored output** — use [+] green for success, [!] yellow for warnings, [-] red for errors

## Helper Function
`get_release_url` in github-tools.sh fetches the latest release asset URL from GitHub API:
```bash
get_release_url "owner/repo" "filename_pattern"
```

## Target Environment
- Kali Linux 2025.4 (VMware Workstation pre-built image)
- XFCE desktop with QTerminal
- zsh shell (may default to bash on fresh install — terminal-setup.sh fixes this)
- Tools that are pre-installed on Kali and should NOT be installed: nmap, ffuf, gobuster, feroxbuster, sqlmap, hydra, hashcat, john, metasploit, impacket, evil-winrm, netexec (nxc), chisel, eyewitness, mimikatz, linpeas/winpeas, burpsuite, responder, proxychains4, socat, netcat, docker, seclists, joomscan, droopescan

## Testing
After running install.sh, verify with:
```bash
# Check pipx tools
pipx list

# Check binaries
ls ~/htb/tools/ad/kerbrute ~/htb/tools/postex/pspy64 ~/htb/tools/ligolo/proxy

# Check terminal
echo $SHELL  # should be /usr/bin/zsh
fc-list | grep JetBrains
```
