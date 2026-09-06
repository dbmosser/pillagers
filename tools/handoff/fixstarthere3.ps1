$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# START-HERE: the five follow-up builds from the shipped-code review join the
# queue after 1193. Placed after the review paragraph, which sits after the
# queue list and outside fixstate.ps1's rewrite range. Idempotent.
$f = 'C:\claudecode\dark raiders\tools\handoff\START-HERE.md'
$s = [IO.File]::ReadAllText($f)
$marker = '**FIVE FOLLOW-UP BUILDS FROM THE REVIEW OF THE SHIPPED CODE'
if ($s.IndexOf($marker) -ge 0) { Write-Output 'START-HERE: follow-ups already recorded'; exit 0 }
$anchor = '**DRAFTED THIS MORNING (about 07:20),'
$c = ([regex]::Matches($s, [regex]::Escape($anchor))).Count
if ($c -ne 1) { throw ('anchor matched ' + $c + ' times') }
$nl = if ($s.IndexOf("`r`n") -ge 0) { "`r`n" } else { "`n" }
$para = '**FIVE FOLLOW-UP BUILDS FROM THE REVIEW OF THE SHIPPED CODE (workflow wf_b2fb5361-485, seven read-only agents over v11.74 to v11.80), DRAFTED AND QUEUED AFTER 1193, in this order:** 1194 a controller or the keyboard can craft again (v11.75 deleted the button click; a synthetic-only click returns, the hold dies when the trader window hides, tooltip reads CRAFT_HOLD, card drops the SERVICE sentence); 1195 the bench tells the truth about its guns (the Carbine is blue by dispR, one green and three blue; itemBlurb gun branch; detail pill via dispR; craftPart/craftUse know servo and optic; shop panel line; checks 11.79 and 9.43 repaired); 1196 the station heading balance is hidden under the enlarged readout (check 11.52 repaired, it double-scaled condTop); 1197 the bigger blast follow-ups (pillager throw band near edge follows the radius, cover warning covers the radius, card centre figures 140/98, check 11.44 sentinel unpinned); 1198 the sector map says EXTRACT NOW under a landed ring. Dry-run 1183 to 1198 from the tree VER+1 before shipping 1183 and run every new check twice on :8801. Lower findings from that review not built: 11.76 check wording ("the 1800 he asked for" is mine), 11.75 tooltip prose, 11.80 draft record (p1180 lacks the shipped second line; fix1180b/c partly applied), 11.78 DESIGN wording ("twice").' + $nl + $nl
$s = $s.Replace($anchor, $para + $anchor)
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'START-HERE: follow-ups recorded'
