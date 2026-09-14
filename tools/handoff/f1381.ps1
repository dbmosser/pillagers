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
  {v:'13.80',what:
'@ @'
  {v:'13.81',what:'a dropped gun comes back with its own rounds: an emptied Burst Carbine bagged, dropped and picked up from its crate creates no rounds, while a carbine found in an ordinary crate still arrives with half a magazine (combat and player state audit 2026-09-14, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof bagHeldGun!=='function'||typeof dropItem!=='function'||typeof openContainer!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function'||!WEAPONS.carbine||!ITEMS.gun_carbine) return 'SKIP: no gun bagging or crates in this build';
     var bad=[];
     function copyW(id){ var w={},k; for(k in WEAPONS[id]) w[k]=WEAPONS[id][k]; return w; }
     function rounds(g){ var p=g.player, S=(p.ammo||0)+(p.secAmmo||0)+(p.reserve||0), m=g.stowAmmo||{}, k, i; for(k in m) for(i=0;i<m[k].length;i++) S+=(m[k][i]|0); return S; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.bag=[]; g.hotAssign={}; g.hotAuto={}; g.stowAmmo={};
       p.downed=false; p.dying=false; p.iv=99; p.reloading=0; p.swapped=false;
       p.wep=WEAPONS.fists; p.ammo=0; p.wepIssued=true; p.wepFromArmory=false; p.reserve=0;
       p.sec=copyW('carbine'); p.secAmmo=0; p.secIssued=false; p.secFromArmory=false;
       // THE FINDING: an empty carbine, bagged, dropped and picked up again.
       if(!bagHeldGun('gunB')) return 'SKIP: the belt would not bag the carbine';
       var ix=g.bag.indexOf('gun_carbine');
       if(ix<0) return 'SKIP: the carbine did not reach the backpack';
       var S0=rounds(g);
       dropItem(ix);
       var crate=g.containers[g.containers.length-1];
       if(!crate||!crate.dropped) return 'SKIP: dropping made no dropped crate';
       openContainer(crate,['gun_carbine']);
       var up=(p.sec&&p.sec.id==='carbine')||(p.wep&&p.wep.id==='carbine');
       if(!up) return 'SKIP: the carbine was not equipped from the crate, so there is no refill to measure';
       var S1=rounds(g);
       if(S1>S0) bad.push('an empty carbine dropped and picked up came back with '+(S1-S0)+' rounds that did not exist');
       // CONTROL: a carbine found in an ordinary crate arrives with half a magazine.
       if(!bagHeldGun(p.sec&&p.sec.id==='carbine'?'gunB':'gunA')) return bad.length?bad.join('; '):'SKIP: could not bag the carbine again for the control';
       g.bag=[]; g.stowAmmo={};
       var box=setLoot(mkContainer(p.x+6,p.y+6,'crate'),['gun_carbine']);
       g.containers.push(box);
       openContainer(box,['gun_carbine']);
       var got=(p.sec&&p.sec.id==='carbine')?p.secAmmo:((p.wep&&p.wep.id==='carbine')?p.ammo:-1);
       if(got!==Math.ceil(WEAPONS.carbine.mag/2)) bad.push('control: a carbine found in an ordinary crate arrived with '+got+' rounds, not half a magazine');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
