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

# A GUN SWAPPED IN DURING A RELOAD STARTS ITS OWN RELOAD RING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  pp.reloading=0; pp.fired=true; pp.lastShot=G.t*1000; pp.swapT=G.t;
'@ @'
  // v28.55 (cloud-feel-reload-swap-ring), CLOUD HUNT 2026-10-15: the swap stopped the reload but kept the old gun's ring length (rlTot), so an
  // empty gun swapped in with the trigger held measured its new reload against the old one and the ring opened past its sweet spot.
  pp.reloading=0; pp.rlTot=0; pp.rlArm=0; pp.fired=true; pp.lastShot=G.t*1000; pp.swapT=G.t;
'@

SubRx @'
        p.wep=found; p.ammo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false; p.reloading=0;   // v13.81
'@ @'
        p.wep=found; p.ammo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; p.rlTot=0; p.rlArm=0;   // v13.81; v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@

SubRx @'
    p.wep=p.sec||WEAPONS.fists; p.ammo=p.secAmmo||0; p.wepIssued=!!p.secIssued; p.wepFromArmory=!!p.secFromArmory; p.reloading=0;
'@ @'
    p.wep=p.sec||WEAPONS.fists; p.ammo=p.secAmmo||0; p.wepIssued=!!p.secIssued; p.wepFromArmory=!!p.secFromArmory; p.reloading=0; p.rlTot=0; p.rlArm=0;   // v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@

SubRx @'
  else { p.wep=g; p.ammo=_rd; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; }
'@ @'
  else { p.wep=g; p.ammo=_rd; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; p.rlTot=0; p.rlArm=0; }   // v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@

SubRx @'
  if(hand){ p.wep=nc; p.ammo=carry; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; G.tel.weapon=nc.name; }
'@ @'
  if(hand){ p.wep=nc; p.ammo=carry; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; p.rlTot=0; p.rlArm=0; G.tel.weapon=nc.name; }   // v28.55 (cloud-feel-reload-swap-ring): the reload ring starts over for the gun now in hand
'@

SubRx @'
var VER='28.54';
'@ @'
var VER='28.55';
'@

$pat = "(?m)^  now:'v28\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.55: Swapping to an empty gun while reloading starts its reload ring from the beginning. Check 28.55 fails on v28.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
