#!/usr/bin/env bash
# Play OctoWoW — launches VanillaFixes.exe (the multicore chainloader) under
# wine-ge in a 32-bit prefix, with DXVK. This is the file Lutris "Play" runs
# (via octowow-chooser.sh). This Lutris path is for HD users: it never opens the
# OctoLauncher, so the launcher's per-update patch-A rewrite can't clobber HD.
# (Non-HD players can just use the launcher's PLAY button instead — see README.)
#
# Place this script INSIDE the game folder, next to WoW.exe / VanillaFixes.exe.
set -euo pipefail

# Game dir = the folder this script lives in (no hardcoded path).
GAMEDIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# Prefix lives NEXT TO the game folder, never inside it: WoW scans the game
# folder recursively at startup, and a prefix in there can cause a stack
# overflow -> ERROR #132 before any window appears.
PREFIX="$(cd "$GAMEDIR/.." && pwd)/octowow-prefix"

# Find a wine-ge runner (native Lutris, Flatpak Lutris, or system wine).
find_wine() {
  local base w
  for base in \
    "$HOME/.local/share/lutris/runners/wine" \
    "$HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine"; do
    [ -d "$base" ] || continue
    for w in "$base"/wine-ge-8-* "$base"/wine-ge-* "$base"/lutris-* "$base"/*; do
      [ -x "$w/bin/wine" ] && { printf '%s' "$w/bin/wine"; return 0; }
    done
  done
  command -v wine >/dev/null 2>&1 && { command -v wine; return 0; }
  return 1
}

WINE="${OCTOWOW_WINE:-$(find_wine || true)}"
if [ -z "${WINE:-}" ]; then
  echo "No Wine runner found. In Lutris install a wine-ge build (Runners -> Wine)," >&2
  echo "or set OCTOWOW_WINE=/path/to/bin/wine before launching." >&2
  exit 1
fi

export WINEPREFIX="$PREFIX"
export WINEARCH=win32
export WINEDLLOVERRIDES="d3d9=n,b"   # use the DXVK d3d9.dll already in the folder
export WINEDEBUG=-all
export DXVK_HUD="${DXVK_HUD:-fps}"
export mesa_glthread=true

# Create the 32-bit prefix on first run if it does not exist yet.
if [ ! -f "$PREFIX/system.reg" ]; then
  echo "First run: creating 32-bit Wine prefix at $PREFIX ..."
  "$WINE" wineboot --init >/dev/null 2>&1 || true
fi

cd "$GAMEDIR"
exec "$WINE" VanillaFixes.exe
