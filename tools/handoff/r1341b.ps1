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

# HARNESS REPAIR for v13.41: the sim-raiders roster control read the wrong number.
# Checks 11.25 and 11.24 said "the arms opened with N and M pillagers, so the seeded
# stream moved", but timeline[0] is sampled at 60 s and counts wave arrivals. Which arm
# gets a wave by 60 s depends on who dies first, and v13.41 changed early routes by
# taking the deck edges out, so v13.41 read 7 and 8 while v13.40 read equal. The build
# itself did not move: the control now compares the roster as built (roster0).
SubRx @'
  var live={mach:CFG.machVsRaider, feud:CFG.raiderFeud, greed:CFG.simGreed, sim:!!G.sim};
'@ @'
  var roster0=(G.roster||[]).length;   // r1341b: the roster as built, before any wave
  var live={mach:CFG.machVsRaider, feud:CFG.raiderFeud, greed:CFG.simGreed, sim:!!G.sim};
'@
SubRx @'
outAt:outAt, timeline:tl};
'@ @'
outAt:outAt, timeline:tl, roster0:roster0};
'@
SubRx @'
     if(g6.timeline.length&&g0.timeline.length&&g6.timeline[0][1]!==g0.timeline[0][1]) bad.push('control: the arms opened with '+g6.timeline[0][1]+' and '+g0.timeline[0][1]+' pillagers, so the seeded stream moved');
'@ @'
     if(g6.roster0!==g0.roster0) bad.push('control: the arms were built with '+g6.roster0+' and '+g0.roster0+' pillagers, so the seeded stream moved');   // r1341b: the build, not the roster at 60 s
'@
SubRx @'
     if(on.timeline.length&&off.timeline.length&&on.timeline[0][1]!==off.timeline[0][1]) bad.push('control: the two arms opened with '+on.timeline[0][1]+' and '+off.timeline[0][1]+' pillagers, so the seeded stream moved');
'@ @'
     if(on.roster0!==off.roster0) bad.push('control: the two arms were built with '+on.roster0+' and '+off.roster0+' pillagers, so the seeded stream moved');   // r1341b: the build, not the roster at 60 s
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
