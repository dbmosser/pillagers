#!/bin/bash
# one node process per option, so a killed process loses one shot only; skips what is already shot
cd "C:/claudecode/dark raiders/tools/handoff/art-survey"
for n in "$@"; do node build/run.mjs --resume $n 2>&1 | cut -c1-160; done
echo BATCH DONE
