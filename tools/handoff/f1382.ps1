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
  {v:'13.81',what:
'@ @'
  {v:'13.82',what:'a burst stops when its gun leaves your hand: a Burst Carbine burst followed at once by a swap to the Magnum leaves the Magnum with all 6 rounds and charges the carbine one, while the same burst with no swap spends three (combat and player state audit 2026-09-14, finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof fireWeapon!=='function'||typeof swapGuns!=='function'||typeof updateThrowables!=='function'||!WEAPONS.carbine||!(WEAPONS.carbine.burst>1)||!WEAPONS.magnum) return 'SKIP: no burst gun in this build';
     var bad=[];
     function copyW(id){ var w={},k; for(k in WEAPONS[id]) w[k]=WEAPONS[id][k]; return w; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.bullets.length=0;
       function arm(){
         g.throws=g.throws.filter(function(t){ return !t.burstEcho; });
         p.wep=copyW('carbine'); p.ammo=24; p.wepIssued=false; p.wepFromArmory=false;
         p.sec=copyW('magnum'); p.secAmmo=6; p.secIssued=false; p.secFromArmory=false;
         p.roll=0; p.reloading=0; p.downed=false; p.dying=false; p.swapped=false; p.cooking=0;
       }
       function burst(){ p.ammo--; fireWeapon(p,p.wep,p.x+100,p.y,true); }
       // THE FINDING: burst, then swap to the Magnum at once.
       arm(); burst();
       if(!swapGuns()) return 'SKIP: the swap to the Magnum was refused';
       for(var f=0;f<3;f++) updateThrowables(0.05);
       var mag=(p.wep&&p.wep.id==='magnum')?p.ammo:(p.sec&&p.sec.id==='magnum'?p.secAmmo:-1);
       var car=(p.wep&&p.wep.id==='carbine')?p.ammo:(p.sec&&p.sec.id==='carbine'?p.secAmmo:-1);
       if(mag!==6) bad.push('swapping to the Magnum mid-burst took '+(6-mag)+' of its rounds for the carbine burst');
       if(car!==23) bad.push('the carbine was left with '+car+' after a burst it was allowed to fire one round of');
       // CONTROL: no swap, the burst spends three carbine rounds.
       arm(); burst();
       for(var f2=0;f2<3;f2++) updateThrowables(0.05);
       if(p.ammo!==21) bad.push('control: an unswapped burst left the carbine with '+p.ammo+', not 21, so this check cannot see the later rounds');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.bullets.length=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
