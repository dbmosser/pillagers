$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# v11.34 adds no new fixture check: it makes the pause box satisfy the existing
# check v10.41 again. Nothing to change in tools/mkfixture.ps1.
Write-Output "OK, 0 edits applied (no new check for v11.34)"
