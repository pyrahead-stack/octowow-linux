#!/usr/bin/env bash
# Add OctoWoW to Lutris RELIABLY, without the buggy "Install from a local
# install script" GUI flow.
#
# Why this exists: a `runner: linux` install script with no `files:` section
# makes Lutris leave the game `directory` empty, so `$GAMEDIR` in the resulting
# config is never substituted and Play fails with
#   "Die Datei $GAMEDIR/$GAMEDIR/octowow-chooser.sh konnte nicht gefunden werden".
# This script writes the game config + DB row directly, with absolute paths.
#
# Run AFTER setup-launcher.sh + after the OctoLauncher has downloaded the client
# into ~/Games/octowow. Lutris must be CLOSED (it caches pga.db on exit).
set -euo pipefail

GAMEDIR="$HOME/Games/octowow"
CHOOSER="$GAMEDIR/octowow-chooser.sh"
SLUG="octowow-community"
CONFIGPATH="octowow-community"

# Find Lutris's data dir (native first, then Flatpak).
for d in "$HOME/.local/share/lutris" "$HOME/.var/app/net.lutris.Lutris/data/lutris"; do
  [ -f "$d/pga.db" ] && { PGADIR="$d"; break; }
done
: "${PGADIR:?Lutris pga.db not found — start Lutris once, then re-run.}"

for c in "$HOME/.config/lutris/games" "$HOME/.var/app/net.lutris.Lutris/config/lutris/games"; do
  [ -d "$c" ] && { CFGDIR="$c"; break; }
done
: "${CFGDIR:?Lutris games config dir not found.}"

if pgrep -x lutris >/dev/null 2>&1 || pgrep -f "net.lutris.Lutris" >/dev/null 2>&1; then
  echo "Lutris is running — close it completely first (it would overwrite this entry)." >&2
  exit 1
fi

[ -x "$CHOOSER" ] || { echo "Not found/executable: $CHOOSER — run setup-launcher.sh first." >&2; exit 1; }

echo "==> Writing Lutris game config"
cat > "$CFGDIR/$CONFIGPATH.yml" <<EOF
game:
  exe: $CHOOSER
  working_dir: $GAMEDIR
game_slug: octowow
name: OctoWoW
slug: $SLUG
version: Community
EOF

echo "==> Registering OctoWoW in Lutris pga.db (backup first)"
cp "$PGADIR/pga.db" "$PGADIR/pga.db.bak-octowow"
GAMEDIR="$GAMEDIR" CHOOSER="$CHOOSER" SLUG="$SLUG" CONFIGPATH="$CONFIGPATH" \
PGADB="$PGADIR/pga.db" python3 - <<'PY'
import os, sqlite3
db = os.environ["PGADB"]
c = sqlite3.connect(db)
row = c.execute("select id from games where slug=?", (os.environ["SLUG"],)).fetchone()
vals = dict(name="OctoWoW", slug=os.environ["SLUG"], runner="linux", platform="Linux",
           directory=os.environ["GAMEDIR"], executable=os.environ["CHOOSER"],
           configpath=os.environ["CONFIGPATH"], installed=1)
if row:
    c.execute("""update games set runner=:runner, platform=:platform, directory=:directory,
                 executable=:executable, configpath=:configpath, installed=:installed
                 where id=%d""" % row[0], vals)
    print("Updated existing entry id", row[0])
else:
    cols = ",".join(vals); ph = ",".join(":"+k for k in vals)
    c.execute(f"insert into games ({cols}) values ({ph})", vals)
    print("Inserted new entry")
c.commit()
print("OctoWoW:", c.execute("select id,name,runner,directory,installed from games where slug=?",
                            (os.environ["SLUG"],)).fetchall())
c.close()
PY

cat <<EOF

==> Done. Open Lutris -> OctoWoW -> Play -> 🎮 Play OctoWoW.
EOF
