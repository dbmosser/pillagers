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

if ($s.Contains("  {v:'32.91',what:")) { throw "check 32.91 is in the fixture already" }

SubRx @'
  {v:'32.90',what:
'@ @'
  {v:'32.91',what:'reduced flashing: new profiles and demo start on, old implicit off survives, and blasts plus lightning share a three-per-second visual cap; off is unchanged',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, oldWx=wx, oldNow=performance.now, ownNow=Object.prototype.hasOwnProperty.call(performance,'now'), T=10000, g=null;
     var bad=[], i, n, snap, fill, seen=0;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.gameOpts={}; P.tuned={}; P.cfg=null; applyLoadedProfile(null);
       need(CFG.flashRed===1,'new profile is not reduced flashing on');
       if(CFG.flashRed!==1) return bad.join('; ');
       snap=JSON.parse(JSON.stringify(P)); snap.cfg={flashRed:CFG.flashRed}; snap.cfgv=18;
       applyLoadedProfile({value:JSON.stringify(snap)});
       need(CFG.flashRed===1,'new default did not survive reload');
       snap=JSON.parse(JSON.stringify(P)); snap.gameOpts={}; snap.cfg=null;
       applyLoadedProfile({value:JSON.stringify(snap)});
       need(CFG.flashRed===0&&P.gameOpts.flashRed===0,'old implicit off did not become a saved off');
       applyLoadedProfile({value:JSON.stringify(P)});
       need(CFG.flashRed===0&&P.gameOpts.flashRed===0,'old implicit off changed on second load');
       for(i=0;i<2;i++){
         snap=JSON.parse(JSON.stringify(P)); snap.gameOpts.flashRed=i;
         applyLoadedProfile({value:JSON.stringify(snap)});
         need(CFG.flashRed===i&&P.gameOpts.flashRed===i,'stored choice '+i+' was lost');
       }
       for(i=0;i<2;i++){
         P.gameOpts.flashRed=0; CFG.flashRed=0;
         if(!arcadeSandboxIn(i?'p2':'host')) return 'demo sandbox staging failed';
         need(CFG.flashRed===1&&P.gameOpts.flashRed===1,'demo does not start on for '+(i?'p2':'host'));
         applyGameOpts(); need(CFG.flashRed===1,'demo Settings reapplied the career choice');
         arcadeSandboxOut(); need(CFG.flashRed===0&&P.gameOpts.flashRed===0,'demo changed career choice');
       }
       if(typeof brightFlashOk!=='function'||typeof lightningVisual!=='function') return 'no bright flash limiter';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.ents.length=0; g.player.iv=99; g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false;
       performance.now=function(){ return T; }; if(performance.now()!==T) return 'cannot hold the flash clock';
       CFG.flashRed=1; delete g._brightFlashAt; g.flashes.length=0;
       for(i=0;i<10;i++){ T=10000+i*100; flash(g.player.x,g.player.y,200,'#fff',.14); }
       need(g.flashes.length===3,'ten flash requests made '+g.flashes.length+' lights, wanted three');
       CFG.flashRed=0; g.flashes.length=0;
       for(i=0;i<10;i++){ T=12000+i*100; flash(g.player.x,g.player.y,200,'#fff',.14); }
       need(g.flashes.length===10&&g.flashes[0].r===200&&g.flashes[0].life===.14,'off changed flash count, radius or duration');
       wx=function(){ var w=oldWx(); var o={}; for(var a in w) o[a]=w[a]; o.lightning=true; return o; };
       fill=wc.fillRect; wc.fillRect=function(x,y,w,h){ if(x===0&&y===0&&w===W&&h===H&&/^rgba\(150,\s*170,\s*220,/.test(wc.fillStyle)) seen++; return fill.apply(this,arguments); };
       for(k=0;k<2;k++){
         CFG.flashRed=k; delete g._brightFlashAt; n=0; seen=0;
         for(i=0;i<10;i++){
           T=15000+k*2000+i*100; g.strikeAt=99;
           g.strikes=[{x:g.player.x+500,y:g.player.y+500,t:0,rm:1}]; strikeTick(0);
           need(g.lightning===.34,'visual limiter changed lightning gameplay timer');
           if(lightningVisual()>0) n++;
           __frame(.016);
         }
         need(n===(k?3:10),'ten bolts made '+n+' visible flashes with reduced '+k);
         need(seen===(k?3:10),'ten bolts drew '+seen+' full-screen lightning sheets with reduced '+k);
       }
       wc.fillRect=fill; fill=null;
       CFG.flashRed=1; delete g._brightFlashAt; g.flashes.length=0; T=20000;
       flash(g.player.x,g.player.y,200); T+=100;
       g.strikeAt=99; g.strikes=[{x:0,y:0,t:0,rm:1}]; strikeTick(0);
       need(lightningVisual()===0,'lightning bypassed the blast budget');
       g.flashes.length=0; g.nukeT=.5; g.nukeAcc=1; tickNuke(.01);
       need(g.flashes.length===0,'barrage bloom bypassed the blast budget');
       T+=234; g.nukeAcc=1; tickNuke(.01);
       need(g.flashes.length===1,'barrage bloom did not recover after 334 ms');
       return bad.length?bad.join('; '):null;
     }finally{
       if(fill) wc.fillRect=fill;
       wx=oldWx; if(ownNow) performance.now=oldNow; else delete performance.now;
       try{ if(ARCADE.on) arcadeSandboxOut(); }catch(_a){}
       try{ __endRaid('abandon'); }catch(_e){}
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       __topClear();
     }
   }},
  {v:'32.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
