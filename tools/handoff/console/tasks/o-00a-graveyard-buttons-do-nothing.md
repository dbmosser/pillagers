# 00a-graveyard-buttons-do-nothing : the title "graveyard" button and the graveyard "close" button throw when clicked, so the graveyard never opens by click (since v37.68)
Queued 11-12 06:1x by the HTML CEO from the JT PC full run corpus-1111-2205 (origin/spare-results, spare/DESKTOP-82BKOP4/corpus/corpus-1111-2205.txt, build 94c50606f = v37.69). Build at HEAD.
Codex: never change tools/mkfixture.ps1 except through your draft's new check; if an older check must change, put the finding and exact change in your notes and stop. Owner quotes below are binding as written.
HIS PRIORITY: a shipped feature that does not work for the player (his g-98 "Yes, an optional hardcore save", shipped v37.68). Ahead of every other job (o-00 prefix).
effort: low

What is wrong: the game script is one closure (dark_raiders.html line 3923 `(function(){ 'use strict';`), so hcGraveOpen (about line 63070) and hcGraveClose (about line 63069) are local functions. The two buttons call them through inline handlers that run in the page's global scope, where those names do not exist:
- #hcgraves (about line 3580) `onclick="hcGraveOpen()"`: clicking "graveyard" on the title throws "ReferenceError: hcGraveOpen is not defined" and nothing opens.
- #hcgraveclose (about line 3604) `onclick="hcGraveClose()"`: clicking "close" in the graveyard throws the same way. Esc still closes it (the keydown listener at about line 63090 calls hcGraveClose from inside the closure).
Evidence, old checks that passed on v37.67 (corpus-1111-0904) and fail on v37.69 (corpus-1111-2205):
- 10.98 "a button on the character screen threw: Uncaught ReferenceError: hcGraveOpen is not defined".
- 10.10 "windows with no way out: hcgrave" (its "ESC did not close: gamblemodal" part is older and is not this job).
The o-h01 camera pictures looked right only because the recipes opened the panel without clicking the button.

Do: bind both buttons from inside the closure with addEventListener('click', ...) next to hcGraveOpen and hcGraveClose, and remove the two inline onclick attributes. Do not move the functions to window. Change nothing else on the graveyard (ranking, rows, body, focus, esc, the button's show/hide at about line 78837) and nothing on the title, settings, hub or raid. Look for any other inline handler that names a closure function (today the only other inline handlers, #oc_x at about line 3016 and the cheat box close at about line 3614, use only document calls and are fine).
Check (must FAIL on the build before, PASS on the new): on the title with one graveyard record staged and #hcgraves shown, a real click on #hcgraves (dispatch a click event, never call hcGraveOpen) opens #hcgrave (class on) with no page error captured; then a real click on #hcgraveclose closes it (class on gone) with no page error, and focus returns to #hcgraves. Old save reload; seed 4242 fingerprint holds.
Note for the gate: it runs only the newest 80 older checks, so 10.10 and 10.98 will not run there; the coordinator confirms them on the next JT full run after the ship.
Second part, only if the cause is in v37.68 to v37.72: old check 32.90 (close X at one height in settings, shop and stash) passed on v37.67 and now reads "settings 1008, shop 12, stash 13". Find whether one of these ships moved #closesettings (or what the check measures) on the settings display tab. If one did and the fix is small and safe, fix it in the same key and say so; if it predates v37.68 or the cause is the check, write the finding in your notes and leave it.
Pictures at 1080p: the title with the graveyard button, and the graveyard open after the click (reuse hc-graveyard-ranked from .codex-work/o-h01-177-hardcore-save/camera-recipes.json in lane o's worktree, but open it by clicking #hcgraves).
Rules: player text all lower case; never touch the pickup stack, loot sounds or loot rows; the seed 4242 fingerprint holds. Say in DESIGN.md what he should watch for: clicking "graveyard" on the title opens it and "close" closes it.
TASK DONE when shipped (ON HIS PC) and the click picture shows the open graveyard; TASK PARTIAL with what is left.
