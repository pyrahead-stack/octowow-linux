#!/usr/bin/env bash
# Shown when you press "Play" on OctoWoW in Lutris: pick what to start.
#   Play OctoWoW  -> the game (VanillaFixes chainloader, modernized + DXVK)
#   OctoLauncher  -> manage patches / tweaks / addons (NOT for playing)
# If no dialog tool is available, it just plays the game.
set -euo pipefail

GAMEDIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
PLAY="$GAMEDIR/play-octowow.sh"

# The launcher lives in a sibling "<game>-launcher" folder (see setup-launcher.sh).
LAUNCHER="$(cd "$GAMEDIR/.." && pwd)/octowow-launcher/start-octolauncher.sh"

CHOICE=""
if command -v kdialog >/dev/null 2>&1; then
  CHOICE=$(kdialog --title "OctoWoW" --menu "What do you want to start?" \
      play     "🎮 Play OctoWoW" \
      launcher "🔧 OctoLauncher (manage patches / tweaks / addons)" 2>/dev/null) || exit 0
elif command -v zenity >/dev/null 2>&1; then
  CHOICE=$(zenity --list --title="OctoWoW" --text="What do you want to start?" \
      --hide-header --print-column=1 --column=key --column=desc \
      play     "🎮 Play OctoWoW" \
      launcher "🔧 OctoLauncher (manage patches / tweaks / addons)" 2>/dev/null) || exit 0
else
  CHOICE=play   # no dialog tool -> just play
fi

case "$CHOICE" in
  play)     exec "$PLAY" ;;
  launcher)
    if [ -x "$LAUNCHER" ]; then exec "$LAUNCHER"; fi
    echo "OctoLauncher not found at $LAUNCHER (run setup-launcher.sh first)." >&2
    exit 1 ;;
  *)        exit 0 ;;   # cancelled
esac
