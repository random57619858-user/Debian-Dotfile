#!/bin/bash

CACHE_FILE="$HOME/.cache/current_wallpaper"
CACHE_DIR="$(dirname "$CACHE_FILE")"

detect_image_dir() {
    for dir in "$HOME/Imágenes" "$HOME/Pictures" "$HOME/Images"; do
        if [ -d "$dir" ]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

restore_wallpaper() {
    if [ ! -f "$CACHE_FILE" ]; then
        return 0
    fi

    local saved
    saved=$(cat "$CACHE_FILE")

    if [ -f "$saved" ]; then
        pkill -x swaybg 2>/dev/null
        swaybg -i "$saved" -m fill >/dev/null 2>&1 &
        disown
    fi
}

if [ "$1" = "restore" ]; then
    if ! command -v swaybg &>/dev/null; then
        echo "swaybg no está instalado" >&2
        exit 1
    fi
    restore_wallpaper
    exit 0
fi

if ! command -v swaybg &>/dev/null; then
    notify-send "Error" "swaybg not installed"
    exit 1
fi

IMAGE_DIR=$(detect_image_dir)

if [ -z "$IMAGE_DIR" ]; then
    notify-send "Error"
    exit 1
fi

TEMP_LIST=$(mktemp)
trap 'rm -f "$TEMP_LIST"' EXIT

find "$IMAGE_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) \
    | sort \
    | while read -r img; do
        relpath="${img#$IMAGE_DIR/}"
        echo "$relpath|$img"
    done > "$TEMP_LIST"

if [ ! -s "$TEMP_LIST" ]; then
    notify-send "Rofi Wallpaper error"
    exit 1
fi

chosen=$(awk -F'|' '{print $1}' "$TEMP_LIST" | rofi -dmenu -p "󰸉 Wallpaper" -i)

if [ -n "$chosen" ]; then
    full_path=$(grep -F "$chosen|" "$TEMP_LIST" | head -n 1 | cut -d'|' -f2-)

    if [ -f "$full_path" ]; then
        mkdir -p "$CACHE_DIR"
        echo "$full_path" > "$CACHE_FILE"

        pkill -x swaybg 2>/dev/null
        swaybg -i "$full_path" -m fill >/dev/null 2>&1 &
        disown
    fi
fi
