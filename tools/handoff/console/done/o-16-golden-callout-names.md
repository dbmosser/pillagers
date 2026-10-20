o-16-golden-callout-names : the golden kill callout names the kind ("golden sentry down") (planner draft 2026-10-20)
effort: medium

Source: tools/handoff/q-round3/answers.md 3.84: 'b: Always the specific name ("golden sentry down", "golden pillager down")'; RULES.md line 195.
Not done (planner, 10-20): rg "GOLDEN ENEMY DOWN" dark_raiders.html -> 62074 (goldDrop: say('GOLDEN ENEMY DOWN','obj',{sub:'SEARCH
THE HOARD'})) and 62513 (the same call), plus comments at 62038 and 62498. No kind-specific form exists anywhere.

1. The callout names the kind of the golden enemy that fell: "golden sentry down", "golden pillager bot down" (kind raider shows as
   "pillager bot" under his 10-18 words rule), and the same for crawler, bulwark, howler and listener (GOLD.kinds).
2. goldDrop(x,y) is not given the body: pass the kind in from the death path. Keep the sub line "search the hoard".
3. Both windows get the same line in 2 player. Lower case through the text door, as every callout.
Checks (control must FAIL on v32.90): a golden sentry kill gives "golden sentry down"; a golden raider kill gives "golden pillager bot
down". Fixture gotcha: the fixture replaces say(), so put the name choice in its own function and test that.
Party risk: low (words only).

TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
