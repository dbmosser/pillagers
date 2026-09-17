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
  {v:'15.30',what:
'@ @'
  {v:'15.31',what:'on a controller, X held in an extraction point searches one box and then calls or extracts: with two wrecks in reach of a landed ring the first opens, the second is left alone and the extraction hold starts on the same press, a fresh press still searches the second, and with one wreck the hold starts as before (extraction audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__keysRef)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof updatePlayer!=='function'||typeof refreshVseg!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function'||typeof PAD==='undefined'||!ITEMS.scrap) return 'SKIP: no pad poll, player update, container maker or Scrap Metal in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, g=null, z=null, keepZ=null, keepG=null, keepPad=null, DT=1/60;
     var ZK=['open','beaconT','hold','holdMax','pullT','pullFloor','boardT','callT','siege','siegeSpawnT','siegeSpawned','siegeGreed','pingT'];
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<17;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     // One frame at 60 a second in the order the raid loop runs it: the pad, the raid clock, the sight lines, then the player.
     function frame(){ pollPad(); if(!g.over){ g.t+=DT; refreshVseg(); updatePlayer(DT); } }
     // The ring landed with a 20 s window, nobody else on the map, no other box anywhere, and him standing in the middle.
     function stage(){
       keysOff(); padWith(-1);
       g.ents.length=0; g.waveT=-1e9; g.containers.length=0; g.trade=null; g.paused=false; g.bagOpen=false; g.mapOpen=false;
       z.open=true; z.beaconT=-1; z.hold=20; z.holdMax=20; z.pullT=null; z.pullFloor=0; z.boardT=0; z.callT=0; z.siege=0; z.siegeSpawnT=0; z.siegeSpawned=0;
       g.active=z;
       var p=g.player; p.x=z.x; p.y=z.y; p.vx=0; p.vy=0; p.downed=false; p.roll=0; p.iv=99;
     }
     // A machine wreck holding one Scrap Metal, searched in 0.6 s, dx units along the ring from its middle.
     function wreck(dx){ var w=setLoot(mkContainer(z.x+dx,z.y,'botwreck'),['scrap']); w.time=0.6; w.prog=0; w.pulled=0; w.opened=false; g.containers.push(w); return w; }
     // X held until the wreck opens (at most 1.5 s), then half a second more on the same press. False if it never opened.
     function holdX(w){
       padWith(2);
       for(var f=0;f<90&&!w.opened&&!g.over;f++) frame();
       if(!w.opened) return false;
       for(var f2=0;f2<30&&!g.over;f2++) frame();
       return true;
     }
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.zones||!g.zones.length) return 'SKIP: no live raid with an extraction point';
       for(var zi=0;zi<g.zones.length;zi++) if(g.zones[zi].closeAt===undefined){ z=g.zones[zi]; break; }
       if(!z) z=g.zones[0];
       keepZ={}; for(var ki=0;ki<ZK.length;ki++) keepZ[ZK[ki]]=z[ZK[ki]];
       keepG={active:g.active,beaconT:g.beaconT,shipHold:g.shipHold,shipHoldMax:g.shipHoldMax,t:g.t,waveT:g.waveT,px:g.player.x,py:g.player.y,
              ents:g.ents.slice(),containers:g.containers.slice(),bag:(g.bag||[]).slice()};
       keepPad={xDownAt:PAD.xDownAt,xSearched:PAD.xSearched,xAfterTrade:PAD.xAfterTrade};
       // CONTROL: one wreck in reach. X searches it, and once it is open the same hold runs the extraction hold, on either build.
       stage(); var w0=wreck(12);
       frame();
       if(g.nearContainer!==w0||!g.nearPad) return 'SKIP: staging: the wreck at his feet in the ring was not found in reach';
       if(!holdX(w0)) return 'SKIP: pad X held in the ring did not open the wreck at his feet within 1.5 s here';
       if(g.over) return 'SKIP: the raid ended during the one wreck control ('+g.over+')';
       if(!((z.pullT||0)>0.3)) return 'SKIP: with one wreck, X held after it opened did not run the extraction hold here (hold at '+(z.pullT||0)+' of 1.4 s), so the pad or the ring staging did not take';
       padWith(-1); frame();
       // CONTROL: the second wreck, 30 units off, is in reach and in sight on its own.
       stage(); var w2=wreck(-30);
       frame();
       if(g.nearContainer!==w2||!g.nearPad) return 'SKIP: staging: a wreck 30 units off in the ring was not found in reach';
       var w1=wreck(12);
       frame();
       if(g.nearContainer!==w1) return 'SKIP: staging: the nearer of two wrecks was not the one in reach';
       // THE FIX: X searches the nearer wreck, and once it is open the same hold runs the extraction hold, not the second wreck.
       if(!holdX(w1)) return 'SKIP: pad X held in the ring did not open the nearer of two wrecks within 1.5 s here';
       if(g.over) return 'SKIP: the raid ended during the two wreck arm ('+g.over+')';
       if(w2.opened||(w2.prog||0)>0) bad.push('with X still held after the first wreck opened, the same hold went on to search the second wreck in reach ('+(w2.opened?'opened':Math.round(100*(w2.prog||0)/w2.time)+'% of it')+' in half a second) instead of calling or extracting');
       if(!((z.pullT||0)>0.3)) bad.push('half a second of X held after the first of two wrecks opened, the extraction hold had not started (hold at '+(z.pullT||0)+' of 1.4 s)');
       // KEPT FROM v13.51: let go and pressed again, X searches the wreck still in reach first.
       padWith(-1); frame(); frame();
       padWith(2); frame(); frame(); frame();
       if(!w2.opened&&g.searching!==w2) bad.push('let go and pressed again, X on the ring did not search the second wreck still in reach');
       padWith(-1); frame();
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ keysOff(); }catch(_k){}
       try{ if(keepPad){ PAD.xDownAt=keepPad.xDownAt; PAD.xSearched=keepPad.xSearched; PAD.xAfterTrade=keepPad.xAfterTrade; } }catch(_pd){}
       try{ if(z&&keepZ){ for(var kz in keepZ) z[kz]=keepZ[kz]; } }catch(_z){}
       try{
         if(g&&keepG){
           g.active=keepG.active; g.beaconT=keepG.beaconT; g.shipHold=keepG.shipHold; g.shipHoldMax=keepG.shipHoldMax;
           g.t=keepG.t; g.waveT=keepG.waveT; g.bag=keepG.bag; g.searching=null; g.searchT=0; g.nearContainer=null;
           if(g.player){ g.player.x=keepG.px; g.player.y=keepG.py; }
           g.ents.length=0; for(var ke=0;ke<keepG.ents.length;ke++) g.ents.push(keepG.ents[ke]);
           g.containers.length=0; for(var kc=0;kc<keepG.containers.length;kc++) g.containers.push(keepG.containers[kc]);
         }
       }catch(_g){}
       try{ if(g&&g.player){ g.player.iv=0; g.player.downed=false; } if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
