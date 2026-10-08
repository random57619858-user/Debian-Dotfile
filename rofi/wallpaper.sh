#!/bin/bash
set -euo pipefail

CACHE_FILE="$HOME/.cache/current_wallpaper"
CACHE_DIR="$(dirname "$CACHE_FILE")"
SWAYBG_MODE="${SWAYBG_MODE:-fill}"

detect_image_dir() {
    for dir in "$HOME/Pictures" "$HOME/Images" "$HOME/Imágenes"; do
        if [ -d "$dir" ]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

require_cmd() {
    if ! command -v "$1" &>/dev/null; then
        notify-send "Wallpaper" "$1 is not installed" 2>/dev/null || echo "$1 is not installed" >&2
        exit 1
    fi
}

apply_wallpaper() {
    local img="$1"
    pkill -x swaybg 2>/dev/null || true
    swaybg -i "$img" -m "$SWAYBG_MODE" >/dev/null 2>&1 &
    disown
}

restore_wallpaper() {
    [ -f "$CACHE_FILE" ] || return 0
    local saved
    saved=$(cat "$CACHE_FILE")
    if [ -f "$saved" ]; then
        apply_wallpaper "$saved"
    fi
}

require_cmd swaybg

if [ "${1:-}" = "restore" ]; then
    restore_wallpaper
    exit 0
fi

require_cmd rofi

IMAGE_DIR=$(detect_image_dir) || {
    notify-send "Wallpaper" "No image directory found" 2>/dev/null || echo "No image directory found" >&2
    exit 1
}

TEMP_LIST=$(mktemp)
trap 'rm -f "$TEMP_LIST"' EXIT

find "$IMAGE_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) \
    -printf "%P|%p\n" | sort > "$TEMP_LIST"

if [ ! -s "$TEMP_LIST" ]; then
    notify-send "Wallpaper" "No images found in $IMAGE_DIR" 2>/dev/null || echo "No images found" >&2
    exit 1
fi

chosen=$(awk -F'|' '{print $1}' "$TEMP_LIST" | rofi -dmenu -p "󰸉 Wallpaper" -i -matching fuzzy)

if [ -n "${chosen:-}" ]; then
    full_path=$(grep -F "$chosen|" "$TEMP_LIST" | head -n 1 | cut -d'|' -f2-)
    if [ -f "$full_path" ]; then
        mkdir -p "$CACHE_DIR"
        echo "$full_path" > "$CACHE_FILE"
        apply_wallpaper "$full_path"
    fi
fi
