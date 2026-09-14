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

SubRx @'
  var rtOn=!PAD.aSpent&&!G.over&&!G.paused&&pressed(0);
'@ @'
  // v14.24, controller audit finding 6: A DOES NOT FIRE UNDER THE OPEN MAP OR BACKPACK. The mouse path never lets a click on
  // the map or on the backpack panel reach the trigger, but A did: D-UP then A fired the gun, and in the backpack A on an
  // item fired it, or cooked and threw a frag with a grenade cell selected.
  var rtOn=!PAD.aSpent&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&pressed(0);
'@
SubRx @'
var VER='14.23';
'@ @'
var VER='14.24';
'@

$pat = "(?m)^  now:'v14\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.24: A DOES NOT FIRE UNDER THE OPEN MAP OR BACKPACK. A click on the map or the backpack panel never reaches the trigger, but pad A did: with the map open it fired the gun, and in the backpack it fired or cooked and threw a selected frag. The pad trigger is now off while either is open. Check 14.24 holds A with the map open, then the backpack open, with a faked pad, and fires with both shut as the control; it fails on v14.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
