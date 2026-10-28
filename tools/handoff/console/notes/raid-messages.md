# Raid messages: what reaches the screen (cw-msgroute, job 186c)

His complaint (10-27 ~21:25): too many messages reach the player. Built to the research rule of that night (reports/Player alerts and HUD messaging.md): a line reaches the screen only on the ladder.

- P0 danger: danger to you now (seen, shot at, a siege, a lock-on, low health), or your teammate down. The alert lane, at once.
- P1 extraction: a change in extraction (called, inbound, missed, closing, the raid clock). A line about one exit only for the exit you are heading to or one within 60 m.
- P2 teammate: other teammate news (revived, extracted, left, a gift), in the teammate colour in a party raid. Waits at most 4 s for its turn.
- P3 goal done: a contract or goal done (not progress counts). Waits until no shot was fired or taken for 4 s; several become one line.
- P4 answer: the answer to something you tried that did not work (health full, bandages stop at 85, no x left). Into the feed at once.

Everything else goes into the run log (G.msgLog) and is drawn nowhere in the raid; the pause box lists the last 8 lines of that log. The left feed shows at most 3 lines, each gone after 5 s, and takes at most one new line every 2.5 s; a repeat joins its line as x2. Kill lines stay (his answer g-86). Contract item nearby stays as it was. Looting is untouched.

Measured in a staged 3 minute raid (fixture, seed 4242, map 0: looting, a fight, an extraction): 43.3 lines drawn a minute on the build before, 30 on the new build. How to rerun it: tools/handoff/console/notes/fewer-msgs/README.md.

332 call sites: 199 keep, 107 cut (the rest pass a kind on or are run log only). Words: X is a part worked out at run time. Said in: the function that says it (its trigger). Staged raid: how many times it was said in the staged 3 minute raid on v35.42 (blank: not counted; 0: not said in that raid; the count is per wording, so two call sites with the same words show the same count).

| line | said in | words | kind | verdict | where | staged raid |
|---|---|---|---|---|---|---|
| 6721 | contractStep | CONTRACT DONE | obj | KEEP P3 goal done | left feed | 0 |
| 8200 | alarmOk | MACHINE ALERT | info | KEEP P0 danger | left feed | 0 |
| 8471 | tickMachSiren | LOCKED ON | warn | KEEP P0 danger | alert lane | 10 |
| 11573 | wxTick | X | chat | cut (run log only) |  | 0 |
| 11668 | strikeTick | LIGHTNING FUSED A CACHE | obj | cut (run log only) |  | 0 |
| 14855 | forgeOpen | X | info | cut (run log only) |  | 0 |
| 14857 | forgeOpen | need X | warn | KEEP P0 danger | alert lane | 0 |
| 14874 | forgeBuy | need X | warn | KEEP P0 danger | alert lane | 0 |
| 14879 | forgeBuy | gun upgraded | obj | KEEP P3 goal done | left feed | 0 |
| 15530 | listenersHearInner | SOMETHING WOKE UP | warn | KEEP P0 danger | alert lane | 0 |
| 16068 | strayGive | NOT ENOUGH AMMUNITION | info | KEEP P4 answer | left feed | 0 |
| 16070 | strayGive | He needs X X | info | KEEP P4 answer | left feed | 0 |
| 16089 | strayGive | +$X | pick | KEEP P3 goal done | pickup stack | 0 |
| 16093 | strayGive | CACHE MARKED | obj | KEEP P3 goal done | left feed | 0 |
| 16100 | strayGive | NOTORIETY DOWN TO X | info | cut (run log only) |  | 0 |
| 16144 | pedSellAll | HE WANTS NOTHING YOU CARRY | info | KEEP P4 answer | left feed | 0 |
| 16182 | pedSellAll | +$X | pick | KEEP P3 goal done | pickup stack | 0 |
| 16183 | pedSellAll | SOLD X ITEM / SOLD X ITEMS | info | KEEP P3 goal done | left feed | 0 |
| 16196 | pedBuy | need $X | info | KEEP P4 answer | left feed | 0 |
| 16228 | pedBuy | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 16229 | pedBuy | -$X | pick | KEEP P3 goal done | pickup stack | 0 |
| 17965 | startRaid | X | chat | cut (run log only) |  | 0 |
| 17974 | startRaid | X | info | KEEP P4 answer | left feed | 0 |
| 17980 | startRaid | YOUR RIVAL IS UP TOP | warn | cut (run log only) |  | 0 |
| 18406 | raidKey | Xloot LOOTS ON HIS OWNX | ally | KEEP P2 teammate | left feed | 0 |
| 18473 | raidKey | ZOOM X% | sys | cut (run log only) |  | 0 |
| 18474 | raidKey | ZOOM X% | sys | cut (run log only) |  | 0 |
| 18476 | raidKey | ZOOM X% | sys | cut (run log only) |  | 0 |
| 18493 | hudSizeStep | X | sys | cut (run log only) |  | 0 |
| 18609 | msMove | WAYPOINT CLEARED | sys | cut (run log only) |  | 0 |
| 18618 | msMove | WAYPOINT SET | sys | cut (run log only) |  | 0 |
| 18935 | msMove | X to slot X | info | cut (run log only) |  | 0 |
| 18940 | msMove | Xgun | info | cut (run log only) |  | 0 |
| 18993 | msMove | NOT IN BACKPACK | info | KEEP P4 answer | left feed | 0 |
| 18994 | msMove | CANNOT EQUIP | info | KEEP P4 answer | left feed | 0 |
| 19034 | msMove | X to slot X | info | cut (run log only) |  | 0 |
| 19040 | msMove | CANNOT EQUIP | info | KEEP P4 answer | left feed | 0 |
| 19047 | msMove | X to slot X | info | cut (run log only) |  | 0 |
| 19063 | msMove | SLOT X TAKES GUNS ONLY | info | KEEP P4 answer | left feed | 0 |
| 19069 | msMove | X | info | cut (run log only) |  | 0 |
| 19121 | msMove | X to slot X | info | cut (run log only) |  | 0 |
| 19146 | msMove | Gave X | info | cut (run log only) |  | 0 |
| 19160 | msMove | Dropped X | info | cut (run log only) |  | 0 |
| 19191 | msMove | X off slot X | info | cut (run log only) |  | 0 |
| 19860 | padHold | CONTROLLER CONNECTED | sys | cut (run log only) |  | 0 |
| 20325 | trig | CONTROLLER DISCONNECTED | sys | KEEP P4 answer | left feed | 0 |
| 20969 | cycleThrow | NO THROWABLE ON THE TACTICAL BELT / NO THROWABLES LEFT | info | KEEP P4 answer | left feed | 0 |
| 20975 | cycleThrow | X ready | info | cut (run log only) |  | 0 |
| 21005 | tryRoll | TOO TIRED TO ROLL | info | KEEP P4 answer | left feed | 0 |
| 21224 | throwFrom | THROW BLOCKED | info | KEEP P4 answer | left feed | 0 |
| 21224 | throwFrom | GRENADE HIT COVER | warn | KEEP P0 danger | alert lane | 0 |
| 21239 | emptyThrowCell | No X left | info | KEEP P4 answer | left feed | 0 |
| 21251 | doThrow | THROW THE ONE IN YOUR HAND FIRST | info | KEEP P4 answer | left feed | 0 |
| 21291 | cookOff | GRENADE WENT OFF IN YOUR HAND | crit | KEEP P0 danger | alert lane | 0 |
| 21339 | tripArm | TRIPWIRE SET | info | cut (run log only) |  | 0 |
| 22463 | hubToast | X | info | cut (run log only) |  | 0 |
| 22464 | hubToast | m | kind | passes the kind on |  |  |
| 22464 | hubToast | m | kind | passes the kind on |  |  |
| 22705 | locDraw | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 23358 | msgTick | _qn.m | _qn.k | passes the kind on |  |  |
| 23370 | sayWhenFree | m | kind | passes the kind on |  |  |
| 23579 | notoStamp | NOTORIETY X  .  X | warn | cut (run log only) |  | 0 |
| 23896 | _logHit | AUTO-JOG OFF | sys | cut (run log only) |  | 0 |
| 24132 | cycleHeal | NO HEAL ON BELT / NO MEDICAL SUPPLIES | info | KEEP P4 answer | left feed | 0 |
| 24136 | cycleHeal | X ready | info | cut (run log only) |  | 0 |
| 24146 | useBeltHeal | ALREADY HEALING / HEALTH FULL | info | KEEP P4 answer | left feed | 0 |
| 24148 | useBeltHeal | NO HEAL ON BELT | info | KEEP P4 answer | left feed | 0 |
| 24149 | useBeltHeal | NO MEDICAL SUPPLIES | info | KEEP P4 answer | left feed | 0 |
| 24154 | useBeltHeal | BANDAGES STOP AT X | info | KEEP P4 answer | left feed | 0 |
| 24155 | useBeltHeal | X stops at X | info | KEEP P4 answer | left feed | 0 |
| 24158 | useBeltHeal | ALREADY APPLYING | info | KEEP P4 answer | left feed | 0 |
| 24172 | beltInstant | NOT WHILE DOWN | info | KEEP P4 answer | left feed | 0 |
| 24178 | beltInstant | NO THROWABLE ON KEY X | info | KEEP P4 answer | left feed | 0 |
| 24195 | beltEquip | NOT WHILE DOWN | info | KEEP P4 answer | left feed | 0 |
| 24202 | beltEquip | NO X | info | KEEP P4 answer | left feed | 0 |
| 24233 | quickPlate | NO ARMOUR PLATE | info | KEEP P4 answer | left feed | 0 |
| 24290 | wheelOpen | NOTHING TO USE | info | KEEP P4 answer | left feed | 0 |
| 24338 | wheelRelease | NO X | info | KEEP P4 answer | left feed | 0 |
| 24356 | handTake | X out | info | cut (run log only) |  | 0 |
| 24369 | wheelHeal | ALREADY HEALING / HEALTH FULL | info | KEEP P4 answer | left feed | 0 |
| 24371 | wheelHeal | BANDAGES STOP AT X | info | KEEP P4 answer | left feed | 0 |
| 24372 | wheelHeal | X stops at X | info | KEEP P4 answer | left feed | 0 |
| 24375 | wheelHeal | ALREADY APPLYING | info | KEEP P4 answer | left feed | 0 |
| 25122 | bagDropSel | Dropped X | info | cut (run log only) |  | 0 |
| 25135 | bagBeltNo | MOVE IT TO THE BACKPACK FIRST | info | KEEP P4 answer | left feed | 0 |
| 25404 | useMedical | ALREADY HEALING / HEALTH FULL | info | KEEP P4 answer | left feed | 0 |
| 25411 | useMedical | BANDAGES STOP AT X | info | KEEP P4 answer | left feed | 0 |
| 25412 | useMedical | NO MEDICAL SUPPLIES | info | KEEP P4 answer | left feed | 0 |
| 25415 | useMedical | ALREADY APPLYING | info | KEEP P4 answer | left feed | 0 |
| 25506 | tickPrepSlot | X slotted | info | cut (run log only) |  | 0 |
| 25515 | tickPrepSlot | PATCHED UP | info | cut (run log only) |  | 0 |
| 25974 | overseerTick | X | warn | KEEP P0 danger | alert lane | 0 |
| 26522 | openContainer | HOT GROUND | obj | cut (run log only) |  | 0 |
| 26740 | grantLoot | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 26741 | grantLoot | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 26877 | bagHeldGun | Nothing to pick up. | info | KEEP P4 answer | left feed | 0 |
| 26878 | bagHeldGun | ISSUED GEAR STAYS IN YOUR HANDS | info | KEEP P4 answer | left feed | 0 |
| 26879 | bagHeldGun | CANNOT STOW THAT GUN | info | KEEP P4 answer | left feed | 0 |
| 26893 | bagHeldGun | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 27071 | _slotFree | X | info | cut (run log only) |  | 0 |
| 27169 | gunClassPlace | X | info | cut (run log only) |  | 0 |
| 27177 | gunClassPlace | X | info | cut (run log only) |  | 0 |
| 27181 | gunClassPlace | X | info | cut (run log only) |  | 0 |
| 27181 | gunClassPlace | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 27193 | gunClassUpgrade | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 27308 | beltGunFull | X | info | cut (run log only) |  | 0 |
| 27331 | beltGunFull | X | info | cut (run log only) |  | 0 |
| 27331 | beltGunFull | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 27381 | autoBelt | X | info | cut (run log only) |  | 0 |
| 27642 | beltClassPin | X | info | cut (run log only) |  | 0 |
| 27645 | beltClassPin | NO FREE KEY | info | KEEP P4 answer | left feed | 0 |
| 27716 | useArmor | ARMOUR FULL | info | KEEP P4 answer | left feed | 0 |
| 27718 | useArmor | ALREADY SLOTTING | info | KEEP P4 answer | left feed | 0 |
| 27737 | beltStep | X | info | cut (run log only) |  | 0 |
| 27798 | setHot | Gun slot X empty | info | KEEP P4 answer | left feed | 0 |
| 27814 | setHot | Gun slot X empty | info | KEEP P4 answer | left feed | 0 |
| 27824 | setHot | NOT IN BACKPACK | info | KEEP P4 answer | left feed | 0 |
| 27825 | setHot | CANNOT EQUIP | info | KEEP P4 answer | left feed | 0 |
| 27862 | useStim | No X left | info | KEEP P4 answer | left feed | 0 |
| 27865 | useStim | X active | info | cut (run log only) |  | 0 |
| 27873 | useHot | NOT WHILE DOWN | info | KEEP P4 answer | left feed | 0 |
| 27897 | useHot | No X left | info | KEEP P4 answer | left feed | 0 |
| 27910 | useHot | ALREADY HEALING / HEALTH FULL | info | KEEP P4 answer | left feed | 0 |
| 27915 | useHot | X stops at X | info | KEEP P4 answer | left feed | 0 |
| 27916 | useHot | ALREADY APPLYING | info | KEEP P4 answer | left feed | 0 |
| 27997 | tryExtractTick | Knocked down. Extraction progress bar reset. Hold XKeyXX to try again. | ext | KEEP P1 extraction | alert lane | 0 |
| 28068 | tryExtractTick | EXTRACTION X IS CLOSED | info | KEEP P1 extraction | left feed | 0 |
| 28150 | tryExtractTick | EXTRACTION CALLED | ext | KEEP P1 extraction | alert lane | 2 |
| 28151 | tryExtractTick | SIEGE INCOMING | warn | KEEP P0 danger | alert lane | 1 |
| 28435 | tickRaiderWaves | PILLAGER BOT REINFORCEMENTS | warn | KEEP P0 danger | alert lane | 6 |
| 28668 | tickExtractPoints | EXTRACT IN PROGRESS! | ext | KEEP P1 extraction | alert lane | 3 |
| 28698 | tickExtractPoints | EXTRACTION MISSED | ext | KEEP P1 extraction | alert lane | 2 |
| 28745 | tickExtractPoints | EXTRACTION X CLOSING | ext | KEEP P1 extraction, only for your exit or one within 60 m (his order 10-27 ~22:35); any other exit: run log only | alert lane | 4 |
| 28750 | tickExtractPoints | EXTRACTION X CLOSED | ext | KEEP P1 extraction, only for your exit or one within 60 m (his order 10-27 ~22:35); any other exit: run log only | alert lane | 2 |
| 28891 | selfRevive | Self-revive spent. One per raid. | info | KEEP P4 answer | left feed | 0 |
| 28900 | selfRevive | SELF-REVIVE USED | info | cut (run log only) |  | 0 |
| 28920 | autoEmptyGun | X | info | cut (run log only) |  | 0 |
| 28958 | updatePlayer | X wore off | chat | cut (run log only) |  | 0 |
| 29102 | updatePlayer | STOP FIRST | info | KEEP P4 answer | left feed | 0 |
| 29103 | updatePlayer | AUTO-JOG OFF | sys | cut (run log only) |  | 0 |
| 29103 | updatePlayer | AUTO-JOG ON | sys | cut (run log only) |  | 0 |
| 29109 | updatePlayer | AUTO-JOG OFF | sys | cut (run log only) |  | 0 |
| 29318 | updatePlayer | JAM CLEARED | info | cut (run log only) |  | 0 |
| 29387 | updatePlayer | EMPTY SLOT | info | KEEP P4 answer | left feed | 0 |
| 29398 | updatePlayer | No X left | info | KEEP P4 answer | left feed | 0 |
| 29413 | updatePlayer | No X left | info | KEEP P4 answer | left feed | 0 |
| 29437 | updatePlayer | X jammed | info | KEEP P4 answer | left feed | 0 |
| 29505 | updatePlayer | X open | obj | cut (run log only) |  | 0 |
| 29535 | updatePlayer | SEAL BROKEN | obj | cut (run log only) |  | 0 |
| 29661 | updatePlayer | X received | info | KEEP P2 teammate | left feed | 0 |
| 29670 | updatePlayer | X IS BACK UP | ally | KEEP P2 teammate | left feed | 0 |
| 29671 | updatePlayer | HE IS BACK UP | ally | KEEP P2 teammate | left feed | 0 |
| 29724 | updatePlayer | NO DEAL | info | KEEP P4 answer | left feed | 0 |
| 29778 | updatePlayer | WALL GLITCH SAVED TO RUN REPORT | sys | KEEP P4 answer | left feed | 0 |
| 29954 | updatePlayer | X EMPTY | info | KEEP P4 answer | left feed | 0 |
| 31232 | updateEnts | SOMETHING RESTOCKED NEARBY | chat | cut (run log only) |  | 1 |
| 31348 | updateEnts | IT WAS PLAYING DEAD | warn | KEEP P0 danger | alert lane | 0 |
| 31417 | updateEnts | SOMEONE SHOT THE SURVIVOR | chat | cut (run log only) |  | 0 |
| 31439 | updateEnts | THE PEDDLER IS DEAD | chat | cut (run log only) |  | 0 |
| 31470 | updateEnts | X WANTS REVENGE | info | cut (run log only) |  | 0 |
| 31478 | updateEnts | X IS DEAD | obj | KEEP P3 goal done | left feed | 0 |
| 31483 | updateEnts | X DESTROYED | obj | KEEP P3 goal done | left feed | 0 |
| 31484 | updateEnts | X DESTROYED | obj | KEEP P3 goal done | left feed | 0 |
| 31494 | updateEnts | X DESTROYED | obj | KEEP P3 goal done | left feed | 0 |
| 31524 | updateEnts | X DESTROYED | obj | KEEP P3 goal done | left feed | 0 |
| 31691 | updateEnts | SURVIVOR EXTRACTED | info | KEEP P3 goal done | left feed | 0 |
| 31716 | updateEnts | TEAMMATE FOUND A SURVIVOR | obj | cut (run log only) |  | 0 |
| 31719 | updateEnts | THE SURVIVOR IS STILL THERE | obj | cut (run log only) |  | 0 |
| 31720 | updateEnts | SURVIVOR FOUND | obj | cut (run log only) |  | 0 |
| 31734 | updateEnts | THE PEDDLER BOLTS | info | cut (run log only) |  | 0 |
| 31763 | updateEnts | THE PEDDLER SET UP SHOP | chat | cut (run log only) |  | 0 |
| 31771 | updateEnts | THE PEDDLER IS BACK | chat | cut (run log only) |  | 0 |
| 31781 | updateEnts | THE PEDDLER WAVES YOU OVER / THE PEDDLER TURNS HIS BACK | ally | cut (run log only) |  | 0 |
| 32026 | updateEnts | THE PILLBOX HAS SEEN YOU | warn | KEEP P0 danger | alert lane | 0 |
| 32060 | updateEnts | X | warn | KEEP P0 danger | alert lane | 0 |
| 32156 | updateEnts | A CRIER IS REVEALING YOUR LOCATION | warn | KEEP P0 danger | alert lane | 16 |
| 32201 | updateEnts | CRIER REVEALED YOUR LOCATION / CRIER REVEALED YOUR LAST LOCATION | warn | KEEP P0 danger | alert lane | 8 |
| 32341 | updateEnts | X TRUSTED YOU | info | cut (run log only) |  | 0 |
| 32350 | updateEnts | PILLAGER BOT TURNED HOSTILE | warn | KEEP P0 danger | alert lane | 0 |
| 32354 | updateEnts | X IS FRIENDLY / X IS WATCHING | chat | cut (run log only) |  | 1 |
| 32726 | updateEnts | X IS COMING FOR YOU | ally | KEEP P2 teammate | left feed | 0 |
| 32734 | updateEnts | X REVIVED YOU | ally | KEEP P2 teammate | left feed | 0 |
| 33071 | updateEnts | PILLAGER BOT CALLED EXTRACTION | info | KEEP P1 extraction | left feed | 1 |
| 33449 | updateBullets | WARDEN ARMOUR / BULWARK SHIELD | info | KEEP P4 answer | left feed | 0 |
| 33470 | updateBullets | THE SURVIVOR RETURNS FIRE | warn | KEEP P0 danger | alert lane | 0 |
| 33471 | updateBullets | THE SURVIVOR RETURNS FIRE | warn | KEEP P0 danger | alert lane | 0 |
| 33612 | updateBullets | DEER DOWN / BIRD DOWN | chat | cut (run log only) |  | 0 |
| 35730 | drsMove | RESOLUTION STEPPED DOWN | sys | cut (run log only) |  | 0 |
| 42916 | giftTick | OFFER EXPIRED | ally | KEEP P2 teammate | left feed | 0 |
| 42917 | giftTick | X DID NOT TAKE IT | ally | KEEP P2 teammate | left feed | 0 |
| 43201 | msgRowH | m | kind | passes the kind on |  |  |
| 45742 | trophyKill | TROPHY EARNED | ext | KEEP P3 goal done | alert lane | 0 |
| 45807 | needHint | CONTRACT ITEM NEARBY | obj | KEEP as before (his call, close to looting) | left feed | 0 |
| 46194 | tickHot | HOT GROUND MOVED | obj | cut (run log only) |  | 1 |
| 50771 | tickClockWarn | THIRTY SECONDS | warn | KEEP P0 danger | alert lane | 0 |
| 50773 | tickClockWarn | X MINUTE LEFT / X MINUTES LEFT | obj | KEEP P1 extraction | left feed | 0 |
| 50780 | tickClockWarn | TEN SECONDS | crit | KEEP P0 danger | alert lane | 0 |
| 51694 | restoreCursor | CURSOR RESET | sys | cut (run log only) |  | 0 |
| 51757 | errRow | String(raw) | log | run log only (as before) |  | 0 |
| 51758 | errRow | X | sys | cut (run log only) |  | 0 |
| 51761 | errRow | X | sys | cut (run log only) |  | 0 |
| 51888 | perfNote | RUNNING SLOWLY | sys | cut (run log only) |  | 0 |
| 54476 | loop | MERIDIAN IS BURNING THE SITE | crit | KEEP P0 danger | alert lane | 0 |
| 54677 | buildArray | An Array takes X racks. You have X. | info | hub or menu line: shows as before |  | 0 |
| 54682 | buildArray | Array X comes online. The wall is clear again, and it pays $X | info | hub or menu line: shows as before |  | 0 |
| 54697 | buildRack | The mainframe wall is full. | info | hub or menu line: shows as before |  | 0 |
| 54698 | buildRack | Not enough parts. X | info | hub or menu line: shows as before |  | 0 |
| 54713 | buildRack | Rack X hums to life. $X | info | hub or menu line: shows as before |  | 0 |
| 54762 | importGhost | Enter a name first. | info | hub or menu line: shows as before |  | 0 |
| 54770 | importGhost | That is not a Pillagers run report. | info | hub or menu line: shows as before |  | 0 |
| 54774 | importGhost | X imported: X runs, X% extractX, favours the X | info | hub or menu line: shows as before |  | 0 |
| 54834 | slotCore | A core is already slotted for your next raid. | info | hub or menu line: shows as before |  | 0 |
| 54836 | slotCore | No Data Core in your stash. Find them in rare containers or on elite p | info | hub or menu line: shows as before |  | 0 |
| 54848 | slotCore | Core slotted. Your next raid starts with intel.X Used X | info | hub or menu line: shows as before |  | 0 |
| 55624 | sayAny | m | k | passes the kind on |  |  |
| 59630 | netOnState | TEAMMATE DOWN | crit | KEEP P0 danger | alert lane | 0 |
| 60825 | netLateReply | PLAYER 2 JOINED | ally | KEEP P2 teammate | left feed | 0 |
| 60826 | netLateReply | X IS JOINING | ally | KEEP P2 teammate | left feed | 0 |
| 60854 | netLateApply | YOU JOINED THE RAID IN PROGRESS | ally | KEEP P2 teammate | left feed | 0 |
| 60961 | netUpWord | HOST IS OUT | crit | KEEP P0 danger | alert lane | 0 |
| 60968 | netUpWord | XabandonedPLAYER 2 OUTXkilledX | ally | KEEP P2 teammate | left feed | 0 |
| 60968 | netUpWord | X | info | cut (run log only) |  | 0 |
| 61428 | netAidHold | SELECT A HEAL | info | KEEP P4 answer | left feed | 0 |
| 61434 | netAidHold | ALREADY SLOTTING | info | KEEP P4 answer | left feed | 0 |
| 61434 | netAidHold | X ARMOUR FULL | info | KEEP P4 answer | left feed | 0 |
| 61435 | netAidHold | ALREADY APPLYING | info | KEEP P4 answer | left feed | 0 |
| 61435 | netAidHold | X DOES NOT NEED IT | info | KEEP P4 answer | left feed | 0 |
| 61436 | netAidHold | No X left | info | KEEP P4 answer | left feed | 0 |
| 61455 | kept | X | info | cut (run log only) |  | 0 |
| 61464 | kept | XarmorPlate slotted for XPatched up X | ally | KEEP P2 teammate | left feed | 0 |
| 61493 | netGiftKey | TAKING IT | ally | KEEP P2 teammate | left feed | 0 |
| 61500 | netGiftKey | NO TEAMMATE IN RANGE | info | KEEP P4 answer | left feed | 0 |
| 61507 | netGiftKey | TAKING IT | ally | KEEP P2 teammate | left feed | 0 |
| 61722 | netGiftTake | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 61723 | netGiftTake | Gave X to X. | info | KEEP P2 teammate | left feed | 0 |
| 61731 | netGiftTake | Took X from X. | info | KEEP P2 teammate | left feed | 0 |
| 61737 | netGiftTake | XdownXgoneXdown IS DOWNX | ally | KEEP P2 teammate | left feed | 0 |
| 61763 | netAidApply | Plate from X | ally | KEEP P2 teammate | left feed | 0 |
| 61770 | netAidApply | X patched you up | ally | KEEP P2 teammate | left feed | 0 |
| 61816 | netAidKept | X already healing / X could not take it | info | KEEP P4 answer | left feed | 0 |
| 61907 | netWpFromMap | WAYPOINT SET | sys | cut (run log only) |  | 0 |
| 61965 | shSay | X | info | cut (run log only) |  | 0 |
| 62403 | netDoorTake | X open | obj | cut (run log only) |  | 0 |
| 62459 | netWorldTake | X | chat | cut (run log only) |  | 0 |
| 62489 | netWorldTake | HOT GROUND MOVED | obj | cut (run log only) |  | 1 |
| 62522 | netBeaconTake | EXTRACTION CALLED | ext | KEEP P1 extraction | alert lane | 2 |
| 63051 | netEntDeathFx | X DESTROYED | obj | KEEP P3 goal done | left feed | 0 |
| 63074 | netMarkTake | A CRIER IS REVEALING YOUR LOCATION | warn | KEEP P0 danger | alert lane | 16 |
| 63081 | netMarkTake | CRIER REVEALED YOUR LOCATION / CRIER REVEALED YOUR LAST LOCATION | warn | KEEP P0 danger | alert lane | 8 |
| 63085 | netMarkTake | X | warn | KEEP P0 danger | alert lane | 0 |
| 63088 | netMarkTake | X | warn | KEEP P0 danger | alert lane | 0 |
| 63089 | netMarkTake | THE PILLBOX HAS SEEN YOU | warn | KEEP P0 danger | alert lane | 0 |
| 63090 | netMarkTake | THE PEDDLER WAVES YOU OVER / THE PEDDLER TURNS HIS BACK | ally | cut (run log only) |  | 0 |
| 63095 | netMarkTake | THE SURVIVOR IS STILL THERE | obj | cut (run log only) |  | 0 |
| 63096 | netMarkTake | SURVIVOR FOUND | obj | cut (run log only) |  | 0 |
| 63248 | netRevHold | X IS BACK UP | ally | KEEP P2 teammate | left feed | 0 |
| 63290 | netRevApply | X REVIVED YOU | ally | KEEP P2 teammate | left feed | 0 |
| 63434 | netKillTake | X WANTS REVENGE | info | cut (run log only) |  | 0 |
| 63458 | netBetrayTake | X TRUSTED YOU | info | cut (run log only) |  | 0 |
| 63538 | netSrchHold | X IS SEARCHING | info | KEEP P4 answer | left feed | 0 |
| 63588 | netSrchAnswer | X IS SEARCHING | info | KEEP P4 answer | left feed | 0 |
| 63874 | netLootTake | HOT GROUND | obj | cut (run log only) |  | 0 |
| 63916 | netContWord | SOMETHING RESTOCKED NEARBY | chat | cut (run log only) |  | 1 |
| 64013 | netHostGone | HOST IS OUT / HOST DISCONNECTED | crit | KEEP P0 danger | alert lane | 0 |
| 64375 | arcadeKeycardDrop | KEYCARD DROPPED | obj | KEEP P3 goal done | left feed | 0 |
| 64668 | arcadeDied | SCORE LOST | warn | KEEP P0 danger | alert lane | 0 |
| 64781 | arcadeExtractEnd | Extracted | ally | KEEP P2 teammate | left feed | 0 |
| 64959 | arcadeWaveTick | WAVE X | warn | KEEP P0 danger | alert lane | 0 |
| 65053 | airScan | AIR STRIKE READY | ext | KEEP P3 goal done | alert lane | 0 |
| 65063 | airKey | AIR STRIKE X% | info | KEEP P4 answer | left feed | 0 |
| 65074 | airCall | AIR STRIKE INBOUND | warn | KEEP P0 danger | alert lane | 0 |
| 65236 | flowChip | X | ext | KEEP P3 goal done | alert lane | 0 |
| 65352 | fireTick | FUEL FIRE | warn | KEEP P0 danger | alert lane | 0 |
| 65495 | evLaunch | X | warn | KEEP P0 danger | alert lane | 0 |
| 65627 | debrisImpact | DEBRIS INBOUND | crit | KEEP P0 danger | alert lane | 0 |
| 65708 | ok | CONVOY MOVING | warn | cut (run log only) |  | 0 |
| 65718 | ok | CONVOY DOWN | ext | KEEP P3 goal done | alert lane | 0 |
| 65723 | ok | CONVOY ARRIVED | info | cut (run log only) |  | 0 |
| 65723 | ok | CONVOY AWAY | info | cut (run log only) |  | 0 |
| 65776 | ok | BOUNTY ON THE MAP | warn | KEEP P0 danger | alert lane | 0 |
| 65786 | ok | BOUNTY GONE | info | cut (run log only) |  | 0 |
| 65797 | ok | BOUNTY SLIPPED AWAY | info | cut (run log only) |  | 0 |
| 65798 | ok | BOUNTY OVER | info | cut (run log only) |  | 0 |
| 65863 | flowCryo | COOLANT RUPTURE | crit | cut (run log only) |  | 0 |
| 65927 | flowCryo | OVERSEER RAMPAGE | crit | KEEP P0 danger | alert lane | 0 |
| 65944 | flowCryo | OVERSEER RETURNS | info | KEEP P0 danger | left feed | 0 |
| 66141 | shOpen | GATE BREACHED | warn | cut (run log only) |  | 0 |
| 66175 | shTick | STRONGHOLD | info | cut (run log only) |  | 0 |
| 66317 | goldDrop | X | obj | cut (run log only) |  | 0 |
| 66330 | goldTick | GOLDEN ENEMY | info | cut (run log only) |  | 0 |
| 66505 | waveNetTake | WAVE X | warn | KEEP P0 danger | alert lane | 0 |
| 66577 | evPeerEnd | CONVOY DOWN | ext | KEEP P3 goal done | alert lane | 0 |
| 66577 | evPeerEnd | CONVOY ARRIVED | info | cut (run log only) |  | 0 |
| 66577 | evPeerEnd | CONVOY AWAY | info | cut (run log only) |  | 0 |
| 66578 | evPeerEnd | OVERSEER RETURNS | info | KEEP P0 danger | left feed | 0 |
| 66585 | evPeerStart | DEBRIS INBOUND | crit | KEEP P0 danger | alert lane | 0 |
| 66586 | evPeerStart | CONVOY MOVING | warn | cut (run log only) |  | 0 |
| 66587 | evPeerStart | BOUNTY ON THE MAP | warn | KEEP P0 danger | alert lane | 0 |
| 66588 | evPeerStart | COOLANT RUPTURE | crit | cut (run log only) |  | 0 |
| 66589 | evPeerStart | OVERSEER RAMPAGE | crit | KEEP P0 danger | alert lane | 0 |
| 66603 | evNetTake | X | warn | KEEP P0 danger | alert lane | 0 |
| 66720 | shNetTake | GATE BREACHED | warn | cut (run log only) |  | 0 |
| 66723 | shNetTake | STRONGHOLD CLEARED | ext | KEEP P3 goal done | alert lane | 0 |
| 66726 | shNetTake | STRONGHOLD | info | cut (run log only) |  | 0 |
| 66763 | goldNetTake | X | obj | cut (run log only) |  | 0 |
| 66768 | goldNetTake | GOLDEN ENEMY | info | cut (run log only) |  | 0 |
| 66786 | airCharge | AIR STRIKE READY | ext | KEEP P3 goal done | alert lane | 0 |
| 66802 | airStrikeFx | AIR STRIKE INBOUND | warn | KEEP P0 danger | alert lane | 0 |
| 66829 | goalsNetTake | GOAL DONE | ext | KEEP P3 goal done | alert lane | 0 |
| 66976 | arcadeKillPerks | X | pick | KEEP P3 goal done | pickup stack | 0 |
| 67156 | scoreKill | X | ext | KEEP P3 goal done | alert lane | 0 |
| 67181 | arcadeKill | X | ext | KEEP P3 goal done | alert lane | 0 |
| 67510 | pwrTake | X | ext | KEEP P3 goal done | alert lane | 0 |
| 67768 | teamKill | TEAM COMBO | ext | KEEP P3 goal done | alert lane | 0 |
| 67837 | arcadeScTake | PLAYER 1 EXTRACTED +X / PLAYER 2 EXTRACTED +X | ally | KEEP P2 teammate | left feed | 0 |
| 68083 | arcadeOnMsg | PLAYER 2 IS IN A RAID | warn | KEEP P0 danger | alert lane | 0 |
| 68092 | arcadeOnMsg | Player 2 extracted | ally | KEEP P2 teammate | left feed | 0 |
| 68559 | arcadeRebuild | PLAYER 2 JOINING | ally | KEEP P2 teammate | left feed | 0 |
| 68631 | arcadeIdleTick | STILL PLAYING? | warn | KEEP P0 danger | alert lane | 0 |
| 68635 | arcadeIdleTick | RUN ENDS IN X / OUT IN X | warn | KEEP P0 danger | alert lane | 0 |
| 68956 | arcadeIniDone | Pick other initials | warn | KEEP P0 danger | alert lane | 0 |
| 69110 | easyAnswer | Easy mode on | info | hub or menu line: shows as before |  | 0 |
| 70169 | fbSaid | X | info | hub or menu line: shows as before |  | 0 |
| 70275 | gameOptRaidNow | RAID CLOCK SET TO X | sys | cut (run log only) |  | 0 |
| 72413 | applyGameOpts | SUPERHOT FOLLOWS THE HOST | sys | KEEP P4 answer | left feed | 0 |
| 72442 | finishRestore | X The game is reloading. | info | hub or menu line: shows as before |  | 0 |
| 72671 | renderSettingsInner | Backed up to Downloads as X. | info | cut (run log only) |  | 0 |
| 72686 | hasPreRestore | There is no profile to go back to. | info | hub or menu line: shows as before |  | 0 |
| 72698 | applyBackupRaw | unreadable backup | info | hub or menu line: shows as before |  | 0 |
| 72701 | applyBackupRaw | restore unavailable | info | hub or menu line: shows as before |  | 0 |
| 72703 | applyBackupRaw | restore skipped: storage full | info | hub or menu line: shows as before |  | 0 |
| 72721 | applyBackupRaw | restore unavailable | info | hub or menu line: shows as before |  | 0 |

## Lines that went straight into the feed (not through say)

| path | what | verdict |
|---|---|---|
| feedKillLine / feedKillEnt | the kill feed (YOU > X, X DESTROYED, X DOWNED) and its +50 SP | KEEP (his answer g-86); 3 lines, 5 s, like any feed line |
| feedLabel | world label copies (ACTIVE RELOAD, CLOSE CALL, a revive, a seal broken) | cut from the feed; the label still rises in the world |
| feedMoney | a kill popup +50 SP | KEEP: rides on its kill line, as before |
| feedMedal / styMedal | the medal copy in the feed | cut from the feed; the medal plate over the cursor ring stays |
| codexScan | CODEX ENTRY (a new gun) | cut (run log only) |
| lore card (G.lore) | the story card name and text | cut from the feed; the card stays |
| cook shout (feedAdd danger) | a grenade cooking in your hand | KEEP P0 danger |
| pickSay / drawPickups | every pickup row, its sound, money and SP rows, item labels | untouched (his order 10-27 ~21:35: looting stays exactly as it is) |

Line numbers are from v35.42, the build before the change.
