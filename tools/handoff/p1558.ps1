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
    if(kept.length) P.equipped=kept[0].id;
'@ @'
    // v15.58, first run audit finding: EXTRACTING WITH THE FREEBIE KIT KEEPS THE GUN YOU CHOSE IN GUN 1. The kit puts its Scav
    // Pistol in his hand not flagged issued, so that an extraction keeps it, and carriedGuns therefore lists it as a carried
    // gun: this line then put it in gun 1. A fresh player who chose Equip as your gun on the Compact SMG, as the loaner line
    // tells him to, took the kit, extracted, and was quietly moved off the SMG: the sector page said he was going up with the
    // Scav Pistol, and the next raid took his own armoury pistol up, where it wears and can be lost. A character on fists was
    // moved to the pistol the same way, undoing the v2.80 rolled starter that v2.82 keeps on the death path. What is New
    // promises that taking the kit does not change the gun he goes up with. The kit pistol is still kept exactly as before
    // (the loop above banks it); it is only never equipped, the way the death path already treats it as the kit's loaner
    // (_egFree): on a freebie raid, a gun of FREEKIT_GUN's id in either hand that did not come out of the armoury. A gun found
    // in the raid still takes gun 1 by the tier sort. This keeps his own choice; it is not a switch to a gun. No player text,
    // no number and no seeded draw moved.
    var _keq=kept.filter(function(w){ return !(G.freeKit&&w.id===FREEKIT_GUN&&((w===_kp.wep&&!_kp.wepFromArmory)||(w===_kp.sec&&!_kp.secFromArmory))); });
    if(_keq.length) P.equipped=_keq[0].id;
'@
SubRx @'
    if(kept.length&&(P.equippedSec||'none')===P.equipped)
      P.equippedSec=(kept.length>1&&kept[1].id!==P.equipped)?kept[1].id:'none';
'@ @'
    // v15.58, first run audit finding: AND THE KIT PISTOL NEVER FILLS GUN 2 EITHER. This repair read the raw list, so with his
    // own Burst Carbine in gun 2 and a field Carbine carried out beside the kit pistol, gun 1 became the Carbine by the tier
    // sort and this line put the kit pistol in gun 2. It reads the same filtered list as gun 1 now, so the slot takes another
    // gun he really carried or is honestly empty, the v12.38 rule.
    if(_keq.length&&(P.equippedSec||'none')===P.equipped)
      P.equippedSec=(_keq.length>1&&_keq[1].id!==P.equipped)?_keq[1].id:'none';
'@
SubRx @'
var VER='15.57';
'@ @'
var VER='15.58';
'@

$pat = "(?m)^  now:'v15\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.58: EXTRACTING WITH THE FREEBIE KIT KEEPS THE GUN YOU CHOSE IN GUN 1. Walking out of a raid on the freebie kit put its Scav Pistol in gun 1, so a Compact SMG you had equipped was quietly taken off and your next raid went up with your own pistol, where it can be lost, and a character with nothing in gun 1 was moved onto the pistol the same way. You still keep the kit pistol, but gun 1 and gun 2 now stay on what you chose, and a gun you find in the raid still takes gun 1 as before. Check 15.58 extracts on the freebie kit with the SMG in gun 1, with nothing in gun 1, and with a field Burst Carbine beside the kit pistol; it fails on v15.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
