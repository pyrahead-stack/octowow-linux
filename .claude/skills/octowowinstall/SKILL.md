---
name: octowowinstall
description: Resume or run the OctoWoW-on-Linux install/test. Use when the user types "octowowinstall" or asks to install, set up, test, or debug OctoWoW (Mysteries of Azeroth, WoW 1.12) on Bazzite / Fedora Atomic / Steam Deck via the Lutris + OctoLauncher package in this repo.
---

# OctoWoW install / resume

You are continuing work on the OctoWoW Linux install package in this repo. This skill
loads the project context so you can pick up where things left off on any machine.

## Step 1 — load context

Read these (they are the portable memory):
- `CLAUDE.md` — install model, hard-won facts, current status, open items.
- `README.md` — the user-facing launcher-centric guide.
- `TESTING.md` — the clean-room test checklist.

## Step 2 — orient

Determine the situation before acting:
- **Which machine / who** — the author's PC (has a working reference install at
  `~/Spiele/OctoWoW`; don't wipe it) or a fresh machine (e.g. the girlfriend's PC)?
- **What exists already** — check `~/Games/octowow`, `~/Games/octowow-launcher`, Lutris
  entries (`~/.config/lutris/games/`, `~/.local/share/lutris/pga.db`), and whether the
  client is downloaded (WoW.exe / VanillaFixes.exe / d3d9.dll present).
- **Fresh install vs resume vs debug a crash** — pick the path accordingly.

## Step 3 — act

- **Fresh install:** follow the README's launcher-centric flow — run
  `scripts/setup-launcher.sh`, open the OctoLauncher (folder `~/Games/octowow`, enable
  vanillaFixes + largeAddress, Install/Verify), then add `octowow.yml` to Lutris and Play.
- **Debugging:** consult the "Hard-won facts" in `CLAUDE.md` first — most crashes map to a
  known cause (prefix inside game folder → #132; Proton instead of wine-ge; corrupted
  WoW.exe; missing largeAddress → green screen; wrong realmlist).
- **Testing:** use `TESTING.md` as the checklist; record every friction point as a guide bug.

Always verify a file/flag still exists before relying on it — this package evolves.
Keep the README a lean checklist (the author dislikes fluff). Use `~/Games/octowow` and
English everywhere.
