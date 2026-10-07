set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────
ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
GREEN="${ESC}[32m"
CYAN="${ESC}[36m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
RED="${ESC}[31m"

# ─── Helpers ──────────────────────────────────────────────────────────────
banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "┌──────────────────────────────────────────────────┐"
    echo "│         DEBIAN HYPRLAND DOTFILES INSTALLER       │"
    echo "└──────────────────────────────────────────────────┘"
    echo -e "${RESET}"
}

info()  { echo -e "\n${BLUE}${BOLD}==> ${1}${RESET}"; }
ok()    { echo -e "${GREEN}✔ ${1}${RESET}"; }
warn()  { echo -e "${YELLOW}⚠ ${1}${RESET}"; }
fail()  { echo -e "${RED}✖ ${1}${RESET}" >&2; }

confirm() {
    local msg="$1"
    local reply=""
    read -p "$msg (y/N): " reply < /dev/tty || true
    [[ "${reply:-}" =~ ^[yYsS]$ ]]
}

# ─── Preflight ────────────────────────────────────────────────────────────
banner

if ! sudo -v; then
    fail "sudo is required. Aborting."
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$DOTFILES_DIR/backup"
mkdir -p "$BACKUP_ROOT"

# ─── Repo setup (Sid) ─────────────────────────────────────────────────────
info "Switching APT to Debian unstable (Sid)..."
warn "This will replace /etc/apt/sources.list. Sid is a rolling release."
warn "You may hit occasional breakage. Make sure you know what you're doing."

if ! confirm "Continue anyway?"; then
    fail "Aborted by user."
    exit 0
fi

if confirm "Back up your current sources.list?"; then
    if [ -f /etc/apt/sources.list ]; then
        sudo cp /etc/apt/sources.list "$BACKUP_ROOT/sources.list.bak"
        ok "Saved to $BACKUP_ROOT/sources.list.bak"
    else
        warn "No sources.list found, skipping."
    fi
fi

sudo tee /etc/apt/sources.list > /dev/null <<'EOF'
deb http://deb.debian.org/debian/ unstable main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ unstable main contrib non-free non-free-firmware
EOF

# ─── Base packages ────────────────────────────────────────────────────────
info "Updating and installing base packages..."
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y \
    hyprland firefox nautilus kitty cava rofi swaybg playerctl \
    brightnessctl waybar wl-clipboard grim slurp nwg-look \
    pipewire zenity wlogout xdg-desktop-portal-hyprland hyprpolkitagent cliphist hypridle hyprlock wireplumber pipewire-audio \
    xdg-user-dirs git unzip build-essential curl wget \
    fonts-noto-color-emoji fonts-nerd-symbols fonts-jetbrains-mono

# ─── Audio ────────────────────────────────────────────────────────────────
info "Enabling PipeWire services..."
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service

# ─── Fonts ────────────────────────────────────────────────────────────────
info "Installing JetBrainsMono Nerd Font..."
mkdir -p "$HOME/.local/share/fonts"
FONT_TEMP="$(mktemp -d)"
trap 'rm -rf "$FONT_TEMP"' EXIT

curl -fsSL -o "$FONT_TEMP/JetBrainsMono.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -oq "$FONT_TEMP/JetBrainsMono.zip" -d "$HOME/.local/share/fonts/JetBrainsMono"
fc-cache -f "$HOME/.local/share/fonts" > /dev/null
ok "Font installed."

# ─── Optional stuff ───────────────────────────────────────────────────────
info "Optional components..."

if confirm "Install printer support?"; then
    sudo apt install -y cups cups-client avahi-daemon \
        printer-driver-gutenprint foomatic-db-compressed-ppds system-config-printer
    sudo systemctl enable --now cups avahi-daemon
    sudo cupsctl WebInterface=yes
    sudo usermod -aG lpadmin "$USER"
    ok "Printer support ready."
fi

if confirm "Install Flatpak + Flathub?"; then
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
    ok "Flatpak and Flathub configured."
fi

if confirm "Install extra apps (Steam, OnlyOffice, Discord)?"; then
    TMP_APPS="$(mktemp -d)"
    trap 'rm -rf "$TMP_APPS"' EXIT

    info "Steam..."
    sudo dpkg --add-architecture i386
    sudo apt update
    wget -q -O "$TMP_APPS/steam.deb" \
        "https://repo.steampowered.com/steam/archive/precise/steam_latest.deb"
    sudo apt install -y "$TMP_APPS/steam.deb" || sudo apt --fix-broken install -y

    info "OnlyOffice..."
    wget -q -O "$TMP_APPS/onlyoffice.deb" \
        "https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb"
    sudo apt install -y "$TMP_APPS/onlyoffice.deb"

    info "Discord..."
    wget -q -O "$TMP_APPS/discord.deb" \
        "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt install -y "$TMP_APPS/discord.deb"

    ok "Extra apps installed."
fi

# ─── User dirs ────────────────────────────────────────────────────────────
info "Setting up user directories..."
xdg-user-dirs-update
if [ -d "$HOME/Imágenes" ]; then
    IMG_DIR="$HOME/Imágenes"
else
    IMG_DIR="$HOME/Pictures"
fi
mkdir -p "$IMG_DIR"

# ─── Fluent icons ─────────────────────────────────────────────────────────
info "Installing Fluent icon theme..."
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme.git \
    "$TMP_DIR/Fluent-icon-theme"
( cd "$TMP_DIR/Fluent-icon-theme" && chmod +x install.sh && \
  ./install.sh -d "$HOME/.local/share/icons" )
ok "Icons installed."

# ─── GTK ──────────────────────────────────────────────────────────────────
info "Applying GTK settings..."
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/nwg-look"

GTK_SETTINGS='[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Fluent-dark
gtk-font-name=Sans 10'

printf '%s\n' "$GTK_SETTINGS" > "$HOME/.config/gtk-3.0/settings.ini"
printf '%s\n' "$GTK_SETTINGS" > "$HOME/.config/gtk-4.0/settings.ini"

cat > "$HOME/.config/nwg-look/gsettings" <<'EOF'
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Fluent-dark
EOF

if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Fluent-dark'
fi

# ─── Dotfiles ─────────────────────────────────────────────────────────────
info "Deploying dotfiles..."

deploy() {
    local src="$1" dest="$2" name="$3"

    if { [ -d "$dest" ] && [ -n "$(ls -A "$dest" 2>/dev/null)" ]; } || [ -f "$dest" ]; then
        if confirm "Back up your existing $name config?"; then
            mkdir -p "$BACKUP_ROOT/$name"
              ok "Saved $name to $BACKUP_ROOT/$name"
            if [ -f "$dest" ]; then
                cp -f "$dest" "$BACKUP_ROOT/$name/"
            else
                cp -rf "$dest/." "$BACKUP_ROOT/$name/"
            fi
        fi
    fi

    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -f "$src" "$dest"
    elif [ -d "$src" ]; then
        mkdir -p "$dest"
        cp -rf "$src/." "$dest/"
    fi
}

deploy "$DOTFILES_DIR/cava"                  "$HOME/.config/cava"              "cava"
deploy "$DOTFILES_DIR/kitty"                 "$HOME/.config/kitty"             "kitty"
deploy "$DOTFILES_DIR/waybar"                "$HOME/.config/waybar"            "waybar"
deploy "$DOTFILES_DIR/wlogout"               "$HOME/.config/wlogout"           "wlogout"
deploy "$DOTFILES_DIR/hypr"                  "$HOME/.config/hypr"              "hypr"
deploy "$DOTFILES_DIR/rofi"                  "$HOME/.config/rofi"              "rofi"

info "Setting up wlogout icons from Fluent-dark..."
ICON_SRC="$HOME/.local/share/icons/Fluent-dark/scalable/apps"

if [ -d "$ICON_SRC" ]; then
    mkdir -p "$HOME/.config/wlogout/icons"
    declare -A ICONS=(
        [lock]="system-lock-screen"
        [logout]="gnome-logout"
        [suspend]="system-suspend"
        [hibernate]="system-suspend-hibernate"
        [reboot]="system-reboot"
        [shutdown]="system-shutdown"
    )
    for dest in "${!ICONS[@]}"; do
        src_file="$ICON_SRC/${ICONS[$dest]}.svg"
        if [ -f "$src_file" ]; then
            cp "$src_file" "$HOME/.config/wlogout/icons/$dest.svg"
        else
            warn "Icon not found: ${ICONS[$dest]}.svg"
        fi
    done
    ok "wlogout icons installed."
else
    warn "Fluent-dark icon theme not found, skipping wlogout icons."
fi

# ─── Wallpapers ───────────────────────────────────────────────────────────
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    cp -rf "$DOTFILES_DIR/wallpapers/." "$IMG_DIR/"
fi

# ─── Permissions ──────────────────────────────────────────────────────────
info "Fixing script permissions..."
find "$HOME/.config" -type f -name "*.sh" -exec chmod +x {} +
find "$DOTFILES_DIR" -type f -name "*.sh" -exec chmod +x {} +


echo -e "\n${GREEN}${BOLD}┌──────────────────────────────────────────────────┐"
echo "│              All done! Reboot when ready :)        │"
echo "└──────────────────────────────────────────────────┘${RESET}\n"
