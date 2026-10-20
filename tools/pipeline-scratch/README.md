# pipeline-scratch: a copy of the build pipeline's helper scripts

The ship queue, the full test run and the lanes call these scripts from the coordinator scratchpad
(C:/Users/User1/AppData/Local/Temp/claude/...8a09e991.../scratchpad). That folder is not in git, so this copy keeps them on GitHub.
Every coordinator check-in runs tools/health.sh, which copies any of these that changed in the scratchpad (never one that looks like
it holds a key) and flags the copy until it is committed. Every other script they call is already in tools/.
If the scratchpad is ever lost, copy these files back into it. Do not edit them here: the scratchpad versions are the live ones.
