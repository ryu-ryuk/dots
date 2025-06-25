#!/bin/bash

# Check dependencies
command -v rofi >/dev/null 2>&1 || { echo "rofi is required but not installed"; exit 1; }
command -v nmcli >/dev/null 2>&1 || { echo "nmcli is required but not installed"; exit 1; }

# Configuration
ROFI_CONFIG="$HOME/.config/rofi/wifi-menu.rasi"
NOTIFY_TIMEOUT=3000

# Functions
notify_send() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -t $NOTIFY_TIMEOUT "WiFi" "$1"
    fi
}

get_wifi_status() {
    nmcli -t -f WIFI g | grep -q "enabled" && echo "enabled" || echo "disabled"
}

get_current_connection() {
    nmcli -t -f NAME connection show --active | head -1
}

get_wifi_list() {
    nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE device wifi list | \
    awk -F: '
    $1 != "" {
        ssid = $1
        signal = $2
        security = $3
        in_use = $4
        
        # Security icon
        if (security ~ /WPA|WEP/) {
            sec_icon = "🔒"
        } else {
            sec_icon = "📶"
        }
        
        # Signal strength bars
        if (signal >= 75) bars = "▰▰▰▰"
        else if (signal >= 50) bars = "▰▰▰▱"
        else if (signal >= 25) bars = "▰▰▱▱"
        else bars = "▰▱▱▱"
        
        # Current connection indicator
        if (in_use == "*") {
            printf "✓ %s %s %s (%s%%)\n", sec_icon, ssid, bars, signal
        } else {
            printf "%s %s %s (%s%%)\n", sec_icon, ssid, bars, signal
        }
    }' | sort -k2
}

# Main menu
main_menu() {
    local wifi_status=$(get_wifi_status)
    local current=$(get_current_connection)
    local menu_items=""
    
    if [[ "$wifi_status" == "enabled" ]]; then
        menu_items="🔄 Refresh
📡 WiFi: ON
📶 Current: ${current:-None}
───────────────
$(get_wifi_list)
───────────────
📱 Manual Connection
⚙️ Network Settings
🔌 Disconnect Current
📴 Turn WiFi OFF"
    else
        menu_items="📡 Turn WiFi ON
⚙️ Network Settings"
    fi
    echo -e "$menu_items" | rofi -dmenu -p "WiFis~" -config "~/.config/rofi/config.rasi" -format "s"


}

# Connect to network
connect_network() {
    local selection="$1"
    local ssid=$(echo "$selection" | sed -E 's/^[✓🔒📶] //' | awk '{print $1}')
    
    # Check if connection already exists
    local existing=$(nmcli -t -f NAME connection show | grep "^$ssid$")
    
    if [[ -n "$existing" ]]; then
        nmcli connection up "$ssid"
        notify_send "Connected to $ssid"
    else
        # Check if network is secured
        local security=$(nmcli -t -f SSID,SECURITY device wifi list | grep "^$ssid:" | cut -d: -f2)
        
        if [[ "$security" =~ (WPA|WEP) ]]; then
            local password=$(echo "" | rofi -dmenu -p "Password for $ssid" -password -config "$ROFI_CONFIG")
            if [[ -n "$password" ]]; then
                if nmcli device wifi connect "$ssid" password "$password"; then
                    notify_send "Connected to $ssid"
                else
                    notify_send "Failed to connect to $ssid"
                fi
            fi
        else
            if nmcli device wifi connect "$ssid"; then
                notify_send "Connected to $ssid"
            else
                notify_send "Failed to connect to $ssid"
            fi
        fi
    fi
}

# Manual connection
manual_connection() {
    local ssid=$(echo "" | rofi -dmenu -p "Enter SSID" -config "$ROFI_CONFIG")
    [[ -z "$ssid" ]] && exit 0
    
    local password=$(echo "" | rofi -dmenu -p "Password (leave blank for open)" -password -config "$ROFI_CONFIG")
    
    if [[ -n "$password" ]]; then
        nmcli device wifi connect "$ssid" password "$password"
    else
        nmcli device wifi connect "$ssid"
    fi
    
    notify_send "Attempting to connect to $ssid"
}

# Main logic
selection=$(main_menu)

case "$selection" in
    "🔄 Refresh")
        exec "$0"
        ;;
    "📡 Turn WiFi ON")
        nmcli radio wifi on
        notify_send "WiFi enabled"
        ;;
    "📴 Turn WiFi OFF")
        nmcli radio wifi off
        notify_send "WiFi disabled"
        ;;
    "📱 Manual Connection")
        manual_connection
        ;;
    "⚙️ Network Settings")
        nm-connection-editor &
        ;;
    "🔌 Disconnect Current")
        local current=$(get_current_connection)
        if [[ -n "$current" ]]; then
            nmcli connection down "$current"
            notify_send "Disconnected from $current"
        fi
        ;;
    *"🔒"*|*"📶"*|*"✓"*)
        connect_network "$selection"
        ;;
esac

