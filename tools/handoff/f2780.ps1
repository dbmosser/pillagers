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

if ($s.Contains("  {v:'27.80',what:")) { throw "check 27.80 is in the fixture already" }

SubRx @'
  {v:'27.79',what:
'@ @'
  {v:'27.80',what:'feel2b, his yes to the Halo Reach bloom, the pacing half: the moment the bloom a round opened has fully closed, the ring on the cursor flashes once (a contracting ring and four ticks, p.rstT), not while a spam keeps it open, never for a player who has not fired, and the flash is really drawn',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     var bad=[], g, p, all, oWep, oAmmo, oMx, oMy, w, q, t, seen, rstAt, n0, R0, R1, cap=[], proto, oArc, i;
     function wipe(){ p.bloom=0; p.bloomK=0; p.bloomPend=0; p.bloomQ=9; p.blmX=undefined; p.ads=false; p.roll=0; p.rstT=0; p.rstN=0; p.bloomArm=0; p.bloomPk=0; g.sprinting=false; g.pCrouch=false; }
     function ringR(){
       var k, mr=0;
       p.drawT=0; p.reloading=0; p.ammo=p.wep.mag; mouse.x=W/2; mouse.y=H/2; cap.length=0; render2D(0);
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ drawHUD(); } finally { proto.arc=oArc; }
       for(k=0;k<cap.length;k++) if(cap[k].length>=5&&Math.abs(cap[k][0]-mouse.x)<1.5&&Math.abs(cap[k][1]-mouse.y)<1.5&&cap[k][2]>mr) mr=cap[k][2];
       return mr;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; oMx=mouse.x; oMy=mouse.y; p.iv=99;
       w=cloneObj(WEAPONS.dmr); p.wep=w; p.ammo=w.mag; wipe();
       // ONE: a lone Marksman round: nothing, then one flash once the bloom has closed
       for(q=0;q<10;q++) bloomTick(p,0.016);
       if(p.rstT>0||p.rstN>0) bad.push('ONE: a player who has not fired got a reset flash');
       fireWeapon(p,w,p.x+100,p.y,true); g.bullets.length=0;
       rstAt=-1; seen=0;
       for(q=0;q<400;q++){ bloomTick(p,0.016); if(p.rstT>0&&rstAt<0){ rstAt=q*0.016; if((p.bloomK||0)>0) bad.push('ONE: the flash came while the bloom was still open ('+p.bloomK.toFixed(2)+')'); } }
       if(rstAt<0) bad.push('ONE: no reset flash came in 6.4 s after a Marksman round');
       else if(!(rstAt>0.4&&rstAt<3.5)) bad.push('ONE: the reset flash came '+rstAt.toFixed(2)+' s after the round, not between 0.4 and 3.5');
       if(p.rstN!==1) bad.push('ONE: '+(p.rstN|0)+' reset flashes for one round, not 1');
       if(p.rstT>0) bad.push('ONE: the flash is still on 6 s later');
       // TWO: a spam keeps it open: no flash until it stops
       wipe(); n0=0;
       for(i=0;i<4;i++){ fireWeapon(p,w,p.x+100,p.y,true); g.bullets.length=0; for(q=0;q<Math.round(0.68/0.016);q++) bloomTick(p,0.016); }
       if(p.rstN>0) bad.push('TWO: a flash came during a Marksman spam ('+p.rstN+')');
       for(q=0;q<400;q++) bloomTick(p,0.016);
       if(p.rstN!==1) bad.push('TWO: '+(p.rstN|0)+' flashes after the spam ended, not 1');
       // THREE: the ring is really drawn
       wipe(); p.bloom=0; p.rstT=0; R0=ringR();
       p.rstT=0.3; R1=ringR();
       if(!(R0>0)) bad.push('THREE: no ring was drawn at the cursor');
       else if(!(R1>R0+6)) bad.push('THREE: with the flash on the outer ring is '+(R1-R0).toFixed(1)+' px wider than without, not 6 or more');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(p){ p.wep=oWep; p.ammo=oAmmo; p.bloom=0; p.bloomK=0; p.bloomPend=0; p.rstT=0; p.rstN=0; p.bloomArm=0; p.blmX=undefined; } if(g){ if(all) g.ents=all.slice(); g.bullets.length=0; } if(oMx!==undefined){ mouse.x=oMx; mouse.y=oMy; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
