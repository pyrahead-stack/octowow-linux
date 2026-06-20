# OctoWoW on Linux

Install **OctoWoW** (Mysteries of Azeroth, WoW 1.12) on **Bazzite / Fedora Atomic** and the **Steam Deck**.
The official **OctoLauncher** downloads the client, applies the tweaks, and **runs the game** — its PLAY button is all you need.

> Everything lives in **`~/Games/octowow`** (the folder Lutris suggests by default — don't change it).
>
> **Using the HD patches?** Then you can't play through the launcher (it rewrites `patch-A` and clobbers HD) — play via **Lutris** instead. See [Play via Lutris (required for HD)](#play-via-lutris-required-for-hd).

---

## TL;DR

1. **Run `scripts/setup-launcher.sh`** → installs the OctoLauncher (+ play scripts + desktop icon).
2. **Open the OctoLauncher** → point it at `~/Games/octowow`, enable the tweaks you want, press **Apply**, then **Install/Verify** (downloads the ~9–10 GB client).
3. **Press PLAY.** Log in (account name **UPPERCASE**). That's it.

> **HD graphics?** Don't use the launcher's PLAY — it clobbers the HD `patch-A`. Play via [Lutris](#play-via-lutris-required-for-hd) instead.

---

## Requirements (once)

| Need | How |
|---|---|
| **umu-launcher** | Runs the launcher **and its PLAY**. Preinstalled on Bazzite. Steam Deck: see the Deck note below. |
| **GE-Proton** *(for the launcher)* | Install via **ProtonUp-Qt**, or let umu fetch its own UMU-Proton on first run. |
| **Lutris + wine-ge** *(HD path only)* | Only if you use the HD patches. Lutris is preinstalled on Bazzite (else `flatpak install -y flathub net.lutris.Lutris`); then Lutris → **Runners → Wine** → install a **wine-ge-8** build. **Not** Proton — Proton can't run WoW's 32-bit prefix. |
| `kdialog` or `zenity` *(HD/Lutris only)* | For the Play/Launcher chooser menu. Preinstalled on KDE (kdialog). |

---

## Install

### Phase 1 — OctoLauncher: download + tweaks

```bash
~/octowow-linux/scripts/setup-launcher.sh
```

This creates `~/Games/octowow`, drops the play scripts in (for the HD/Lutris path), installs the OctoLauncher into its own prefix, and adds an **OctoLauncher** desktop icon.

Then:

1. Open **OctoLauncher** (desktop icon).
2. **Set the game folder** to **`~/Games/octowow`**. The launcher's Wine folder picker is fiddly: select the folder in the **right pane** (not the left tree) — expand `/` → `home` → `<you>` → `Games` → `octowow`. The chosen path then shows as a Wine drive letter (e.g. `X:\Games\octowow`) — that's normal.
3. Enable the **tweaks/mods** you want — at least **vanillaFixes** (multicore fix) and **largeAddress** (4 GB / prevents the green screen) — then press **Apply**. *Tweaks/mods only take effect after **Apply**; **Install** alone just fetches/verifies client files.*
4. **Install / Verify** → it downloads the ~9–10 GB client and writes a clean LAA-patched `WoW.exe`. You may have to press **Install** and then **Update** (it can take two passes) to fully finish.

### Phase 2 — Play

Press **PLAY** in the OctoLauncher. The game launches (umu + GE-Proton) and reaches the login screen.

First login: account name is **uppercase** (e.g. `PYRAHEAD`); the realm list (**C'Thun / N'Zoth**) appears **after** a successful login.

> The launcher's PLAY works once the client is installed cleanly. The old *"PLAY is broken under Wine / ERROR #132"* was a **misdiagnosis** — the real cause was a corrupt `WoW.exe` from the headless updater; a launcher Install/Verify writes a clean LAA exe and PLAY works end-to-end.

---

## Play via Lutris (required for HD)

The launcher rewrites `patch-A.mpq` every time it updates, replacing the HD `patch-A` with OctoWoW's own — so **if you use the HD patches you must not play through the launcher.** Play via **Lutris** instead; it launches the game directly (`VanillaFixes.exe`) and never opens the launcher, so the HD `patch-A` survives.

1. **Close Lutris** if it's open.
2. Run the helper:
   ```bash
   ~/octowow-linux/scripts/add-to-lutris.sh
   ```
   It registers **OctoWoW** in Lutris (runner: linux → the Play/Launcher chooser) with absolute paths.
3. Open **Lutris** → **OctoWoW** → **Play** → choose **🎮 Play OctoWoW**.

> The **🔧 OctoLauncher** entry in the chooser is for managing mods/updates. Opening it re-triggers the `patch-A` rewrite, so **re-copy the HD `patch-A` afterwards** if you used it to update.

> Why a script and not Lutris's "Install from a local install script"? That GUI flow leaves the
> game directory unset for a `runner: linux` script, so `$GAMEDIR` isn't substituted and Play
> fails with *"$GAMEDIR/$GAMEDIR/octowow-chooser.sh not found"*. The helper avoids that.

---

## Good to know (short)

- **realmlist = `185.165.170.6`** (octowow.st). The old `.33` is wrong — login fails.
- **Two ways to play:** the launcher's **PLAY** (simplest), or **Lutris → `VanillaFixes.exe`** (required for HD — see above). Pick one.
- The Lutris path's Wine prefix is **`~/Games/octowow-prefix`** (next to, not inside the game folder — inside can cause ERROR #132).
- **DXVK runs once**: the `d3d9.dll` in the game folder is used (`d3d9=n,b`). Don't add a second DXVK layer.
- Account name is forced **uppercase**; English (`enUS`) isn't cleanly possible — the playable locale is **deDE**.

---

## Optional

### HD graphics (Project Reforged)

Manage HD in the **OctoLauncher** (enable the HD patches there); they install into `Data/` at letters A,B,C,D,E,G,I,L,M,N,P,S,T,U.

> ⚠️ **The launcher rewrites `patch-A.mpq` on every update**, replacing the HD `patch-A` (~1.7 GB, character/NPC models) with OctoWoW's own (~6 MB). **Don't try to rename the HD patches** to dodge this — it does **not** work: keeping OctoWoW's `patch-A` and moving HD to another letter makes OctoWoW's char data conflict with the HD models → **crash at the character screen**. Instead:
>
> - Keep every HD patch at its **native letter** (the HD `patch-A` *replaces* OctoWoW's `patch-A`).
> - Enable **vanillaHelpers** in the launcher — without it only `patch-A` loads and the lettered patches don't.
> - **Play via [Lutris](#play-via-lutris-required-for-hd), not the launcher**, so the launcher never runs and never clobbers the HD `patch-A`.
> - If you ever open the launcher to update OctoWoW, **re-copy the HD `patch-A`** afterwards.
>
> (Project Reforged is a *Turtle WoW* HD set running on OctoWoW — some custom models may differ; content compatibility is your call.)

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
| **Crash on launch (ERROR #132)** right away | `WoW.exe` is the corrupt headless-updater one. Run the launcher's **Install/Verify** — it writes a clean LAA exe. (On the Lutris path, also keep the prefix at `~/Games/octowow-prefix`, never inside the game folder.) |
| **Play (Lutris) fails: "Proton not compatible with 32-bit prefixes"** | You're on Proton. The play script uses wine-ge automatically — make sure a **wine-ge-8** build is installed in Lutris (Runners → Wine). |
| **Green screen / out of memory** | **largeAddress** tweak not applied — enable it in the launcher, press **Apply**, then Install/Verify. |
| **Crash at the character screen (HD)** | HD `patch-A` got renamed, or got clobbered by a launcher update. Restore the HD `patch-A` at its native letter and play via Lutris. |
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
| `scripts/setup-launcher.sh` | installs the OctoLauncher + play scripts (start here) |
| `scripts/start-octolauncher.sh` | starts the OctoLauncher (umu + GE-Proton) |
| `scripts/add-to-lutris.sh` | registers OctoWoW in Lutris for the HD/Lutris play path |
| `scripts/octowow-chooser.sh` | the Play / OctoLauncher menu (Lutris "Play" runs this) |
| `scripts/play-octowow.sh` | launches the game directly (VanillaFixes + DXVK, wine-ge) |
| `octowow.yml` | legacy Lutris install script (GUI flow — unreliable, use `add-to-lutris.sh`) |
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
