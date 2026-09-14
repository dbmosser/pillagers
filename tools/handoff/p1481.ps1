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
    if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&
       P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
'@ @'
    if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&
       P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
    // v14.81, gun audit finding 3: AND THE TWO SLOTS NEVER NAME ONE GUN. Gun 1 is refilled from the first gun on the list, which
    // can be the gun already in gun 2, and buildRaid then leaves gun 2 empty while the armoury menu calls both slots taken.
    if((P.equippedSec||'none')===P.equipped) P.equippedSec='none';
'@
SubRx @'
var VER='14.80';
'@ @'
var VER='14.81';
'@

$pat = "(?m)^  now:'v14\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.81: AFTER A DEATH THE TWO GUN SLOTS NEVER NAME ONE GUN. Gun 1 was refilled from the first gun he still owned, which could be the gun in gun 2, so both slots named it, the next raid left gun 2 empty and the armoury menu called both slots taken. Gun 2 is now emptied when that happens. Check 14.81 dies with that armoury; it fails on v14.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
