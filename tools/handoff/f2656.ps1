$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'26.56',what:")) { throw "check 26.56 is in the fixture already" }

SubRx @'
  {v:'26.55',what:
'@ @'
  {v:'26.56',what:'feel11, his order: ACTIVE RELOAD. A fresh R inside the sweet spot of the reload finishes it at once and gives the next magazine 15 percent more damage; a press before or after the window, or R held from the start, does nothing and the reload goes on; the next reload ends the bonus; and the reload ring draws the sweet spot',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)) return 'SKIP: no raid here';
     var bad=[], g, p, all, oWep, oAmmo, oRes, oMx, oMy, tot, b, cap=[], proto, oArc, i, hit, a0, a1;
     function press(){ keys['KeyR']=true; __sim(0.016); keys['KeyR']=false; __sim(0.001); }
     function start(){ p.ammo=2; p.reserve=60; p.reloading=0; p.arBonus=0; p.rlTot=0; p.hand=false; press(); }
     function runTo(fr){ var n=0; while(p.reloading>0&&(1-p.reloading/tot)<fr&&n<400){ __sim(0.016); n++; } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; oRes=p.reserve; oMx=mouse.x; oMy=mouse.y;
       p.wep=cloneObj(WEAPONS.pistol); tot=p.wep.reload*buzzSlow(); keys['KeyR']=false;
       // ONE: a fresh R in the window finishes the reload and arms the bonus
       start(); if(!(p.reloading>0)) return 'SKIP: staging: R did not start a reload';
       runTo(0.5);
       if(!(p.reloading>0)) bad.push('ONE: the reload ended before the window');
       keys['KeyR']=true; __sim(0.016); keys['KeyR']=false;
       if(p.reloading>0) bad.push('ONE: R inside the sweet spot did not finish the reload ('+Math.round(p.reloading)+' ms left)');
       if(p.ammo!==p.wep.mag) bad.push('ONE: the magazine is '+p.ammo+', not full ('+p.wep.mag+')');
       if(!(p.arBonus>0)) bad.push('ONE: no active reload bonus was set');
       g.bullets.length=0; fireWeapon(p,p.wep,p.x+100,p.y,true); b=g.bullets[g.bullets.length-1];
       if(!b||Math.abs(b.dmg-p.wep.dmg*1.15)>0.01) bad.push('ONE: the next round did '+(b&&b.dmg)+', not '+(p.wep.dmg*1.15).toFixed(2));
       // the next reload ends the bonus
       p.ammo=3; p.reloading=0; p.rlTot=0; press();
       if(p.arBonus>0) bad.push('ONE: a new reload kept the bonus');
       g.bullets.length=0; fireWeapon(p,p.wep,p.x+100,p.y,true); b=g.bullets[g.bullets.length-1];
       if(!b||Math.abs(b.dmg-p.wep.dmg)>0.01) bad.push('ONE: a round after the bonus ended did '+(b&&b.dmg));
       // TWO: too early, too late: nothing, the reload goes on
       start(); runTo(0.12); press();
       if(!(p.reloading>0)) bad.push('TWO: R before the window finished the reload');
       runTo(0.8); press();
       if(!(p.reloading>0)) bad.push('TWO: R after the window finished the reload');
       i=0; while(p.reloading>0&&i<400){ __sim(0.016); i++; }
       if(p.ammo!==p.wep.mag) bad.push('TWO: the reload did not finish by itself ('+p.ammo+')');
       if(p.arBonus>0) bad.push('TWO: a missed window gave the bonus');
       // THREE: R held from the start never counts
       p.ammo=2; p.reserve=60; p.reloading=0; p.arBonus=0; p.rlTot=0; keys['KeyR']=true; __sim(0.016);
       runTo(0.5); __sim(0.016); __sim(0.016);
       if(!(p.reloading>0)) bad.push('THREE: holding R from the start finished the reload');
       keys['KeyR']=false; i=0; while(p.reloading>0&&i<400){ __sim(0.016); i++; }
       // FOUR: the ring draws the sweet spot
       start(); runTo(0.5); mouse.x=W/2; mouse.y=H/2;
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ render2D(0); drawHUD(); } finally { proto.arc=oArc; }
       a0=-1.5708+6.2832*AR_A; a1=-1.5708+6.2832*AR_B; hit=0;
       for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][3]-a0)<0.002&&Math.abs(cap[i][4]-a1)<0.002) hit++;
       if(!hit) bad.push('FOUR: the reload ring drew no sweet spot ('+cap.length+' arcs)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keys['KeyR']=false; if(p){ p.wep=oWep; p.ammo=oAmmo; p.reserve=oRes; p.reloading=0; p.arBonus=0; p.rlTot=0; } if(g&&all) g.ents=all.slice(); if(g) g.bullets.length=0; if(oMx!==undefined){ mouse.x=oMx; mouse.y=oMy; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
