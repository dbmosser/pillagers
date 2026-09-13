$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HARNESS REPAIR: CHECK 13.33 LISTENED TO A LIVE RAID.
#
# The v13.34 corpus failed 13.33 with "a third line queued behind the second was lost",
# shown: first line | second line | A crier has you. Kill it or move. | The Crier raised
# the alarm... | A crier has you... The check starts a raid on a random seed and steps
# twelve seconds of real frames with the player parked, and on this run a crier reached
# him. Its lines go through plain say(), which writes over whatever shows and resets the
# clock, so the third queued line was still waiting when the stepping stopped. It passed
# its three gate runs and the whole v13.33 corpus, so it depends on the seed, which is
# the defect in the check.
#
# The machines are removed once landing has settled, the way other checks empty
# g.ents before measuring, so nothing else speaks while the queue is measured. The
# control on v13.32 is unaffected: that build has no queue and its direct say() loses
# the first two lines whatever the machines do.
#
# NOT A GAME FIX, AND NOTED: a queued line waits as long as other messages keep the
# line busy, so a crier alarm repeating in a fight can hold the rival warning back.
# Urgent combat lines going first is arguably right; it is recorded, not changed.
SubRx @'
       for(i=0;i<420;i++){ __loop(t0+(++f)*16.7); }
       G2.msgQ=[]; G2.msgT=0;
'@ @'
       for(i=0;i<420;i++){ __loop(t0+(++f)*16.7); }
       // r1334b: nothing else may speak while the queue is measured. A live crier on
       // one seed kept the line busy past the stepping window.
       G2.ents.length=0;
       G2.msgQ=[]; G2.msgT=0;
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
