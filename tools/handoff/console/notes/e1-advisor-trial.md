# e1-advisor-trial (lane b, run 11-01 about 13:00)

## Result: not run. A headless lane worker cannot run this trial.

What the trial needs, and what a lane worker may do:

| Needed | Lane worker permission |
|---|---|
| Set the model per job (Sonnet 5.5 high + `/advisor opus` vs Opus 5.5 high) | none. The model is picked by console-lane.sh or start_session. |
| `claude -p "/usage"` before and after each job, nothing else running | not on the command list. Also the lanes (a, b, c, e, f) and chat sessions burn plan at the same time, so a clean before/after is not possible while they run. |
| Ten comparable mid-weight fix jobs in pairs | tasks/ holds 8 files on 11-01, and only 4 are mid-weight fix jobs (o-146, o-243, z-163, z-165). No matched pairs exist. |
| Rule: a lane may not start agents or sessions | applies. |
| `plan-usage.txt` shows 0 / 3 (no live reading to difference) | nothing to measure with. |

Nothing was changed. Ladder in START-HERE and ESC_MODEL in console-lane.sh stay as they are (opus, high).

## What the coordinator would need to do (suggested design)
1. Pick 5 matched pairs of fix jobs from tasks/ (same size, same area). Put the A job on `model: sonnet` plus `/advisor opus`, the B job on `model: opus`, both effort high.
2. Run them one at a time in a quiet window, with `claude -p "/usage"` before and after each. Log per job: plan points, preflight fails, ships, ON HIS PC line, critic score.
3. Verdict rule from the task: Sonnet + advisor matches Opus on gate passes for clearly less plan, then make it the rung 3 default (START-HERE ladder and ESC_MODEL). Otherwise keep the ladder.
4. Note: advisor is untested on 5.5 (Anthropic's test: +2.7 points, 11.9 percent cheaper on older models), so the sample of five pairs is small; only a large gap in plan points is a real signal.

## Per-job table (empty)
| job | model | plan pts | preflight fails | ships | ON HIS PC | critic |
|---|---|---|---|---|---|---|
