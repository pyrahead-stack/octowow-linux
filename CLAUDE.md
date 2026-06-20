# OctoWoW on Linux — project context (for Claude Code)

This repo is a **community install package** for **OctoWoW** (Mysteries of Azeroth,
WoW 1.12 private server) on **Bazzite / Fedora Atomic** and the **Steam Deck**.
Goal: an idiot-proof guide + scripts so a Windows-switcher (the author's girlfriend)
and the community can install it. This file is the portable memory — it travels with
the repo so work can resume on any machine.

## The install model

1. **OctoLauncher** (official, Electron) downloads the client and applies tweaks
   (vanillaFixes = multicore fix, largeAddress = 4 GB / anti-green-screen, HD). Runs
   under **umu + GE-Proton** (UMU-Proton fetched on first run).
2. The launcher's **PLAY button WORKS** — proven 2026-06-20 on the girlfriend's Bazzite PC
   (launcher v1.1.0, UMU-Proton-10.0-4, clean launcher install): pressed PLAY → login →
   in-world, no errors, walked around. **This overturns the old "PLAY is broken under Wine
   (#132)" assumption** — that was a *misdiagnosis*. The real blocker was always the
   **corrupt headless-OctoUpdater `WoW.exe`** (see below): every PC that "couldn't use PLAY"
   was running that corrupt exe and crashing with `c0000005` *before* the PLAY injection
   even mattered. Install via the launcher (it writes a clean LAA-patched exe) → PLAY works.
3. **Lutris is the OLD/fallback path** (built only as a workaround for the non-existent PLAY
   bug): `octowow.yml` is `runner: linux` → `octowow-chooser.sh` → `play-octowow.sh` launches
   **VanillaFixes.exe** under **wine-ge** in a 32-bit prefix with DXVK. Still works, but the
   launcher-PLAY path is simpler. **DECIDED 2026-06-20 (author): launcher-PLAY is the PRIMARY
   documented path; Lutris is demoted to the HD-only path.** Rationale: PLAY works for vanilla,
   but the launcher rewrites `patch-A` on every update → clobbers HD → HD users must play via
   Lutris (never opens the launcher). No workaround beyond that caveat (renaming HD patches
   crashes). README restructured to match (Phase 2 = press PLAY; "Play via Lutris (required for HD)"
   is its own section).

Everything lives in **`~/Games/octowow`** (Lutris's default — never use a different path).
The Lutris-path prefix is **`~/Games/octowow-prefix`** (sibling of, not inside, the game
folder). The launcher's own prefix is **`~/Games/octowow-launcher/prefix`**.

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
  **This corrupt exe — NOT the PLAY button — is the real cause of the crashes once blamed
  on "launcher PLAY broken under Wine".** Confirmed 2026-06-20: deleting the corrupt exe and
  letting the launcher restore it (clean `1707f3b…` + LAA=True) made the launcher's PLAY work
  end-to-end.
- **DXVK only once.** The modern client ships `d3d9.dll` in the game folder → use it via
  `WINEDLLOVERRIDES=d3d9=n,b`, Lutris DXVK off. Never stack two DXVK layers.
- **HD patches (Project Reforged, *Turtle* set) — OPTIONAL, kept independent of the core guide.**
  Uses letters A,B,C,D,E,G,I,L,M,N,P,S,T,U. **Principle (set by the author 2026-06-20): keep the
  HD patches at their NATIVE letters as Project Reforged prescribes — do NOT rename them, do NOT
  invent workarounds.** Install all of them with their original names into `Data/`, enable
  **`vanillaHelpers`** (else only `patch-A` loads; the lettered patches B…Z don't load at all).
- **The patch-A conflict (and why renaming FAILS):** OctoWoW's own client also uses `patch-A`
  (~6 MB, char DBC/data). The HD "Characters & NPCs" patch is ALSO `patch-A` (~1.7 GB) and must
  **replace** OctoWoW's — the two cannot coexist. **Tried & FAILED 2026-06-20: renaming the HD
  `patch-A`→`patch-F` (keeping OctoWoW's `patch-A`) → crash at the character screen** (OctoWoW's
  patch-A char data conflicts with the HD char models). An earlier "patch-F works" note was a
  FALSE POSITIVE (tested with vanillaHelpers OFF, so HD was actually loading from `patch-A`).
- **Consequence → the Lutris play path is the HD-safe one.** The OctoLauncher rewrites `patch-A`
  with OctoWoW's own on every update (UPDATE replaces PLAY until you let it), clobbering the HD
  `patch-A`. **`play-octowow.sh` (the Lutris path) never opens the launcher → the HD `patch-A`
  survives.** So: HD users play via Lutris; after ever opening the launcher to update OctoWoW,
  re-copy the HD `patch-A`. (vanillaHelpers is also the DLL that recursively scans the game
  folder → keep the prefix a SIBLING.) Caveat: Turtle patches on OctoWoW — some custom models
  may differ; content compatibility is the user's call.
- **Leave the launcher mod "UnitXP" OFF** (re-injects UnitXP_SP3.dll → crash).
- English `enUS` is **not** cleanly possible (no enUS locale data → #132 after login).
  Playable state = deDE.

## Repo layout

- `README.md` — the lean, launcher-centric guide (English, ~/Games/octowow).
- `octowow.yml` — legacy Lutris install script (GUI flow unreliable — use add-to-lutris.sh).
- `scripts/` — setup-launcher, add-to-lutris, octowow-chooser, play-octowow, start-octolauncher.
- `appendix/` — bare headless install (raw-exe fix) + lutris.net draft (blocked until repo public).
- `install-artwork.sh` + `artwork/` — Lutris + Steam art.
- `TESTING.md` — clean-room checklist for the launcher flow.

## Status & open items (2026-06-20)

- **Tested the full flow on the girlfriend's Bazzite PC (Shari-PC) on 2026-06-20.** Started
  from a leftover broken headless install at `~/Spiele/OctoWoW` (9.3 GB, corrupt exe). Moved
  it to `~/Games/octowow` (no re-download), removed the corrupt `WoW.exe`, old prefix and stale
  Lutris entry, ran `setup-launcher.sh` (✅ smoke-test passed — silent install produced a working
  OctoLauncher.exe), opened the launcher, enabled vanillaFixes + dxvk (MODS) + largeAddress
  (TWEAKS), Install/Verify restored a clean LAA `WoW.exe` + `d3d9.dll` + `VanillaFixes.exe`.
  **Then the launcher's PLAY worked end-to-end → in-world.** (so open items a + b: DONE.)
- **Both play paths now proven on this machine:** (1) launcher PLAY (umu + Proton) works for a
  plain install; (2) the **Lutris path** (`add-to-lutris.sh` → chooser → `play-octowow.sh` →
  VanillaFixes under wine-ge, sibling prefix, DXVK) works → in-world. DXVK confirmed active
  (RX 6800/RADV). **For HD users the Lutris path is the right one** (launcher PLAY forces a
  `patch-A` update that clobbers HD; the Lutris path never opens the launcher). Author's call
  (2026-06-20): **keep HD patches at native letters, no renaming hacks** (the patch-F idea was
  abandoned — it crashes; see HD facts above).
- **Guide bugs found during this test (fix in README before publishing):**
  - The OctoLauncher's Wine **folder picker** is confusing: must pick the folder in the
    **right pane** (not the left tree); expand `/` → `home` → `<user>` → `Games` → `octowow`;
    the chosen path then shows as a Wine drive letter (e.g. `X:\Games\octowow`) — that's normal.
  - **Apply vs Install:** mods/tweaks only take effect after pressing **Apply**; **Install**
    only fetches/verifies client files. Had to press Install + Update (×2) to fully finish.
  - The **"Update available!" screen appears on every launcher start** and re-writes
    `patch-A.mpq` (the HD patch-A trap — see HD facts; play via Lutris to avoid it).
  - **`octowow.yml` GUI install is broken (FIXED via new script):** (1) its `execute: chmod`
    installer step ran with no operands → install aborted (code 256) — removed from the yml;
    (2) `runner: linux` + no `files:` section made Lutris leave the game `directory` empty, so
    `$GAMEDIR` stayed literal and Play failed (`$GAMEDIR/$GAMEDIR/octowow-chooser.sh not found`).
    **Fix: new `scripts/add-to-lutris.sh`** writes the config + pga.db row directly with absolute
    paths (Lutris must be closed). README Phase 2 now uses it; `octowow.yml` kept only as legacy.
- **DONE 2026-06-20:** (c) public repo created + pushed → **https://github.com/pyrahead-stack/octowow-linux**
  (`main` branch, SSH remote `git@github.com:pyrahead-stack/octowow-linux.git`).
- **`add-to-lutris.sh` VALIDATED 2026-06-20** (sandbox run under a fake `HOME` with a real-schema empty
  pga.db, on the author's PC): writes a correct config yml (abs paths, slug `octowow-community`) + pga.db
  row (runner=linux, platform=Linux, directory/executable/configpath set, installed=1); **idempotent**
  (2nd run UPDATEs the same id, no dup); fails cleanly if the chooser is missing/non-exec. No script change
  needed. (Real Lutris left untouched; tested in isolation, not launched via Lutris.)
- **Still not done:** (d) lutris.net submission; re-test the whole launcher→PLAY flow on a truly CLEAN
  machine (the Shari-PC + author-PC runs both reused existing data / pre-existing installs).
- The author's own PC has a reference install at `~/Spiele/OctoWoW` (19 GB) + `~/Spiele/OctoLauncher`
  — do not wipe it. **VERIFIED WORKING 2026-06-20:** its `WoW.exe` is already a CLEAN LAA exe
  (4 907 008 B, LAA on; the corrupt headless one is safely kept as `WoW.exe.octopatched.bak`,
  4 907 050 B). Launched via the in-folder `play-octowow.sh` (wine-ge-8-26, prefix `~/Spiele/OctoWoW/prefix`,
  `d3d9=n,b`) → DXVK swapchain 2560×1440, login screen, **author confirmed in-world**. So the corrupt-exe
  crash is gone here; no launcher Install/Verify was needed. (Prefix sits INSIDE the game folder here and
  works fine — the recursion #132 only bites with a `pfx -> .` symlink loop, not a plain prefix dir.)

## Clean-room test on a fresh Linux Mint laptop (2026-06-20, ✅ PASSED end-to-end)

**RESULT: the README alone took a stranger from nothing → in-world on a fresh non-Bazzite machine.**
Client downloaded (9.3 GB), launcher's **PLAY** → login → in-game confirmed by the author. The guide is
now clean-room-proven cross-distro (Mint 22.3 / AMD RADV), which unblocks the lutris.net submission.


First truly-clean, non-Bazzite test — laptop `janosch@Minty`, **Linux Mint 22.3**, kernel 6.17,
**AMD Renoir APU / RADV** (Vulkan 1.4 fine), reached via SSH (driven by the author's PC). Installed
fresh from a `git clone` of the public repo. Findings + fixes already pushed:
- **Guide-bug: "Get the package" step was missing** → README now has a `git clone` / Download-ZIP step.
- **Guide-bug: non-Bazzite needs umu-launcher** (the only manual prereq) → README "Not on Bazzite?"
  note with a robust umu **zipapp** one-liner (tar extracts to `umu/umu-run`; copy that to `~/.local/bin`).
  Mint already had `git/curl/tar/zenity/wine/vulkaninfo`; only `umu-run` was missing.
- **BIG one — Proton choice decides whether the silent install works:** umu with a forced **GE-Proton**
  returns from its pressure-vessel container BEFORE the silent OctoLauncher installer finishes → install
  killed half-done, `OctoLauncher.exe` never appears. umu with **UMU-Proton** (PROTONPATH unset) **WAITS**
  → install completes (~65 s, proven). So: **leave PROTONPATH unset everywhere → UMU-Proton.** (An earlier
  "PROTONPATH=GE-Proton" fix was WRONG and was reverted.) setup-launcher.sh also waits for the exe to appear.
- **First umu run downloads UMU-Proton + the Steam runtime (sniper, ~790 MB).** The very first UMU-Proton
  fetch can fail transiently ("UMU-Proton not found") — a re-run succeeds (runtime cached). Documented.
- **Not a guide bug (SSH artifact):** running the GUI install over SSH needs `DISPLAY=:0` +
  `XAUTHORITY=~/.Xauthority` stolen from the active session (tty7). A normal user runs setup in their
  own graphical terminal, which already has a display. Detached procs survive (active GUI session present).
- **Full path that worked on Mint:** install umu zipapp → `git clone` repo → `setup-launcher.sh` (umu
  pulls UMU-Proton + runtime, installs the launcher) → open launcher → set folder `~/Games/octowow` →
  vanillaFixes+largeAddress+Apply → Install/Verify (9.3 GB) → **PLAY → login → in-world.** No Lutris needed
  (vanilla path). The launcher's folder picker (right pane → X:\Games\octowow) and Apply-vs-Install were
  the only mild friction — already documented in the README.

## Handoff — resuming on the author's own PC (transferred via Warpinator 2026-06-20)

This repo was last worked on the girlfriend's PC (Shari-PC) and copied to the author's
PC via Warpinator. Personal memory in `~/.claude/...` does NOT travel — everything needed
is in this file. State at handoff: commit `bb3efe3`, working tree clean. **Next steps:**
- ✅ **DONE 2026-06-20:** GitHub remote set up + pushed → https://github.com/pyrahead-stack/octowow-linux (`main`).
- **Author's PC reference install** at `~/Spiele/OctoWoW` (19 GB): its `WoW.exe` likely came via
  the headless OctoUpdater = the corrupt one → that's why "PLAY failed" there. To get a working
  setup: point the OctoLauncher at it (or a fresh `~/Games/octowow`) and **Install/Verify** — that
  restores a clean LAA `WoW.exe`, after which both launcher-PLAY and the Lutris path work.
- **Test `scripts/add-to-lutris.sh` fresh** — on Shari-PC the Lutris entry was first hand-built,
  then the script written to match; it hasn't been run from scratch yet.
- **Steam Deck:** the author plans to run the original Lutris test there and uninstall OctoWoW.
- Optional: Steam artwork (needs a Steam shortcut first), lutris.net submission.

## When `/octowowinstall` is invoked

Read this file + `TESTING.md`, figure out whether the user is starting fresh or resuming,
and walk them through the launcher-centric install (or the relevant fix). Verify any
file/flag still exists before relying on it.
