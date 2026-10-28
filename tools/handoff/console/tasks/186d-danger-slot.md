# 186d-danger-slot : one danger at a time, lower on the screen (build 2 of job 186c)
Queue: his complaint 10-27 ~21:25 (verbatim): "I am worried your quiet hud shit isn't actually addressing my complaint, which is that there are too many messages coming in to the player". On the plan he said (verbatim): "Ok? I don't know. You need to figure out what works". The research rule of that night (reports/Player alerts and HUD messaging.md, section "Centre: one danger slot above, one answer line below", and build job 3) is the design. Build 1 (cw-msgroute: the ladder, the run log on the pause box, a 3 line feed) must be ON HIS PC first; this job is the second build, so either one can be reverted alone. Polish, allowed before 11/1.
effort: high (Opus: it touches the alert lane every party raid runs through)
Key: cw-dangerslot

What is true (v35.43 + build 1): the alert banner draws at about 16% of screen height (alertLayout, alertDraw near line 23018). One that waits over 2.5 s goes into the left feed (alertToFeed). A keyed warning such as "a crier is revealing your location" was said 14 times in the staged 3 minute raid; the lane shows it again each time it comes free.

Build:
1. Move the danger banner from about 16% to about 27% of screen height (y about 290 at 1080p), centred: one line about 30 px on a plate, scaling in over about 200 ms, life 3 s (4 s for "down", or as long as the state holds).
2. One danger at a time. P0 replaces P1 at once and the P1 goes back to wait. The same source and words do not show again for about 10 s. A danger that could not show within 1.5 s is dropped, never sent to the feed (today it moves to the feed after 2.5 s).
3. Teammate down is P0 in the other window, in the teammate colour (P1 amber, P2 cyan: SEATCOL, mapSeatColor). Keep the "!" world mark over the enemy that saw you.
4. Downed card: today about 480 by 200 px at screen centre. First check whether the camera centres the player (the arcade picture says yes; the career pictures look off centre). If it covers the player, shrink it into the danger slot (the timer, the bar, the "[f] self-revive" line). If it does not, leave it and say so.

Check (must FAIL on the build before): a danger draws at about 27% of the height; a second danger said while one shows does not draw over it; the same keyed danger said again within 10 s draws once; a danger that waited over 1.5 s is dropped and is not in the feed.
Old checks that expect the banner at 16% or the move to the feed: re-aim through fixq, never loosen.
Pictures: uishots 21, 33, 34, 50 at 1080; look at them.
Watch-for line for him: whether the lower danger slot covers enemies coming from above the character.
TASK DONE when shipq prints ON HIS PC. Then send one line to the order chat (Gameplay Edit Intaker 2, local_cf9fff85-d314-431d-aba9-bc4ddd180177): "cw-dangerslot is ON HIS PC vNN.NN".

## Downed card findings (folded in 10-28 by the CEO chat, from the Codex critic on o-120e, v35.54; final scores 3 and 3)
Pictures: tools/handoff/console/notes/shots/o-120e-downed-damage-cuts-recipes-4/ (downcuts-linked-p1-1080.jpg, downcuts-linked-p2-1080.jpg, both windows) and o-120e-downed-damage-cuts-recipes-1/report.json. The critic's P1s, shortened, in its words:
1. One state, one place: "the red down label, timing bar, hp bar and 'down' tag all repeat the same state in several places"; "the player 1 label appears twice"; "the bottom-left down tag and hp bar are still two separate pieces".
2. Skill check and countdown: "nobody can tell which one is the bleed-out countdown". Make the bleed-out countdown the hero and the skill-check bar plainly secondary.
3. Card contrast: "the card has no scrim" over a busy map.
4. Self-revive: "it is the primary action but has no key chip". The key on a keycap chip in the shared HUD style; the line short and lower case.
5. Empty hp bar: draw it as an outlined empty bar, not a dark block.
6. Mixed status chips: the top-left "keyboard" chip "is tucked into the corner at x 10 ... and has a green border that matches nothing else". Bring it to the shared inset and style (see 186f, which owns the corner margins and panel style; whichever ships second rebases).
7. Roster density and alignment: owned by 186f.
Keep: the 3 px danger tab on the card (intentional, cw-downedcard) and the downed skill check itself (his downbar1 order of 10-16; removing it would be his call). Step 4 above (shrink the card into the danger slot if it covers the player) still decides where the card goes; do these with it, in the same build or a follow-up build cw-downedpolish.
