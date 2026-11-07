# FnP development, 100 KPIs (Codex Correspondent, 11-03 evening)

How to read this. Grades: A strong, B good, C middling, D weak, F failing, ND no data (not graded). Evidence is what I read today in pillagers-fortnite (docs/progress.md, goals-saturday-1107.md, gap-audit-1103.md, fnp-stock-audit-1103.md, shots/, tools/fnp-scripts, overlord-orders.md). I did not run the editor or any test, and I did not play it. Feel (group 10) is the owner's call, not mine.

## 1. Saturday goals
|#|KPI|Grade|Evidence|
|---|---|---|---|
|1|Goal 1 start a raid, squad of 2|C|Solo loops pass (loop3 8 of 8); a two-player join is not shown, one join got stuck (vault2)|
|2|Goal 2 robots|B|Stage 3 passed 10 of 10 with 16 robots; robots fire; "heavy takes teamwork" untested|
|3|Goal 3 map|C|Shrunk to a small loading bay (orders v8); the dam plan was dropped|
|4|Goal 4 loot|B|Drop rule proven in game, a bag survived 9 robot drops twice|
|5|Goal 5 extract or lose|D|RunExit is written (raid 618 to 637), never run|
|6|Goal 6 stash that lasts|ND|fnp_save.verse exists (86 lines); no restart test seen|
|7|Goal 7 pillager and SL|ND|Ranks exist; self revive not seen|
|8|Goal 8 Forge (his must-have)|D|Steps rarity only; no damage boost; gun-in-hand path never run|
|9|Missing features, count|D|9 in gap-audit (forge boost, spectate, pickaxe, robot damage, wrecks, valuable handover, mobility items, crawlers, looks)|
|10|Written but never run|D|Gap audit section 2; extraction and forge matter most|

## 2. Schedule against the plan
|#|KPI|Grade|Evidence|
|---|---|---|---|
|11|Mon 11/2 editor in, first tests|B|Done|
|12|Tue 11/3 blockout, exits, clock|B|Exist; friend-join path untested|
|13|Wed 11/4 full raid start to finish|C|Pieces run; no full raid shown; tomorrow|
|14|Thu 11/5 Undercroft, stash, sell, Forge|D|Forge and stash screen are the biggest gaps|
|15|Fri 11/6 revives, tuning, 2-player check|D|No 2-player run yet|
|16|Days left to Saturday|C|4 including today; 11/14 fallback exists|
|17|Slip against the original table|C|About a day behind on Wed/Thu items|
|18|Plan updated when it slipped|B|progress.md and orders kept current|
|19|Fallback date used|ND|Not needed yet|
|20|Scope cuts to protect the date|B|Map shrunk; vehicles, mini overseer pushed after Saturday|

## 3. Stability and tooling (editor hangs)
|#|KPI|Grade|Evidence|
|---|---|---|---|
|21|Card hangs today|F|7 or more (03:29, 11:43, 15:25, 17:35, 18:51, 19:10, 19:12)|
|22|Hangs per hour of editor time|F|Several a day against sessions of a few minutes|
|23|Root cause known|D|Leading guess only: editor ignores t.MaxFPS and runs 105 to 115 fps|
|24|Frame cap actually working|F|Logged as set, measured 105 to 115 fps all day|
|25|One variable changed at a time|B|Lead dev plan changes one lever per test|
|26|Time to reopen after a crash|C|Rule is 3 minutes (order 19); actual times not logged in what I read|
|27|Test pass rate when no hang|B|loop3 8 of 8, stage 3 10 of 10|
|28|Tests lost to hangs|D|vault1, vault3, jobs1 second game, earlier ones|
|29|Hang log with screen count|B|Kept; 7,8,9 on two screens, none on one|
|30|Hardware or driver checked|C|No 4101 reset found; one hardware error at 8:56|

## 4. Output and code
|#|KPI|Grade|Evidence|
|---|---|---|---|
|31|Verse written|B|About 1,610 core lines, 7 .verse files|
|32|Lines duplicating stock devices|B|About 100, 6 percent|
|33|Lines that are workarounds|C|About 250, 16 percent, for engine limits|
|34|Lines that are real game logic|A|About 1,100, 68 percent, nothing stock offers|
|35|Stock devices used where possible|B|About 280 lines wire stock devices|
|36|Compiles on every Play FNP|B|"Now always compiles" per the 11:30 note|
|37|Dead work|C|Locked room built and removed the same day|
|38|Throwaway scripts|D|355 files in fnp-scripts, a1 to a22 one-offs|
|39|Probe code beside game code|C|fnp_probe.verse is 55 KB, over half the raid file|
|40|Wrong claims in own notes|C|Audit caught two before they reached the owner|

## 5. Testing and proof
|#|KPI|Grade|Evidence|
|---|---|---|---|
|41|Features proven by script|B|Hazards, crawlers, drop rule, loop3, stage 3, Play FNP|
|42|Features proven in front of the owner|ND|No playtest logged|
|43|Proof labeled honestly|A|"Proven by script" on each item|
|44|Open "not proven" items|D|Room cause, Play FNP on display 2, turrets, brute|
|45|Tests per feature|C|26 sess scripts, 45 logs|
|46|Screenshots taken|A|543 files in shots/|
|47|Screenshots looked at|ND|Not measurable from files|
|48|Regression check before each change|C|By hand per plan, no gate like HTML has|
|49|Test run cost|C|About 4 min for the short test, 300 s sessions|
|50|Results readable at a glance|B|sess1 prints frame rate and result lines|

## 6. Process and coordination
|#|KPI|Grade|Evidence|
|---|---|---|---|
|51|Order versions in one day|D|20 by 19:10 on 11-03|
|52|Orders that reversed an earlier one|D|Display 3 to 2 to 1 inside about 2 hours (v17, v18)|
|53|Roles with one owner|B|FNP CEO, lead dev, OVERLORD named|
|54|Handover quality|C|Handover file is clear; the message to FNP CEO 2 was held, never delivered|
|55|Chat rotation cost|C|Lead dev 3 to 7 and CEO 1 to 2 in a day|
|56|One chat on the editor|B|Rule kept per notes|
|57|Failure turned into a rule|B|Order 19 and several new checks|
|58|Rule followed in the next failure|ND|Too few repeats to judge|
|59|Watcher polling interval|C|Cut to about 5 s at 19:10 on the owner's order|
|60|Idle time with nothing running|ND|Not logged|

## 7. Resources
|#|KPI|Grade|Evidence|
|---|---|---|---|
|61|Claude usage pace|B|About 0.6 percent an hour to the reset|
|62|Codex used on FnP|D|One try at 10:26, blocked by policy, no output; lane resting until 11/4|
|63|Codex output usable|F|Zero findings; it asked for the files to be pasted|
|64|RAM headroom with editor open|C|About 12 GB free at the end of one test|
|65|One helper beside the editor|B|Enforced in both lanes|
|66|Main PC left to the owner|B|Owner-always-wins rule|
|67|HTML tests on the spare PC|A|Gate runs on JTPC|
|68|Web research done|B|Stock-vs-custom audit read Epic pages|
|69|Cost per working feature|ND|No spend log for FnP|
|70|Tokens on notes vs building|ND|Not measured|

## 8. Decisions and owner time
|#|KPI|Grade|Evidence|
|---|---|---|---|
|71|Answers binding and recorded|A|Rounds 1 to 3 in docs|
|72|Questions to the owner|B|Batched in rounds|
|73|Owner told when not ready|A|12:13 told crawlers and brute do not work yet|
|74|"Ready" said before it was|C|10:58 "can play with Play FNP"; later notes show unproven parts|
|75|Stale claims repeated|C|Audit lists two not to repeat|
|76|Reinventing-the-wheel check|A|Stock audit done; 68 percent is real logic|
|77|Decisions logged with reason|B|Mostly in verse-notes|
|78|Owner time spent on tooling|D|Display order changed twice; hangs hit his screen|
|79|Friend test left to the owner|A|Standing rule followed|
|80|Hard choices flagged early|B|11/14 fallback stated up front|

## 9. Documentation
|#|KPI|Grade|Evidence|
|---|---|---|---|
|81|Single start page|A|progress.md|
|82|Long record searchable|B|verse-notes.md|
|83|Docs agree with each other|C|Some stale ("Guard Spawner has no gun setting")|
|84|Gap list current|A|gap-audit-1103 with line numbers|
|85|Progress page focus|D|215 lines, about 30 hang mentions, built around problems|
|86|Binding answers findable|A|answers-round-3 wins|
|87|Handoffs complete|C|One held, replaced by a file|
|88|Test logs kept|A|45 logs|
|89|Plain language|B|Mostly; some dev talk|
|90|Owner setup steps short|B|setup-needs.md|

## 10. Readiness for Saturday
|#|KPI|Grade|Evidence|
|---|---|---|---|
|91|Core loop, one player|B|Raid loops pass in tests|
|92|Core loop, two players|D|Not shown|
|93|Forge ready|D|Not working end to end|
|94|Extraction ready|D|Never run|
|95|Stash survives quitting|ND|Not shown|
|96|Robots challenging|ND|Owner's hands|
|97|Fights, not walking|ND|Owner's call|
|98|Crash risk in his two hours|D|Hang every 1 to 2 hours; game lived, editor died|
|99|Test held 11/7|C|My read: even odds, 11/14 the likelier landing|
|100|Overall efficiency|C+|Good output, honest proof; time lost to hangs, order churn, unrun forge and extraction|
