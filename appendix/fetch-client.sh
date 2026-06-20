#!/usr/bin/env bash
#
# fetch-client.sh — used by the lutris.net OctoWoW installer.
# Builds a playable client without the GUI launcher:
#   1. Download the complete OctoWoW client via the OctoUpdater (headless).
#   2. Replace the OctoUpdater-patched WoW.exe with the RAW server build — the
#      patched one is CORRUPT (instant c0000005 crash); the raw one is already
#      LAA-on (4 GB / anti-green-screen). Proven by A/B test.
#   3. Drop in VanillaFixes (multicore fix) + its bundled DXVK d3d9.dll from the
#      upstream GitHub release. VanillaFixes.exe (88 576 B) and VfPatcher.dll
#      (72 704 B) there are byte-identical to what OctoWoW's own launcher installs.
# Result: a modernized-enough client — multicore fix + LAA + a single DXVK layer.
# NOT included: HD patches (launcher-managed) and OctoWoW's VanillaHelpers.dll
# (an OctoWoW-specific injected helper; the game is playable without it).
#
# Called by the installer's `execute` step with:
#   OCTO_GAMEDIR = $GAMEDIR   (the chosen install location)
#   OCTO_UPDATER = $updater   (path to the downloaded updater.py)
set -euo pipefail

DIR="${OCTO_GAMEDIR:?OCTO_GAMEDIR not set}"
UP="${OCTO_UPDATER:?OCTO_UPDATER not set}"
RAW_WOW_URL="https://octowow.st/client/latest/WoW.exe"   # SHA1 1707f3b1cf31d24041ebf58406ef6d75b47c1c55 (raw, LAA-on)
VF_URL="https://github.com/hannesmann/vanillafixes/releases/download/v1.5.3/vanillafixes-1.5.3-dxvk.zip"

for c in python3 curl unzip; do command -v "$c" >/dev/null || { echo "$c missing"; exit 1; }; done
mkdir -p "$DIR"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# Point the OctoUpdater at the install dir (it hardcodes CLIENT_DIR at the top).
sed -i "s|^CLIENT_DIR = Path(.*|CLIENT_DIR = Path(\"$DIR\")|" "$UP"
grep -q "Path(\"$DIR\")" "$UP" || { echo "could not set CLIENT_DIR in updater.py"; exit 1; }

# Headless full download: main 3 = Full -> data 3 = Download all -> WoW.exe y -> 4 = Quit.
echo "Downloading the complete OctoWoW client (~9-10 GB) — this can take a while…"
printf '3\n3\ny\n4\n' | python3 "$UP"

# The OctoUpdater corrupts WoW.exe -> swap in the raw server build (already LAA-on).
echo "Installing the raw (non-corrupt, LAA) WoW.exe…"
if curl -L --fail -o "$TMP/WoW.exe" "$RAW_WOW_URL"; then
  [ -f "$DIR/WoW.exe" ] && cp "$DIR/WoW.exe" "$DIR/WoW.exe.octopatched.bak"
  cp "$TMP/WoW.exe" "$DIR/WoW.exe"
else
  echo "WARN: could not fetch the raw WoW.exe — the game may crash (OctoUpdater patch bug)."
fi

# VanillaFixes (+ bundled DXVK d3d9.dll, dlls.txt, dxvk.conf) into the game folder.
echo "Adding VanillaFixes (multicore fix) + its bundled DXVK…"
if curl -L --fail -o "$TMP/vf.zip" "$VF_URL"; then
  unzip -o "$TMP/vf.zip" -d "$DIR" >/dev/null
else
  echo "WARN: could not fetch VanillaFixes — the client will fall back to plain WoW.exe."
fi

# DXVK comes from the d3d9.dll now in the folder (single layer). The installer
# sets Lutris dxvk:false + WINEDLLOVERRIDES d3d9=n,b so the two don't stack.

if [ ! -f "$DIR/VanillaFixes.exe" ] && [ ! -f "$DIR/WoW.exe" ]; then
  echo "Download finished but no VanillaFixes.exe/WoW.exe found — check the OctoUpdater output."
  exit 1
fi
echo "Client ready in: $DIR"
