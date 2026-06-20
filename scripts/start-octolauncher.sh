#!/usr/bin/env bash
# Start the official OctoLauncher (Electron) under Proton via umu.
# Use it to download the client and to enable/apply tweaks (vanillaFixes,
# largeAddress) and HD patches. Its PLAY button works once the client is
# installed cleanly (the old "injection fails under Proton" was a misdiagnosis
# of a corrupt WoW.exe). Exception: HD users play via Lutris — opening the
# launcher rewrites patch-A and clobbers the HD patch-A.
#
# Place this script in the launcher folder, next to its "prefix".
#
# PROTONPATH is left UNSET on purpose: umu then uses UMU-Proton, which waits for
# the app properly. (A forced GE-Proton can make umu's pressure-vessel container
# return early.) The first run may download UMU-Proton + the Steam runtime; if it
# ever errors once with "UMU-Proton not found" (a transient download hiccup), just
# run this again — the runtime is cached and UMU-Proton downloads on the retry.
set -euo pipefail

APPBASE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
export WINEPREFIX="$APPBASE/prefix"
export GAMEID="${GAMEID:-0}"

LAUNCHER="$WINEPREFIX/drive_c/users/steamuser/AppData/Local/Programs/OctoLauncher/OctoLauncher.exe"
if [ ! -f "$LAUNCHER" ]; then
  echo "OctoLauncher.exe not found. Run setup-launcher.sh first." >&2
  exit 1
fi

UMU="$(command -v umu-run || true)"
[ -z "$UMU" ] && { echo "umu-run not found. Install the 'umu-launcher' package." >&2; exit 1; }

exec "$UMU" "$LAUNCHER" --no-sandbox
