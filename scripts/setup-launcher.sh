#!/usr/bin/env bash
# One-time setup for the launcher-centric OctoWoW install.
#  - creates ~/Games/octowow (the game folder Lutris defaults to) + the launcher folder
#  - drops the play/chooser scripts into the game folder
#  - downloads and silently installs the official OctoLauncher into its own prefix
#  - creates a desktop entry for the launcher
# After this: open the OctoLauncher, point it at ~/Games/octowow, enable the
# tweaks you want, and let it download/verify the client. Then add the game to
# Lutris with octowow.yml and press Play.
set -euo pipefail

PKG="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"   # this scripts/ folder
GAMES="$HOME/Games"
GAMEDIR="$GAMES/octowow"
LDIR="$GAMES/octowow-launcher"

echo "==> Creating folders"
mkdir -p "$GAMEDIR" "$LDIR"

echo "==> Installing play/chooser scripts into the game folder"
cp "$PKG/play-octowow.sh"   "$GAMEDIR/"
cp "$PKG/octowow-chooser.sh" "$GAMEDIR/"
cp "$PKG/start-octolauncher.sh" "$LDIR/"
chmod +x "$GAMEDIR"/*.sh "$LDIR"/*.sh

UMU="$(command -v umu-run || true)"
[ -z "$UMU" ] && { echo "umu-run not found. Install the 'umu-launcher' package, then re-run." >&2; exit 1; }

LAUNCHER_EXE="$LDIR/prefix/drive_c/users/steamuser/AppData/Local/Programs/OctoLauncher/OctoLauncher.exe"
if [ -f "$LAUNCHER_EXE" ]; then
  echo "==> OctoLauncher already installed, skipping download"
else
  echo "==> Downloading OctoLauncher installer"
  curl -L --fail https://octowow.st/download/launcher -o "$LDIR/OctoLauncher_Installer.exe"
  echo "==> Installing OctoLauncher silently (this can take a minute)"
  # PROTONPATH left unset -> umu fetches its own UMU-Proton; GE-Proton is used at runtime if present.
  GAMEID=0 WINEPREFIX="$LDIR/prefix" "$UMU" "$LDIR/OctoLauncher_Installer.exe" /S || true
  [ -f "$LAUNCHER_EXE" ] || { echo "Install did not produce OctoLauncher.exe — run the installer manually." >&2; exit 1; }
fi

echo "==> Creating desktop entry"
APPS="$HOME/.local/share/applications"
mkdir -p "$APPS"
cat > "$APPS/octolauncher.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=OctoLauncher
Comment=Manage OctoWoW patches / tweaks / addons
Exec=$LDIR/start-octolauncher.sh
Icon=lutris_octowow
Terminal=false
Categories=Game;
EOF
update-desktop-database "$APPS" >/dev/null 2>&1 || true

cat <<EOF

==> Done.

Next steps:
  1. Open "OctoLauncher" (desktop entry) or run:
       $LDIR/start-octolauncher.sh
  2. In the launcher set the game folder to:  $GAMEDIR
     Enable the tweaks you want (vanillaFixes, largeAddress), then Install/Verify
     to download the client. Do NOT press the launcher's PLAY button.
  3. Add the game to Lutris: + -> "Install from a local install script" ->
     octowow.yml (location = $GAMEDIR). Then press Play.
EOF
