# o-01c-249 seal-faster-and-defended : the seal opens 50% faster, and enemies come at you once you start opening it
HIS WORDS 10-31 (in the Gameplay Edit Intaker chat): "make the seal 50% faster to open and make it so enemies spawn and attack when you start opening the seal"
PARKED for the party freeze; build after Sun 11/1 01:00.

What is on v36.55: dark_raiders.html ~14941 sealNeed(tier)=34+tier*21 (v17.97; the work it takes to open, by tier); the seal places anywhere fair (sealrandom ~14946, SEAL_SAFE/SEAL_EXT ~14954); SEAL_CRATE ~15001.
Build:
1. 50% faster: opening speed x1.5, so the time to open is two thirds of today's at every tier (sealNeed x 2/3, or the rate x1.5; keep any perk or tool that speeds it working on top). Fix any text that states the old time.
2. Defended: the moment a pillager starts opening the seal (first frame of progress), a wave is called on it: machines (and hostile pillager bots where the map has them) come in from about 700 to 1,000 away, off the player's screen, out of sight lines, and attack the opener; a few more arrive while the opening runs (scale with the seal tier and the difficulty settings like the extraction siege does; reuse the siege arrival code rather than writing a new spawner). Only once per seal per raid (stopping and restarting does not call a second wave). A short callout in the alert lane, lower case, like "seal breach: incoming", and the existing alarm sound if one fits; nothing more (he wants fewer messages).
3. Party: one wave for the seal whoever starts it, host-run, both windows see it. Arcade the same as career.
Check (must FAIL on v36.55): start opening a tier 1 seal: within 2 s at least N hostiles are spawned and heading for the opener; the seal opens in 2/3 of the old time.
Rules: seed 4242 fingerprint must hold (draw spawns on a side stream, never the main one); both windows; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "the seal opens faster but calls a wave". Model: Opus high (or Codex).
TASK DONE when it shipped and is ON HIS PC.
