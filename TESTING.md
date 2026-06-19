# Clean-room test — OctoWoW on Bazzite

Goal: prove the **written guide alone** gets a brand-new person from "nothing" to "playing OctoWoW".
Rule of the test: **only do what `README.md` says.** No insider knowledge, no shortcuts you remember.
Whenever you have to guess, improvise, or look something up — that's a **bug in the guide**: write it down.

Environment of this run:
- Machine / GPU: ____________________
- Bazzite version (`rpm-ostree status` or About): ____________________
- Lutris: native or Flatpak? ____________________
- Date: ____________________

---

## How to capture problems
For every hiccup, note: **which step**, **what you expected**, **what happened** (incl. exact error text).
Keep a terminal open; if a command fails, copy the full output.

---

## Checklist (tick as you go)

### 0. Starting point
- [ ] Fresh/clean machine, no OctoWoW or leftover folders
- [ ] You have the package folder (`octowow-bazzite/`) on this machine — note **how you got it here**: ____________________

### 1. Preparation — Lutris
- [ ] Followed "PREPARATION — install Lutris" exactly
- [ ] `command -v lutris` OR Flatpak present
- Notes: ____________________

### 2. Run the installer (the one terminal command)
- [ ] Ran `~/octowow-bazzite/install-octowow-headless.sh` (adjust path if the folder is elsewhere)
- [ ] **Client download actually completed** (this is the experimental part — watch it!)
      - Download path used: ____________________
      - Size on disk afterwards (`du -sh <gamefolder>`): __________
- [ ] realmlist written
- [ ] Lutris installer opened automatically at the end
- If the download got stuck → did the `WITH_LAUNCHER=1` fallback work? ____________________
- Notes: ____________________

### 3. Lutris install + first launch
- [ ] Clicked **Install** once in Lutris
- [ ] Pointed it at the existing game folder (if asked)
- [ ] OctoWoW appears in Lutris with **icon/banner/cover** (artwork step worked)
- [ ] Clicked **Play** → game window opens
- [ ] Reached the **login screen** (OctoWoW "Mysteries of Azeroth")
- Notes: ____________________

### 4. Login → world
- [ ] Logged in (test account) → realm list shows **C'Thun / N'Zoth**
- [ ] Entered the world, moved around, looks smooth (DXVK working, no green screen)
- Notes: ____________________

### 5. (optional) Steam integration
- [ ] Created a Steam shortcut (Lutris right-click → "Create Steam shortcut")
- [ ] Closed Steam, ran `./install-artwork.sh --steam`, restarted Steam
- [ ] Steam library page shows poster + hero + logo
- Notes: ____________________

### 6. (optional) AIO / HD patches
- [ ] Step 2 (AIO) — was the manual link easy to find from the README? ____________________
- [ ] Step 5 (HD) — clear enough? ____________________

---

## Verdict
- Did the **written guide alone** get you to "playing"?  ☐ yes  ☐ no
- Worst friction point: ____________________
- Anything missing / unclear / wrong in the README: ____________________
- Anything that needed a second try or a guess: ____________________

> After the test, bring this filled-in file back — we fix every noted point **before** publishing.
