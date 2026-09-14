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

# RAID HUD AND MAP SCREEN AUDIT OF 2026-09-15, finding 6: PICKING THE EMPTY SECOND-GUN SLOT ALWAYS SHOWED "Second weapon x0"
# INSTEAD OF ITS EXPLANATION. setHot says "No second weapon. Drag one here to carry it." for the vacant cell, but does not mark
# that it has hinted, so the generic cell line further down wrote "Second weapon  x0" over it in the same call. say() holds one
# line, so the explanation was never on screen. The vacant cell's line now counts as the hint.
SubRx @'
  if(s2.vacant){ if(!G.sim) say('No second weapon. Drag one here to carry it.'); }
'@ @'
  if(s2.vacant){ if(!G.sim) say('No second weapon. Drag one here to carry it.'); _hinted=true; }   // v14.09, HUD audit: not written over by the cell line below
'@
SubRx @'
var VER='14.08';
'@ @'
var VER='14.09';
'@

$pat = "(?m)^  now:'v14\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.09: THE EMPTY SECOND-GUN SLOT SAYS HOW TO FILL IT. Raid HUD and map screen audit of 2026-09-15, finding 6: setHot said No second weapon. Drag one here to carry it. for the vacant cell but did not mark the hint given, so the generic cell line wrote Second weapon x0 over it in the same call and the explanation never showed. The vacant line now counts as the hint. Check 14.09 selects the empty second slot with one gun carried and requires the message to be the explanation, with a probe line reaching the message as the control; it fails on v14.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
