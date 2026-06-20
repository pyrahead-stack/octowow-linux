# OctoWoW on Linux — project context (for Claude Code)

This repo is a **community install package** for **OctoWoW** (Mysteries of Azeroth,
WoW 1.12 private server) on **Bazzite / Fedora Atomic** and the **Steam Deck**.
Goal: an idiot-proof guide + scripts so a Windows-switcher (the author's girlfriend)
and the community can install it. This file is the portable memory — it travels with
the repo so work can resume on any machine.

## The install model (launcher-centric)

1. **OctoLauncher** (official, Electron) downloads the client and applies tweaks
   (vanillaFixes = multicore fix, largeAddress = 4 GB / anti-green-screen, HD). Runs
   under **umu + GE-Proton**. Its own **PLAY button is broken under Wine** (DLL injection
   fails → ERROR #132) — never use it to play.
2. **Lutris** runs the game: `octowow.yml` is `runner: linux` → `octowow-chooser.sh`
   (a Play / OctoLauncher menu) → `play-octowow.sh` launches **VanillaFixes.exe** under
   **wine-ge** in a 32-bit prefix with DXVK.

Everything lives in **`~/Games/octowow`** (Lutris's default — never use a different path).
Prefix is **`~/Games/octowow-prefix`** (next to, not inside the game folder).

## Hard-won facts (don't relearn these)

- **realmlist = `185.165.170.6`** (octowow.st). The old `.33` fails login. Account name
  is uppercase; realms **C'Thun / N'Zoth** appear only after a successful login.
- **Prefix must be a SIBLING of the game folder, never inside it.** WoW (VanillaHelpers.dll)
  scans the game folder recursively at startup → a prefix inside → stack overflow → ERROR #132.
  (On the Deck this was caused by prefixes + a `pfx -> .` symlink loop inside the folder.)
- **Wine, not Proton.** Proton forces win64 → "Proton not compatible with 32-bit prefixes".
  Use **wine-ge-8-26** (real win32 Wine). The play script finds it automatically.
- **OctoUpdater's `patch_wow_exe()` corrupts WoW.exe** (offsets are for a different build;
  two are past EOF) → instant crash (c0000005) before any DLL loads. Proven by A/B test:
  the **raw server WoW.exe** (`https://octowow.st/client/latest/WoW.exe`, SHA1
  `1707f3b1cf31d24041ebf58406ef6d75b47c1c55`, 4 907 008 bytes) runs. The launcher patches
  WoW.exe correctly (LAA) — another reason the launcher path is preferred over headless.
- **DXVK only once.** The modern client ships `d3d9.dll` in the game folder → use it via
  `WINEDLLOVERRIDES=d3d9=n,b`, Lutris DXVK off. Never stack two DXVK layers.
- **HD patch-A trap:** the launcher overwrites `patch-A.mpq` with OctoWoW's own on every
  update → the Project Reforged HD patch-A is lost. Rename the HD patch to a free letter,
  or re-copy it after each official update.
- **Leave the launcher mod "UnitXP" OFF** (re-injects UnitXP_SP3.dll → crash).
- English `enUS` is **not** cleanly possible (no enUS locale data → #132 after login).
  Playable state = deDE.

## Repo layout

- `README.md` — the lean, launcher-centric guide (English, ~/Games/octowow).
- `octowow.yml` — Lutris install script (runner: linux → chooser).
- `scripts/` — setup-launcher, octowow-chooser, play-octowow, start-octolauncher.
- `appendix/` — bare headless install (raw-exe fix) + lutris.net draft (blocked until repo public).
- `install-artwork.sh` + `artwork/` — Lutris + Steam art.
- `TESTING.md` — clean-room checklist for the launcher flow.

## Status & open items (2026-06-20)

- Package was **redesigned to launcher-centric** after a clean-room test on the author's
  girlfriend's Bazzite PC exposed: the WoW.exe corruption, the missing wine pin, and a
  folder mismatch (~/Spiele vs Lutris's ~/Games). All three addressed.
- **Not yet done:** (a) re-test this new flow from a clean machine; (b) smoke-test the one
  new piece, `scripts/setup-launcher.sh` (silent OctoLauncher install); (c) git commit +
  public push (repo target: `pyrahead-stack/octowow-bazzite`); (d) lutris.net submission.
- The author's own PC has a working reference install at `~/Spiele/OctoWoW` (19 GB) +
  `~/Spiele/OctoLauncher` — do not wipe it; it's the known-good baseline.

## When `/octowowinstall` is invoked

Read this file + `TESTING.md`, figure out whether the user is starting fresh or resuming,
and walk them through the launcher-centric install (or the relevant fix). Verify any
file/flag still exists before relying on it.
