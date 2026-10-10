# Debian-Hypr-Dotfile

A basic Hyprland dotfile for **Debian**. It sets up a minimal, gruvbox-themed
desktop: compositor, bar, launcher, terminal, wallpaper and a few tools so you
can log in after a reboot and just use it.

Debian doesn't ship Hyprland, and every dotfile out there seems to be for Arch,
Fedora or NixOS. So I made one for Debian. There are two install scripts: one
for **Debian Sid** and one for **Debian Stable + Backports**. Pick whichever
fits your setup.

GDM is installed and enabled as the login manager, so you can pick the Hyprland
session right from the greeter after rebooting.

<img width="1366" height="768" alt="imagen" src="https://github.com/user-attachments/assets/68700ec4-a07a-4609-94ae-e0b3281434b3" />

## ⚠️ Which install script should I use?

### `install.sh` — Debian Sid

This script switches `/etc/apt/sources.list` to **Debian unstable (Sid)**.
Hyprland and some of its dependencies live there, so you get the latest
versions, but Sid is a rolling release. Breakage happens. That's the trade-off.

If you're not comfortable with that, use the stable script instead.

### `stable-install.sh` — Debian Stable + Backports

This script keeps your system on **Debian Stable** and enables
`trixie-backports` to install a recent Hyprland without switching the whole
system to Sid. Your base stays stable, only the Hyprland stack comes from
backports.

Requires **Debian 13 (Trixie)**. On older releases the backports repo won't
have Hyprland. If you're on Bookworm, upgrade to Trixie first.

## Requirements

- A Debian installation
- `git` and `sudo` installed
- A working internet connection
- A bit of patience, the initial `apt` update takes a while

## Installation

### Option A — Debian Sid

```bash
git clone https://github.com/random57619858-user/Debian-Hypr-Dotfiles
cd Debian-Hypr-Dotfiles
chmod +x install.sh
./install.sh
```

### Option B — Debian Stable + Backports (BETA)

```bash
git clone https://github.com/random57619858-user/Debian-Hypr-Dotfiles
cd Debian-Hypr-Dotfiles
chmod +x stable-install.sh
./stable-install.sh
```

After a reboot, GDM will show up. Pick the Hyprland session from the session
menu and log in.

## What it installs

Core desktop:
```
    Hyprland (compositor)

    Waybar (status bar)

    Rofi (app launcher and wallpaper picker)

    Kitty (terminal)

    Cava (audio visualizer)

    Swaybg (wallpaper setter)
```

Extra tools:
```
    GDM (login manager)

    Wlogout (power menu)

    Hypridle + Hyprlock (idle and lock screen)

    Cliphist (clipboard history)

    Grim + Slurp + wl-clipboard (screenshots)

    PipeWire + WirePlumber (audio)

    XDG Desktop Portal Hyprland (screen sharing)

    Hyprpolkitagent (auth dialogs)

    Fluent icon theme

    JetBrainsMono Nerd Font
```

Optional (asked during install):
```
    Printer support (CUPS)

    Flatpak + Flathub

    Steam, OnlyOffice, Discord
```

## Keybindings

```
SUPER + Q	           Open kitty
SUPER + D	           App launcher (rofi)
SUPER + W 	           Change wallpaper
SUPER + C	           Close window
SUPER + V	           Toggle floating window
SUPER + A	           Clipboard history
SUPER + L	           Lock screen
SUPER + 1-0	           Switch workspace
SUPER + SHIFT + 1-0	   Move window to workspace
SUPER + SHIFT + E	   Power menu (wlogout)
SUPER + Print	       Screenshot
```

## Backups

Both scripts ask before overwriting anything in `~/.config/`. If you say yes, a
copy gets saved to `backup/` inside this repo. Your `sources.list` (Sid script)
or `debian-backports.sources` (stable script) can also be backed up before
being replaced.

It's not the best dotfile, but I hope you like it :)

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/9a6554fd-20c5-481c-9163-0b7872f84037" />
