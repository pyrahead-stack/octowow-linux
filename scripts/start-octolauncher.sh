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
# Prefer a GE-Proton if one is installed; otherwise leave PROTONPATH unset so umu
# fetches its own UMU-Proton, which runs the launcher fine (proven in testing).
# This is what lets a fresh non-Steam machine (e.g. Linux Mint) work with just umu.
export PROTONPATH="${PROTONPATH:-$(find_proton || true)}"
if [ -z "${PROTONPATH:-}" ]; then
  echo "No GE-Proton found — letting umu fetch its own UMU-Proton (first run may take a minute)." >&2
  unset PROTONPATH
fi

LAUNCHER="$WINEPREFIX/drive_c/users/steamuser/AppData/Local/Programs/OctoLauncher/OctoLauncher.exe"
if [ ! -f "$LAUNCHER" ]; then
  echo "OctoLauncher.exe not found. Run setup-launcher.sh first." >&2
  exit 1
fi

UMU="$(command -v umu-run || true)"
[ -z "$UMU" ] && { echo "umu-run not found. Install the 'umu-launcher' package." >&2; exit 1; }

exec "$UMU" "$LAUNCHER" --no-sandbox
