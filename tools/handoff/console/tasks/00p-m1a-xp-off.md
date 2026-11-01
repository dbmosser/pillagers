# 00p-m1a-xp-off : season zero m1, build 1 of 5: XP, the player level and the XP reward ladder go away, the last unclaimed rewards paid as $
model: opus
His order (11-01, binding): "lets get rid of the concept of xp altogether -- everything you can get, you have to buy with cash". Plan: tools/handoff/progression-plan.html, milestone m1 ("XP, levels and the XP ladder off every screen"). Read tools/handoff/console/notes/progression/README.md first (m0 helpers, rules, the old save rule).
Area this job owns: the XP counters and every screen that prints XP or the player level (the Mainframe reward ladder renderSeason and openOps rows, the raid-end card XP lines in endRaid, the title and account card LVL, the hub top right, achievements or contracts that read xpLevel). NOT the stash and Peddler sale lines (00p-m1c owns them: leave their P.xp+= lines alone) and NOT the extract money (00p-m1b).
Do:
1. Once per save (stamp P.mig1x, born set in the P literal): call ladderPayout(P) again so rewards earned since v37.14 are paid as $, queue the one-time line through P.szNote exactly as seasonZeroMig does (add to an unshown note rather than replace it), and add the payout to lifetime earnings with lifeEarnAdd.
2. Stop XP from being earned (addXp, addProgress, xpForRun and every P.xp+= outside the sale lines). Keep SP (score points) exactly as it is: m4 fills the Pillager Survival Level from SP. Keep P.xp in the save untouched (a number nobody reads), so nothing is lost.
3. Take the ladder off the Mainframe (SEASON_TIERS rows, claim buttons, "rewards ready" badges, the XP away line) and every XP or level number off every screen. The Mainframe keeps contracts and stats; 00p-m1e puts lifetime earnings and the rank there.
4. Anything that a player level gated (a level-gated cosmetic, e.g. the hair colour at level 4) stops being gated: what the save has stays, nothing is taken away. grep xpLevel and syncXpLevel for every reader.
5. The restore code keeps carrying x and l (old codes must still load) but nothing shows them.
Check (must FAIL on the current build): an old save (no P.mig1x) with xp past two unclaimed rewards loads with exactly their $ added and claimed, the hub line queued, lifetime earnings up by the same; a second load adds nothing; a full extract (__deploy then __endRaid('extract')) leaves P.xp unchanged and SP counted as before; the Mainframe and raid-end card text contain no "xp" and no "lvl" (draw them through their real routes, grep the drawn text). Old save reload rule from the README.
Rules: seed 4242 fingerprint holds; demo untouched; no new player text beyond the payout line; lower case.
Pictures: Mainframe, raid-end card, title, account card, 1080p and 4K.
TASK DONE when it shipped and is ON HIS PC, with one line in notes/progression/log.md.
