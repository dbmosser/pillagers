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
    if(kept.length&&(P.equippedSec||'none')===P.equipped)
      P.equippedSec=(kept.length>1&&kept[1].id!==P.equipped)?kept[1].id:'none';
'@ @'
    if(kept.length&&(P.equippedSec||'none')===P.equipped)
      P.equippedSec=(kept.length>1&&kept[1].id!==P.equipped)?kept[1].id:'none';
    // v14.79, gun audit finding 2: AN EXTRACTION LEAVES BOTH SLOTS ON GUNS HE OWNS. Only the collision above was repaired here.
    // A gun put in the backpack from its belt key leaves the armoury, and if it was then dropped or given away he extracted
    // empty-handed with gun 1 still naming it: the sector page and the ascent check said it was going up, a raid handed him a
    // loaner, and a gun bought next did not go into his hand. The death branch's two ownership repairs, applied here too.
    if(P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
    if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
    if((P.equippedSec||'none')===P.equipped) P.equippedSec='none';
'@
SubRx @'
var VER='14.78';
'@ @'
var VER='14.79';
'@

$pat = "(?m)^  now:'v14\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.79: AN EXTRACTION LEAVES BOTH GUN SLOTS ON GUNS HE OWNS. A gun put in the backpack from its belt key leaves the armoury, and dropped or given away it left gun 1 naming a gun he no longer owned after an extraction, so the sector page promised it and the next raid handed out a loaner. Extraction now repairs both slots the way a death does. Check 14.79 puts gun 1 away, drops it and extracts; it fails on v14.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
