#!/usr/bin/env bash

# Configuration (hardcoded, no external config file)
battery_full_threshold=95        # Notify when battery is full (80–100)
battery_critical_threshold=5     # Critical battery level (2–50)
battery_low_threshold=20         # Low battery level (10–80)
unplug_charger_threshold=80     # Unplug charger threshold (50–100)
timer=120                       # Seconds for critical action countdown
notify=60                       # Minutes between full battery notifications
interval=5                      # Percentage interval for low/unplug notifications
execute_critical="systemctl suspend"  # Command for critical battery
execute_low=""                  # Command for low battery
execute_unplug=""               # Command for unplug notification
execute_charging=""             # Command when charging
execute_discharging=""          # Command when discharging

# Check if the system is a laptop
is_laptop() {
    if grep -q "Battery" /sys/class/power_supply/BAT*/type 2>/dev/null; then
        return 0  # It's a laptop
    else
        echo "No battery detected. Exiting."
        exit 1
    fi
}

# Send notification
fn_notify() {
    local replace_id="$1" urgency="$2" title="$3" message="$4"
    if [ -n "$replace_id" ]; then
        notify-send -a "Power" -r "$replace_id" -u "$urgency" "$title" "$message" -t 5000
    else
        notify-send -a "Power" -u "$urgency" "$title" "$message" -t 5000
    fi
}

# Get battery info
get_battery_info() {
    total_percentage=0
    battery_count=0
    for battery in /sys/class/power_supply/BAT*; do
        if [ -f "$battery/status" ] && [ -f "$battery/capacity" ]; then
            battery_status=$(<"$battery/status")
            battery_percentage=$(<"$battery/capacity")
            total_percentage=$((total_percentage + battery_percentage))
            battery_count=$((battery_count + 1))
        fi
    done
    if [ $battery_count -gt 0 ]; then
        battery_percentage=$((total_percentage / battery_count))
    else
        echo "No battery data available."
        exit 1
    fi
}

# Handle notifications based on percentage
fn_percentage() {
    if [ "$battery_percentage" -ge "$unplug_charger_threshold" ] && [ "$battery_status" != "Discharging" ] && [ "$battery_status" != "Full" ] && [ $((battery_percentage - last_notified_percentage)) -ge $interval ]; then
        fn_notify "" "CRITICAL" "Battery Charged" "Battery is at $battery_percentage%. Unplug the charger."
        last_notified_percentage=$battery_percentage
        [ -n "$execute_unplug" ] && $execute_unplug
    elif [ "$battery_percentage" -le "$battery_critical_threshold" ] && [ "$battery_status" = "Discharging" ]; then
        count=$timer
        while [ $count -gt 0 ] && [ "$battery_status" = "Discharging" ]; do
            fn_notify "69" "CRITICAL" "Battery Critically Low" "$battery_percentage% is critically low. Suspending in $((count/60)):$((count%60))."
            count=$((count - 1))
            sleep 1
            get_battery_info
        done
        [ $count -eq 0 ] && [ -n "$execute_critical" ] && $execute_critical
    elif [ "$battery_percentage" -le "$battery_low_threshold" ] && [ "$battery_status" = "Discharging" ] && [ $((last_notified_percentage - battery_percentage)) -ge $interval ]; then
        fn_notify "" "CRITICAL" "Battery Low" "Battery is at $battery_percentage%. Connect the charger."
        last_notified_percentage=$battery_percentage
        [ -n "$execute_low" ] && $execute_low
    fi
}

# Handle battery status changes
fn_status() {
    if [ "$battery_percentage" -ge "$battery_full_threshold" ] && [ "$battery_status" != "Discharging" ]; then
        battery_status="Full"
    fi

    case "$battery_status" in
        "Discharging")
            if [ "$prev_status" != "Discharging" ] || [ "$prev_status" = "Full" ]; then
                prev_status=$battery_status
                urgency=$([ "$battery_percentage" -le "$battery_low_threshold" ] && echo "CRITICAL" || echo "NORMAL")
                fn_notify "54321" "$urgency" "Charger Unplugged" "Battery is at $battery_percentage%."
                [ -n "$execute_discharging" ] && $execute_discharging
            fi
            fn_percentage
            ;;
        "Charging"|"Not charging")
            if [ "$prev_status" = "Discharging" ] || [ "$prev_status" = "Not charging" ]; then
                prev_status=$battery_status
                urgency=$([ "$battery_percentage" -ge "$unplug_charger_threshold" ] && echo "CRITICAL" || echo "NORMAL")
                fn_notify "54321" "$urgency" "Charger Plugged In" "Battery is at $battery_percentage%."
                [ -n "$execute_charging" ] && $execute_charging
            fi
            fn_percentage
            ;;
        "Full")
            now=$(date +%s)
            if [ "$prev_status" != "Full" ] || [ $((now - lt)) -ge $((notify * 60)) ]; then
                fn_notify "54321" "CRITICAL" "Battery Full" "Unplug your charger."
                prev_status=$battery_status
                lt=$now
                [ -n "$execute_charging" ] && $execute_charging
            fi
            ;;
        *)
            echo "Unknown battery status: $battery_status"
            fn_percentage
            ;;
    esac
}

# Main function
main() {
    is_laptop
    get_battery_info
    last_notified_percentage=$battery_percentage
    prev_status=$battery_status
    lt=$(date +%s)

    # Monitor battery changes via D-Bus
    dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',path='$(upower -e | grep battery)'" 2>/dev/null | while read -r line; do
        get_battery_info
        if [ "$battery_status" != "$last_battery_status" ] || [ "$battery_percentage" != "$last_battery_percentage" ]; then
            last_battery_status=$battery_status
            last_battery_percentage=$battery_percentage
            fn_status
        fi
    done
}

# Parse command-line options
verbose=false
while [ $# -gt 0 ]; do
    case "$1" in
        -v|--verbose)
            verbose=true
            ;;
        -h|--help)
            echo "Usage: $0 [-v|--verbose] [-h|--help]"
            echo "  -v, --verbose: Enable verbose output"
            echo "  -h, --help: Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Verbose output function
fn_verbose() {
    if $verbose; then
        echo "============================================="
        echo "        Battery Status: $battery_status"
        echo "        Battery Percentage: $battery_percentage"
        echo "============================================="
    fi
}

# Start the script
main
