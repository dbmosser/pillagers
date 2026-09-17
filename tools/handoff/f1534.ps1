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
  {v:'15.33',what:
'@ @'
  {v:'15.34',what:'standing in any landed extraction point shows the extract prompt: with one point landed and a later call still inbound at another point, so the pointer stays on the inbound one, standing in the landed point draws the centre prompt to hold E and extract, while standing in the inbound point still draws none and a single landed call still draws it (extraction audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||typeof tryExtractTick!=='function'||typeof txRecord!=='function'||typeof standingRing!=='function'||typeof ringLanded!=='function'||typeof keyLabel!=='function') return 'SKIP: no HUD, extraction tick, text recorder, point readers or key labels in this build';
     var bad=[], g=null, p=null, A=null, B=null, keepZ=null, keepG=null, keepP=null, keepWaves=CFG.raiderWaves, keepHit=null, hadHit=false;
     var ZK=['open','closeAt','warned','beaconT','hold','holdMax','pullT','pullFloor','boardT','callT','siege','siegeSpawnT','siegeSpawned','siegeGreed','pingT'];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // Every point quiet, then A landed with a 20 s window and B inbound at 12 s (or quiet), the pointer on act and him standing
     // in the middle of at. One extraction tick at no time step down the real path, which runs the mirrors and the pointer rules.
     function stage(bIn,act,at){
       for(var qi=0;qi<g.zones.length;qi++){ var q=g.zones[qi]; q.beaconT=null; q.hold=null; q.pullT=null; q.callT=0; }
       A.open=true; A.closeAt=undefined; A.beaconT=-1; A.hold=20; A.holdMax=20; A.siege=0; A.siegeSpawnT=0; A.pingT=0;
       B.open=true; B.closeAt=undefined; B.siege=0; B.siegeSpawnT=0; B.pingT=0;
       if(bIn) B.beaconT=12;
       g.active=act;
       p.x=at.x; p.y=at.y; p.vx=0; p.vy=0;
       tryExtractTick(0,false);
     }
     function drawn(){ return txRecord(function(){ drawHUD(); }).map(function(h){ return h.o; }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.sim||!g.zones||g.zones.length<2) return 'SKIP: no live raid with two extraction points';
       p=g.player;
       if(p.downed) return 'SKIP: he starts this raid down';
       keepZ=[]; for(var zk=0;zk<g.zones.length;zk++){ var kz={}; for(var ki=0;ki<ZK.length;ki++) kz[ZK[ki]]=g.zones[zk][ZK[ki]]; keepZ.push(kz); }
       keepG={active:g.active,beaconT:g.beaconT,shipHold:g.shipHold,shipHoldMax:g.shipHoldMax,siege:g.siege,siegeSpawnT:g.siegeSpawnT,siegeSpawned:g.siegeSpawned,msg:g.msg,msgT:g.msgT,msgQ:(g.msgQ?g.msgQ.slice():g.msgQ),ents:g.ents.slice()};
       keepP={x:p.x,y:p.y,vx:p.vx,vy:p.vy};
       try{ hadHit=(typeof TXHIT!=='undefined'); if(hadHit) keepHit=TXHIT; }catch(_h){ hadHit=false; }
       // No machine anywhere and no pillager wave, so the tick can only move the extraction points.
       g.ents.length=0; CFG.raiderWaves=0;
       // Two points that do not overlap, so standing in the middle of one is standing in that one alone.
       for(var ai=0;ai<g.zones.length&&!A;ai++){
         for(var bi=0;bi<g.zones.length;bi++){
           var za=g.zones[ai], zb=g.zones[bi];
           if(za!==zb&&dist(za,zb)>za.r+zb.r){ A=za; B=zb; break; }
         }
       }
       if(!A) return 'SKIP: no two extraction points here stand apart';
       // Assembled, so the needle is never written out whole in the page. No pad is faked, so on the keyboard this reads E.
       var HE=['HOLD',keyLabel('KeyE','E'),'TO','EXTRACT'].join(' ');
       // CONTROL: one call, landed at A, him standing in it. The prompt is drawn on either build, so the recorder sees the centre verb.
       stage(false,A,A);
       if(!(g.active===A&&standingRing()===A&&ringLanded(A)&&g.beaconT!==null&&g.beaconT<=0&&g.shipHold===20)) return 'SKIP: staging: a single landed point did not reach the pointer and the HUD mirrors here (beacon '+g.beaconT+', window '+g.shipHold+')';
       var c0=drawn();
       if(c0.indexOf(HE)<0) return 'SKIP: standing in a single landed point, the HUD drew no prompt to hold '+keyLabel('KeyE','E')+' and extract here, so this trace cannot see the centre verb';
       // THE FINDING: B called after A and still inbound, so the pointer is on B, and him standing in landed A.
       stage(true,B,A);
       // CONTROL: the tick left the pointer and the mirrors on inbound B, and A is still landed with him inside it, on either build.
       if(!(g.active===B&&g.beaconT!==null&&g.beaconT>0&&g.shipHold===null&&ringLanded(A)&&standingRing()===A)) return 'SKIP: staging: the pointer did not stay on the inbound point with him in the landed one here (pointer on the inbound point '+(g.active===B)+', beacon '+g.beaconT+', window '+g.shipHold+')';
       var s1=drawn();
       if(s1.indexOf(HE)<0) bad.push('standing in a landed extraction point while a later call was still inbound at another point, the HUD drew no prompt to hold '+keyLabel('KeyE','E')+' and extract, though a hold there extracts him');
       // KEPT: standing in inbound B instead, with A landed elsewhere, nothing has landed under him and no prompt to extract is drawn.
       stage(true,B,B);
       if(!(g.active===B&&standingRing()===B&&!ringLanded(B)&&ringLanded(A))) return skip('staging: standing in the inbound point did not read as the inbound point here');
       var k1=drawn();
       if(k1.indexOf(HE)>=0) bad.push('standing in an extraction point still inbound, with another landed elsewhere, the HUD drew the prompt to hold '+keyLabel('KeyE','E')+' and extract, where a hold does not extract');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ CFG.raiderWaves=keepWaves; }catch(_w){}
       try{ if(hadHit) TXHIT=keepHit; }catch(_x){}
       try{ if(g&&keepZ){ for(var rz=0;rz<keepZ.length&&rz<g.zones.length;rz++){ for(var rk in keepZ[rz]) g.zones[rz][rk]=keepZ[rz][rk]; } } }catch(_z){}
       try{
         if(g&&keepG){
           g.active=keepG.active; g.beaconT=keepG.beaconT; g.shipHold=keepG.shipHold; g.shipHoldMax=keepG.shipHoldMax;
           g.siege=keepG.siege; g.siegeSpawnT=keepG.siegeSpawnT; g.siegeSpawned=keepG.siegeSpawned;
           g.msg=keepG.msg; g.msgT=keepG.msgT; g.msgQ=keepG.msgQ;
           g.ents.length=0; for(var ke=0;ke<keepG.ents.length;ke++) g.ents.push(keepG.ents[ke]);
         }
       }catch(_g){}
       try{ if(p&&keepP){ for(var pk in keepP) p[pk]=keepP[pk]; } }catch(_pp){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.33',what:
'@
SubRx @'
       g2.shipHold=8; g2.beaconT=0;
'@ @'
       // v15.34: THE POINT LANDS TOO, NOT JUST THE MIRRORS. The standing prompt reads the point he stands in now (standingRing,
       // as the downed screen has since v12.94), so a window staged on G.shipHold and G.beaconT alone drew no prompt at all.
       z2.beaconT=0; z2.hold=8; z2.holdMax=30;
       g2.shipHold=8; g2.beaconT=0;
'@
SubRx @'
         g3.shipHold=8; g3.beaconT=0;
'@ @'
         // v15.34: the point lands too, not just the mirrors, because the standing prompt reads the point he stands in now.
         z3.beaconT=0; z3.hold=8; z3.holdMax=30;
         g3.shipHold=8; g3.beaconT=0;
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
