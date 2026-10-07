# Debian-Dotfile (Hyprland)

This repository contains a script to configure Hyprland on a clean Debian installation, and also installs several utilities to make the system ready to use after a reboot.

## Warning

This script switches the Debian repositories to the Sid (unstable) branch. When using unstable software, there is a possibility of update failures or system errors.

I recommend that your user already have permissions to run sudo, so the script will run on the first try 

Installing dependencies for Hyprland on Debian is already complicated enough; I had to resort to using the unstable branch :(

Just to clarify, I'm also new to this whole world of creating dotfiles, which is why my configuration is a mess—and just a reminder that there's a chance this dotfile could break your system (since it doesn't make any backups) :)

That was my last warning—if your Debian crashes, it's not my fault :V

The dotfile probably isn't perfect—GTK or the icon theme download might not work—but I'm currently working on fixing that  D:, This isn't Hyde, bro

I'll keep improving the dotfile over time since this is more of a beta than a finished product, but I still hope you like it :V

## Requirements

* A Debian installation.
* `git` must be installed.
* `sudo` must be installed.

## Installation

```bash
git clone https://github.com/random57619858-user/Debian-Dotfile.git
cd Debian-Dotfile
chmod +x install.sh
./install.sh
```
Finally, it reboots, you log in, and launch Hyprland. In the future, I plan to add something like SDDM or GDM, but for now, this is fine :)



