# Raid messages: what reaches the screen (cw-fewermsg, job 186c)

His complaint (10-27): too many messages reach the player. The rule now: only five kinds of line reach the screen.

- danger: danger to you now (seen, shot at, a siege, a lock-on, low health). The alert lane, at once. The same warning with no key is not drawn twice in 20 s.
- extraction: called, inbound, missed, a ring closing, the raid clock.
- teammate: down, revived, extracted, left, a gift.
- money or goal: money, a contract or goal done (not progress counts).
- answer: the answer to something you tried that did not work (health full, bandages stop at 85, no x left). Into the feed at once.

Everything else goes into the run log (G.msgLog) and is drawn nowhere. A search is one pickup row (the best find named, +N ITEMS $V); a gun and a loose pickup keep their own rows. Outside the alert lane the left feed takes at most one new line every 2.5 s; a line that waited over 4 s is dropped unless it is money. Danger and answers never wait.

Measured in a staged 3 minute raid (fixture, seed 4242, map 0: looting, a fight, an extraction): 36.3 lines a minute on the build before, 16.3 on the new build. Map 0 has no water, and the game has no wading line, so the wading part said nothing on either build.

332 call sites: 197 keep, 109 cut (the rest pass a kind on or are run log only). Words: X is a part worked out at run time.

| line | function | words | kind | verdict | where |
|---|---|---|---|---|---|
| 6721 | contractStep | CONTRACT DONE | obj | KEEP money or goal | left feed |
| 8200 | alarmOk | MACHINE ALERT | info | KEEP danger | left feed |
| 8471 | tickMachSiren | LOCKED ON | warn | KEEP danger | alert lane |
| 11499 | wxTick | X | chat | cut (run log only) |  |
| 11594 | strikeTick | LIGHTNING FUSED A CACHE | obj | cut (run log only) |  |
| 14781 | forgeOpen | X | info | cut (run log only) |  |
| 14783 | forgeOpen | need X | warn | KEEP danger | alert lane |
| 14800 | forgeBuy | need X | warn | KEEP danger | alert lane |
| 14805 | forgeBuy | gun upgraded | obj | KEEP money or goal | left feed |
| 15456 | listenersHearInner | SOMETHING WOKE UP | warn | KEEP danger | alert lane |
| 15994 | strayGive | NOT ENOUGH AMMUNITION | info | KEEP answer | left feed |
| 15996 | strayGive | He needs X X | info | KEEP answer | left feed |
| 16015 | strayGive | +$X | pick | KEEP money or goal | pickup stack |
| 16019 | strayGive | CACHE MARKED | obj | KEEP money or goal | left feed |
| 16026 | strayGive | NOTORIETY DOWN TO X | info | cut (run log only) |  |
| 16070 | pedSellAll | HE WANTS NOTHING YOU CARRY | info | KEEP answer | left feed |
| 16108 | pedSellAll | +$X | pick | KEEP money or goal | pickup stack |
| 16109 | pedSellAll | SOLD X ITEM / SOLD X ITEMS | info | KEEP money or goal | left feed |
| 16122 | pedBuy | need $X | info | KEEP answer | left feed |
| 16154 | pedBuy | X | pick | KEEP money or goal | pickup stack |
| 16155 | pedBuy | -$X | pick | KEEP money or goal | pickup stack |
| 17891 | startRaid | X | chat | cut (run log only) |  |
| 17900 | startRaid | X | info | KEEP answer | left feed |
| 17906 | startRaid | YOUR RIVAL IS UP TOP | warn | cut (run log only) |  |
| 18332 | raidKey | Xloot LOOTS ON HIS OWNX | ally | KEEP teammate | left feed |
| 18399 | raidKey | ZOOM X% | sys | cut (run log only) |  |
| 18400 | raidKey | ZOOM X% | sys | cut (run log only) |  |
| 18402 | raidKey | ZOOM X% | sys | cut (run log only) |  |
| 18419 | hudSizeStep | X | sys | cut (run log only) |  |
| 18535 | msMove | WAYPOINT CLEARED | sys | cut (run log only) |  |
| 18544 | msMove | WAYPOINT SET | sys | cut (run log only) |  |
| 18861 | msMove | X to slot X | info | cut (run log only) |  |
| 18866 | msMove | Xgun | info | cut (run log only) |  |
| 18919 | msMove | NOT IN BACKPACK | info | KEEP answer | left feed |
| 18920 | msMove | CANNOT EQUIP | info | KEEP answer | left feed |
| 18960 | msMove | X to slot X | info | cut (run log only) |  |
| 18966 | msMove | CANNOT EQUIP | info | KEEP answer | left feed |
| 18973 | msMove | X to slot X | info | cut (run log only) |  |
| 18989 | msMove | SLOT X TAKES GUNS ONLY | info | KEEP answer | left feed |
| 18995 | msMove | X | info | cut (run log only) |  |
| 19047 | msMove | X to slot X | info | cut (run log only) |  |
| 19072 | msMove | Gave X | info | cut (run log only) |  |
| 19086 | msMove | Dropped X | info | cut (run log only) |  |
| 19117 | msMove | X off slot X | info | cut (run log only) |  |
| 19786 | padHold | CONTROLLER CONNECTED | sys | cut (run log only) |  |
| 20251 | trig | CONTROLLER DISCONNECTED | sys | KEEP answer | left feed |
| 20895 | cycleThrow | NO THROWABLE ON THE TACTICAL BELT / NO THROWABLES LEFT | info | KEEP answer | left feed |
| 20901 | cycleThrow | X ready | info | cut (run log only) |  |
| 20931 | tryRoll | TOO TIRED TO ROLL | info | KEEP answer | left feed |
| 21150 | throwFrom | THROW BLOCKED | info | KEEP answer | left feed |
| 21150 | throwFrom | GRENADE HIT COVER | warn | KEEP danger | alert lane |
| 21165 | emptyThrowCell | No X left | info | KEEP answer | left feed |
| 21177 | doThrow | THROW THE ONE IN YOUR HAND FIRST | info | KEEP answer | left feed |
| 21217 | cookOff | GRENADE WENT OFF IN YOUR HAND | crit | KEEP danger | alert lane |
| 21265 | tripArm | TRIPWIRE SET | info | cut (run log only) |  |
| 22389 | hubToast | X | info | cut (run log only) |  |
| 22390 | hubToast | m | kind | passes the kind on |  |
| 22390 | hubToast | m | kind | passes the kind on |  |
| 22631 | locDraw | X | pick | KEEP money or goal | pickup stack |
| 23284 | msgTick | _qn.m | _qn.k | passes the kind on |  |
| 23296 | sayWhenFree | m | kind | passes the kind on |  |
| 23505 | notoStamp | NOTORIETY X  .  X | warn | cut (run log only) |  |
| 23822 | _logHit | AUTO-JOG OFF | sys | cut (run log only) |  |
| 24058 | cycleHeal | NO HEAL ON BELT / NO MEDICAL SUPPLIES | info | KEEP answer | left feed |
| 24062 | cycleHeal | X ready | info | cut (run log only) |  |
| 24072 | useBeltHeal | ALREADY HEALING / HEALTH FULL | info | KEEP answer | left feed |
| 24074 | useBeltHeal | NO HEAL ON BELT | info | KEEP answer | left feed |
| 24075 | useBeltHeal | NO MEDICAL SUPPLIES | info | KEEP answer | left feed |
| 24080 | useBeltHeal | BANDAGES STOP AT X | info | KEEP answer | left feed |
| 24081 | useBeltHeal | X stops at X | info | KEEP answer | left feed |
| 24084 | useBeltHeal | ALREADY APPLYING | info | KEEP answer | left feed |
| 24098 | beltInstant | NOT WHILE DOWN | info | KEEP answer | left feed |
| 24104 | beltInstant | NO THROWABLE ON KEY X | info | KEEP answer | left feed |
| 24121 | beltEquip | NOT WHILE DOWN | info | KEEP answer | left feed |
| 24128 | beltEquip | NO X | info | KEEP answer | left feed |
| 24159 | quickPlate | NO ARMOUR PLATE | info | KEEP answer | left feed |
| 24216 | wheelOpen | NOTHING TO USE | info | KEEP answer | left feed |
| 24264 | wheelRelease | NO X | info | KEEP answer | left feed |
| 24282 | handTake | X out | info | cut (run log only) |  |
| 24295 | wheelHeal | ALREADY HEALING / HEALTH FULL | info | KEEP answer | left feed |
| 24297 | wheelHeal | BANDAGES STOP AT X | info | KEEP answer | left feed |
| 24298 | wheelHeal | X stops at X | info | KEEP answer | left feed |
| 24301 | wheelHeal | ALREADY APPLYING | info | KEEP answer | left feed |
| 25048 | bagDropSel | Dropped X | info | cut (run log only) |  |
| 25061 | bagBeltNo | MOVE IT TO THE BACKPACK FIRST | info | KEEP answer | left feed |
| 25330 | useMedical | ALREADY HEALING / HEALTH FULL | info | KEEP answer | left feed |
| 25337 | useMedical | BANDAGES STOP AT X | info | KEEP answer | left feed |
| 25338 | useMedical | NO MEDICAL SUPPLIES | info | KEEP answer | left feed |
| 25341 | useMedical | ALREADY APPLYING | info | KEEP answer | left feed |
| 25432 | tickPrepSlot | X slotted | info | cut (run log only) |  |
| 25441 | tickPrepSlot | PATCHED UP | info | cut (run log only) |  |
| 25900 | overseerTick | X | warn | KEEP danger | alert lane |
| 26448 | openContainer | HOT GROUND | obj | cut (run log only) |  |
| 26666 | grantLoot | X | pick | KEEP money or goal | pickup stack |
| 26667 | grantLoot | X | pick | KEEP money or goal | pickup stack |
| 26803 | bagHeldGun | Nothing to pick up. | info | KEEP answer | left feed |
| 26804 | bagHeldGun | ISSUED GEAR STAYS IN YOUR HANDS | info | KEEP answer | left feed |
| 26805 | bagHeldGun | CANNOT STOW THAT GUN | info | KEEP answer | left feed |
| 26819 | bagHeldGun | X | pick | KEEP money or goal | pickup stack |
| 26997 | _slotFree | X | info | cut (run log only) |  |
| 27095 | gunClassPlace | X | info | cut (run log only) |  |
| 27103 | gunClassPlace | X | info | cut (run log only) |  |
| 27107 | gunClassPlace | X | info | cut (run log only) |  |
| 27107 | gunClassPlace | X | pick | KEEP money or goal | pickup stack |
| 27119 | gunClassUpgrade | X | pick | KEEP money or goal | pickup stack |
| 27234 | beltGunFull | X | info | cut (run log only) |  |
| 27257 | beltGunFull | X | info | cut (run log only) |  |
| 27257 | beltGunFull | X | pick | KEEP money or goal | pickup stack |
| 27307 | autoBelt | X | info | cut (run log only) |  |
| 27568 | beltClassPin | X | info | cut (run log only) |  |
| 27571 | beltClassPin | NO FREE KEY | info | KEEP answer | left feed |
| 27642 | useArmor | ARMOUR FULL | info | KEEP answer | left feed |
| 27644 | useArmor | ALREADY SLOTTING | info | KEEP answer | left feed |
| 27663 | beltStep | X | info | cut (run log only) |  |
| 27724 | setHot | Gun slot X empty | info | KEEP answer | left feed |
| 27740 | setHot | Gun slot X empty | info | KEEP answer | left feed |
| 27750 | setHot | NOT IN BACKPACK | info | KEEP answer | left feed |
| 27751 | setHot | CANNOT EQUIP | info | KEEP answer | left feed |
| 27788 | useStim | No X left | info | KEEP answer | left feed |
| 27791 | useStim | X active | info | cut (run log only) |  |
| 27799 | useHot | NOT WHILE DOWN | info | KEEP answer | left feed |
| 27823 | useHot | No X left | info | KEEP answer | left feed |
| 27836 | useHot | ALREADY HEALING / HEALTH FULL | info | KEEP answer | left feed |
| 27841 | useHot | X stops at X | info | KEEP answer | left feed |
| 27842 | useHot | ALREADY APPLYING | info | KEEP answer | left feed |
| 27923 | tryExtractTick | Knocked down. Extraction progress bar reset. Hold XKeyXX to try again. | ext | KEEP extraction | alert lane |
| 27994 | tryExtractTick | EXTRACTION X IS CLOSED | info | KEEP extraction | left feed |
| 28076 | tryExtractTick | EXTRACTION CALLED | ext | KEEP extraction | alert lane |
| 28077 | tryExtractTick | SIEGE INCOMING | warn | KEEP danger | alert lane |
| 28361 | tickRaiderWaves | PILLAGER BOT REINFORCEMENTS | warn | KEEP danger | alert lane |
| 28594 | tickExtractPoints | EXTRACT IN PROGRESS! | ext | KEEP extraction | alert lane |
| 28624 | tickExtractPoints | EXTRACTION MISSED | ext | KEEP extraction | alert lane |
| 28671 | tickExtractPoints | EXTRACTION X CLOSING | ext | KEEP extraction | alert lane |
| 28676 | tickExtractPoints | EXTRACTION X CLOSED | ext | KEEP extraction | alert lane |
| 28817 | selfRevive | Self-revive spent. One per raid. | info | KEEP answer | left feed |
| 28826 | selfRevive | SELF-REVIVE USED | info | cut (run log only) |  |
| 28846 | autoEmptyGun | X | info | cut (run log only) |  |
| 28884 | updatePlayer | X wore off | chat | cut (run log only) |  |
| 29028 | updatePlayer | STOP FIRST | info | KEEP answer | left feed |
| 29029 | updatePlayer | AUTO-JOG OFF | sys | cut (run log only) |  |
| 29029 | updatePlayer | AUTO-JOG ON | sys | cut (run log only) |  |
| 29035 | updatePlayer | AUTO-JOG OFF | sys | cut (run log only) |  |
| 29244 | updatePlayer | JAM CLEARED | info | cut (run log only) |  |
| 29313 | updatePlayer | EMPTY SLOT | info | KEEP answer | left feed |
| 29324 | updatePlayer | No X left | info | KEEP answer | left feed |
| 29339 | updatePlayer | No X left | info | KEEP answer | left feed |
| 29363 | updatePlayer | X jammed | info | KEEP answer | left feed |
| 29431 | updatePlayer | X open | obj | cut (run log only) |  |
| 29461 | updatePlayer | SEAL BROKEN | obj | cut (run log only) |  |
| 29587 | updatePlayer | X received | info | KEEP teammate | left feed |
| 29596 | updatePlayer | X IS BACK UP | ally | cut (run log only) |  |
| 29597 | updatePlayer | HE IS BACK UP | ally | cut (run log only) |  |
| 29650 | updatePlayer | NO DEAL | info | KEEP answer | left feed |
| 29704 | updatePlayer | WALL GLITCH SAVED TO RUN REPORT | sys | KEEP answer | left feed |
| 29880 | updatePlayer | X EMPTY | info | KEEP answer | left feed |
| 31158 | updateEnts | SOMETHING RESTOCKED NEARBY | chat | cut (run log only) |  |
| 31274 | updateEnts | IT WAS PLAYING DEAD | warn | KEEP danger | alert lane |
| 31343 | updateEnts | SOMEONE SHOT THE SURVIVOR | chat | cut (run log only) |  |
| 31365 | updateEnts | THE PEDDLER IS DEAD | chat | cut (run log only) |  |
| 31396 | updateEnts | X WANTS REVENGE | info | cut (run log only) |  |
| 31404 | updateEnts | X IS DEAD | obj | KEEP money or goal | left feed |
| 31409 | updateEnts | X DESTROYED | obj | KEEP money or goal | left feed |
| 31410 | updateEnts | X DESTROYED | obj | KEEP money or goal | left feed |
| 31420 | updateEnts | X DESTROYED | obj | KEEP money or goal | left feed |
| 31450 | updateEnts | X DESTROYED | obj | KEEP money or goal | left feed |
| 31617 | updateEnts | SURVIVOR EXTRACTED | info | KEEP money or goal | left feed |
| 31642 | updateEnts | TEAMMATE FOUND A SURVIVOR | obj | cut (run log only) |  |
| 31645 | updateEnts | THE SURVIVOR IS STILL THERE | obj | cut (run log only) |  |
| 31646 | updateEnts | SURVIVOR FOUND | obj | cut (run log only) |  |
| 31660 | updateEnts | THE PEDDLER BOLTS | info | cut (run log only) |  |
| 31689 | updateEnts | THE PEDDLER SET UP SHOP | chat | cut (run log only) |  |
| 31697 | updateEnts | THE PEDDLER IS BACK | chat | cut (run log only) |  |
| 31707 | updateEnts | THE PEDDLER WAVES YOU OVER / THE PEDDLER TURNS HIS BACK | ally | cut (run log only) |  |
| 31952 | updateEnts | THE PILLBOX HAS SEEN YOU | warn | KEEP danger | alert lane |
| 31986 | updateEnts | X | warn | KEEP danger | alert lane |
| 32082 | updateEnts | A CRIER IS REVEALING YOUR LOCATION | warn | KEEP danger | alert lane |
| 32127 | updateEnts | CRIER REVEALED YOUR LOCATION / CRIER REVEALED YOUR LAST LOCATION | warn | KEEP danger | alert lane |
| 32267 | updateEnts | X TRUSTED YOU | info | cut (run log only) |  |
| 32276 | updateEnts | PILLAGER BOT TURNED HOSTILE | warn | KEEP danger | alert lane |
| 32280 | updateEnts | X IS FRIENDLY / X IS WATCHING | chat | cut (run log only) |  |
| 32652 | updateEnts | X IS COMING FOR YOU | ally | KEEP teammate | left feed |
| 32660 | updateEnts | X REVIVED YOU | ally | KEEP teammate | left feed |
| 32997 | updateEnts | PILLAGER BOT CALLED EXTRACTION | info | KEEP extraction | left feed |
| 33375 | updateBullets | WARDEN ARMOUR / BULWARK SHIELD | info | KEEP answer | left feed |
| 33396 | updateBullets | THE SURVIVOR RETURNS FIRE | warn | KEEP danger | alert lane |
| 33397 | updateBullets | THE SURVIVOR RETURNS FIRE | warn | KEEP danger | alert lane |
| 33538 | updateBullets | DEER DOWN / BIRD DOWN | chat | cut (run log only) |  |
| 35656 | drsMove | RESOLUTION STEPPED DOWN | sys | cut (run log only) |  |
| 42842 | giftTick | OFFER EXPIRED | ally | KEEP teammate | left feed |
| 42843 | giftTick | X DID NOT TAKE IT | ally | KEEP teammate | left feed |
| 43127 | msgRowH | m | kind | passes the kind on |  |
| 45668 | trophyKill | TROPHY EARNED | ext | KEEP money or goal | alert lane |
| 45733 | needHint | CONTRACT ITEM NEARBY | obj | KEEP money or goal | left feed |
| 46120 | tickHot | HOT GROUND MOVED | obj | cut (run log only) |  |
| 50697 | tickClockWarn | THIRTY SECONDS | warn | KEEP danger | alert lane |
| 50699 | tickClockWarn | X MINUTE LEFT / X MINUTES LEFT | obj | KEEP extraction | left feed |
| 50706 | tickClockWarn | TEN SECONDS | crit | KEEP danger | alert lane |
| 51620 | restoreCursor | CURSOR RESET | sys | cut (run log only) |  |
| 51683 | errRow | String(raw) | log | run log only (as before) |  |
| 51684 | errRow | X | sys | cut (run log only) |  |
| 51687 | errRow | X | sys | cut (run log only) |  |
| 51814 | perfNote | RUNNING SLOWLY | sys | cut (run log only) |  |
| 54402 | loop | MERIDIAN IS BURNING THE SITE | crit | KEEP danger | alert lane |
| 54603 | buildArray | An Array takes X racks. You have X. | info | hub or menu line: shows as before |  |
| 54608 | buildArray | Array X comes online. The wall is clear again, and it pays $X | info | hub or menu line: shows as before |  |
| 54623 | buildRack | The mainframe wall is full. | info | hub or menu line: shows as before |  |
| 54624 | buildRack | Not enough parts. X | info | hub or menu line: shows as before |  |
| 54639 | buildRack | Rack X hums to life. $X | info | hub or menu line: shows as before |  |
| 54688 | importGhost | Enter a name first. | info | hub or menu line: shows as before |  |
| 54696 | importGhost | That is not a Pillagers run report. | info | hub or menu line: shows as before |  |
| 54700 | importGhost | X imported: X runs, X% extractX, favours the X | info | hub or menu line: shows as before |  |
| 54760 | slotCore | A core is already slotted for your next raid. | info | hub or menu line: shows as before |  |
| 54762 | slotCore | No Data Core in your stash. Find them in rare containers or on elite p | info | hub or menu line: shows as before |  |
| 54774 | slotCore | Core slotted. Your next raid starts with intel.X Used X | info | hub or menu line: shows as before |  |
| 55550 | sayAny | m | k | passes the kind on |  |
| 59556 | netOnState | TEAMMATE DOWN | crit | KEEP danger | alert lane |
| 60751 | netLateReply | PLAYER 2 JOINED | ally | KEEP teammate | left feed |
| 60752 | netLateReply | X IS JOINING | ally | KEEP teammate | left feed |
| 60780 | netLateApply | YOU JOINED THE RAID IN PROGRESS | ally | KEEP teammate | left feed |
| 60887 | netUpWord | HOST IS OUT | crit | KEEP danger | alert lane |
| 60894 | netUpWord | XabandonedPLAYER 2 OUTXkilledX | ally | KEEP teammate | left feed |
| 60894 | netUpWord | X | info | cut (run log only) |  |
| 61354 | netAidHold | SELECT A HEAL | info | KEEP answer | left feed |
| 61360 | netAidHold | ALREADY SLOTTING | info | KEEP answer | left feed |
| 61360 | netAidHold | X ARMOUR FULL | info | KEEP answer | left feed |
| 61361 | netAidHold | ALREADY APPLYING | info | KEEP answer | left feed |
| 61361 | netAidHold | X DOES NOT NEED IT | info | KEEP answer | left feed |
| 61362 | netAidHold | No X left | info | KEEP answer | left feed |
| 61381 | kept | X | info | cut (run log only) |  |
| 61390 | kept | XarmorPlate slotted for XPatched up X | ally | KEEP teammate | left feed |
| 61419 | netGiftKey | TAKING IT | ally | KEEP teammate | left feed |
| 61426 | netGiftKey | NO TEAMMATE IN RANGE | info | KEEP answer | left feed |
| 61433 | netGiftKey | TAKING IT | ally | KEEP teammate | left feed |
| 61648 | netGiftTake | X | pick | KEEP money or goal | pickup stack |
| 61649 | netGiftTake | Gave X to X. | info | KEEP teammate | left feed |
| 61657 | netGiftTake | Took X from X. | info | KEEP teammate | left feed |
| 61663 | netGiftTake | XdownXgoneXdown IS DOWNX | ally | KEEP teammate | left feed |
| 61689 | netAidApply | Plate from X | ally | KEEP teammate | left feed |
| 61696 | netAidApply | X patched you up | ally | KEEP teammate | left feed |
| 61742 | netAidKept | X already healing / X could not take it | info | KEEP answer | left feed |
| 61833 | netWpFromMap | WAYPOINT SET | sys | cut (run log only) |  |
| 61891 | shSay | X | info | cut (run log only) |  |
| 62329 | netDoorTake | X open | obj | cut (run log only) |  |
| 62385 | netWorldTake | X | chat | cut (run log only) |  |
| 62415 | netWorldTake | HOT GROUND MOVED | obj | cut (run log only) |  |
| 62448 | netBeaconTake | EXTRACTION CALLED | ext | KEEP extraction | alert lane |
| 62977 | netEntDeathFx | X DESTROYED | obj | KEEP money or goal | left feed |
| 63000 | netMarkTake | A CRIER IS REVEALING YOUR LOCATION | warn | KEEP danger | alert lane |
| 63007 | netMarkTake | CRIER REVEALED YOUR LOCATION / CRIER REVEALED YOUR LAST LOCATION | warn | KEEP danger | alert lane |
| 63011 | netMarkTake | X | warn | KEEP danger | alert lane |
| 63014 | netMarkTake | X | warn | KEEP danger | alert lane |
| 63015 | netMarkTake | THE PILLBOX HAS SEEN YOU | warn | KEEP danger | alert lane |
| 63016 | netMarkTake | THE PEDDLER WAVES YOU OVER / THE PEDDLER TURNS HIS BACK | ally | cut (run log only) |  |
| 63021 | netMarkTake | THE SURVIVOR IS STILL THERE | obj | cut (run log only) |  |
| 63022 | netMarkTake | SURVIVOR FOUND | obj | cut (run log only) |  |
| 63174 | netRevHold | X IS BACK UP | ally | KEEP teammate | left feed |
| 63216 | netRevApply | X REVIVED YOU | ally | KEEP teammate | left feed |
| 63360 | netKillTake | X WANTS REVENGE | info | cut (run log only) |  |
| 63384 | netBetrayTake | X TRUSTED YOU | info | cut (run log only) |  |
| 63464 | netSrchHold | X IS SEARCHING | info | KEEP answer | left feed |
| 63514 | netSrchAnswer | X IS SEARCHING | info | KEEP answer | left feed |
| 63800 | netLootTake | HOT GROUND | obj | cut (run log only) |  |
| 63842 | netContWord | SOMETHING RESTOCKED NEARBY | chat | cut (run log only) |  |
| 63939 | netHostGone | HOST IS OUT / HOST DISCONNECTED | crit | KEEP danger | alert lane |
| 64301 | arcadeKeycardDrop | KEYCARD DROPPED | obj | KEEP money or goal | left feed |
| 64594 | arcadeDied | SCORE LOST | warn | KEEP danger | alert lane |
| 64707 | arcadeExtractEnd | Extracted | ally | KEEP teammate | left feed |
| 64885 | arcadeWaveTick | WAVE X | warn | KEEP danger | alert lane |
| 64979 | airScan | AIR STRIKE READY | ext | KEEP money or goal | alert lane |
| 64989 | airKey | AIR STRIKE X% | info | KEEP answer | left feed |
| 65000 | airCall | AIR STRIKE INBOUND | warn | KEEP danger | alert lane |
| 65162 | flowChip | X | ext | KEEP money or goal | alert lane |
| 65278 | fireTick | FUEL FIRE | warn | KEEP danger | alert lane |
| 65421 | evLaunch | X | warn | KEEP danger | alert lane |
| 65553 | debrisImpact | DEBRIS INBOUND | crit | KEEP danger | alert lane |
| 65634 | ok | CONVOY MOVING | warn | cut (run log only) |  |
| 65644 | ok | CONVOY DOWN | ext | KEEP money or goal | alert lane |
| 65649 | ok | CONVOY ARRIVED | info | cut (run log only) |  |
| 65649 | ok | CONVOY AWAY | info | cut (run log only) |  |
| 65702 | ok | BOUNTY ON THE MAP | warn | KEEP danger | alert lane |
| 65712 | ok | BOUNTY GONE | info | cut (run log only) |  |
| 65723 | ok | BOUNTY SLIPPED AWAY | info | cut (run log only) |  |
| 65724 | ok | BOUNTY OVER | info | cut (run log only) |  |
| 65789 | flowCryo | COOLANT RUPTURE | crit | cut (run log only) |  |
| 65853 | flowCryo | OVERSEER RAMPAGE | crit | KEEP danger | alert lane |
| 65870 | flowCryo | OVERSEER RETURNS | info | KEEP danger | left feed |
| 66067 | shOpen | GATE BREACHED | warn | cut (run log only) |  |
| 66101 | shTick | STRONGHOLD | info | cut (run log only) |  |
| 66243 | goldDrop | X | obj | cut (run log only) |  |
| 66256 | goldTick | GOLDEN ENEMY | info | cut (run log only) |  |
| 66431 | waveNetTake | WAVE X | warn | KEEP danger | alert lane |
| 66503 | evPeerEnd | CONVOY DOWN | ext | KEEP money or goal | alert lane |
| 66503 | evPeerEnd | CONVOY ARRIVED | info | cut (run log only) |  |
| 66503 | evPeerEnd | CONVOY AWAY | info | cut (run log only) |  |
| 66504 | evPeerEnd | OVERSEER RETURNS | info | KEEP danger | left feed |
| 66511 | evPeerStart | DEBRIS INBOUND | crit | KEEP danger | alert lane |
| 66512 | evPeerStart | CONVOY MOVING | warn | cut (run log only) |  |
| 66513 | evPeerStart | BOUNTY ON THE MAP | warn | KEEP danger | alert lane |
| 66514 | evPeerStart | COOLANT RUPTURE | crit | cut (run log only) |  |
| 66515 | evPeerStart | OVERSEER RAMPAGE | crit | KEEP danger | alert lane |
| 66529 | evNetTake | X | warn | KEEP danger | alert lane |
| 66646 | shNetTake | GATE BREACHED | warn | cut (run log only) |  |
| 66649 | shNetTake | STRONGHOLD CLEARED | ext | KEEP money or goal | alert lane |
| 66652 | shNetTake | STRONGHOLD | info | cut (run log only) |  |
| 66689 | goldNetTake | X | obj | cut (run log only) |  |
| 66694 | goldNetTake | GOLDEN ENEMY | info | cut (run log only) |  |
| 66712 | airCharge | AIR STRIKE READY | ext | KEEP money or goal | alert lane |
| 66728 | airStrikeFx | AIR STRIKE INBOUND | warn | KEEP danger | alert lane |
| 66755 | goalsNetTake | GOAL DONE | ext | KEEP money or goal | alert lane |
| 66902 | arcadeKillPerks | X | pick | KEEP money or goal | pickup stack |
| 67082 | scoreKill | X | ext | KEEP money or goal | alert lane |
| 67107 | arcadeKill | X | ext | KEEP money or goal | alert lane |
| 67436 | pwrTake | X | ext | KEEP money or goal | alert lane |
| 67694 | teamKill | TEAM COMBO | ext | KEEP money or goal | alert lane |
| 67763 | arcadeScTake | PLAYER 1 EXTRACTED +X / PLAYER 2 EXTRACTED +X | ally | KEEP teammate | left feed |
| 68009 | arcadeOnMsg | PLAYER 2 IS IN A RAID | warn | KEEP danger | alert lane |
| 68018 | arcadeOnMsg | Player 2 extracted | ally | KEEP teammate | left feed |
| 68485 | arcadeRebuild | PLAYER 2 JOINING | ally | KEEP teammate | left feed |
| 68557 | arcadeIdleTick | STILL PLAYING? | warn | KEEP danger | alert lane |
| 68561 | arcadeIdleTick | RUN ENDS IN X / OUT IN X | warn | KEEP danger | alert lane |
| 68882 | arcadeIniDone | Pick other initials | warn | KEEP danger | alert lane |
| 69036 | easyAnswer | Easy mode on | info | hub or menu line: shows as before |  |
| 70095 | fbSaid | X | info | hub or menu line: shows as before |  |
| 70201 | gameOptRaidNow | RAID CLOCK SET TO X | sys | cut (run log only) |  |
| 72339 | applyGameOpts | SUPERHOT FOLLOWS THE HOST | sys | KEEP answer | left feed |
| 72368 | finishRestore | X The game is reloading. | info | hub or menu line: shows as before |  |
| 72597 | renderSettingsInner | Backed up to Downloads as X. | info | cut (run log only) |  |
| 72612 | hasPreRestore | There is no profile to go back to. | info | hub or menu line: shows as before |  |
| 72624 | applyBackupRaw | unreadable backup | info | hub or menu line: shows as before |  |
| 72627 | applyBackupRaw | restore unavailable | info | hub or menu line: shows as before |  |
| 72629 | applyBackupRaw | restore skipped: storage full | info | hub or menu line: shows as before |  |
| 72647 | applyBackupRaw | restore unavailable | info | hub or menu line: shows as before |  |

## Lines that went straight into the feed (not through say)

| path | what | verdict |
|---|---|---|
| feedLabel | world label copies (+50 SP, ACTIVE RELOAD, CLOSE CALL, ...) | cut from the feed; the label still rises in the world |
| feedKillLine / feedKillEnt | the kill feed (YOU > X, X DESTROYED, X DOWNED) | cut; a kill shows on the target |
| feedMedal / styMedal | the medal copy in the feed | cut from the feed; the medal plate over the cursor ring stays |
| codexScan | CODEX ENTRY (a new gun) | cut (run log only) |
| lore card (G.lore) | the story card name and text | cut from the feed; the card stays |
| cook shout (feedAdd danger) | a grenade cooking in your hand | KEEP danger |

Line numbers are from v35.37, the build before the change.
