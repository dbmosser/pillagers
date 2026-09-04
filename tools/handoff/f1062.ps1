$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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
  {v:'10.61',what:'the Undercroft plays slower, darker and softer: no bright square leading the tune, seventy-six a minute, a closed filter, half the shimmer and a held bass',
'@ @'
  {v:'10.62',what:'a found gun takes the empty weapon slot instead of turning out the gun in hand, and with both slots full it still replaces the one asked for',
   run:function(){
     var bad=[];
     if(!(window.__startRaid&&window.__equipBag&&window.__weapons&&window.__state)) return 'SKIP: this build cannot equip from the bag';
     __startRaid({seed:4242,mapIx:0});
     var G=__state(); if(!G||!G.player) return 'no raid';
     var p=G.player, W=__weapons();
     function mk(id){ var g={}; for(var k in W[id]) g[k]=W[id][k]; g.q='field'; g.qRank=1; return g; }
     function set(handId,secId){
       p.wep=mk(handId); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0;
       p.sec=mk(secId);  p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       G.bag.length=0;
     }
     // 1. HIS CASE. A pistol in hand, nothing in the second slot, a rifle found:
     //    the rifle takes the empty slot and the pistol stays where it is.
     set('pistol','fists');
     G.bag.push('gun_rifle');
     __equipBag(0,1);
     if(p.wep.id!=='pistol') bad.push('with the second slot empty, equipping a found rifle turned the Scav Pistol out of his hand (hand is now '+p.wep.name+')');
     if(p.sec.id!=='rifle') bad.push('the found rifle did not go to the empty second slot (it holds '+p.sec.name+')');
     if(G.bag.length) bad.push('the pistol was bagged anyway: the bag holds '+G.bag.join(','));
     // 2. The other way round: hands empty, a gun in the second slot, equip to slot 2.
     set('fists','smg');
     G.bag.push('gun_rifle');
     __equipBag(0,2);
     if(p.sec.id!=='smg') bad.push('with his hands empty, equipping to the second slot turned the SMG out (second is now '+p.sec.name+')');
     if(p.wep.id!=='rifle') bad.push('the found rifle did not go to the empty hand (it holds '+p.wep.name+')');
     // 3. BOTH FULL: the slot he asked for is the one that changes, which is the
     //    only way to choose, and the gun that leaves is bagged as before.
     set('pistol','smg');
     G.bag.push('gun_rifle');
     __equipBag(0,1);
     if(p.wep.id!=='rifle') bad.push('with both slots full, the gun he asked to equip did not go into his hand (it holds '+p.wep.name+')');
     if(p.sec.id!=='smg') bad.push('with both slots full, equipping to the hand also changed the second slot (it holds '+p.sec.name+')');
     if(G.bag.indexOf('gun_pistol')<0) bad.push('the gun he replaced was not bagged: the bag holds '+G.bag.join(','));
     // 4. Asking for a slot that is already empty still fills that slot.
     set('fists','smg');
     G.bag.push('gun_rifle');
     __equipBag(0,1);
     if(p.wep.id!=='rifle') bad.push('equipping into an empty hand did not fill it (it holds '+p.wep.name+')');
     if(p.sec.id!=='smg') bad.push('equipping into an empty hand disturbed the second slot (it holds '+p.sec.name+')');
     return bad.length?bad.join('; '):null; }},
  {v:'10.61',what:'the Undercroft plays slower, darker and softer: no bright square leading the tune, seventy-six a minute, a closed filter, half the shimmer and a held bass',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
