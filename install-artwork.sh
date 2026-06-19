#!/usr/bin/env bash
#
# OctoWoW – Artwork installer (Lutris + Steam)
# ---------------------------------------------------------------------------
# Places the bundled banner/cover/icon/hero/logo where Lutris and Steam expect
# them. Auto-detects native AND Flatpak installs. Nothing is hardcoded to a
# specific account or path.
#
# Usage:
#   ./install-artwork.sh                 # Lutris images + (if shortcut exists) Steam
#   ./install-artwork.sh --lutris        # Lutris only
#   ./install-artwork.sh --steam         # Steam only
#   ./install-artwork.sh my-slug         # different Lutris slug (default: octowow)
#
# Order for Steam:
#   1) Add OctoWoW as a Steam shortcut ONCE
#      (Lutris: right-click OctoWoW -> "Create Steam shortcut"
#       OR in Steam: Games -> "Add a Non-Steam Game")
#   2) Fully CLOSE Steam
#   3) run this script
#   4) start Steam -> poster/header/hero/logo are there
# ---------------------------------------------------------------------------
set -euo pipefail

# Name of the Steam shortcut (as it appears in Steam) and the Lutris slug.
GAME_NAME="OctoWoW"
LUTRIS_SLUG="octowow"

HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
ART_LUTRIS="$HERE/artwork/lutris"
ART_STEAM="$HERE/artwork/steam"

c_ok="\033[0;32m"; c_warn="\033[0;33m"; c_err="\033[0;31m"; c_inf="\033[0;36m"; c0="\033[0m"
ok(){   echo -e "${c_ok}✔${c0} $*"; }
inf(){  echo -e "${c_inf}•${c0} $*"; }
warn(){ echo -e "${c_warn}!${c0} $*"; }
err(){  echo -e "${c_err}✗${c0} $*" >&2; }

# ---- Arguments: --lutris/--steam/--all + optional slug ----
DO_LUTRIS=1; DO_STEAM=1
for a in "$@"; do
  case "$a" in
    --lutris) DO_STEAM=0 ;;
    --steam)  DO_LUTRIS=0 ;;
    --all)    ;;
    --*) err "Unknown option: $a"; exit 2 ;;
    *)  LUTRIS_SLUG="$a" ;;   # anything else = slug override (backwards compatible)
  esac
done

[ -d "$ART_LUTRIS" ] || { err "Artwork folder missing: $ART_LUTRIS"; exit 1; }

# --------------------------------------------------------------------------
# LUTRIS
# --------------------------------------------------------------------------
install_lutris(){
  inf "Installing Lutris artwork (slug: $LUTRIS_SLUG)…"
  local found=0
  local roots=(
    "$HOME/.local/share/lutris"
    "$HOME/.var/app/net.lutris.Lutris/data/lutris"
  )
  for r in "${roots[@]}"; do
    [ -d "$r" ] || continue
    found=1
    mkdir -p "$r/banners" "$r/coverart"
    cp -f "$ART_LUTRIS/banner.png"   "$r/banners/$LUTRIS_SLUG.png"
    cp -f "$ART_LUTRIS/coverart.png" "$r/coverart/$LUTRIS_SLUG.png"
    ok "  banner + coverart -> $r"
  done
  # Icon -> hicolor theme (native and/or Flatpak), normalized to 128x128
  local icon_roots=()
  [ -d "$HOME/.local/share/lutris" ]        && icon_roots+=("$HOME/.local/share/icons/hicolor/128x128/apps")
  [ -d "$HOME/.var/app/net.lutris.Lutris" ] && icon_roots+=("$HOME/.var/app/net.lutris.Lutris/data/icons/hicolor/128x128/apps")
  for ir in "${icon_roots[@]}"; do
    mkdir -p "$ir"
    if   command -v magick  >/dev/null 2>&1; then magick  "$ART_LUTRIS/icon.png" -resize 128x128 "$ir/lutris_$LUTRIS_SLUG.png"
    elif command -v convert >/dev/null 2>&1; then convert "$ART_LUTRIS/icon.png" -resize 128x128 "$ir/lutris_$LUTRIS_SLUG.png"
    else cp -f "$ART_LUTRIS/icon.png" "$ir/lutris_$LUTRIS_SLUG.png"; fi
    ok "  icon -> $ir/lutris_$LUTRIS_SLUG.png"
    gtk-update-icon-cache -f -t "$(dirname "$(dirname "$(dirname "$ir")")")" >/dev/null 2>&1 || true
  done
  # Refresh the desktop icon cache (otherwise the desktop may show an old icon)
  rm -f "$HOME/.cache/icon-cache.kcache" 2>/dev/null || true
  command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

  if [ "$found" -eq 1 ]; then
    ok "Lutris done. RESTART Lutris once so the images reload."
  else
    warn "No Lutris data directory found – is Lutris installed? Skipped."
  fi
}

# --------------------------------------------------------------------------
# STEAM
# --------------------------------------------------------------------------
steam_bases(){
  for b in \
    "$HOME/.local/share/Steam" \
    "$HOME/.steam/steam" \
    "$HOME/.steam/root" \
    "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"; do
    [ -d "$b/userdata" ] || continue
    realpath "$b" 2>/dev/null || echo "$b"   # resolve symlinks…
  done | awk '!seen[$0]++'                    # …then drop real duplicates
}

install_steam(){
  inf "Installing Steam artwork (shortcut: \"$GAME_NAME\")…"
  [ -d "$ART_STEAM" ] || { warn "Steam artwork folder missing: $ART_STEAM"; return 0; }

  if pgrep -x steam >/dev/null 2>&1; then
    warn "Steam is running. Please CLOSE Steam completely and run the script again,"
    warn "otherwise Steam overwrites the images on exit."
    return 1
  fi

  local any_base=0 any_match=0
  while IFS= read -r base; do
    any_base=1
    for vdf in "$base"/userdata/*/config/shortcuts.vdf; do
      [ -f "$vdf" ] || continue
      local griddir; griddir="$(dirname "$vdf")/grid"
      local appid
      appid="$(GAME_NAME="$GAME_NAME" python3 - "$vdf" <<'PY'
import sys, struct, os
data = open(sys.argv[1], 'rb').read()
target = os.environ["GAME_NAME"].lower()
n = len(data)
def rdstr(j):
    e = data.index(b'\x00', j); return data[j:e].decode('utf-8','replace'), e+1
def parse(j):
    entry = {}
    while j < n:
        t = data[j]; j += 1
        if t == 0x08: return entry, j
        key, j = rdstr(j)
        if   t == 0x00: val, j = parse(j); entry[key.lower()] = val
        elif t == 0x01: val, j = rdstr(j); entry[key.lower()] = val
        elif t == 0x02: val = struct.unpack('<i', data[j:j+4])[0]; j += 4; entry[key.lower()] = val
        else: return entry, j
    return entry, j
try:
    root,_ = parse(0)
except Exception:
    sys.exit(0)
for e in root.get('shortcuts', {}).values():
    if isinstance(e, dict):
        if target in str(e.get('appname','')).lower() or target in str(e.get('exe','')).lower():
            aid = e.get('appid')
            if aid is not None:
                print(aid & 0xFFFFFFFF)   # unsigned 32-bit = grid filename
                break
PY
)"
      [ -z "$appid" ] && continue
      any_match=1
      mkdir -p "$griddir"
      cp -f "$ART_STEAM/poster.png" "$griddir/${appid}p.png"       # vertical poster
      cp -f "$ART_STEAM/header.png" "$griddir/${appid}.png"        # horizontal capsule
      cp -f "$ART_STEAM/hero.png"   "$griddir/${appid}_hero.png"   # hero background
      cp -f "$ART_STEAM/logo.png"   "$griddir/${appid}_logo.png"   # transparent logo
      cp -f "$ART_STEAM/icon.png"   "$griddir/${appid}_icon.png"   # icon
      ok "  AppID $appid -> $griddir"
    done
  done < <(steam_bases)

  if [ "$any_base" -eq 0 ]; then
    warn "No Steam found. Is Steam installed?"; return 0
  fi
  if [ "$any_match" -eq 0 ]; then
    warn "No Steam shortcut named \"$GAME_NAME\" found."
    warn "Create the shortcut first (Lutris right-click -> \"Create Steam shortcut\""
    warn "or Steam -> \"Add a Non-Steam Game\"), close Steam, then run again."
    return 0
  fi
  ok "Steam done. Start Steam -> the library page is complete."
}

# --------------------------------------------------------------------------
echo "=== OctoWoW artwork installer ==="
[ "$DO_LUTRIS" -eq 1 ] && install_lutris || true
[ "$DO_STEAM"  -eq 1 ] && { echo; install_steam || true; }
echo
ok "Done."
