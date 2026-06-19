#!/usr/bin/env bash
#
# install-octowow-headless.sh — (almost) fully automatic OctoWoW installation on Bazzite
#
# Primary path = OctoUpdater (headless, no launcher needed).
#
# Does in ONE run:
#   1. Create game folder
#   2. Fetch OctoUpdater, set CLIENT_DIR, download the COMPLETE client headless
#   3. Write realmlist.wtf
#   4. Generate Lutris entry from octowow-bazzite.yml (prefix NEXT TO the folder,
#      start EXE + DXVK adaptive depending on the files present) and open the installer
#   5. (optional) Install Lutris artwork
#
# After that, just: in Lutris click "Install" ONCE -> "Play".
#
# IMPORTANT (Steam Deck lesson 19.06.2026): The Wine prefix sits NEXT TO the
# game folder, never inside it (otherwise recursive directory scan -> #132). The
# octowow-bazzite.yml does this automatically ($GAMEDIR/../octowow-prefix).
#
# Note: OctoUpdater downloads the RAW client (WoW.exe). For the fully modernized
# stack (VanillaFixes chainloader, DXVK d3d9.dll, LAA patch) let the official
# OctoLauncher do its INSTALL run once; afterwards this script detects
# VanillaFixes.exe/d3d9.dll automatically and sets the Lutris config accordingly.
#
# The GUI launcher is NOT needed. Anyone who still wants it as a fallback
# (e.g. for later large updates) sets WITH_LAUNCHER=1.
#
# !!! EXPERIMENTAL / PLEASE CHECK ON THE FIRST RUN !!!
#   - The OctoUpdater menu inputs (3 = Full download, y = confirm, 4 = Quit) are
#     derived from the source code, but not tested by me. If the download doesn't
#     go through, just use the GUI launcher (placed below as a fallback).
#   - AIO setup (Step 2) and HD patches are forum attachments without a stable URL and
#     stay manual (see README.md). Optionally hookable here via the AIO_URL environment variable.
#
# Usage:
#   chmod +x install-octowow-headless.sh
#   ./install-octowow-headless.sh
#   # optional custom folder:   OCTOWOW_DIR=~/Games/OctoWoW ./install-octowow-headless.sh
#   # optional automatic AIO:   AIO_URL="https://.../OctoWoW_AIO_Setup.zip" ./install-octowow-headless.sh

set -euo pipefail

GAME_DIR="${OCTOWOW_DIR:-$HOME/Spiele/OctoWoW}"   # Linux filesystem, NOT NTFS
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

UPDATER_URL="https://raw.githubusercontent.com/OctoScripting/OctoUpdater/main/updater.py"
LAUNCHER_URL="https://github.com/nikany96/OctoLauncherForLinuxDistros/releases/download/v1.0/OctoLauncher.AppImage"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
die()   { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; exit 1; }

# --- 0. Prerequisites -------------------------------------------------------
command -v curl    >/dev/null || die "curl missing."
command -v python3 >/dev/null || die "python3 missing (OctoUpdater needs Python 3.10+)."
if ! python3 -c 'import sys; raise SystemExit(0 if sys.version_info>=(3,10) else 1)'; then
  warn "Python < 3.10 detected — OctoUpdater requires 3.10+. Trying anyway."
fi
# Detect Lutris — native (rpm) OR Flatpak
if command -v lutris >/dev/null 2>&1; then
  LUTRIS=(lutris)
  ok "Lutris found (native): $(command -v lutris)"
elif flatpak info net.lutris.Lutris >/dev/null 2>&1; then
  LUTRIS=(flatpak run net.lutris.Lutris)
  ok "Lutris found (Flatpak)."
else
  LUTRIS=()
  warn "Lutris not found. Install it first (e.g. flatpak install -y flathub net.lutris.Lutris)."
fi
[[ -f "$SCRIPT_DIR/octowow-bazzite.yml" ]] || die "octowow-bazzite.yml missing next to this script."

mkdir -p "$GAME_DIR"
ok "Game folder: $GAME_DIR"

# --- 1. (optional) Launcher as fallback -----------------------------------
if [[ "${WITH_LAUNCHER:-0}" == "1" ]]; then
  info "WITH_LAUNCHER=1 — downloading Linux launcher as fallback ..."
  curl -L --fail -o "$GAME_DIR/OctoLauncher.AppImage" "$LAUNCHER_URL"
  chmod +x "$GAME_DIR/OctoLauncher.AppImage"
  ok "Launcher placed: $GAME_DIR/OctoLauncher.AppImage"
else
  ok "Launcher skipped (not needed — download runs through OctoUpdater)."
fi

# --- 2. Fetch OctoUpdater + set CLIENT_DIR ---------------------------------
info "Fetching OctoUpdater ..."
curl -L --fail -o "$WORK/updater.py" "$UPDATER_URL"
# Set CLIENT_DIR to the game folder (only the active, non-commented line)
sed -i "s|^CLIENT_DIR = Path(.*|CLIENT_DIR = Path(\"$GAME_DIR\")|" "$WORK/updater.py"
grep -q "Path(\"$GAME_DIR\")" "$WORK/updater.py" \
  && ok "CLIENT_DIR set: $GAME_DIR" \
  || warn "Could not reliably set CLIENT_DIR — please check updater.py."

# --- 3. Download the complete client headless ------------------------------
info "Starting full client download (headless) ... this may take a while."
# Verified sequence (fresh installation):
#   Main menu 3 = Full download  ->  Data submenu 3 = Download all  ->  WoW.exe y = Proceed  ->  Main menu 4 = Quit
if printf '3\n3\ny\n4\n' | python3 "$WORK/updater.py"; then
  ok "Client download complete."
else
  warn "Headless download failed."
  warn "As a fallback use the GUI launcher:  run again with WITH_LAUNCHER=1,"
  warn "then  $GAME_DIR/OctoLauncher.AppImage  ->  folder $GAME_DIR  ->  Verify"
fi

# --- 4. realmlist ----------------------------------------------------------
printf 'set realmlist 185.165.170.6\nset patchlist 185.165.170.6\n' > "$GAME_DIR/realmlist.wtf"
ok "realmlist.wtf written."

# --- 5. (optional) AIO setup, if URL provided ------------------------------
if [[ -n "${AIO_URL:-}" ]]; then
  info "Downloading & extracting AIO setup ..."
  curl -L --fail -o "$WORK/aio.zip" "$AIO_URL"
  command -v unzip >/dev/null && unzip -o "$WORK/aio.zip" -d "$GAME_DIR" && ok "AIO extracted." \
    || warn "unzip missing — please extract AIO manually."
else
  warn "No AIO_URL set — please do AIO setup (Step 2) manually (see README.md)."
fi

# --- 6. Generate Lutris entry & open installer -----------------------------
# Adapt start EXE + DXVK to what was actually downloaded/installed:
#   - VanillaFixes.exe (chainloader) preferred, otherwise WoW.exe directly
#   - if a d3d9.dll (DXVK) is in the folder -> Lutris DXVK OFF + override d3d9=n,b,
#     otherwise Lutris DXVK ON (and no d3d9 override)
EXE_NAME="WoW.exe"
[[ -f "$GAME_DIR/VanillaFixes.exe" ]] && EXE_NAME="VanillaFixes.exe"
if [[ -f "$GAME_DIR/d3d9.dll" ]]; then
  DXVK_FLAG="false"; OVERRIDES="mscoree=;mshtml=;d3d9=n,b"
else
  DXVK_FLAG="true";  OVERRIDES="mscoree=;mshtml="
fi
ok "Start EXE: $EXE_NAME · Lutris DXVK: $DXVK_FLAG"

# Prefix NEXT TO the game folder (never inside -> otherwise recursive scan/#132)
PREFIX_DIR="$(dirname "$GAME_DIR")/octowow-prefix"
ok "Wine prefix: $PREFIX_DIR"

RESOLVED="$WORK/octowow-bazzite.resolved.yml"
# Resolve template: first normalize prefix path, then $GAMEDIR, then set exe/dxvk/overrides
sed -e "s|\$GAMEDIR/\.\./octowow-prefix|$PREFIX_DIR|g" \
    -e "s|\$GAMEDIR|$GAME_DIR|g" \
    -e "s|^\( *exe:\).*|\1 $GAME_DIR/$EXE_NAME|" \
    -e "s|^\( *dxvk:\).*|\1 $DXVK_FLAG|" \
    -e "s|^\( *WINEDLLOVERRIDES:\).*|\1 $OVERRIDES|" \
    "$SCRIPT_DIR/octowow-bazzite.yml" > "$RESOLVED"
cp "$RESOLVED" "$GAME_DIR/octowow-bazzite.resolved.yml"  # keep a copy (WORK gets deleted)
ok "Lutris script generated: $GAME_DIR/octowow-bazzite.resolved.yml"

info "Opening Lutris installer — please click \"Install\" there once ..."
if [[ ${#LUTRIS[@]} -eq 0 ]] || ! "${LUTRIS[@]}" -i "$GAME_DIR/octowow-bazzite.resolved.yml"; then
  warn "Lutris could not be started automatically. Import manually:"
  warn "  Lutris -> + -> \"Install from a local install script\" -> $GAME_DIR/octowow-bazzite.resolved.yml"
fi

# --- 7. (optional) Install Lutris artwork ----------------------------------
if [[ -x "$SCRIPT_DIR/install-artwork.sh" && -d "$SCRIPT_DIR/artwork" ]]; then
  info "Installing Lutris artwork (icon/banner/coverart) ..."
  "$SCRIPT_DIR/install-artwork.sh" --lutris octowow && ok "Artwork installed (restart Lutris)." \
    || warn "Artwork installation skipped."
else
  warn "Artwork script/folder not found — artwork skipped (optional)."
fi

cat <<EOF

------------------------------------------------------------
Done (except for the one click).
  - Client is located in:  $GAME_DIR
  - Wine prefix:           $PREFIX_DIR   (deliberately NEXT TO the game folder)
  - Start EXE:             $EXE_NAME  ·  Lutris DXVK: $DXVK_FLAG
  - In Lutris: OctoWoW -> Play   (restart Lutris once if needed, then the artwork is there too)
  - Optional: AIO/modernization & HD patches -> see README.md (Step 2,4,5)
------------------------------------------------------------
EOF
