# 186a-quiet-hud-text : the quiet hud, part A: every raid line shows in one place only
Queue: his order 10-27 ~20:20 in chat (verbatim): "build the quiet hud, all 5 changes". Polish of what exists, allowed before 11/1.
It REVERSES his rs-2 a ruling of 10-24 ("keep both alert copies", memory pillagers-ready-by-friday-2026-10-25): his newer order wins. Update that memory line and any critic or job note that calls the doubled alert his ruling (grep "keep both", "rs-2").
Part B (186b, another session at the same time) does the panels: cash card, at-rest hiding, gun name. Touch only the text lanes and the two words below.
effort: high
Worked in: a Claude session started from his orders thread. Lanes skip in-session/.

The quiet hud he picked has 4 places: top centre (clock, extract distance, one alert at a time, danger or extract only), left feed (everything else, each line once), right stack (pickups only), bottom strip (health, belt, ammo).

Part A, his changes 1 and 5:
1. No more double lines. Today say() (dark_raiders.html ~23226) sends EVERY line to the left feed (feedSay, v27.24 feed1) and also to the alert lane (crit/warn/ext) or the two grey centre rows (G.msg / G.feed). In the picture tools/handoff/shots recipe 33-raid-fight-alerts, "the pillbox has seen you", "location revealed" and "running slowly" each show twice. New rule: an alert (crit, warn, ext) shows only as the top-centre banner, one at a time (the existing alert queue); every other line (obj, ally, info, chat, sys) shows only in the left feed. The two grey centre rows stop drawing. Keep msgLog, the pause answer line and the pickup stack as they are. Check what reads G.msg / G.feed before removing anything (extract prompts, tutorials, co-op lines) and keep any line that would otherwise vanish.
5. "concealed - in cover" (right side) becomes an icon in the left status column (STATUSL, ~42846, same look as the others, lower case words). "extraction c available" (right side) moves under the extract distance at the top centre.

Checks (each must FAIL on v35.25): a warn line said once draws in exactly one place; an info line draws in the feed and not in the centre; concealed shows as a status icon and not as the right-side word; the extraction available word draws under the extract distance. Old checks that test the doubled feed or the centre rows: re-aim them through fixq (RULES.md step 8) so they prove the new rule; never loosen one just to pass.
Pictures: uishots screens 21, 33, 34, 50 at 1080, look at them, and send the 33 picture to him (SendUserFile) with one line.
Ship: preflight on lane g (check no other preflight runs on g first), then shipq. Rules: player text lower case, short; HUD layer only; no storage key change; seed fingerprint unchanged.
TASK DONE when shipped and his main PC reports the build (git show origin/spare-results:spare/JUL26/status.txt, game=VER). Then move this file to console/done/ and report one line: build, on his PC, what to watch for (a warning now shows only once, at the top).

## DONE 2026-10-27 21:20 (186a session)
- v35.30 (27b937da4): one place per line (alert = top banner only, pick = right stack only, the rest = left feed only; grey centre rows retired); concealed is an eye icon in the left status column; an edge-held extraction ring shows under the extract distance.
- v35.31 (705095bed): a line said under the solo pause box shows on the answer line only; a keyed feed line keeps its detail (contract done names the contract).
- v35.33 (a4dec94e1): four lines whose detail matters carry a key (loaner gun waits at The Stash, contract item nearby, select a heal, 2P extracted / player 2 still out).
- fixture 8c67af2af: 18 old checks re-aimed at the left feed and run log; all pass on 35.34.
- His main PC reports game v35.34 (21:18). Pictures: notes/shots/186a-after (21, 33, 34, 50 at 1080).
- Not mine, still failing: 9.89 (Undercroft loadout labels read "hotbar0 on keys", panel heading says hotbar) since about 35.30; it reads the hub belt labels, the 186b lane's area.
