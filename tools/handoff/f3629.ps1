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

if ($s.Contains("  {v:'36.29',what:")) { throw "check 36.29 is in the fixture already" }

SubRx @'
  {v:'36.28',what:
'@ @'
  {v:'36.29',what:'ADS preserves the aimed ground point while zooming toward it, keeps the local pillager visible, and leaves hip framing unchanged',
   run:function(){
     var g,p,bad=[],saveMouse={x:mouse.x,y:mouse.y},savePad={},pk=['curOwn','aimA','reach','adsing','adsAim'],i;
     var saveNet={on:NET.on,role:NET.role,seat:NET.seat},zw=ZC,zt=ZT;
     for(i=0;i<pk.length;i++) savePad[pk[i]]=PAD[pk[i]];
     function frames(n){ for(var j=0;j<n;j++) __frame(.05); }
     function screen(a){ return {x:(a.x-g.camX)*ZOOM(),y:(a.y-g.camY)*ZOOM()}; }
     function distance(a,b){ return Math.hypot(a.x-b.x,a.y-b.y); }
     function stage(w,role){
       p.wep=cloneObj(w); p.ads=false; p.downed=false; p.roll=0; p.iv=999; p.hand=false; p.x=WORLD_W/2; p.y=WORLD_H/2;
       g.sprinting=false; g.adsZ=1; g.adsCam=null; g.anchX=undefined; g.shake=0;
       NET.on=false; NET.role=role; NET.seat=role==='join'?1:0;
       PAD.curOwn=0; PAD.adsing=0; PAD.adsAim=false; mouse.x=W/2; mouse.y=H*.54; frames(12);
       mouse.x=W/2+400/(1+lookLean(p)); mouse.y=H*.54; frames(24);
     }
     function mouseCase(w,role){
       stage(w,role);
       var hip={x:g.camX,y:g.camY},z=ZOOM(),a=mouseWorld(),s0={x:mouse.x,y:mouse.y};
       var px=(p.x-g.camX)*z;
       if(Math.abs(mouse.x-px-400)>.2) bad.push('staging: pointer is not 400px right of the pillager');
       var expectedX=camClamp(g.anchX-(W/2-g.leanSX)/z,W/z,WORLD_W), expectedY=camClamp(g.anchY-(H*.54-g.leanSY)/z,H/z,WORLD_H);
       if(Math.abs(hip.x-expectedX)>.01||Math.abs(hip.y-expectedY)>.01) bad.push('hip camera changed');
       p.ads=true; frames(1);
       if(distance(screen(a),s0)>6) bad.push(role+' ADS start moved the aimed point');
       frames(35);
       if(distance(screen(a),s0)>6) bad.push(role+' '+w.id+' ADS target drift '+distance(screen(a),s0).toFixed(2)+'px');
       if(distance(w2s(a.x,0,a.y),s0)>6) bad.push('the drawn target left the crosshair');
       var ps=screen(p);
       if(ps.x<W*.119||ps.x>W*.881||ps.y<H*.119||ps.y>H*.881) bad.push('ADS put the pillager against an edge');
       if(mouse.x!==s0.x||mouse.y!==s0.y) bad.push('mouse crosshair moved');
       var end=mouseWorld(); p.ads=false; frames(1);
       if(distance(screen(end),s0)>6) bad.push('ADS release moved the aimed point');
       frames(35);
       if(Math.hypot(g.camX-hip.x,g.camY-hip.y)>.05) bad.push('hip framing did not return');
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); p=g.player;
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false; ZC=1; ZT=1;
       mouseCase(WEAPONS.rifle,'host'); mouseCase(WEAPONS.rifle,'join');
       mouseCase(WEAPONS.pistol,'host'); mouseCase(WEAPONS.sniper,'join');
       stage(WEAPONS.sniper,'join'); PAD.curOwn=1; PAD.aimA=0; PAD.reach=400; PAD.adsing=1; PAD.adsAim=true; p.ads=true; frames(36);
       var a={x:p.x+400,y:p.y},s=screen(a);
       if(distance(s,{x:mouse.x,y:mouse.y})>2) bad.push('pad endpoint and crosshair disagree');
       if(g.adsCam&&Math.abs(g.adsCam.fx-(p.x+240))>.1) bad.push('long gun pad focal point is not 60 percent along the aim');
       var c0={x:g.camX,y:g.camY}; CFG.fxInt=0; frames(12);
       if(Math.hypot(g.camX-c0.x,g.camY-c0.y)>.1) bad.push('reduced effects changed framing');
       PAD.curOwn=0; PAD.adsing=0; PAD.adsAim=false; mouse.x=W-2; mouse.y=2; frames(48);
       var edge=screen(p);
       if(edge.x<W*.119||edge.x>W*.881||edge.y<H*.119||edge.y>H*.881) bad.push('diagonal aim lost the pillager margin');
       if(typeof adsCameraFrame!=='function') bad.push('missing shared camera solver');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       ZC=zw; ZT=zt; mouse.x=saveMouse.x; mouse.y=saveMouse.y;
       for(i=0;i<pk.length;i++){ if(savePad[pk[i]]===undefined) delete PAD[pk[i]]; else PAD[pk[i]]=savePad[pk[i]]; }
       NET.on=saveNet.on; NET.role=saveNet.role; NET.seat=saveNet.seat;
       try{ __endRaid('abandon'); }catch(_e){} __topClear(); __resetCfg();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'36.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
