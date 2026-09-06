$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# START-HERE: record the folded-in review, placed after the queue list so
# fixstate.ps1 (which rewrites the STATE block up to the queue heading) never
# swallows it. Idempotent.
$f = 'C:\claudecode\dark raiders\tools\handoff\START-HERE.md'
$s = [IO.File]::ReadAllText($f)
$marker = '**A READ-ONLY REVIEW OF DRAFTS 1180 TO 1193'
if ($s.IndexOf($marker) -ge 0) { Write-Output 'START-HERE: review already recorded'; exit 0 }
$anchor = '**DRAFTED THIS MORNING (about 07:20),'
$c = ([regex]::Matches($s, [regex]::Escape($anchor))).Count
if ($c -ne 1) { throw ('anchor matched ' + $c + ' times') }
$nl = if ($s.IndexOf("`r`n") -ge 0) { "`r`n" } else { "`n" }
$para = '**A READ-ONLY REVIEW OF DRAFTS 1180 TO 1193 (workflow wf_27344e1d-0ec, 14 agents, Read/Grep/Glob only) FOUND 30 DEFECTS AND ALL ARE FOLDED IN** by fixdrafts1/2/3.ps1 (drafts), fix1180b/c.ps1 (the v11.80 tree delta) and fixd1180.ps1 (its DESIGN entry); every script is idempotent and already applied, do NOT re-run them. The biggest: 1180 slowed the cut (re-asserted last) and gave a false reason deaths never hummed; 1184 counted a piercing round as N hits (accuracy over 100 percent); 1186 said "gave you" on a death card; 1189 flipped the slot map with no gun in hand; 1190 pointed the highlight at a blanked cell (trigger dead); 1191 left the keydown copy of the gate; 1192 poisoned the profile and left the pocket in the right-click menu; 1193 missed the lift question, dead keys and the death restore; 1183 froze the stim clock during rolls; 1187 walked backwards and lost its count. All thirteen repaired checks (11.81 to 11.93) run green twice on the :8801 dry fixture at v11.93. A finding is acted on only after reading the quoted lines yourself; these were.' + $nl + $nl
$s = $s.Replace($anchor, $para + $anchor)
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'START-HERE: review recorded after the queue'
