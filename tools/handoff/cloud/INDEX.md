# Cloud drafts: index (2026-10-15)

Every draft below was found, proven, drafted, reviewed and gated by a cloud hunt (see tools/handoff/CLOUD-DRAFTS.md and the
five findings files in this folder). Ship one with `bash tools/handoff/shipone.sh KEY PREV NEW` on his PC. Gate any draft
in the cloud with `python3 tools/cloud/draftgate.py KEY`. The PC kept shipping while the hunts ran, so a draft can STOP
on an anchor the PC changed; that STOP is the right outcome (re-draft or drop it), never force it.

## Same bug found twice: ship the first key, drop the rest

| Bug | Ship | Drop (same fix) |
|---|---|---|
| Player 2 screen clear | cloud-coop-p2-screen-clear | cloud-raid-p2clear |
| Player 2 sees the volatile blast | cloud-coop-volatile-boom-seen | cloud-raid-p2boom |
| Takeover replays events and fires | cloud-coop-takeover-no-replay | cloud-raid-takeoverflow, cloud-robust-takeover-events, cloud-robust-takeover-fires |
| Takeover pays a free stronghold | cloud-raid-takeover | cloud-coop-takeover-no-free-stronghold, cloud-robust-takeover-stronghold |
| Power-ups end on death | cloud-raid-pwrdeath | cloud-robust-pwr-death |
| Dead Overseer ends its rampage | cloud-raid-rampagedead | cloud-robust-rampage-dead |
| Respawn pulled into a stronghold | cloud-raid-shrespawn | cloud-robust-sh-respawn |
| Close call for player 2 | cloud-coop-p2-close-call | cloud-feel-closecall-p2 |
| Hit stop for player 2 rounds | cloud-coop-p2-hit-stop-rule | cloud-feel-hitstop-p2 |
| Teammate sees ricochets | cloud-coop-ricochet-seen | cloud-feel-ricochet-net |
| Player 2 sees a pillager gun and role | cloud-coop-pillager-gun-sync | cloud-feel-role-net |
| Pad prompts follow changed buttons | cloud-menus-pad-prompts-follow-binds | cloud-coop-pad-prompts-rebound |
| Air strike names your buttons | cloud-menus-air-strike-keys | cloud-coop-air-chord-rebound |

## Overlapping fixes: ship one, then re-gate the others (they may STOP or become one line)

- Player 2 reach, cones and the Overseer mark: cloud-raid-p2reach, cloud-raid-p2boss, cloud-coop-search-cones-built, cloud-coop-late-body-boss-range
- Player 2 blows and blasts: cloud-coop-p2-blast-past-shield, cloud-feel-p2-blow-not-round

## Drafted, but one hunt flagged it as his call

- cloud-coop-barrels-both-windows: the crashes hunt left barrel sharing across windows for his ruling
- cloud-coop-kid-firing-no-item: the crashes hunt left kid auto-fire for his ruling
- cloud-coop-mender-beams-seen: the raid hunt left the mender beams in the player 2 window for his ruling; his principle (player 2 sees what the host sees) may already decide it

## All drafts (96), by area

| Key | Title | Note |
|---|---|---|
| cloud-coop-air-chord-rebound | AIR STRIKE PROMPTS FOLLOW CHANGED BUTTONS | DROP: same as cloud-menus-air-strike-keys |
| cloud-coop-barrels-both-windows | BARRELS GO UP IN BOTH WINDOWS |  |
| cloud-coop-bounty-end-said | PLAYER 2 HEARS HOW THE BOUNTY ENDS |  |
| cloud-coop-convoy-dest | PLAYER 2 KEEPS THE CONVOY WHEN THE HOST LEAVES |  |
| cloud-coop-event-ends-said | PLAYER 2 HEARS HOW THE CONVOY AND THE RAMPAGE END |  |
| cloud-coop-getup-vs-burn | PLAYER 2 SEES A BURNING DOWNED PILLAGER GET UP EARLY |  |
| cloud-coop-host-out-events-end | RAID EVENTS END FOR PLAYER 2 WHEN THE HOST LEAVES |  |
| cloud-coop-kid-firing-no-item | KID FIRING LEAVES HIS ITEM ALONE |  |
| cloud-coop-late-body-boss-range | PLAYER 2 SEES THE OVERSEER AND LATE SENTRIES AT FULL REACH |  |
| cloud-coop-mender-beams-seen | PLAYER 2 SEES THE MENDER BEAMS |  |
| cloud-coop-overseer-phase-shake | PLAYER 2 FEELS THE OVERSEER CHANGE PHASE |  |
| cloud-coop-p2-blast-past-shield | PLAYER 2 BLASTS GO PAST THE SHIELD |  |
| cloud-coop-p2-close-call | PLAYER 2 GETS CLOSE CALL |  |
| cloud-coop-p2-hit-stop-rule | PLAYER 2 HIT STOP BY THE HOST RULE |  |
| cloud-coop-p2-kept-kit | PLAYER 2 GOES UP WITH HIS KEPT KIT |  |
| cloud-coop-p2-mimic-seen | PLAYER 2 SEES THE MIMIC HE OPENED |  |
| cloud-coop-p2-near-miss-pins | PLAYER 2 NEAR MISSES PIN PILLAGERS |  |
| cloud-coop-p2-screen-clear | PLAYER 2 SCREEN CLEAR CLEARS THE SCREEN |  |
| cloud-coop-pad-active-reload | ACTIVE RELOAD ON A CONTROLLER NEXT TO A BOX |  |
| cloud-coop-pad-prompts-rebound | PAD PROMPTS NAME THE BUTTONS AS BOUND | DROP: same as cloud-menus-pad-prompts-follow-binds |
| cloud-coop-pad-settings-under-bar | CONTROLLER HIGHLIGHT NEVER HIDES UNDER THE SETTINGS JUMP BAR |  |
| cloud-coop-pillager-gun-sync | PLAYER 2 SEES THE GUN EACH PILLAGER REALLY HOLDS |  |
| cloud-coop-ricochet-seen | TEAMMATE SEES RICOCHETS |  |
| cloud-coop-search-cones-built | PLAYER 2 SEES SEARCH CONES ON BUILT BODIES |  |
| cloud-coop-smg-on-its-key | THE SMG STARTS ON ITS OWN KEY |  |
| cloud-coop-spectate-event-buffs-end | THE OVERSEER RAMPAGE ENDS WHEN THE HOST LEAVES |  |
| cloud-coop-takeover-goals-kept | PARTY RUN GOALS KEEP THEIR PROGRESS WHEN THE HOST LEAVES |  |
| cloud-coop-takeover-no-free-event | NO FREE CONVOY CRATE WHEN THE HOST LEAVES |  |
| cloud-coop-takeover-no-free-stronghold | NO FREE STRONGHOLD PAY AFTER THE TAKEOVER | DROP: same as cloud-raid-takeover |
| cloud-coop-takeover-no-replay | A RAID PICKED UP FROM THE HOST DOES NOT REPLAY ITS EVENTS |  |
| cloud-coop-teammate-bare-hands | YOUR TEAMMATE SHOWS BARE HANDS WHEN HIS HANDS ARE BUSY |  |
| cloud-coop-teammate-hears-windup | THE TEAMMATE HEARS THE SPIN-UP AND THE LANCE CHARGE |  |
| cloud-coop-teammate-shield-bubble | YOUR TEAMMATE'S SHIELD BUBBLE IS SEEN IN YOUR WINDOW |  |
| cloud-coop-volatile-boom-seen | PLAYER 2 SEES THE VOLATILE BLAST |  |
| cloud-coop-wave-said-to-p2 | PLAYER 2 IS TOLD EVERY WAVE |  |
| cloud-feel-closecall-downed | NO CLOSE CALL ON THE FLOOR |  |
| cloud-feel-closecall-p2 | CLOSE CALL FOR PLAYER 2 TOO | DROP: same as cloud-coop-p2-close-call |
| cloud-feel-draw-roll | A ROLL NO LONGER HOLDS UP THE GUN YOU ARE DRAWING |  |
| cloud-feel-finish-dying | NO FINISH PROMPT WHILE YOU DIE |  |
| cloud-feel-hitstop-p2 | PLAYER 2'S HEAVY ROUNDS STOP AN ARMOURED PILLAGER TOO | DROP: same as cloud-coop-p2-hit-stop-rule |
| cloud-feel-hold-crowbar | NO CROWBAR SWING WHILE YOU ARE DROPPING IN |  |
| cloud-feel-howler-circle | HOWLER LANDING CIRCLE SHOWS THE REAL BLAST |  |
| cloud-feel-lane-target | THE AIM LANE POINTS AT THE PLAYER THE MACHINE WILL SHOOT |  |
| cloud-feel-muzzle-net | PLAYER 2 SEES HIS TEAMMATE'S FLASH AT THE MUZZLE |  |
| cloud-feel-p2-blow-not-round | PLAYER 2'S CROWBAR AND BLASTS ACT LIKE THE HOST'S |  |
| cloud-feel-padcap-nextgun | THE NEXT GUN KEYCAP NAMES RB ON A CONTROLLER |  |
| cloud-feel-reload-swap-ring | A GUN SWAPPED IN DURING A RELOAD STARTS ITS OWN RELOAD RING |  |
| cloud-feel-rico-wreck-gone | A ROUND THAT BREAKS A WRECK NO LONGER BOUNCES OFF IT |  |
| cloud-feel-ricochet-net | PLAYER 2 SEES A ROUND GLANCE OFF STEEL | DROP: same as cloud-coop-ricochet-seen |
| cloud-feel-role-net | PLAYER 2 SEES A PILLAGER'S NEW GUN AND ROLE | DROP: same as cloud-coop-pillager-gun-sync |
| cloud-feel-role-twin | A PILLAGER WITH A RARER COPY OF A GUN FIGHTS LIKE ONE WITH THE PLAIN GUN |  |
| cloud-feel-spin-downed | THE SUPPORT MG SPINS UP AGAIN AFTER YOU ARE DOWNED |  |
| cloud-menus-air-strike-keys | THE AIR STRIKE NAMES YOUR KEYS |  |
| cloud-menus-belt-key9-fits | THE NINTH BELT KEY STAYS ON SCREEN |  |
| cloud-menus-enter-skips-haul | ENTER SKIPS THE HAUL REVEAL |  |
| cloud-menus-f1-list-moved-keys | F1 LIST NAMES MOVED KEYS |  |
| cloud-menus-haul-reveal-stops | THE HAUL REVEAL STOPS WITH ITS CARD |  |
| cloud-menus-held-aim-blur | HELD AIM LET GO ON A FOCUS CHANGE |  |
| cloud-menus-keys-hold-toggle-labels | KEYS WINDOW CROUCH AND SPRINT ROWS CLAIM NO MODE |  |
| cloud-menus-keys-x-no-board | THE X KEY ROW SAYS CALL FOR EXTRACTION, THEN EXTRACT |  |
| cloud-menus-kid-sync-launch | KID ROWS PICKED UP AT LAUNCH |  |
| cloud-menus-kit-tile-names-fit | GUN KEY AND WHEEL NAMES FIT |  |
| cloud-menus-nuke-reduced-flash | REDUCED FLASHING TONES DOWN THE SITE GOING UP |  |
| cloud-menus-p2-event-trophies | PLAYER 2 EARNS THE KILL TROPHIES |  |
| cloud-menus-pad-b-closes-settings | CONTROLLER B CLOSES SETTINGS |  |
| cloud-menus-pad-menu-press-spent | A MENU PRESS NEVER ACTS IN THE RAID AFTER CHANGE PAD BUTTONS |  |
| cloud-menus-pad-prompts-follow-binds | PAD PROMPTS NAME THE BUTTONS AS SET |  |
| cloud-menus-pause-legend-fit | PAUSE KEY LINE FITS AT TEXT SIZE 2.0 |  |
| cloud-menus-restore-keeps-codex | A RESTORE CODE KEEPS THE CODEX AND GUN KILLS |  |
| cloud-menus-restore-keeps-locks | A RESTORE CODE KEEPS LOCKS AND TROPHIES |  |
| cloud-menus-settings-chip-on-open | SETTINGS LIGHTS THE RIGHT SECTION ON OPEN |  |
| cloud-menus-settings-jump-zoom | SETTINGS CHIPS JUMP RIGHT ON A BIG SCREEN |  |
| cloud-menus-tab-closes-keys | TAB CLOSES THE KEYS WINDOWS |  |
| cloud-menus-ui-volume-finds | UI VOLUME SILENCES THE FIND SOUNDS |  |
| cloud-raid-bountyfire | A BOUNTY THAT BURNS IS NOT YOUR KILL |  |
| cloud-raid-evsh | THE CONVOY AND THE BOUNTY STAY OUT OF THE STRONGHOLDS |  |
| cloud-raid-goldlabel | THE GOLDEN LABEL STANDS ABOVE THE NAMEPLATE |  |
| cloud-raid-magfence | THE MAGNET STOPS AT A SHUT STRONGHOLD FENCE |  |
| cloud-raid-p2boom | PLAYER 2 SEES A VOLATILE ELITE BLOW UP | DROP: same as cloud-coop-volatile-boom-seen |
| cloud-raid-p2boss | PLAYER 2 FIGHTS THE OVERSEER, NOT A WARDEN |  |
| cloud-raid-p2clear | PLAYER 2'S SCREEN CLEAR CLEARS THE SCREEN | DROP: same as cloud-coop-p2-screen-clear |
| cloud-raid-p2reach | PLAYER 2 SEES THE FULL SCAN CONES |  |
| cloud-raid-pwrdeath | POWER-UPS END WHEN YOU DIE |  |
| cloud-raid-rampagedead | A DEAD OVERSEER ENDS ITS RAMPAGE |  |
| cloud-raid-shforge | NO STRONGHOLD IS BUILT OVER THE FORGE |  |
| cloud-raid-shrespawn | A RESPAWN IS NOT DRAGGED BACK INTO A STRONGHOLD |  |
| cloud-raid-takeover | A TAKEOVER PAYS NO FREE STRONGHOLD OR GOLDEN HOARD |  |
| cloud-raid-takeoverflow | A TAKEOVER KEEPS THE RAID FLOW | DROP: same as cloud-coop-takeover-no-replay |
| cloud-robust-air-tally | AN AIR STRIKE KILL IS NOT COUNTED ON YOUR GUN |  |
| cloud-robust-fire-wall | A FIRE NEVER PUTS A BODY THROUGH A WALL |  |
| cloud-robust-pwr-death | POWER-UPS END WHEN YOU DIE IN THE 2 PLAYER DEMO | DROP: same as cloud-raid-pwrdeath |
| cloud-robust-rampage-dead | THE OVERSEER RAMPAGE ENDS WHEN THE OVERSEER IS ALREADY DEAD | DROP: same as cloud-raid-rampagedead |
| cloud-robust-sh-respawn | A RESPAWN IS NOT THROWN THROUGH A STRONGHOLD FENCE | DROP: same as cloud-raid-shrespawn |
| cloud-robust-takeover-events | PLAYER 2 TAKING OVER THE RAID DOES NOT RUN THE RAID EVENTS AGAIN | DROP: same as cloud-coop-takeover-no-replay |
| cloud-robust-takeover-fires | PLAYER 2 TAKING OVER THE RAID DOES NOT LIGHT THE FIRES TWICE | DROP: same as cloud-coop-takeover-no-replay |
| cloud-robust-takeover-stronghold | A STRONGHOLD IS NOT CLEARED BY PLAYER 2 TAKING OVER THE RAID | DROP: same as cloud-raid-takeover |

## Re-gated after the hunts (2026-10-15 morning)

Every draft passed its gate in its own hunt. A second pass against the newest master was cut short (cloud time limits); these
passed it again. The ship step on the PC gates each draft again in any case.

- cloud-coop-barrels-both-windows (as v27.49 on v27.48)
- cloud-coop-bounty-end-said (as v27.49 on v27.48)
- cloud-coop-convoy-dest (as v27.49 on v27.48)
- cloud-coop-event-ends-said (as v27.49 on v27.48)
- cloud-coop-getup-vs-burn (as v27.49 on v27.48)
- cloud-coop-host-out-events-end (as v27.49 on v27.48)
- cloud-coop-kid-firing-no-item (as v27.49 on v27.48)
- cloud-coop-late-body-boss-range (as v27.49 on v27.48)
- cloud-coop-mender-beams-seen (as v27.49 on v27.48)
- cloud-coop-overseer-phase-shake (as v27.49 on v27.48)
- cloud-coop-p2-blast-past-shield (as v27.49 on v27.48)
- cloud-coop-p2-close-call (as v27.49 on v27.48)
- cloud-coop-p2-hit-stop-rule (as v27.49 on v27.48)
- cloud-coop-p2-kept-kit (as v27.49 on v27.48)
- cloud-coop-barrels-both-windows (as v27.53 on v27.52)
- cloud-coop-bounty-end-said (as v27.53 on v27.52)
- cloud-coop-convoy-dest (as v27.53 on v27.52)
