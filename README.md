# OctoWoW on Linux — Idiot-Proof Installation Guide

> Last updated: 2026-06-19 · For **Bazzite / Fedora Atomic** (native **or** Flatpak Lutris) **and Steam Deck** · tested end-to-end (login → world → playable) on PC **and** Deck
>
> Goal: written so that **anyone can follow along** — even someone who just switched from Windows to Bazzite. Every step is over-explained.
>
> This guide is **universal**. Wherever the **Steam Deck** differs, there's a **🎮 Steam Deck box**.

---

## What's in this package

| File | Purpose |
|---|---|
| `README.md` | this guide |
| `install-octowow-headless.sh` | one-command installer: downloads the client, writes the realmlist, opens the Lutris installer |
| `octowow-bazzite.yml` | the Lutris install script (32-bit Wine prefix, DXVK, realmlist) |
| `install-artwork.sh` + `artwork/` | *(optional)* icon/banner/cover for Lutris + full Steam library art |

> **How the install actually works — read this so nothing surprises you:**
> OctoWoW is **not** on lutris.net, so you **can't** find it by searching Lutris's online "add game" list. Instead you run the helper script **once** in a terminal — it downloads the ~9–10 GB client and then **opens the Lutris installer automatically**. In Lutris you click **Install** once, then **Play**. So one terminal command is part of the flow; everything after that is clicks in Lutris.

---

## Important first (what's different on Linux vs. Windows)

- **You do NOT need any of the "allow the antivirus" stuff from the Windows guide.** Windows Defender doesn't exist here. The mod files (`vanillaFixes` etc.) are simply copied, nothing blocks them.
- WoW 1.12 is an old **32-bit game with DirectX 9**. On Linux we run **DXVK (D3D9 → Vulkan)** via **Lutris** — this completely replaces the Windows "WoW Modernization Tool" for the DXVK part.
- The **launcher is ONLY for downloading/updating** the game files. The game is launched afterwards via **Lutris** (because of DXVK). Just like in the Windows guide: "DO NOT CLICK PLAY" in the launcher.

There are **3 mandatory batches** + **2 optional** ones (pretty graphics):

1. **Launcher + base files** (downloads the complete client)
2. **AIO setup** (turns the client into the "modern" OctoWoW)
3. **DXVK / launch via Lutris** (smooth graphics)
4. *(optional)* **Client modernization** with the WoW Modernization Tool
5. *(optional)* **Project Reforged HD patches**

---

## ⚠️ Critical pitfalls (read these first, no matter what)

These four points each cost several hours during testing (PC **and** Steam Deck) — if you keep them in mind, you'll breeze right through:

1. **The Wine prefix must NEVER live inside the game folder.** WoW (more precisely: `VanillaHelpers.dll`) scans the game folder **recursively** at startup. If a Wine prefix is in there (deep folder trees, sometimes symlink loops like `pfx -> .`), the scan runs into a **stack overflow → ERROR #132** (`0x85100084`, ACCESS_VIOLATION) **before a window even appears**. → Always put the prefix **next to** the game folder (the bundled Lutris package does this automatically: `$GAMEDIR/../octowow-prefix`). The game folder contains only `Data/ Interface/ WTF/` + the exe/dll files.
2. **You launch `VanillaFixes.exe`, not the launcher's "PLAY" button.** `VanillaFixes.exe` is a chainloader (it loads the multicore fix and then WoW). The **launcher PLAY** attempts a DLL injection that fails under Wine/Proton → "Injecting failed" / #132. The **launcher is only for installing/updating/managing mods**.
3. **DXVK only ONCE.** The modern OctoWoW client already ships a `d3d9.dll` (DXVK) in the game folder. In that case, in Lutris turn **DXVK off** + the override `WINEDLLOVERRIDES=d3d9=n,b` (loads the existing one). If there is **no** `d3d9.dll` in the folder: turn **DXVK on** and leave out the override. Never both.
4. **Leave the launcher mod "UnitXP" disabled** and set **realmlist = `185.165.170.6`** (octowow.st). The previously circulating `185.165.170.33` is wrong/outdated (login fails).

---

## Quick start — (almost) fully automatic

The most reliable path is **not** the GUI launcher, but the **OctoUpdater** (text-based, a single Python file, can be driven headless). You don't need the launcher for this at all.

For that there's the script **`install-octowow-headless.sh`**. It downloads the complete client via the OctoUpdater (without a GUI), writes the `realmlist.wtf`, and at the end opens the Lutris installer:

```bash
flatpak install -y flathub net.lutris.Lutris   # if Lutris is not installed yet
~/octowow-bazzite/install-octowow-headless.sh
```

After that you only have to **click "Install" once** in Lutris → done, then **Play**.

### What can be automated — and what can't (honestly)

| Part | Automatic? | Why |
|---|---|---|
| Complete client download | ✅ yes (headless) | via **OctoUpdater** (Python, menu "3 = Full download" is fed by the script) — **no launcher needed** |
| Wine prefix + DXVK + realmlist | ✅ yes | handled by the Lutris package `octowow-bazzite.yml` |
| Create Lutris entry | ⚠️ almost | `lutris -i` opens the installer → **click "Install" once** |
| AIO setup (step 2) & HD patches (step 5) | ❌ manual | forum/Discord attachments without a stable download URL (optionally hookable via `AIO_URL=...`) |

> **Why OctoUpdater instead of the GUI launcher?** The official launcher mandatorily requires clicks (choose folder, "Verify") and can't be driven headless. The OctoUpdater downloads exactly the same files but is scriptable — hence the better path for an automatic installation. You don't need the launcher; if you want it as a fallback for later large updates, set `WITH_LAUNCHER=1`.
>
> ⚠️ **Experimental:** The OctoUpdater menu inputs are derived from the source code but not live-tested by me. If the download gets stuck: run `WITH_LAUNCHER=1 ~/octowow-bazzite/install-octowow-headless.sh` again and use the GUI launcher as a fallback.

If you'd rather control each step yourself, follow the detailed variant below.

---

## PREPARATION (one-time) — install Lutris

You need **Lutris** (it brings its own Wine + DXVK toggle). **Both installation methods work** — the quick-start script automatically detects which one you have:

- **Flatpak (recommended, identical everywhere):**
  ```bash
  flatpak install -y flathub net.lutris.Lutris
  ```
- **Native (rpm/repo):** on some distros (Arch/CachyOS) and partly on Bazzite already **preinstalled** — then there's nothing to do. Check with `command -v lutris`.

> Flatpak note: If the Lutris Flatpak can't see the game folder, grant home/folder access with **Flatseal**.
>
> Vulkan drivers are already present on Bazzite (Mesa for AMD). Nothing else needed.

The rest (creating the folder, downloading the client, prefix/DXVK) is handled automatically by the quick-start script `install-octowow-headless.sh`. If you'd rather do it by hand, just follow the steps below.

---

## STEP 1 — download the base files (mandatory)

You **don't** need your own WoW 1.12 client and **don't necessarily need the launcher** — the OctoUpdater downloads the **complete client automatically**.

### Path A — OctoUpdater (recommended, scriptable)

The quick-start script does this automatically. By hand:

1. Create the game folder:
   ```bash
   mkdir -p ~/Spiele/OctoWoW
   ```
2. Get the OctoUpdater:
   ```bash
   curl -L -o ~/Spiele/OctoWoW/updater.py \
     https://raw.githubusercontent.com/OctoScripting/OctoUpdater/main/updater.py
   ```
3. In `updater.py`, at the very top, set `CLIENT_DIR` to your folder:
   ```python
   CLIENT_DIR = Path("/home/DEINNAME/Spiele/OctoWoW")
   ```
4. Run it and in the menu choose **`3` (Full download)**, confirm with **`y`**, and at the end **`4`** to quit:
   ```bash
   python3 ~/Spiele/OctoWoW/updater.py
   ```
   (Needs **Python 3.10+** — present on Bazzite. Standard library only, no extra packages.)

### Path B — GUI launcher (alternative, if you'd rather click)

1. Download & start the launcher:
   ```bash
   curl -L -o ~/Downloads/OctoLauncher.AppImage \
     https://github.com/nikany96/OctoLauncherForLinuxDistros/releases/download/v1.0/OctoLauncher.AppImage
   chmod +x ~/Downloads/OctoLauncher.AppImage
   ~/Downloads/OctoLauncher.AppImage
   ```
2. Choose the folder `~/Spiele/OctoWoW` → **"Verify"/"Install"** → until the button shows **"Play"**.
3. **Do NOT click Play. Close the launcher.** (Launching happens via Lutris.)

✅ Result (both paths): `~/Spiele/OctoWoW` contains the complete, playable client (incl. `WoW.exe` and `vanillaFixes`).

---

## STEP 2 — AIO setup (the "modern" OctoWoW)

Identical to the Windows guide, just **without** the antivirus step.

1. Download the **`OctoWoW_AIO_Setup.zip`** from the official forum/Discord thread (see links below).
2. Extract **all** files from it into your game folder and overwrite everything:
   ```bash
   unzip -o ~/Downloads/OctoWoW_AIO_Setup.zip -d ~/Spiele/OctoWoW
   ```
   (On "overwrite?" → always **yes/all**.)

✅ From here on OctoWoW is basically playable. Step 3 takes care of smooth graphics.

---

## STEP 3 — DXVK / launch the game via Lutris (mandatory for smooth play)

Instead of the Windows tool, **Lutris** takes over the DXVK part. Easiest with the **ready-made package** (`octowow-bazzite.yml`):

### Variant A — ready-made Lutris package (recommended)

1. Open Lutris → at the top **"+"** → **"Install from a local install script"**.
2. Select the file **`octowow-bazzite.yml`** from this folder.
3. At the "installation location" step, point to your **existing** folder `~/Spiele/OctoWoW`.
4. Lutris creates a 32-bit Wine prefix, enables DXVK, and writes the `realmlist.wtf`.
5. Done → in Lutris click **OctoWoW → Play**.

### Variant B — set up Lutris by hand

1. Lutris → **"+"** → **"Add locally installed game"**.
2. Runner: **Wine**. Executable: `~/Spiele/OctoWoW/WoW.exe`. Working dir: `~/Spiele/OctoWoW`.
3. Tab **Runner options**: **DXVK = ON**, **Wine arch = win32** (32-bit), Vulkan.
4. Save → **Play**.

> ⚠️ **Don't stack two DXVK layers!** If DXVK DLLs (`d3d9.dll`, `dxgi.dll`) from the Windows tool are already in the game folder, **delete them** as long as Lutris handles DXVK. Otherwise crashes/glitches.

> ℹ️ **Realmlist:** On Windows the launcher rewrites the realm/patch list on every start. Since we launch via Lutris, the package sets the `realmlist.wtf` file itself (contents below). If you can't connect, also copy `realmlist.wtf` to `~/Spiele/OctoWoW/Data/enUS/` (or `deDE`).

```
set realmlist 185.165.170.6
set patchlist 185.165.170.6
```

---

## STEP 4 (optional) — client modernization with the "WoW Modernization Tool"

This is the Linux counterpart to **step 3 of the Windows guide**. The tool is a **Windows .exe** — we run it **in the same Wine prefix** that Lutris created for OctoWoW. On top of DXVK it adds QoL/graphics tweaks (multicore fix, field of view/widescreen, optional HD options, etc.).

> **First settle the DXVK question** (important, otherwise crashes): DXVK may only be active ONCE.
>
> - **Recommended (simple):** Lutris provides DXVK (the package has `dxvk: true`). In that case, **do NOT** select the DXVK installation in the tool — just use the other options.
> - **Like in the Windows guide:** The tool places the DXVK DLLs into the game folder. Then you have to **turn off Lutris DXVK** and let the native DLLs load (see 4.3).

### 4.1 Get the tool
1. From the official forum/Discord thread, download **both** files: the `.zip` and `WoW Modernization Tool 1.2.exe`.
2. Extract the `.zip` **into `~/Downloads` — NOT** into the game folder.
   ```bash
   unzip -o ~/Downloads/WoW_Modernization_Tool*.zip -d ~/Downloads/wowmt
   ```
   (The Windows antivirus/"Protection History" stuff from the guide doesn't exist on Linux — skip it entirely.)

### 4.2 Start the tool in the OctoWoW Wine prefix
1. In Lutris **right-click OctoWoW → "Run EXE inside Wine prefix"**.
2. Choose `~/Downloads/wowmt/WoW Modernization Tool 1.2.exe` (or wherever you put it).
   → This way the tool runs in the **same** prefix as the game and writes into the same folder.
3. In the tool, point to your folder `~/Spiele/OctoWoW`.
4. **DXVK selection:** AMD (for your RX 9070 XT) — **or leave it out** if Lutris handles DXVK (see box above).
5. Tick any other options you want → apply → close the tool.

> ⚠️ We do **not** use the **"Play Modernized WoW"** button in the tool — OctoWoW is still launched via **Lutris**.

### 4.3 If you use DXVK via the tool (instead of Lutris)
1. In Lutris for OctoWoW: **Runner options → DXVK = OFF**.
2. So the DLLs placed by the tool get loaded, set DLL overrides — either in Lutris under **System options → Environment variables**:
   ```
   WINEDLLOVERRIDES = d3d9,dxgi=n,b
   ```
   or via `winecfg` (right-click → "Wine configuration" → Libraries) add `d3d9` and `dxgi` as **native, builtin**.
3. Test: launch the game — if it runs smoothly and stably, you're good.

### 4.4 Manual DXVK fallback (from the Windows guide's troubleshooting)
If the tool acts up: just take **`dxgi.dll` and `d3d9.dll` from the DXVK pack and place them directly in `~/Spiele/OctoWoW`**, then as in 4.3 turn Lutris DXVK off + `WINEDLLOVERRIDES=d3d9,dxgi=n,b`.

---

## STEP 5 (optional) — Project Reforged HD patches

Purely file-based, identical to Windows (no .exe):

1. Download the HD patch `.mpq` files from Neishin's guide and place them in `~/Spiele/OctoWoW/Data/`.
2. **Known issue (as of 2026-05-22):** OctoWoW's `patch-A.mpq` overwrites the one from Project Reforged → **rename the Project Reforged file** (e.g. to a free letter like `patch-B.mpq`) so both get loaded.

---

## TROUBLESHOOTING (Bazzite)

| Problem | Solution |
|---|---|
| **Stuttery / janky** | Is DXVK really running? The env var `DXVK_HUD=fps` is set in the package → an FPS overlay should appear. No overlay = DXVK not active. |
| **Mouse cursor goes haywire in the window** | Enable **"relative mouse mode"** in Lutris, possibly launch via **gamescope**. |
| **Connection fails** | Check `realmlist.wtf`; if needed, also copy it to `Data/enUS/`. |
| **Launcher won't start** | Make sure the AppImage is executable (`chmod +x`). FUSE is present on Bazzite. |
| **Alternative to Lutris** | Add the launcher/`WoW.exe` as a non-Steam game → force **Proton 8 or 9** (newer Proton versions cause problems according to the forum). |

---

## Artwork: icon, banner, cover (Lutris) & full Steam library art (optional)

So OctoWoW looks polished in Lutris — and, if you want, gets full artwork in Steam too — the package ships an `artwork/` folder plus **`install-artwork.sh`**. It auto-detects native **and** Flatpak installs (Steam Deck included) and places every image where it belongs. Nothing is hardcoded to a path or account.

```bash
~/octowow-bazzite/install-artwork.sh            # Lutris images + Steam (if a shortcut exists)
~/octowow-bazzite/install-artwork.sh --lutris   # Lutris only
~/octowow-bazzite/install-artwork.sh --steam    # Steam only
# different slug? -> ./install-artwork.sh my-slug
```

After it runs, **restart Lutris** so the images reload.

### Want it in Steam too? ("everything in one place")

In Lutris a single view only ever shows one image (grid view = cover, banner view = banner). Steam instead combines several artworks on the game's library page (vertical poster, hero background, logo overlay, icon). To get that:

1. Add OctoWoW as a Steam shortcut **once** — in Lutris: right-click OctoWoW → **"Create Steam shortcut"**, or in Steam: **Games → "Add a Non-Steam Game"**.
2. **Close Steam completely.**
3. Run `./install-artwork.sh --steam` (or the plain command above).
4. **Start Steam** → poster, header, hero and logo are all in place.

The script finds the shortcut by name in your `shortcuts.vdf`, reads its app-id, and drops the correctly named files into Steam's `grid/` folder. (Lutris's own shortcut export only carries over cover + icon — the hero background and logo overlay are what this script adds.)

> **Your own/better images?** Replace the files in `artwork/lutris/` and `artwork/steam/` with the same names and re-run. Recommended sizes — Lutris: cover **600×800 (3:4 portrait)**, banner **552×207**, icon **128–256 px**. Steam: poster **600×900 (2:3)**, header **460×215**, hero **1920×620**, logo **transparent PNG**, icon **256×256**.

---

## 🎮 Steam Deck — what's different (SteamOS / immutable)

The procedure is **identical** to the PC guide (download client → Lutris package → Play). Only these points differ:

- **Lutris on the Deck is only available as a Flatpak.** `flatpak install -y flathub net.lutris.Lutris`. Discover/Bazaar sometimes won't start installs → if needed, use the console (Desktop Mode). The Flatpak ships Vulkan/DXVK itself (including the 32-bit drivers) — **nothing extra needed**.
- **Wine version:** In the Lutris game, choose **wine-ge-8-26** (not Proton — Proton forces 64-bit, WoW 1.12 needs real win32). Install it via **ProtonUp-Qt** as "Lutris-Wine/Wine-GE".
- **Especially do NOT put the prefix inside the game folder** (see pitfall 1) — on the Deck that was exactly the crash cause. The Lutris package places it next to it automatically.
- **Register the game:** In the Lutris Flatpak **"+" → "Install from a local install script" →** `octowow-bazzite.yml`, installation location = your game folder (e.g. `~/Games/octowow-linux`). Then **Play**.
- **The OctoLauncher** (for installing/updating/mods) runs on the Deck via **umu** (`umu-launcher` as a zipapp, since there's no system `umu-run`); its clientDir must point exactly at the game folder. The launcher closes itself after the file check — that is **not** a crash.
- **Performance:** 1280×800 (= the Deck display) runs smoothly; adjust the resolution in-game if needed.

> Controls/on-screen keyboard: WoW 1.12 has no controller support — on the Deck it's best to set up and play in **Desktop Mode** with mouse/keyboard, or create a Steam Input profile (trackpad as mouse).

---

## Later updates

When OctoWoW ships a big game update: **only then** start the launcher from step 1 again and press "Verify". After that you keep playing normally via Lutris. Re-copy the AIO/modernization if an update overwrote it.

---

## For a friend / the community (short version)

1. Install Lutris (if needed): `flatpak install -y flathub net.lutris.Lutris`
2. Run `install-octowow-headless.sh` → downloads the client (OctoUpdater), writes realmlist, opens Lutris.
3. In Lutris click **"Install"** once → **Play**.
4. *(optional)* Extract the AIO zip into the folder (step 2), run the WoW Modernization Tool via Lutris "Run EXE inside Wine prefix" (step 4), add the HD patches (step 5).

---

## Sources & links

- OctoWoW official: <https://octowow.st/>
- Linux launcher (fork, v1.0): <https://github.com/nikany96/OctoLauncherForLinuxDistros>
- OctoUpdater (Python): <https://github.com/OctoScripting/OctoUpdater>
- Forum "Installing it on Linux": <https://octowow.st/forum/viewtopic.php?t=14>
- Realmlist thread: <https://octowow.st/forum/viewtopic.php?t=24>
- Lutris: <https://lutris.net/>

> Note: The `OctoWoW_AIO_Setup.zip` and the HD patches are forum/Discord attachments — please take the links from the official thread/Discord (they change occasionally).

---

## Credits & notes

- This is **community fan content** for OctoWoW — not affiliated with or endorsed by the OctoWoW team. The bundled artwork (icon/banner/cover/Steam art) is derived from OctoWoW's own *Mysteries of Azeroth* key art and fonts and is intended for use with OctoWoW only.
- Guide + scripts are free to use and share. **No warranty** — note in particular the experimental flag on the headless OctoUpdater download. If something breaks, the GUI launcher (`WITH_LAUNCHER=1`) is the fallback.
