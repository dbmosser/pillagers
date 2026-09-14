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
function hubBagState(){
  var wep=WEAPONS[P.equipped]||WEAPONS.fists;
'@ @'
function hubBagState(){
  // v14.87, belt audit finding 4: THE UNDERCROFT BELT COUNTS WHAT GOES UP. Its pouch was empty, so a Frag key over three packed
  // Frags drew greyed with 0 while the stash row said x3 and the raid carried three, and with no second gun a key on gun 2 was
  // skipped and slot 2 read Second weapon. The pouch counts the packed grenades and gun 2 is the equipped second gun.
  var wep=WEAPONS[P.equipped]||WEAPONS.fists, sec=(P.equippedSec&&P.equippedSec!==P.equipped&&WEAPONS[P.equippedSec])||WEAPONS.fists, pq={smoke:0,decoy:0,frag:0};
  (P.kit||[]).forEach(function(k){ if(pq[k]!==undefined) pq[k]++; });
'@
SubRx @'
    bagOpen:true, over:false, sim:0, t:0, pouch:{},
'@ @'
    bagOpen:true, over:false, sim:0, t:0, pouch:pq,
'@
SubRx @'
    player:{wep:wep, ammo:(wep&&wep.mag)||0, hp:100, maxhp:100, armor:0, reserve:0, r:11}
'@ @'
    player:{wep:wep, ammo:(wep&&wep.mag)||0, sec:sec, secAmmo:sec.mag||0, hp:100, maxhp:100, armor:0, reserve:0, r:11}
'@
SubRx @'
var VER='14.86';
'@ @'
var VER='14.87';
'@

$pat = "(?m)^  now:'v14\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.87: THE UNDERCROFT BELT COUNTS WHAT GOES UP. The belt drawn in the Undercroft had an empty pouch, so a key on three packed Frags read 0 and greyed while the stash row said x3, and a key on gun 2 was skipped. The pouch now counts packed grenades and gun 2 is the equipped second gun. Check 14.87 draws that belt with three Frags packed; it fails on v14.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
