$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# A CRIER GOES BACK ON PATROL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        if(e.cd>0) e.cd-=dt;
        else { var spn=freeSpot(G.map,24); e.tx=spn.x; e.ty=spn.y; e.cd=rnd(3,6); }
'@ @'
        // v22.25, from the whole-game bug hunt of 2026-10-08 (K36): A CRIER GOES BACK ON PATROL WHEN IT PICKS ITS NEXT POINT. A noise,
        // a pack call or a blast put it in 'investigate' or 'chase', and this branch only ever ends an alarm, so it wandered for the
        // rest of the raid with a '?' or a red mark, counted as coming for the ring, and never walked out of a house (the v9.04 rule
        // runs on patrol only). It still walks that one leg to the noise; arriving there or its clock running out ends it. No draw is
        // added and the reroll stays on the same frame.
        if(e.cd>0) e.cd-=dt;
        else { if(e.state!=='patrol') e.state='patrol'; var spn=freeSpot(G.map,24); e.tx=spn.x; e.ty=spn.y; e.cd=rnd(3,6); }
'@

SubRx @'
var VER='22.24';
'@ @'
var VER='22.25';
'@

$pat = "(?m)^  now:'v22\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.25: A Crier that heard something goes back on patrol once it has looked, and walks out of houses again. Check 22.25 fails on v22.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
