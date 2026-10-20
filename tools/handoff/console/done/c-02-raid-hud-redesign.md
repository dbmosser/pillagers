REDESIGN THE RAID SCREEN (his answers 10-18; he put the raid screen FIRST, Q49). His answers of 10-18 are in the memory file pillagers-answers-1-78-2026-10-18.md (read the numbers named here first). Read notes\b-30-ui-hud.md (an earlier
helper's audit of this screen; it was blocked on these answers), the "UI work" rules, notes\ui\style-guide.md and notes\ui\references.md.
Notes: notes\02-raid-hud-redesign.md. His words: Q57 "Ammo needs to be prominent. Ideally redesign the whole raid HUD."
- Q1: the Run info box shows at most the 3 contracts closest to done; ALL contracts are listed on the map screen.
- Q55: in the demo hide credits, XP, stash and bag. Q56: also hide the item-value line and the backpack hint (keep run goals).
- Q58: in career the top-right becomes one tidy row. Q59: $ for money, SP for score. Q64: keep the low-ammo box marker.
- Take what Halo Reach, Halo 4, Destiny 2, Diablo IV, ARC Raiders and Fortnite do well and adapt it to top-down 2.5D (Q41).
Screens 19-24, 33, 34, 36, 37, 48, 50, 51, 61, 78. Before and after pictures, the critic, 4 or more everywhere (Q6).
TASK DONE when every listed screen scores 4 or more from the critic, or TASK PARTIAL with the rest.

## RE-QUEUED 10-18 night (coordinator)
- Why your camera and critic were refused: the command did not match the one exact form (most likely a different port, e.g. 9352, or extra bits on the line). It is fixed now: a trailing "2>&1" or "| tail -N" is allowed, and a refused command now tells you the exact form with your lane's port. Lane a uses -Port 9361, b 9362, c 9363. Take pictures and run the critic again.
- His new finish line (3.51 a): critic 4 for the raid, waiting, pause and run-over screens, and 3 for the rest. Screens already at 3 that are not one of those four are done.
- Renamed c-02 so lane c runs it beside c-31 (lane a has the party jobs). Your run count was reset. Start from your notes and do not redo shipped work.

## RE-QUEUED 10-19 23:05 (coordinator, in the VM)
- Both blockers of runs 10 to 15 are fixed: writing your mk-cw-*.ps1 into the scratchpad works again in the VM (fixed 10-19 evening; helpers have shipped v32.02 to v32.06 since), and the critic runs on his Claude plan (no key needed).
- Start from RUN 15 in notes\02-raid-hud-redesign.md: its critic P0/P1 list (minimap and run info glued; three bar styles bottom-left, stamina label outside its bar, hp not the hero; ammo name as heavy as the number) is your work list. Fix them in that order, one key each, then re-shoot and re-judge.
- His 10-19 answers: the judge now measures against Halo Reach, Halo 4, Destiny 2, Diablo IV, Call of Duty, ARC Raiders and Fortnite; his taste beats the judge; the style guide beats the judge. Lane b's b-30-ui-hud waits on you, so this job comes first. Your run count was reset.

Coordinator note 10-20 01:00 (in the VM): ran out of tries at 00:31 while still shipping every run (last: v32.25, the toast feed no longer draws over the open map). Parked in blocked/ on b-30-ui-hud, which owns the same raid screens and is running now, so two helpers never restyle the same HUD at once. When b-30 ends, this job comes back with a fresh run count (reset once). Your own next list: 37 one big extract timer (retarget the old banner checks first), 61 the wheel's muddy focus wedge, 78 mixed 14px and 18px button text. Critic last: 19, 21, 36, 37 at 2; 50 at 3; 22 at 3.

Coordinator note 10-20 01:55: b-30-ui-hud is closed and its work is yours. It shipped v32.35 (extract inbound line 39px), v32.36 (that line on a flat dark plate), v32.39 (the compact controls list folds when an extraction is called; F1 opens it). Screen 37 went from 2 to 3. Its open list: on 37, the red "hostiles closing in" line has no plate, the plate has no accent tab, the number is 39px not the 56px hero size, and a folded "controls" handle hangs under the bots panel at top left; 78 mixed button text sizes; 22 the "running slowly" chip over the open map. The What's New card is at P35 (next P36). Notes: notes/b-30-ui-hud.md, pictures notes/shots/b-30t-after.

Coordinator note 10-20 03:30: STOPPED under his 2.83 b rule (6 tries without the finish line: stop, keep the best versions). Best versions with pictures: c-02-r17, r18, r21, r23-after, r24. Tonight it and b-30 shipped v32.25, v32.35, v32.36, v32.39, v32.58, v32.59 on the raid screens. Left (run 25 list in notes/02-raid-hud-redesign.md): run info has two headings (old check 27.42 needs both), ammo card chrome (old check pins a===0.62), left chip stack sizes, hp and stamina bars not one family, career top-right column (his cw-trcol order), screen 78 abandon button and rare-items row. Most of these need an old check retargeted first, which the Codex lane can now do (fixture-retarget.json); a later job can pick them up after that.
