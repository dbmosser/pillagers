# 202-difficulty-score-multiplier : harder settings pay a stacking SP multiplier, shown to the player
His order 10-28 (verbatim): "Ok here's the edit. When the player makes the game harder in any way in the settings (eg number of enemies, number of pillagers, damage taken, etc, that should give a score multiplier (maybe an additional 5% for each tier/level) and that should be indicated to the player. Super hot off should be considered harder and should also give the multiplier. All these multipliers should stack. Eg if player wants to play a really hard game, that should give more points."
This is a NEW FEATURE, but he overrode the 11/1 hold on 10-28 ("No I want it now"): build it now, ship as ready.
Model: claude-opus-5-5, effort high (rung 3: touches scoring, settings, both windows, party host rules).
effort: high

Do (read the settings code first; find every dial that makes the game harder):
1. List every Settings dial that can make a raid harder (enemy count, pillager bot count, damage taken, and any others found; Superhot OFF counts as harder). For each, define tiers from its default: default pays nothing; each step harder than default adds +5% (his "maybe"; keep it one constant per dial so he can tune).
2. The multiplier = product of all dials' factors (stack by multiplying, so the hardest game pays most). Applies to SP earned in raid (kill and score awards); money ($) is NOT multiplied unless he says so. Never touches the pickup stack, loot sounds or loot rows.
3. Show it: one small line in the Settings screen ("score x1.35" style, lower case) that updates as he turns dials; a small "x1.35" tag by the SP readout in raid when above x1.00; the extracted card shows it once. Nothing shown at x1.00.
4. Party: the host's settings rule for the whole party (as Superhot already does, see the v16.74 host word note); both windows show the same multiplier and award the same SP.
5. Demo mode and career follow the same rule (his DEMO/CAREER gameplay identical ruling).
Rules: seed 4242 fingerprint unchanged; no storage key change (derive the multiplier from saved dials, add nothing to the profile); new check must FAIL on the build before; both windows; player text all lower case, short. Pictures of the Settings row and the in-raid tag at 1080 (uishots).
Watch for (tell him): turning any dial harder raises the x tag; turning Superhot off raises it; the extracted card shows the number he earned with the multiplier in.
TASK DONE when ON HIS PC; TASK PARTIAL with what is left.
HIS PRIORITY 10-28: ordered directly, wants it now.

## Build log (helper, 10-28)
Choices made (small, mine):
- Dials that pay, 5% a step (DMUL_STEP, one constant each), stacked by multiplying: pillager bots (standard +1, many +2 over few), machines (standard +1, many +2 over few), how hard they hit (hardened +1, brutal +2 over standard), heat when you call for extraction (standard +1, heavy +2 over light), superhot off +1. Hardest game x1.54. Easier than default pays no less (never below x1.00).
- Baseline is the main game default even on itch (itch starts on the new player set, which then shows x1.05 from superhot off only).
- Default game (superhot off is the default) therefore shows x1.05: his rule that superhot off counts as harder.
- Not counted: raid length (career and demo raids run their own 10 minute clock, the row changes nothing there); how much is out there (it is value only, read when sold, so lean for one raid would be a free bonus); fog of war and shared sight (each window's own view, not in the raid word, so the two party windows could disagree); the experimental switches (every one is on by default, so off is only easier).
- A raid keeps the rows it was built with (G.dmul; a linked window builds from the host word), superhot read live (host word rules it on a linked window).
- Applied to sp from kills, style medals, goals, bounty, strongholds and vaults. Not to money, the haul, loot pickups or the demo loot pot. The career payout is 1 sp = $1 on extraction, so the bank follows the sp, as it always has.
- Test fixture pins DMUL_ON=0 (committed 70aefa3f8) so the older checks keep their figures; the new check turns it on for itself.
- Settings line: shows the dials as they stand (next raid); on a linked window its own rows, the host word rules the raid itself.
