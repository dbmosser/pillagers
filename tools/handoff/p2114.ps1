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

# A GUN PUSHED OUT OF A SLOT GOES IN YOUR BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    else if(oldArm&&P.weapons.indexOf(oldW.id)>=0) _oldLine=oldW.name+' is yours; it goes back to the armoury.';
'@ @'
    // v21.14, HIS REPORT (2026-10-08): "i moved a gun to spot 2 and my meridian lance that was in the spot DISAPPEARED -- not in my
    // backpack either". A gun from his armoury that a backpack gun pushed out of a slot was sent back to the armoury mid raid (the
    // v8.32 rule against a second copy), so it left his hands and never reached his backpack, and the line saying so was written
    // over. It now goes into the backpack with its rounds and comes off the armoury list as a carried gun, exactly as picking a
    // gun up into the backpack does (bagHeldGun, v14.03): no second copy, lost on a death, home on an extraction or an abandon.
    else if(oldArm&&ITEMS['gun_'+oldW.id]){
      G.bag.push('gun_'+oldW.id); stowRounds(oldW.id,toSec?p.secAmmo:p.ammo);
      if(!G.sim){ var _swi=P.weapons.indexOf(oldW.id); if(_swi>=0){ P.weapons.splice(_swi,1); (G.spliced=G.spliced||[]).push(oldW.id); (P.raidSpliced=P.raidSpliced||[]).push(oldW.id); } }
      _oldLine=oldW.name+' into the backpack.';
    }
    else if(oldArm&&P.weapons.indexOf(oldW.id)>=0) _oldLine=oldW.name+' is yours; it goes back to the armoury.';
'@

SubRx @'
var VER='21.13';
'@ @'
var VER='21.14';
'@

$pat = "(?m)^  now:'v21\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.14: A gun pushed out of a belt slot by another goes into your backpack. Check 21.14 fails on v21.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
