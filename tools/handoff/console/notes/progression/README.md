# Season zero progression: shared notes for every 00p job (read before you start one)

Lead: the "season zero progression" session (started 11-01 by the CEO chat). Source of truth: tools/handoff/progression-plan.html (milestones m0 to m10), his rulings tools/handoff/progression-brainstorm-1101.md (rounds 4 and 5) and his 100 answers tools/handoff/progression-answers-1101.md. Where a job file and the plan disagree, the plan wins; where the plan and his newer words disagree, his words win.

## What m0 built (v37.14 on, use these, never a second copy)
Account and pillager (cw-p0acct, v37.14), all at file scope beside rigBuyback:
- P.acctName (account name), P.pil (living pillager {name, gen, traits, lvl, lsp, picks, raids, ext, kills, best, born}), P.hall (ended pillagers, oldest first, kept forever), P.pilGen, P.lifeEarn (lifetime earnings).
- acctEnsure(p) fills and repairs all of them (runs on every load); pilNow() is the living pillager; pilEnd(p, how) moves it to the hall with r.end = {at, ...how} and leaves P.pil null; pilBirth(p, name) makes the next generation.
- lifeEarnAdd(n): THE ONLY WRITER of lifetime earnings. Call it for every $ earned (sales, extraction bonus, retire bonus). Never for refunds or buybacks of your own sale. Spending never lowers it.
- ladderPayout(p): pays every earned and unclaimed XP ladder reward as $ and marks it claimed (safe to run again). seasonZeroMig ran it once (P.mig0p). The job that removes the ladder runs it once more under its own stamp, so rewards earned between m0 and m1 are paid too.
- szNoteShow(): the one-time hub line pattern (P.szNote {c, n, shown}); never shown in the demo.
Worn gear (cw-p0gear, v37.15 or later):
- WORN_SLOTS (head, amulet, armor, pants, ring1, ring2, boots, gloves, pack), WORN_KINDS (kind to name and slots), WORN_RARS (scrap, sound, rare, relic: trait count, multiplier, colour = RCOL loot row colours), WORN_STATS (spd, stam, reload, steady, quiet, hide, heal, grit, revive, search, tough: base and cap), WORN_POOL (slot themes).
- A piece: {id, k, r 0..3, pw 1..100, tr [{s, v}], pip 0..3, dye, rule}. P.gear = stash pieces (no limit), P.worn = slot to piece, P.gearN = id counter.
- wornMake(k, r, pw, seed): rolls on its own dice (wornRand), never RNGS or FXS, so seed 4242 never moves. In a raid seed it from G.seed and something fixed per container or wreck.
- wornAdd(p, piece), wornWear(p, id, slot), wornOff(p, slot), wornClean(p) (every load), wornMods(worn) (the sum: rings with one trait take the stronger; every stat capped), wornTraitV(piece, trait) (pips: a third stronger each), wornName(piece).
Stats (cw-p0stat): raidWornMods() sums P.worn onto the raid body as G.player.wm at buildRaid; wornM(stat) is the only reader (0 with nothing worn, in G.sim, in the demo). Sites: tools/handoff/console/notes/progression/stat-sites.md. Not yet carried for a co-op partner (m3 sends it over the net link).

## Rules for every 00p job
- Ship only through mk script, preflight, shipq (RULES.md). Check must FAIL on the build before. Seed 4242 fingerprint must hold.
- EVERY JOB THAT TOUCHES THE SAVE RELOADS AN OLD SAVE IN ITS CHECK: build a save the way the build before wrote it (delete your new fields from a copy of P), load it with applyLoadedProfile({value:JSON.stringify(snap)}) with storeSet and saveProfile stubbed, and prove nothing was lost (credits, stash, weapons, equipped, contracts, forged guns, the new m0 fields), then load it a second time and prove nothing moved. Copy the pattern of the cw-p0acct and cw-p0gear checks in tools/mkfixture.ps1 (grep "cw-p0acct,").
- Never change the storage key salvagerun:profile. New fields get a once-per-save stamp (P.migNx), born set in the P literal for a new profile.
- NEVER touch the pickup stack, the loot sounds or the loot rows (his angry 10-27 order), except the one m3 job that adds gear as a new row kind in its rarity colour. Looting must feel the same.
- The demo (ARCADE) is untouched by all of this unless the job says otherwise: same preset, nothing saved, no lineage.
- Player text: lower case, short callouts, $ for money, SP for score, "ascend" (never drop in), no em or en dashes, never an explaining sentence. Names: Pillager Survival Level; lifetime earnings; ranks scrounger, cutpurse, sacker, reaver, marauder, warlord (i to v); rarities scrap, sound, rare, relic.
- Take pictures (tools/uishots.ps1) of every screen you change and look at them at 1080p and 4K.
- Never two writers in one area: if your job says WAIT ON another job and that job is in tasks/, waiting/, blocked/ or a lane holds it, end your run with TASK WAITING: <that job name> and nothing else.
- When done, add one line to tools/handoff/console/notes/progression/log.md: job, version, what he can see.
