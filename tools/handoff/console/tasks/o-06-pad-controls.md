# 18-pad-controls : pad and gun handling (his round 3 answers)

- 3.11 b: on a pad, the crowbar swings on a click of the right stick. The focus aim stays on the left trigger. This closes the gap where a pad player had no melee at all.
- 3.10 b: X stays reload and search, and reload wins while a fight is on.
- 3.21 a: holding Alt opens the goals list and the raid status together. Pick a free pad button for the same thing, and name it in your notes.
- 2.58 b: when the gun in your hands has no ammo left at all, the game switches to your next gun that has some, with a short callout naming that gun.
- 3.17 c: once a Magnum is found, it replaces the Scav Pistol on that key.
- 3.18 c: picking up a better copy of the gun you hold swaps it in at once (as now; keep it).
- 2.30 c: helpers tune the pad aim from the pad's numbers. Measure them; he will not be testing it.
- 2.35 a: the party shows Xbox button pictures only.

## How
- His answers are in tools/handoff/q-round3/answers.md (the decoded list, then "How I read them"). He said they are guidance: if something in the game makes one wrong, do the sensible thing and write down why.
- Read the code first. Some of these are already in the game: confirm each one with a check, and do not rebuild it.
- Ship in small pieces, one ship per item or a few related ones. Each ship needs a check that fails on the old build, and the fingerprint must hold. For 2-player items, it is done only when you have seen it work in both windows, with a picture from each (his 2.86 a).
- Write in plain language, with no explaining sentences on screen. All lower case.

Coordinator note 2026-10-19: moved to the ChatGPT lane as o-06 (the Claude helpers are pacing). For the crowbar on RS click, also follow section "J6" of tools/handoff/pad-research/best-practices.md: ignore RS while the bag, map, wheel, stall or forge is open; remove the RS focus toggle (LT hold stays); freeze the aim angle for about 80 ms around the click, because pressing a stick nudges it; check that a held RS never swings faster than the melee cooldown.

## RE-QUEUED 10-19 22:45 (coordinator, in the VM)
- Done for you: your fixture-retarget.json is applied and committed (bc26ed4c, under the ship lock, fixture rebuilt). On the current build 17.78 and 20.44 PASS. 19.86 is red, but it was already red in the 15:31 corpus with the same message (the stash pad row shows a/y with a PlayStation pad, and the check looks for upper-case CROSS while all player text is lower case). Your new xboxonly key decides that path; do not chase 19.86 separately.
- Your run count was reset. What is left is lane work, not new code: preflight and ship cw-cx-copygun (the repaired one), cw-cx-drygun, cw-cx-padstatus and cw-cx-xboxonly, in that order. If a gate fails, read the gate log and fix that key only.
- Pictures: the lane runner has no recipe camera path yet. Leave camera-run-request.json in place; the coordinator takes the pictures after the keys ship. Put any alarm for the coordinator in alarms-new.md (new file, see RULES-codex.md), not in questions-new.md.

Coordinator note 10-20 03:00: o-05 closed; one flaw it left on the same pad buttons card is yours to fix first: the layout picker's "2 / 6" counter sits under the focused layout name box (the lime focus ring covers the "2"), see notes/shots/o-05-pad-presets-recipes-3/74-pad-call-of-duty-1080.jpg. Also "d-right" on the pad drawing overlaps the line to the right stick.
