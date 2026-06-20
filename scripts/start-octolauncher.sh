#!/usr/bin/env bash
# Start the official OctoLauncher (Electron) under Proton via umu.
# Use it to download the client and to enable/apply tweaks (vanillaFixes,
# largeAddress) and HD patches. Its PLAY button works once the client is
# installed cleanly (the old "injection fails under Proton" was a misdiagnosis
# of a corrupt WoW.exe). Exception: HD users play via Lutris — opening the
# launcher rewrites patch-A and clobbers the HD patch-A.
#
# Place this script in the launcher folder, next to its "prefix".
set -euo pipefail

APPBASE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
export WINEPREFIX="$APPBASE/prefix"
export GAMEID="${GAMEID:-0}"

# Find GE-Proton (native Steam, classic Steam, or Flatpak Steam).
find_proton() {
  local base p
  for base in \
    "$HOME/.local/share/Steam/compatibilitytools.d" \
    "$HOME/.steam/steam/compatibilitytools.d" \
    "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d"; do
    [ -d "$base" ] || continue
    for p in "$base"/GE-Proton* "$base"/*; do
      [ -e "$p/proton" ] && { printf '%s' "$p"; return 0; }
    done
  done
  return 1
}
# Prefer a GE-Proton if one is installed; otherwise set PROTONPATH=GE-Proton, the
# umu keyword that makes umu download the latest GE-Proton itself (~400 MB, first
# run only). This is what lets a fresh non-Steam machine (e.g. Linux Mint) work
# with just umu installed. (umu's bare auto-fetch with PROTONPATH empty is NOT
# reliable — on a fresh Mint it failed with "UMU-Proton not found".)
export PROTONPATH="${PROTONPATH:-$(find_proton || true)}"
if [ -z "${PROTONPATH:-}" ]; then
  echo "No local GE-Proton — using PROTONPATH=GE-Proton so umu downloads it (first run pulls ~400 MB)." >&2
  export PROTONPATH=GE-Proton
fi

LAUNCHER="$WINEPREFIX/drive_c/users/steamuser/AppData/Local/Programs/OctoLauncher/OctoLauncher.exe"
if [ ! -f "$LAUNCHER" ]; then
  echo "OctoLauncher.exe not found. Run setup-launcher.sh first." >&2
  exit 1
fi

UMU="$(command -v umu-run || true)"
[ -z "$UMU" ] && { echo "umu-run not found. Install the 'umu-launcher' package." >&2; exit 1; }

exec "$UMU" "$LAUNCHER" --no-sandbox
