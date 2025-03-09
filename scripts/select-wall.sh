#!/bin/bash
# Set config paths
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/scripts"
RofiConf="$XDG_CONFIG_HOME/rofi/catppuccin-def.rasi"
WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

select_wallpaper() {
    # Create a temporary theme file for the 3x3 grid
    TEMP_THEME="/tmp/rofi_wall_grid.rasi"
    
    # Write a simple theme override to the temporary file with shortened text
    cat > "$TEMP_THEME" << EOF
* {
    lines: 3;
}
window {
    width: 85%;
}
listview {
    columns: 3;
    spacing: 20px;
}
element {
    padding: 10px;
    orientation: vertical;
}
element-icon {
    size: 220px;
    border-radius: 8px;
}
element-text {
    enabled: true;
    padding-top: 2px;
    font-size: 5px;
    horizontal-align: 0.5;
}
EOF

    # Process and display wallpapers with shortened names
    imgpath=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf | while read -r file; do
        # Get the filename without path and extension, limit to 15 chars
        filename=$(basename "$file")
        short_name=$(echo "${filename%.*}" | cut -c 1-15)
        if [ "${#filename}" -gt 15 ]; then
            short_name="${short_name}..."
        fi
        echo -en "$file\x00icon\x1f$file\x1finfo\x1f$short_name\n"
    done | rofi -dmenu -theme "$RofiConf" -theme-str "@import \"$TEMP_THEME\"" -show-icons)
    
    # Clean up the temporary theme file
    rm -f "$TEMP_THEME"
    
    # Check if a wallpaper was selected
    if [ -z "$imgpath" ]; then
        echo "No wallpaper selected. Exiting..."
        exit 0
    fi
    
    # Apply wallpaper using switch-wall.sh
    "$CONFIG_DIR/switch-wall.sh" "$imgpath"
}

# Start wallpaper selection
select_wallpaper
