# 00p-m2c-birth notes (lane a, 11-01)

SHIPPED v37.33 (cw-m2birth), v37.35 (cw-m2birth2), v37.37 (cw-m2birth3). All ON HIS PC; the last line read ON HIS PC v37.37.

## What it does
- pilRaidEnd now calls pilHeirs, not pilBirth. acctEnsure leaves P.pil null when the hall holds anyone; only a save with no lineage gets a first pillager by itself.
- Game, beside closeappear: birthNeed, birthState, birthOpen, birthDraw, birthBorn(i, name, kit) (the one door), birthFinish(go), birthAuto (host went up with the card open: heir 1, no kit). firstRunNext opens the card first.
- Guards: ascendNow and the lift R quick ascent. startRaid has no guard on purpose: the fixture's __deploy and the net word call it, and the net path calls birthAuto first.
- Kits: BIRTH_KITS beside FREEKIT. P.birthKit is the kit paid for and not yet taken up. Paying calls kitApply('free') and sets P.kitPick='free'. buildRaid moves it to g.freeKitK and hands it out in the freebie block. kitGunNow() replaces FREEKIT_GUN at the four raid end sites, so the kit gun follows the freebie pistol's rules.
- kitInfoOf(k) is the one source for the kit words on the map page.

## Choices worth knowing
- Job said "the same path the freebie kit uses". Kept: this also stops an exploit. Compact SMG sells for $900, so a kit put in the stash could be bought for $300 and sold at once.
- Economy to watch: a basic kit extracted is worth about $1,080 for $300; privileged about $1,650 for $1,500. The free freebie is already worth about $800 on an extract, so left as is.
- A paid kit is not lost by choosing another tile: P.birthKit waits, and the freebie tile and next birth show it ("paid"). A free walk-back gives it back.
- "ascend as <name>" opens the map page through the lift's own action, not straight into a raid, so he can still pack. Close, esc and B birth what is lit and stay on the floor; a kit that is lit is charged then too.

## Pictures and critic
- Own camera recipes: notes/shots/m2c-recipes.json, written by S\mk-cw-m2cshots.ps1 (not added to the shared list).
- After: shots/00p-m2c-after3 (80 default, 81 basic, 82 privileged, 85 map page), shots/00p-m2c-pad (83 pad hints), 1080 and 4K. Before the follow-ups: 00p-m2c-after, 00p-m2c-after2.
- Pad picture is staged with the padon class and the padfocus class, no real pad. The pad letter picker has no picture: check 37.35 proves it opens, survives a poll and writes the name.
- Critic 3 and 3, finish line 3. P1s skipped: "is gone" line (job keeps it), stash and bag in the header (shared stamp on every window), plain traits (job says green and red lines).

## Open
- The mockup page could not be written to tools/handoff/ (refused, not on my write list). It is at notes/progression/birth-pick-1101.html; asked the coordinator in alarms.md to copy it.
- The P.pilNote toast number and wording are m2a's and unchanged.
