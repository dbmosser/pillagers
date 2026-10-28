# 186h-clock-score-arrow : clock card above score card, arrow to the nearest exit, no score pops, far exit lines silent
Queue: HIS ORDERS 10-28 morning, in the HUD Improver chat, with a picture of the top-centre card and one of the bottom exit line. Built by the HUD Improver (this lane, h). Polish of existing HUD, allowed before 11/1.
effort: high (Opus)
Key: cw-clockcard

His words, verbatim:
1. "extraction arrow should always point to the closest extraction point"
2. "score and clock should be separate windows.  Clock should be bigger than score and should be above score."
3. "score should only be shown here, e.g. it should NOT pop on the screen (like looting does) every time sp is earned"
4. "extracts starting and extracts in progress should only be shown at the bottom of the screen if player is within 250m of the extract"
5. (picture of the bottom-right gun card: "14 items  $9,750" beside "b / i  backpack") "bottom right corner: item number is useless; remove it.  also remove the stash value as that is already shown in another window (current pillager bots)"
6. (picture of the goals panel: "contracts 6/8  goals 0/3", "8pm  clear", "run goals" and three goal rows with +sp) "this menu should spawn in upper right hand corner"
7. Same panel: "not sure what is meant by  'contracts 6/8' -- seems pretty useless if you aren't going to show the contracts"
8. (picture of the roster: "current pillager bots  2", rows you / names with $ values, "0 out  2 dead") "This should say 'current pillagers'  and then 'value at risk'" (the header reads current pillagers, the money column is headed value at risk)
9. "pillagers should always be referred to as 'pillagers' never 'pillager bots'" (reverses his 10-18 PM word; every player-facing "pillager bot(s)" becomes "pillager(s)"; built as its own follow-up build, key cw-pillagersword, so either can be reverted alone)
10. (picture of the danger banner "locked on" / "machine has you in sight") "this should never say 'machine' without telling me which machine....eg overseer? etc" (every player-facing line that says "machine" names the kind instead: sentry, crawler, overseer and so on; in the words build cw-pillagersword)

Keep: looting (pickup stack, loot rows, loot sounds, item labels) untouched; kill lines stay; money ($) is not score; player text lower case.

Check (must FAIL on the build before): the clock draws in its own card above a separate score card, clock type larger than score type; the extraction arrow and distance name the nearest open ring; earning sp draws no float or feed line; a ring called or in progress over 250 m away draws no bottom line, and one under 250 m does.
Pictures: uishots 21, 33, 34, 50 at 1080 plus both party windows; look at them.
Watch-for line for him: whether the clock is easy to find at a glance and the arrow ever points at a far ring.
TASK DONE when shipq prints ON HIS PC.
