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
  {v:'14.80',what:
'@ @'
  {v:'14.81',what:'after a death the two gun slots never name one gun: pistol in hand from the armoury, a field gun put in gun 2, a death refills gun 1 with the SMG and gun 2 does not also name it (gun audit finding 3)',
   run:function(){
     if(typeof equipFromBag!=='function'||typeof endRaid!=='function'||!window.__startRaid||!window.__applyLoaded||!WEAPONS.pistol||!WEAPONS.smg) return 'SKIP: no equip from the backpack or loader in this build';
     var field=null; for(var gk in WEAPONS) if(gk!=='fists'&&gk!=='pistol'&&gk!=='smg'&&ITEMS['gun_'+gk]){ field=gk; break; }
     if(!field) return 'SKIP: no third gun to find in a raid';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.weapons=['pistol','smg']; q.equipped='pistol'; q.equippedSec='smg'; q.freeKit=0;
       __startRaid({mapIx:0,seed:4242});
       var pl=G&&G.player;
       if(!pl||!pl.wep||pl.wep.id!=='pistol'||!pl.wepFromArmory) return 'SKIP: the raid did not put his pistol in hand';
       pl.swapped=false;
       G.bag.push('gun_'+field);
       equipFromBag(G.bag.indexOf('gun_'+field),2);
       if(!(pl.sec&&pl.sec.id===field&&pl.wep.id==='pistol')) return 'SKIP: the '+field+' did not go into gun 2 ('+(pl.wep&&pl.wep.id)+' / '+(pl.sec&&pl.sec.id)+')';
       G.tel.deathKiller='timer'; endRaid('dead');
       var r=__P();
       // CONTROL: the pistol was lost and gun 1 went to the SMG he still owns.
       if(r.weapons.indexOf('pistol')>=0||r.equipped!=='smg') return 'SKIP: the death did not leave the SMG as gun 1 here ('+r.weapons.join(',')+' / '+r.equipped+')';
       if((r.equippedSec||'none')===r.equipped) bad.push('after the death gun 1 and gun 2 both name the '+r.equipped);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
