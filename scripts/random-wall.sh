#!/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/scripts"
$CONFIG_DIR/switch-wall.sh "$(fd . $(xdg-user-dir PICTURES)/wallpapers/ -e .png -e .jpg -e .svg | xargs shuf -n1 -e)"
