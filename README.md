# OctoWoW on Linux

Install **OctoWoW** (Mysteries of Azeroth, WoW 1.12) on **Bazzite / Fedora Atomic** and the **Steam Deck**.
The official **OctoLauncher** handles downloads + tweaks; **Lutris** runs the game (with DXVK).

> Everything lives in **`~/Games/octowow`** (the folder Lutris suggests by default — don't change it).

---

## TL;DR

1. **Install Lutris + the helpers** (once).
2. **Run `scripts/setup-launcher.sh`** → installs the OctoLauncher.
3. **Open the OctoLauncher** → point it at `~/Games/octowow`, enable the tweaks you want, **Install/Verify** (downloads the client). *Don't press the launcher's PLAY.*
4. **Add to Lutris:** close Lutris, run `scripts/add-to-lutris.sh`, then **Lutris → OctoWoW → Play → 🎮 Play OctoWoW**.

That's it. Details below.

---

## Requirements (once)

| Need | How |
|---|---|
| **Lutris** | Preinstalled on Bazzite. Else: `flatpak install -y flathub net.lutris.Lutris` |
| **umu-launcher** | Preinstalled on Bazzite. Steam Deck: see the Deck note below. |
| **wine-ge** (a win32 Wine) | Lutris → **Runners** → **Wine** → install a **wine-ge-8** build. **Not** Proton — Proton can't run WoW's 32-bit prefix. |
| **GE-Proton** *(for the launcher)* | Install via **ProtonUp-Qt**, or let umu fetch its own on first run. |
| `kdialog` or `zenity` *(optional)* | For the Play/Launcher menu. Preinstalled on KDE (kdialog). |

---

## Install

### Phase 1 — OctoLauncher: download + tweaks

```bash
~/octowow-linux/scripts/setup-launcher.sh
```

This creates `~/Games/octowow`, drops the play scripts in, installs the OctoLauncher into its own prefix, and adds an **OctoLauncher** desktop icon.

Then:

1. Open **OctoLauncher** (desktop icon).
2. Set the game folder to **`~/Games/octowow`**.
3. Enable the **tweaks** you want — at least **vanillaFixes** (multicore fix) and **largeAddress** (4 GB / prevents the green screen). Apply.
4. **Install / Verify** → it downloads the ~9–10 GB client and patches `WoW.exe`.
5. **Do NOT press PLAY** in the launcher (its injection fails under Wine). Close it.

### Phase 2 — Lutris: play

1. **Close Lutris** if it's open.
2. Run the helper:
   ```bash
   ~/octowow-linux/scripts/add-to-lutris.sh
   ```
   It registers **OctoWoW** in Lutris (runner: linux → the Play/Launcher chooser) with absolute paths.
3. Open **Lutris** → **OctoWoW** → **Play** → choose **🎮 Play OctoWoW**. (Choose **🔧 OctoLauncher** later to manage patches/addons.)

> Why a script and not Lutris's "Install from a local install script"? That GUI flow leaves the
> game directory unset for a `runner: linux` script, so `$GAMEDIR` isn't substituted and Play
> fails with *"$GAMEDIR/$GAMEDIR/octowow-chooser.sh not found"*. The helper avoids that.

First login: account name is **uppercase** (e.g. `PYRAHEAD`); the realm list (**C'Thun / N'Zoth**) appears **after** a successful login.

---

## Good to know (short)

- **realmlist = `185.165.170.6`** (octowow.st). The old `.33` is wrong — login fails.
- **Play launches `VanillaFixes.exe`, never the launcher's PLAY button.**
- The Wine prefix is **`~/Games/octowow-prefix`** (next to, not inside the game folder — inside can cause ERROR #132).
- **DXVK runs once**: the `d3d9.dll` in the game folder is used (`d3d9=n,b`). Don't add a second DXVK layer.
- Use the **OctoLauncher only to install/update/manage mods** — not to play.

---

## Optional

### HD graphics (Project Reforged)

Manage HD in the **OctoLauncher** (enable the HD patches there).

> ⚠️ **The launcher overwrites `patch-A.mpq` on every update.** OctoWoW's own `patch-A` replaces the Project Reforged HD one whenever the launcher updates. Either **rename the HD patch to a free letter** (e.g. `patch-B.mpq`) so both load, **or** re-copy the HD `patch-A` after each official OctoWoW update. If HD ever crashes the game, this is usually why.

### Artwork (Lutris + Steam)

```bash
~/octowow-linux/install-artwork.sh            # Lutris icon/banner/cover (+ Steam if a shortcut exists)
~/octowow-linux/install-artwork.sh --lutris   # Lutris only
~/octowow-linux/install-artwork.sh --steam    # Steam only
```

Restart Lutris afterwards so the images reload. For Steam: create a shortcut first (Lutris right-click → **Create Steam shortcut**), **close Steam**, run `--steam`, reopen Steam.

---

## 🎮 Steam Deck — what's different

Same flow, with these changes:

- **Lutris is Flatpak only:** `flatpak install -y flathub net.lutris.Lutris`.
- **No system `umu-run`:** grab the `umu-launcher` **zipapp** from its GitHub releases, extract `umu-run` to `~/.local/bin/`. On the first run it may stall validating the Steam runtime — `rm -rf ~/.local/share/umu/steamrt3*` and retry.
- **Wine:** install **wine-ge-8-26** via ProtonUp-Qt (as Lutris-Wine/Wine-GE).
- WoW 1.12 has no controller support → set up in **Desktop Mode** with mouse/keyboard.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| **Play fails: "Proton not compatible with 32-bit prefixes"** | You're on Proton. The play script uses wine-ge automatically — make sure a **wine-ge-8** build is installed in Lutris (Runners → Wine). |
| **Crash on launch (ERROR #132)** right away | Prefix ended up **inside** the game folder, or `WoW.exe` is the OctoUpdater-patched one. Use the launcher (it patches correctly) and keep the prefix at `~/Games/octowow-prefix`. |
| **Green screen / out of memory** | **largeAddress** tweak not applied — enable it in the launcher and Verify. |
| **Stuttery** | DXVK not active — `DXVK_HUD=fps` should show an overlay. No overlay = DXVK off. |
| **Can't connect** | Check `realmlist.wtf` = `185.165.170.6`; if needed also copy it to `Data/<locale>/`. |

---

## Appendix — bare, no-GUI install (for tinkerers)

`appendix/install-octowow-headless.sh` downloads a **bare** client via the OctoUpdater (no launcher) and registers it in Lutris. It is **not modernized** (no VanillaFixes/LAA/HD) and exists only for scripted setups. The launcher path above is the recommended one.

`appendix/octowow-lutris-net.yml` + `fetch-client.sh` are an **unfinished draft** for a future lutris.net "search & install" entry (needs the repo to be public first).

---

## Package contents

| File | Purpose |
|---|---|
| `scripts/add-to-lutris.sh` | registers OctoWoW in Lutris (reliable — use this) |
| `octowow.yml` | Lutris install script (legacy GUI flow — unreliable, see Phase 2) |
| `scripts/setup-launcher.sh` | installs the OctoLauncher + play scripts |
| `scripts/octowow-chooser.sh` | the Play / OctoLauncher menu (Lutris "Play" runs this) |
| `scripts/play-octowow.sh` | launches the game (VanillaFixes + DXVK, wine-ge) |
| `scripts/start-octolauncher.sh` | starts the OctoLauncher (umu + GE-Proton) |
| `install-artwork.sh` + `artwork/` | Lutris + Steam artwork |
| `appendix/` | bare headless install + lutris.net draft |

---

## Links

- OctoWoW: <https://octowow.st/>
- OctoUpdater (Python): <https://github.com/OctoScripting/OctoUpdater>
- Linux launcher fork: <https://github.com/nikany96/OctoLauncherForLinuxDistros>
- Forum "Installing on Linux": <https://octowow.st/forum/viewtopic.php?t=14>

---

## Credits & notes

Community fan content for OctoWoW — not affiliated with or endorsed by the OctoWoW team. The bundled artwork derives from OctoWoW's *Mysteries of Azeroth* key art/fonts and is for use with OctoWoW only. Free to use and share, **no warranty**.
