$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# MACHINE AND PILLAGER AI AUDIT OF 2026-09-14, finding 2: A MACHINE'S CONTACT SHOUT RESTARTED OR CANCELLED A
# CRIER'S ALARM. When a sentry or crawler first spots the player it calls the pack, and packCall pulls in
# nearby sentries, crawlers and criers, skipping only those already in chase. A crier winding up its alarm
# is in state alarm, so it was overwritten to chase: if it still saw the player its next sighting started
# a fresh 3 to 4 second alarm, with the warning and sound again, and every further machine that spotted
# the player reset it again; if the player had just broken sight, the alarm was dropped at once instead of
# after three hidden seconds. A crier already raising its alarm is left to finish it.
SubRx @'
    if(e.state==='chase') continue;                  // already in it
'@ @'
    if(e.state==='chase'||e.state==='alarm') continue;   // already in it; v13.97, AI audit: a crier raising its alarm keeps its countdown
'@
SubRx @'
var VER='13.96';
'@ @'
var VER='13.97';
'@

$pat = "(?m)^  now:'v13\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.97: A PACK CALL DOES NOT RESET A CRIER ALARM. Machine and pillager AI audit of 2026-09-14, finding 2: packCall pulled nearby sentries, crawlers and criers into chase and skipped only those already chasing, so a crier winding up its alarm was overwritten to chase, restarting its 3 to 4 second countdown on its next sighting or dropping the alarm at once if sight was broken, and every machine that spotted the player reset it again. A crier in alarm now keeps its countdown. Check 13.97 calls the pack beside a crier with half a second of alarm left and requires it still in alarm with the same wind, with a patrolling crier joining the call as the control; it fails on v13.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
