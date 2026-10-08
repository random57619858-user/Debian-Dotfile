# Debian-Dotfile (Hyprland)

A basic Hyprland dotfile for **Debian Sid**.
It sets up a minimal, gruvbox-themed desktop: compositor, bar, launcher,
terminal, wallpaper and a few quality-of-life tools so you can log in after a
reboot and just use it.
## ⚠️ About Debian Sid

This script switches `/etc/apt/sources.list` to **Debian unstable (Sid)**.
Hyprland and some of its dependencies are only available there, so there's no
way around it if you want a modern setup on Debian D:

Sid is a rolling release. Breakage happens. That's the trade-off. If you're not
comfortable with that, this repo isn't for you.

## Requirements

- A Debian installation.
- `git` and `sudo` installed.
- A working internet connection.## Installation

```bash
git clone https://github.com/random57619858-user/Debian-Dotfile.git
cd Debian-Dotfile
chmod +x install.sh
./install.sh
```
After a reboot, log in and launch Hyprland. In the future I'd like to add a
proper display manager (SDDM or GDM) to make login cleaner, but for now
launching it manually or from a TTY is fine.
Run in tty: Hyprland
(If that's all)

What it installs

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
    Wlogout (power menu)

    Hypridle + Hyprlock (idle management and lock screen)

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
Keybindings
Key	Action
SUPER + Q	Open kitty

SUPER + D	App launcher (rofi)

SUPER + W	Change wallpaper

SUPER + C	Close window

SUPER + V	Toggle floating window

SUPER + A	Clipboard history

SUPER + L	Lock screen

SUPER + 1-0	Switch workspace

SUPER + SHIFT + 1-0	Move window to workspace

SUPER + SHIFT + E	Power menu (wlogout)

SUPER + Print	Screenshot

Backups

The script asks before overwriting anything in ~/.config/. If you say yes,
a copy is saved to backup/ inside this repo. Your sources.list can also be
backed up before it's replaced.

It's not the best dotfile, but I hope you like it :)

<img width="1366" height="768" alt="imagen" src="https://github.com/user-attachments/assets/68700ec4-a07a-4609-94ae-e0b3281434b3" />

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/9a6554fd-20c5-481c-9163-0b7872f84037" />
