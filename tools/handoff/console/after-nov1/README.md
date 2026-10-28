# after-nov1: new-feature jobs parked until Sun 11/1

HIS ORDER 10-27 ~07:20 (verbatim): "Ok no new features until Nov 1. Resources should now be spent polishing, bug fixing, etc"

No lane or script lists this folder. These go back to tasks/ on Sun 11/1 (the first check-in on or after 11/1 moves them back with mv after-nov1/*.md ../tasks/ minus this README). Until then lanes take only fix and polish jobs from tasks/.

- 120d2-fire-ends-sprint.md (parked 10-27 07:36 by the coordinator): new feature (the firing-ends-sprint rule from his g-1 answer, split out of 120d)
- 141-wall-hits-make-noise.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new noise source that machines hear and react to, which is a new AI trigger)
- 142-hot-ground-kills-pay-more.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new scoring rule, a 1.5x SP multiplier for kills in hot ground)
- 144-crates-faster-with-two.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new two-player search speed reward)
- 147-heal-slows-big-hit-stops-it.md (parked 10-27 07:36 by the coordinator): new feature (Adds new healing mechanics: a move slow and an interrupt on big hits)
- 148-bots-charge-or-flee-grenades.md (parked 10-27 07:36 by the coordinator): new feature (Adds new bot AI behaviours: charging when hurt and fleeing grenades)
- 149-trigger-repeat-shells-fire-cancels-reload.md (parked 10-27 07:36 by the coordinator): new feature (Adds new gun mechanics: hold to repeat, shell by shell loading and reload cancel)
- 150-revive-bandage-pause-alert-medal.md (parked 10-27 07:36 by the coordinator): new feature (Adds new revive rules, a new alert sound and a new medal reward)
- 153-blasts-shove-big-hits-nudge-aim.md (parked 10-27 07:36 by the coordinator): new feature (Blasts now push the player and big hits now move his aim, two new hit mechanics the game does not have)
- 154-machine-tells-unseen-and-open-beat.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new bulwark big shot, a new vulnerable open window for wardens and bulwarks, and a new unseen-machine streak, which is mostly new behaviour rather than tuning of existing tells)
- 155-longshot-glint.md (parked 10-27 07:36 by the coordinator): new feature (Gives elite longshot bots a new pre-shot delay and a new tell, a new AI behaviour even though it targets an unfair death)
- 156-overseer-chases-top-damage.md (parked 10-27 07:36 by the coordinator): new feature (Adds a damage ledger and a new boss targeting rule for co-op)
- 157-golden-bolts-and-stays.md (parked 10-27 07:36 by the coordinator): new feature (Most of the work is a new flee-when-hurt behaviour for golden enemies; the never-leaves part is the smaller share)
- 158-sleeping-machines.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new sleeping state with wake rules for sentries and bulwarks, which is a new AI behaviour)
- 161-throws-bounce-once.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new wall bounce for thrown items)
- 162-loot-in-sight-at-every-spawn.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new placement rule that puts an extra box near every spawn, which changes the economy)
- 169-out-player-watches-and-pings.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new spectate view for the player who is out, with pings while watching)
- 171-endless-spawn-pistol.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new ammo rule (endless reserve for the spawn pistol) that the game does not have today, even though the gun itself exists)
- 172-night-pays-cash.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new night cash reward to the economy)
- 174-elite-element-guns.md (parked 10-27 07:36 by the coordinator): new feature (Adds new loot: element guns carried by elite bots)
- 175-break-down-guns.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new break-down action to the stash)
- 177-hardcore-save.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new hardcore save type and a graveyard screen)
- 178-patrol-routes.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new AI behaviour: fixed patrol routes)
- 182-juggernaut-boss.md (parked 10-27 07:36 by the coordinator): new feature (Adds a new boss)

## His priorities, 10-27 about 20:00 (priorities page https://claude.ai/artifact/8mXPSJ5fqq5DiV1Mxsy8Xr, db "answers", ids p-NNN)
On 11/1 move these back in this order. HIGH first, then MEDIUM, then LOW. Lanes take tasks/ by file name, so release a batch at a time.
- HIGH: 177 hardcore save.
- MEDIUM: 120d2, 141, 142, 147, 149, 153, 154, 161, 172.
- LOW: 144, 148, 150, 155, 156, 157, 158, 162, 169, 171, 174, 175, 178, 182.
- NEVERMIND (moved to console/cut): 133, 159, 160, 164, 167, 170, 173, 176, 179, 180, 181.
