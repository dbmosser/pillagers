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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P3), specced from the source.
#
# A pillager's gun, his damage and his engagement range are one thing in three
# fields, and the file says so twice. The elite blessing moves all three, and a
# man who picks a gun out of a kit moves all three, and the comment beside one
# of them spells out why: an elite with a Longshot that kept an SMG's
# engagement range would read as broken.
#
# The imported ghost is the one re-gun that moves only the gun. So a ghost whose
# body rolled an Auto Rifle and whose report says he favoured the Riot
# Scattergun opens fire at 374 units with a gun whose rounds die at 260: every
# round fired in that band is thrown away short. The other way round, a
# Longshot ghost on a Compact SMG body never engages past 259 and the 580 cap
# never binds.
SubRx @'
if(WEAPONS[P.ghost.wep]) e.wep=(WEAPONS[P.ghost.wep].mag===0)?WEAPONS.pistol:WEAPONS[P.ghost.wep];
'@ @'
    // v12.55, 2026-09-07 audit: THE RANGE COMES WITH THE GUN. A gun, its damage
    // and its engagement range are one thing in three fields, and both other
    // re-gun paths move all three with the same 580 cap; this one moved only the
    // gun. So a ghost whose body rolled a long gun and whose report says he
    // favoured a short one opened fire at the body range and every round in that
    // band died short of the target, and the reverse never engaged at all past
    // the body range. Same two lines the kit path uses, so there is now one rule.
    if(WEAPONS[P.ghost.wep]){
      e.wep=(WEAPONS[P.ghost.wep].mag===0)?WEAPONS.pistol:WEAPONS[P.ghost.wep];
      e.dmg=e.wep.dmg; e.rng=Math.min(e.wep.rng*0.72,580);
    }
'@

# NEW IN.
SubRx @'
  'A PILLAGER CALLING EXTRACTION NOW SIZES THE SIEGE ON THE BAG YOU ARE ACTUALLY HOLDING. His call kept whatever figure your own earlier call at that point had left behind, so riding out on him could bring the siege your bag from half an hour ago deserved.',
'@ @'
  'A PILLAGER CALLING EXTRACTION NOW SIZES THE SIEGE ON THE BAG YOU ARE ACTUALLY HOLDING. His call kept whatever figure your own earlier call at that point had left behind, so riding out on him could bring the siege your bag from half an hour ago deserved.',
  'AN IMPORTED GHOST FIGHTS AT HIS OWN GUN RANGE. He was handed the gun from the report he came out of but kept the engagement range of the body he arrived in, so he opened fire at a distance his rounds could not cross, or refused to open fire at one they could.',
'@

# STAMPS.
SubRx @'
var VER='12.54';
'@ @'
var VER='12.55';
'@
SubRx @'
var WHATSNEW_VER='12.54';
'@ @'
var WHATSNEW_VER='12.55';
'@
$cnt=([regex]::Matches($s,"now:'v12\.54:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.54 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.54:[^']*'",{ param($m) "now:'v12.55: 2026-09-07 audit (P3). A pillagers gun, his damage and his engagement range are one thing held in three fields, and the file says so twice: the elite blessing moves all three, a man who picks a gun out of a kit moves all three, and the comment beside one of them spells out why, that an elite with a Longshot keeping an SMG engagement range would read as broken. The imported ghost is the one re-gun that moved only the gun. So a ghost whose body rolled an Auto Rifle and whose report says he favoured the Riot Scattergun opened fire at 374 units with a gun whose rounds die at 260, and every round fired in that band was thrown away short; the other way round a Longshot ghost on a Compact SMG body never engaged past 259 and the 580 cap never bound. The same two lines the kit path already uses, so there is one rule now. Check 12.55 imports a ghost whose favourite gun is not the gun his body rolled and requires his engagement range and his damage to have moved with it, with a control that a ghost imported onto a body already carrying that same gun is left exactly as he was; fails on v12.54.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
