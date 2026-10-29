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

# RELOAD CHAIN ENDS ON GUN SWITCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function activeReloadTick(p){
'@ @'
// v28.xx (cw-cx-reloadswitch), HIS WORDS (2026-10-28): "Active reload chain should also break if player switches guns".
// v28.xx (cw-cx-reloadswitch): every held-gun assignment uses this door; reset only this player before the status reads it.
function arSetHeldGun(p,w){
  if(p.wep!==w){ p.arStk=0; p.arBonus=0; p.arGun=null; p.arHot=0; }
  p.wep=w;
}
function activeReloadTick(p){
'@

SubRx @'
p.wep=nw; p.wepIssued=false;
'@ @'
arSetHeldGun(p,nw); p.wepIssued=false;
'@

SubRx @'
g.player.wep=WEAPONS[FREEKIT_GUN];
'@ @'
arSetHeldGun(g.player,WEAPONS[FREEKIT_GUN]);
'@

SubRx @'
g.player.wep=rollFieldGun('rifle'); g.player.ammo=g.player.wep.mag;
'@ @'
arSetHeldGun(g.player,rollFieldGun('rifle')); g.player.ammo=g.player.wep.mag;
'@

SubRx @'
p.wep=found; p.ammo=
'@ @'
arSetHeldGun(p,found); p.ammo=
'@

SubRx @'
p.wep=p.sec||WEAPONS.fists; p.ammo=
'@ @'
arSetHeldGun(p,p.sec||WEAPONS.fists); p.ammo=
'@

SubRx @'
pp.wep=pp.sec; pp.ammo=
'@ @'
arSetHeldGun(pp,pp.sec); pp.ammo=
'@

SubRx @'
else { p.wep=g; p.ammo=_rd;
'@ @'
else { arSetHeldGun(p,g); p.ammo=_rd;
'@

SubRx @'
if(hand){ p.wep=nc; p.ammo=carry;
'@ @'
if(hand){ arSetHeldGun(p,nc); p.ammo=carry;
'@

SubRx @'
p.wep=arcadeGun(a); p.sec=
'@ @'
arSetHeldGun(p,arcadeGun(a)); p.sec=
'@

SubRx @'
// 10.1, 7.6, then 5.7 percent of the reload). A press outside the sweet spot, or a reload left to run out on its own, starts the chain over and the spot is wide again; a swap that
'@ @'
// 10.1, 7.6, then 5.7 percent of the reload). A press outside the sweet spot, or a reload left to run out on its own, starts the chain over and the spot is wide again.
'@

SubRx @'
// cuts a reload short keeps it. The chain lives on the player (p.arStk), so in co-op each pillager has their own; the ring, the bar and X on a pad all read arLo and arHi. Live play only.
'@ @'
// v28.xx (cw-cx-reloadswitch): changing the held gun also ends the chain, including a swap that cuts a reload short. Each pillager owns their own chain.
'@

SubRx @'
// v28.xx (cw-cx-reloadstatus): a chain survives a swap or an empty magazine; only claim damage while the bonus applies.
'@ @'
// v28.xx (cw-cx-reloadswitch): an empty magazine keeps the chain; a held-gun change clears it before this status reads it.
'@

SubRx @'
var VER='36.22';
'@ @'
var VER='36.23';
'@

$pat = "(?m)^  now:'v36\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.23: switching guns ends the active reload chain Check 36.23 fails on v36.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
