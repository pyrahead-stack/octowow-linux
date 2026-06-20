#!/usr/bin/env bash
#
# install-octowow-headless.sh — APPENDIX / "for tinkerers"
# ============================================================================
# A no-GUI way to download a BARE OctoWoW client via the OctoUpdater and register
# it in Lutris. This does NOT modernize the game: no VanillaFixes (multicore fix),
# no LAA (4 GB / anti-green-screen), no HD. For a stable, modernized install use
# the launcher-centric path in the main README instead.
#
# What it does:
#   1. Create ~/Games/octowow
#   2. Fetch the OctoUpdater, download the complete client (headless)
#   3. Replace the OctoUpdater-patched WoW.exe with the RAW server WoW.exe
#      (the OctoUpdater's patch_wow_exe() corrupts the 4.9 MB build -> instant
#       crash; proven by A/B test. The raw exe runs.)
#   4. Write realmlist.wtf
#   5. Generate a minimal Lutris install script (runner: wine, pinned wine-ge,
#      prefix NEXT TO the folder, DXVK on) and open the installer
#
# Usage:
#   ./install-octowow-headless.sh
#   OCTOWOW_DIR=~/Games/octowow ./install-octowow-headless.sh   # custom folder
set -euo pipefail

GAME_DIR="${OCTOWOW_DIR:-$HOME/Games/octowow}"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

UPDATER_URL="https://raw.githubusercontent.com/OctoScripting/OctoUpdater/main/updater.py"
RAW_WOW_URL="https://octowow.st/client/latest/WoW.exe"   # SHA1 1707f3b1cf31d24041ebf58406ef6d75b47c1c55
WINE_VERSION="wine-ge-8-26-x86_64"                       # win32-capable; NOT Proton

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
die()   { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; exit 1; }

command -v curl    >/dev/null || die "curl missing."
command -v python3 >/dev/null || die "python3 missing (OctoUpdater needs Python 3.10+)."
if command -v lutris >/dev/null 2>&1; then LUTRIS=(lutris)
elif flatpak info net.lutris.Lutris >/dev/null 2>&1; then LUTRIS=(flatpak run net.lutris.Lutris)
else LUTRIS=(); warn "Lutris not found — install it (flatpak install -y flathub net.lutris.Lutris)."; fi

mkdir -p "$GAME_DIR"; ok "Game folder: $GAME_DIR"

info "Fetching OctoUpdater ..."
curl -L --fail -o "$WORK/updater.py" "$UPDATER_URL"
sed -i "s|^CLIENT_DIR = Path(.*|CLIENT_DIR = Path(\"$GAME_DIR\")|" "$WORK/updater.py"

info "Downloading full client (headless) — this takes a while ..."
# Fresh-folder sequence: main 3=Full -> data 3=all -> WoW.exe y -> main 4=Quit.
printf '3\n3\ny\n4\n' | python3 "$WORK/updater.py" || warn "OctoUpdater reported an error — check the client folder."

info "Replacing patched WoW.exe with the raw server build (avoids the crash) ..."
if curl -L --fail -o "$WORK/WoW.exe" "$RAW_WOW_URL"; then
  [ -f "$GAME_DIR/WoW.exe" ] && cp "$GAME_DIR/WoW.exe" "$GAME_DIR/WoW.exe.octopatched.bak"
  cp "$WORK/WoW.exe" "$GAME_DIR/WoW.exe"
  ok "Raw WoW.exe in place (old one kept as WoW.exe.octopatched.bak)."
else
  warn "Could not fetch raw WoW.exe — the game may crash on launch (OctoUpdater patch bug)."
fi

printf 'set realmlist 185.165.170.6\nset patchlist 185.165.170.6\n' > "$GAME_DIR/realmlist.wtf"
ok "realmlist.wtf written."

PREFIX_DIR="$(dirname "$GAME_DIR")/octowow-prefix"
YML="$GAME_DIR/octowow-bare.yml"
cat > "$YML" <<EOF
name: OctoWoW (bare)
game_slug: octowow
version: Bare client
slug: octowow-bare
runner: wine
script:
  game:
    exe: $GAME_DIR/WoW.exe
    prefix: $PREFIX_DIR
    arch: win32
    working_dir: $GAME_DIR
  wine:
    version: $WINE_VERSION
    dxvk: true
    esync: true
    fsync: true
  installer:
    - task:
        name: create_prefix
        arch: win32
        prefix: $PREFIX_DIR
    - write_file:
        file: $GAME_DIR/realmlist.wtf
        content: |
          set realmlist 185.165.170.6
          set patchlist 185.165.170.6
EOF
ok "Lutris script generated: $YML"

info "Opening Lutris installer — click \"Install\" once there ..."
if [[ ${#LUTRIS[@]} -eq 0 ]] || ! "${LUTRIS[@]}" -i "$YML"; then
  warn "Import manually: Lutris -> + -> Install from a local install script -> $YML"
fi

cat <<EOF

------------------------------------------------------------
Done. Bare client in: $GAME_DIR  (prefix: $PREFIX_DIR)
This client is NOT modernized (no VanillaFixes/LAA/HD). For the full,
stable experience use the launcher path in the main README.
------------------------------------------------------------
EOF
