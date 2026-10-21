91-circle-only-text : no player text names Daniel or calls the game an alpha in the Thanksgiving build (planner draft 2026-10-20)
Lane (coordinator 10-21 00:30): moved to the Codex lane as o-91-circle-only-text (lane o had no jobs while lanes a and b were busy and c waited for memory).
Queue (coordinator 10-20 21:40): renumbered from 74 so the pick order follows the plan (his 10-20 evening play notes took 79 to 86 and come first; lanes pick by number).
effort: medium

Queued 10-20 23:10 (his 10-20 23:00 order: nothing waits for the party, beats the old hold).
Source: CLAUDE.md rule 9: "short callouts ... never an explaining sentence"; q-process/answers.md 75 (store page text): "c) Keep it bare".
Not done (planner, 10-20): grep of dark_raiders.html: "Copied. Paste it to Daniel." at 66038 and 68718; "...paste it to Daniel." at
65945; "Copy it out and send it to Daniel..." at 2906; the outcome card copy note (oc_copynote, 2310); a TXSHIP entry at 4446 ("Copy
this and send it to Daniel."); a What's New line near 3615 ("ready to paste straight to Daniel"); the What's
New card's first line (3261) is "THIS IS AN ALPHA. Things will break..." followed by POLISH PASS filler lines.

1. In player text, nothing names Daniel or calls the game an alpha. Strangers on a bare itch page (75 c) have no contact address, so a
   "paste it to Daniel" line has no meaning for them. Keep each line's job (for example "report copied").
2. The TXSHIP entries are his own rewordings: changing one overrides his language, so the Q8 reason must be strong and written next to it
   in notes/ui/changes.md ("strangers do not know Daniel").
3. The What's New card keeps a few short real lines instead of the alpha line and the POLISH PASS fillers. Old checks read the card's list
   by index (the comment above wnList, about line 3229): retarget them through fixq, and refresh the card stamp (WHATSNEW_VER) through a
   card ship (genP.sh).
4. All lower case, short, no explaining sentences.
Party risk: none (text only).

TASK DONE when the grep finds no "Daniel" and no "alpha" in player text and the card is refreshed; TASK PARTIAL with what is left.

DONE 10-21 01:55 (coordinator, moved from failed/): the goal is met. v33.43 (cw-cx-publicreports) took Daniel out of the report copy lines and v33.49 (cw-cx-shortnews) replaced the alpha line and the polish pass fillers with three short real news notes; card ships v33.45 and v33.46 refreshed the stamp. grep of dark_raiders.html now finds "Daniel" only in a code comment (54331) and "alpha" only in comments and canvas code. The third key (cw-cx-reportnewsstyle, a style pass on the report and news windows) did not ship; the screen judge scores those windows 2 (91-public-news-window, 91-public-report-recorder; the finish line is 3), so it goes on as job o-91b.
