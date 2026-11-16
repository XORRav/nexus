# Nexus

Kali Linux pentesting toolkit bootstrap. Go from fresh Kali VM to fully loaded attack box in one run.

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/nexus.git
cd nexus
chmod +x install.sh scripts/*.sh
./install.sh
```

Then log out and back in for zsh + docker group changes.

## What It Installs

### APT Packages
rlwrap, jq, fzf, bat, ripgrep, seclists, gvm

### pipx Tools (isolated Python)
certipy-ad, bloodyad, adidnsdump, ldapdomaindump, coercer, pypykatz, wesng, droopescan

### GitHub Tools & Binaries
BloodHound CE, RustHound-CE, Kerbrute, windapsearch, PKINITtools, krbrelayx, SharpHound, Rubeus, Seatbelt, Certify, Snaffler, Inveigh, noPac, PrintNightmare, pspy64, Ligolo-ng, Username Anarchy, cupp

### C2 Frameworks
Sliver (installed), Metasploit (pre-installed, DB initialized)

### Terminal
zsh (default shell), JetBrains Mono Nerd Font, fzf keybindings, bat alias, pentesting aliases

## Directory Structure

```
~/htb/
├── scripts/
├── vpn/
└── tools/
    ├── ad/
    ├── exploit/
    ├── postex/
    ├── ligolo/
    ├── pivot/
    ├── web/
    └── wordlists/
```

## Manual Steps After Install

1. Log out and back in (zsh + docker group)
2. Set font in QTerminal: File > Preferences > JetBrainsMono Nerd Font, size 11
3. `sudo gvm-setup` if you need OpenVAS
4. Register for Nessus at https://www.tenable.com/products/nessus/nessus-essentials
5. Take a VMware snapshot
