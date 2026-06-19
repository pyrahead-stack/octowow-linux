#!/usr/bin/env bash
#
# fetch-client.sh — used by the lutris.net OctoWoW installer.
# Downloads the complete OctoWoW client into the Lutris install dir via the
# OctoUpdater (headless), then removes any bundled DXVK d3d9.dll so that Lutris'
# own DXVK is the single graphics layer.
#
# Called by the installer's `execute` step with:
#   OCTO_GAMEDIR = $GAMEDIR   (the chosen install location)
#   OCTO_UPDATER = $updater   (path to the downloaded updater.py)
#
# This mirrors the verified logic of install-octowow-headless.sh (Step 1-3).
set -euo pipefail

DIR="${OCTO_GAMEDIR:?OCTO_GAMEDIR not set}"
UP="${OCTO_UPDATER:?OCTO_UPDATER not set}"

command -v python3 >/dev/null || { echo "python3 missing (OctoUpdater needs Python 3.10+)"; exit 1; }
mkdir -p "$DIR"

# Point the OctoUpdater at the Lutris install dir (it hardcodes CLIENT_DIR at the top).
sed -i "s|^CLIENT_DIR = Path(.*|CLIENT_DIR = Path(\"$DIR\")|" "$UP"
grep -q "Path(\"$DIR\")" "$UP" || { echo "could not set CLIENT_DIR in updater.py"; exit 1; }

# Headless full download:
#   main menu 3 = Full download -> data submenu 3 = Download all -> WoW.exe y -> 4 = Quit
echo "Downloading the complete OctoWoW client (~9-10 GB) — this can take a while…"
printf '3\n3\ny\n4\n' | python3 "$UP"

# Single DXVK layer: Lutris injects DXVK (dxvk: true). If the client shipped its
# own d3d9/dxgi, remove them so the two don't stack (-> crashes/glitches).
rm -f "$DIR/d3d9.dll" "$DIR/dxgi.dll" 2>/dev/null || true

# Sanity check: a playable client has WoW.exe (and usually VanillaFixes.exe).
if [ ! -f "$DIR/WoW.exe" ] && [ ! -f "$DIR/VanillaFixes.exe" ]; then
  echo "Download finished but no WoW.exe/VanillaFixes.exe found — check the OctoUpdater output."
  exit 1
fi
echo "Client ready in: $DIR"
