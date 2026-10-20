o-11-trigger-hysteresis : triggers do not chatter (pad research J9, coordinator 2026-10-19; PILOT of the lighter model)
model: gpt-6-luna
effort: high

Build and test as section "J9" of tools/handoff/pad-research/best-practices.md: RT and LT turn on above 0.35 and off below 0.25.
Check (its control must FAIL on the old build): feeding RT 0.30, 0.40, 0.34, 0.36, 0.30, 0.20 gives exactly one press and one
release, and a semi-auto gun fires once.
If the crowbar job (o-06) has not shipped yet, leave the RS focus toggle as it is.
TASK DONE when shipped and the check passes; TASK PARTIAL with what is left.
