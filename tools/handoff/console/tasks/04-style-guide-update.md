UPDATE THE STYLE GUIDE TO HIS TASTE (his answers 10-18). His answers of 10-18 are in the memory file pillagers-answers-1-78-2026-10-18.md (read the numbers named here first). Notes: notes\04-style-guide-update.md.
Edit notes\ui\style-guide.md and the shared UI object in the game, then re-apply to every screen already on the shared look:
- Q42 clean and modern. Q44 no pixel or arcade font. Q45 straight, no arcade jokes ("Insert coin").
- Q46 the accent for "selected" and main buttons becomes lime yellow, the most visible shade on the dark background (check the
  contrast at 1080 and 4K; keep rarity and danger colours distinct from it).
- Q43 windows (Settings, stash and the rest) become a centred card with an X in the corner that takes up NEARLY THE WHOLE screen.
- Q47 livelier menu motion, with bounce (overshoot about 6 to 10 percent; still never ignore a press). Q48 soft ticks on focus,
  punchy hits on confirm and on score.
- Q40: no single model game; take what each of his six games does well (notes\ui\references.md).
Run the critic on the screens you touch. TASK DONE when the guide and the shared look are updated and re-applied.

--- UPDATE 2026-10-18 evening (coordinator). Read first; where it disagrees with the text above, this block wins. ---
Most of this task has shipped. Do not redo it. Checked in git log and in dark_raiders.html:
- Q46 lime accent: v30.61 cw-limeacc (the accent is lime yellow). --acc:#e6ff3d is on line 55 of the game file.
- Q47 bounce: v30.85 cw-bounce (menus bounce on open).
- Q43 centred card with an X: v30.89 cw-cardwide (settings and keys fill the screen as a card), v30.95 cw-cardwide2, v31.02 cw-closex (windows close with an x in the corner), v31.10 cw-cardmargin (a centred 90 percent card for the shop, codex, trophies, fashion, mainframe, gamble, bar, terms, party and sector windows), v31.16 cw-shopfill.
- Q48 sound: the spec is in guide section 6. The run-over card may still lack a heavier "ok" and one hit per score tick on the count-up (coordinator list item G8). Check the code first. If it is missing, it is the one build item left here.
The style guide itself is now updated (notes\ui\style-guide.md, new section 0 and four stale lines fixed, 2026-10-18 evening): "$" for money and "sp" for score (Q59); ALL text lower case (his order of 10-18 afternoon, which reverses the sentence case the guide used); the reference pictures exist (tools/handoff/ui-refs: arc-raiders-1.jpg to arc-raiders-5.jpg and more); the career top-right is a vertical 1 by 1 list of equal items (key cw-trcol, another helper; it replaces Q58 "one row"). Do not edit those lines again.
PENDING his answers, do not invent them: the player 1 and player 2 ring colours (round 3 question r3-13). The --acc shade stays #e6ff3d.
Left for this task: (1) the sound check above; (2) read the guide once, start to finish, and fix any line that contradicts section 0 (fix the guide, not the screens); (3) a shared fix only if one is left, for example CSS that every window uses. Screen-by-screen work belongs to the screen tasks now (02, 03, 12, 13, b-30, b-31, c-31); do not restyle single screens here.
TASK DONE when the sound item is checked (built, or logged as already there) and the guide has no line that contradicts section 0.
