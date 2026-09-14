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
  {v:'14.79',what:
'@ @'
  {v:'14.80',what:'two of the same gun are two guns lost: a field SMG in hand beside his own armoury SMG in gun 2, a death takes the SMG off the armoury list (gun audit finding 1)',
   run:function(){
     if(typeof equipFromBag!=='function'||typeof endRaid!=='function'||!window.__startRaid||!window.__applyLoaded||!ITEMS.gun_smg||!WEAPONS.pistol) return 'SKIP: no equip from the backpack or loader in this build';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.weapons=['pistol','smg']; q.equipped='pistol'; q.equippedSec='smg'; q.freeKit=0;
       __startRaid({mapIx:0,seed:4242});
       var pl=G&&G.player;
       if(!pl||!pl.sec||pl.sec.id!=='smg'||!pl.secFromArmory) return 'SKIP: the raid did not put his armoury SMG in gun 2';
       pl.swapped=false;
       G.bag.push('gun_smg');
       equipFromBag(G.bag.indexOf('gun_smg'),1);
       // CONTROL: a field SMG in hand and his armoury SMG in gun 2.
       if(!(pl.wep&&pl.wep.id==='smg'&&!pl.wepFromArmory&&pl.sec&&pl.sec.id==='smg'&&pl.secFromArmory))
         return 'SKIP: equipping from the backpack did not leave that pair ('+(pl.wep&&pl.wep.id)+' '+pl.wepFromArmory+' / '+(pl.sec&&pl.sec.id)+' '+pl.secFromArmory+')';
       G.tel.deathKiller='timer'; endRaid('dead');
       if(__P().weapons.indexOf('smg')>=0) bad.push('he died carrying his own armoury SMG in gun 2 and it is still on the armoury list ('+__P().weapons.join(',')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
