#!/bin/bash
# one at a time, no --resume skipping of the names given (their old pictures were deleted)
cd "C:/claudecode/dark raiders/tools/handoff/art-survey"
for n in "$@"; do node build/run.mjs $n 2>&1 | cut -c1-120; done
echo BATCH DONE
