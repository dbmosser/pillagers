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

# MARK LEGENDS AND OLD SAVE CHECKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(typeof NET==='object'&&NET&&NET.on){ if(padOn()) MN.push(['Y','drop to trade']); else MN.push(['V','drop to trade'],['N','ping']); }   /* v35.xx (cw-meleez): drop is on V */   // v18.27: his order, trading is dropping
'@ @'
    if(typeof NET==='object'&&NET&&NET.on){ if(padOn()) MN.push(['Y','drop to trade']); else MN.push(['V','drop to trade'],['N','mark']); }   /* v35.xx (cw-meleez): drop is on V */   // v18.27: his order, trading is dropping   // v28.xx (cw-cx-marklegacy): his single mark order also names the keyboard party row.
'@

SubRx @'
['D-UP','ping, hold: map']
'@ @'
['D-UP','mark, hold: map']
'@

SubRx @'
var VER='36.54';
'@ @'
var VER='36.55';
'@

$pat = "(?m)^  now:'v36\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.55: The compact party legends both say mark. Old saved keys remain unchanged. Regression checks stage independent mouse presses and cover all three views and both roles. Check 36.55 fails on v36.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
