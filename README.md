# Nexus

```
  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗
  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝
  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗
  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║
  ██║ ╚████║███████╗██╔╝ ╚██╗╚██████╔╝███████║
  ╚═╝  ╚═══╝╚══════╝╚═╝   ╚═╝ ╚═════╝ ╚══════╝
```

**Go from a fresh Kali VM to a fully loaded attack box in one command.**

Nexus is a modular bootstrap script that automates the setup of a Kali Linux penetration testing environment. Built for HackTheBox and real-world engagements — run it once, snapshot your VM, and you're ready to go.

## Why?

Every time you spin up a fresh Kali VM, you spend an hour installing the same tools, cloning the same repos, and tweaking the same terminal settings. Nexus does all of that in one unattended run so you can get straight to hacking.

## Quick Start

```bash
git clone https://github.com/XORRav/nexus.git
cd nexus
chmod +x install.sh scripts/*.sh
./install.sh
```

> **Note:** Don't run as root — the script uses `sudo` where needed.
> Log out and back in after install for zsh and docker group changes to take effect.

## What Gets Installed

### APT Packages
`rlwrap` · `jq` · `fzf` · `bat` · `ripgrep` · `seclists` · `gvm`

### Python Tools (via pipx)
`certipy-ad` · `bloodyad` · `adidnsdump` · `ldapdomaindump` · `coercer` · `pypykatz` · `wesng` · `droopescan`

### AD & Exploitation Tools (from GitHub)
| Tool | Category | Source |
|------|----------|--------|
| BloodHound CE | AD Enumeration | Docker / git clone |
| RustHound-CE | AD Collection | Built from source (Rust) |
| Kerbrute | AD Auth | GitHub release binary |
| windapsearch | AD LDAP | GitHub release binary |
| PKINITtools | AD Kerberos | git clone |
| krbrelayx | AD Kerberos | git clone |
| SharpHound | AD Collection | GitHub release (.zip) |
| Rubeus / Seatbelt / Certify | AD Post-Ex | Precompiled .exe |
| Snaffler | AD File Hunting | GitHub release (.exe) |
| Inveigh | MITM / Poisoning | GitHub release (.zip) |
| noPac | AD Exploit | git clone |
| PrintNightmare | AD Exploit | git clone |
| pspy64 | Linux Post-Ex | GitHub release binary |
| Ligolo-ng | Pivoting | Proxy (Linux) + Agent (Windows) |
| Username Anarchy | OSINT / Web | git clone |
| cupp | Wordlist Gen | git clone |

### C2 Frameworks
- **Sliver** — installed via official installer
- **Metasploit** — pre-installed on Kali, database initialized

### Terminal Customization
- **zsh** set as default shell
- **JetBrains Mono Nerd Font** installed
- **fzf** keybindings enabled
- **tmux** config — mouse support, vi copy mode, system clipboard (`xclip`), sane split keys (`|` / `-`)
- Aliases: `listen` (rlwrap nc listener), `serve` (python3 http server), `bat` (batcat)
- QTerminal configured (font, colors, no transparency)

### Wordlists & Rules
- `rockyou.txt` decompressed
- `OneRuleToRuleThemAll` hashcat rule downloaded

## Directory Structure

All tools install to `~/htb/tools/` with a clean layout:

```
~/htb/
├── scripts/           # Your engagement scripts
├── vpn/               # VPN configs
└── tools/
    ├── ad/            # Active Directory tools
    ├── exploit/       # Exploitation frameworks
    ├── postex/        # Post-exploitation binaries
    ├── ligolo/        # Ligolo-ng proxy + agent
    ├── pivot/         # Other pivoting tools
    ├── web/           # Web app tools
    └── wordlists/     # Custom wordlists
```

## Post-Install Checklist

- [ ] Log out and back in (zsh + docker group)
- [ ] Set font in QTerminal → Preferences → JetBrains Mono Nerd Font, size 11
- [ ] Run `sudo gvm-setup` if you need OpenVAS
- [ ] Register for [Nessus Essentials](https://www.tenable.com/products/nessus/nessus-essentials)
- [ ] **Take a VMware snapshot**

## Design Principles

- **Idempotent** — safe to run multiple times; checks before installing
- **No interactive prompts** — runs unattended start to finish
- **pipx over pip** — Python tools get isolated environments, no `--break-system-packages`
- **Modular** — each script in `scripts/` handles one category and can run independently
- **Doesn't reinstall what Kali already has** — nmap, ffuf, gobuster, impacket, evil-winrm, netexec, etc. are already on Kali

## Target Environment

Kali Linux 2025.x on VMware Workstation (pre-built image with XFCE desktop).

## License

MIT
