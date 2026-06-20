# Clean-room test — OctoWoW on Linux (launcher flow)

Goal: prove the **README alone** gets a brand-new person from "nothing" to "playing".
Rule: **only do what `README.md` says.** No insider knowledge. Every time you have to
guess, improvise, or look something up → that's a **guide bug**: write it down below.

Environment of this run:
- Machine / GPU: ____________________
- Bazzite version (`rpm-ostree status`): ____________________
- Lutris: native or Flatpak? ____________________ (only needed for the HD path)
- Date: ____________________

---

## Checklist

### 0. Start
- [ ] Fresh machine, no OctoWoW / leftover folders (`~/Games/octowow*`, `~/Spiele/OctoWoW`)
- [ ] You have the `octowow-linux/` package here — how did you get it? ____________________

### 1. Requirements
- [ ] `umu-run` present (`command -v umu-run`)
- [ ] GE-Proton present (or accept umu fetching its own UMU-Proton)
- [ ] *(HD path only)* Lutris present + a **wine-ge-8** build installed (Runners → Wine)
- Notes: ____________________

### 2. Phase 1 — OctoLauncher setup (setup-launcher.sh)
- [ ] Ran `scripts/setup-launcher.sh` — did it finish without errors? ____________________
- [ ] `~/Games/octowow` + `~/Games/octowow-launcher` created, play scripts copied in
- [ ] OctoLauncher silently installed (`.../OctoLauncher/OctoLauncher.exe` exists)
- [ ] **OctoLauncher** desktop icon appeared and opens the launcher
- Notes: ____________________

### 3. Phase 1 — download + tweaks in the launcher
- [ ] Launcher opened, GUI renders
- [ ] Set game folder to `~/Games/octowow` — was the **right-pane folder picker** tip clear? ____________________
- [ ] Enabled **vanillaFixes** + **largeAddress**, pressed **Apply** (was Apply-vs-Install clear?) ____________________
- [ ] Install/Verify → client downloaded (~9–10 GB). Size on disk: ____________________
- [ ] `WoW.exe`, `VanillaFixes.exe`, `d3d9.dll` present in `~/Games/octowow`
- Notes: ____________________

### 4. Phase 2 — Play (the main way: launcher PLAY)
- [ ] Pressed **PLAY** in the OctoLauncher
- [ ] Game window opens, reaches the **login screen** (no #132 crash)
- Notes: ____________________

### 5. Login → world
- [ ] Logged in (account name **UPPERCASE**) → realm list **C'Thun / N'Zoth**
- [ ] Entered the world, moved around, smooth (no green screen, DXVK working)
- Notes: ____________________

### 6. (optional) HD via Lutris
> Only if you use the HD patches — they need the Lutris path (the launcher's PLAY rewrites `patch-A`).
- [ ] Closed Lutris, ran `scripts/add-to-lutris.sh` — finished without errors? ____________________
- [ ] Lutris → **OctoWoW** → **Play** → the **🎮 Play / 🔧 OctoLauncher** chooser appeared
- [ ] 🎮 Play → game reaches login → world (HD models load, no character-screen crash)
- Notes: ____________________

### 7. (optional) extras
- [ ] Artwork (`install-artwork.sh`) — icon/banner/cover show in Lutris
- [ ] Steam shortcut + `--steam` artwork

---

## Verdict
- Did the **README alone** get you to "playing"?  ☐ yes  ☐ no
- Worst friction point: ____________________
- Anything missing / unclear / wrong: ____________________
- Anything that needed a guess or a second try: ____________________

> Bring this filled-in file back — we fix every noted point before publishing.
