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
  {v:'14.78',what:
'@ @'
  {v:'14.79',what:'an extraction leaves both gun slots on guns you own: gun 1 put in the backpack from its belt key, dropped, and an empty-handed extraction leaves gun 1 on a gun you own or none (gun audit finding 2)',
   run:function(){
     if(typeof bagHeldGun!=='function'||typeof dropItem!=='function'||typeof endRaid!=='function'||!window.__startRaid||!window.__applyLoaded||!ITEMS.gun_smg) return 'SKIP: no belt drop, drop or loader in this build';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.weapons=['smg']; q.equipped='smg'; q.equippedSec='none'; q.freeKit=0;
       __startRaid({mapIx:0,seed:4242});
       var pl=G&&G.player;
       // CONTROL: gun 1 is his SMG out of the armoury.
       if(!pl||!pl.wep||pl.wep.id!=='smg'||!pl.wepFromArmory) return 'SKIP: the raid did not put his armoury SMG in gun 1 ('+(pl&&pl.wep&&pl.wep.id)+')';
       pl.swapped=false;
       if(!bagHeldGun('gunA')) return 'SKIP: the SMG would not go in the backpack here';
       var bi=G.bag.indexOf('gun_smg'); if(bi<0) return 'SKIP: the SMG is not in the backpack';
       dropItem(bi);
       if(__P().weapons.indexOf('smg')>=0||G.bag.indexOf('gun_smg')>=0) return 'SKIP: the SMG is still owned or carried after the drop';
       endRaid('extract');
       var r=__P();
       if(r.equipped!=='fists'&&r.weapons.indexOf(r.equipped)<0) bad.push('after extracting without it, gun 1 still names the '+r.equipped+', which he no longer owns (armoury: '+r.weapons.join(',')+')');
       if(r.equippedSec&&r.equippedSec!=='none'&&r.equippedSec!=='fists'&&r.weapons.indexOf(r.equippedSec)<0) bad.push('gun 2 names the '+r.equippedSec+', which he does not own');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
