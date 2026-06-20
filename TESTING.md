# Clean-room test — OctoWoW on Linux (launcher flow)

Goal: prove the **README alone** gets a brand-new person from "nothing" to "playing".
Rule: **only do what `README.md` says.** No insider knowledge. Every time you have to
guess, improvise, or look something up → that's a **guide bug**: write it down below.

Environment of this run:
- Machine / GPU: ____________________
- Bazzite version (`rpm-ostree status`): ____________________
- Lutris: native or Flatpak? ____________________
- Date: ____________________

---

## Checklist

### 0. Start
- [ ] Fresh machine, no OctoWoW / leftover folders (`~/Games/octowow*`, `~/Spiele/OctoWoW`)
- [ ] You have the `octowow-bazzite/` package here — how did you get it? ____________________

### 1. Requirements
- [ ] Lutris present (`command -v lutris` or Flatpak)
- [ ] `umu-run` present (`command -v umu-run`)
- [ ] A **wine-ge-8** build installed in Lutris (Runners → Wine)
- [ ] GE-Proton present (or accept umu fetching its own)
- Notes: ____________________

### 2. Phase 1 — OctoLauncher (setup-launcher.sh)
- [ ] Ran `scripts/setup-launcher.sh` — did it finish without errors? ____________________
- [ ] `~/Games/octowow` + `~/Games/octowow-launcher` created, play scripts copied in
- [ ] OctoLauncher silently installed (`.../OctoLauncher/OctoLauncher.exe` exists)
- [ ] **OctoLauncher** desktop icon appeared and opens the launcher
- Notes (this is the one new untested piece — watch it): ____________________

### 3. Phase 1 — download + tweaks in the launcher
- [ ] Launcher opened, GUI renders
- [ ] Set game folder to `~/Games/octowow`
- [ ] Enabled **vanillaFixes** + **largeAddress**, applied
- [ ] Install/Verify → client downloaded (~9–10 GB). Size on disk: ____________________
- [ ] `WoW.exe`, `VanillaFixes.exe`, `d3d9.dll` present in `~/Games/octowow`
- [ ] Did NOT press the launcher's PLAY. Closed it.
- Notes: ____________________

### 4. Phase 2 — Lutris + play
- [ ] Lutris → + → Install from a local install script → `octowow.yml`
- [ ] Install location was already `~/Games/octowow` (no manual change needed?)  ____________________
- [ ] "folder contains files" warning — did the README prepare you for it? ____________________
- [ ] Play → the **🎮 Play / 🔧 OctoLauncher chooser** appeared
- [ ] 🎮 Play → game window opens, reaches the **login screen**
- Notes: ____________________

### 5. Login → world
- [ ] Logged in (uppercase account) → realm list **C'Thun / N'Zoth**
- [ ] Entered the world, moved around, smooth (no green screen, DXVK working)
- Notes: ____________________

### 6. (optional)
- [ ] Artwork (`install-artwork.sh`) — icon/banner/cover show in Lutris
- [ ] HD patches — was the patch-A note clear?
- [ ] Steam shortcut + `--steam` artwork

---

## Verdict
- Did the **README alone** get you to "playing"?  ☐ yes  ☐ no
- Worst friction point: ____________________
- Anything missing / unclear / wrong: ____________________
- Anything that needed a guess or a second try: ____________________

> Bring this filled-in file back — we fix every noted point before publishing.
