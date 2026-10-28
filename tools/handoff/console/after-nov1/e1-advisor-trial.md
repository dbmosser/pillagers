# e1-advisor-trial : does Sonnet with an Opus advisor beat Opus high per unit of plan? (efficiency trial, CEO chat)
Queue (CEO chat 10-27 night): after the party, Sat 10/31 or later. Not a game feature; parked only so nothing new touches the setup before
the 2 player party demo. Source: reports/model-escalation-research.md (Anthropic's experimental advisor, `/advisor opus`: Sonnet consults
Opus at stuck points and before declaring done; Anthropic's Apr 2026 test on older models: +2.7 points, 11.9% cheaper per task; untested on 5.5).

Do: run ten mid-weight fix jobs from tasks/ in pairs: one on Sonnet 5.5 high with the Opus advisor, one comparable job on Opus 5.5 high.
Log per job: plan points used (claude -p "/usage" before and after, nothing else running), preflight fails, ships, ON HIS PC, critic score.
Result: one line per job and a verdict in this file. If Sonnet + advisor matches Opus high on gate passes for clearly less plan, make it the
rung 3 default in START-HERE's model ladder and in console-lane.sh (ESC_MODEL); otherwise keep the ladder as it is.
