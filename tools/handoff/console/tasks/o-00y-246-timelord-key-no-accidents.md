# o-00y-246 timelord-key-no-accidents : timelord mode never switches on by a brushed key
party-breaking: yes
camera: 1
HIS WORDS 10-31 (in the Gameplay Edit Intaker chat): "sometimes the game randomly cuts timelord mode on even when I don't change it in settings -- why?"
PARTY RELEVANT (his 10-30 order: fixes critical for two player play may be built in the next 30 hours, tested, mostly on Codex): guests at the party will brush this key.

Cause (v36.55), dark_raiders.html ~18280: one tap of the key left of 1 (Backquote, the ` / ~ key) runs cycleGameOpt('superhot'), which flips timelord mode, SAVES it and says "timelord on" in the left feed. It works everywhere, the arcade demo included. That key sits between Esc, Tab and 1 (gun 1, pause), so it is easy to hit by accident. (The other way it changes without Settings: a joining window follows the host's timelord word, netShTake ~63785; that one is by design.)
Build:
1. The key toggles timelord mode only when HELD about 0.6 s (a short fill ring or bar beside the "timelord on/off" line is enough; no extra text). A tap does nothing.
2. In the arcade demo the key does nothing at all (the demo always starts with timelord off, v35.xx cw-shoff; keep that).
3. Shift + the key (the tune panel) is unchanged. The key list and controls page say "hold" for it.
Check (must FAIL on v36.55): tap Backquote in a raid: CFG.superhot unchanged; hold 0.7 s: it flips; in an arcade raid a hold does nothing.
Rules: seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows; never change salvagerun:profile. DESIGN.md watch line: "timelord mode needs a held key and is off limits in the demo". Model: Codex or Sonnet 5.5 high.
TASK DONE when it shipped and is ON HIS PC.

CEO 10-31 04:55: party-breaking (guests flip timelord by brushing the key left of 1), so Codex builds it past its week reserve. Must be ON HIS PC before the Sat 12:00 freeze; if it cannot pass the gate by 11:30, ship nothing.
