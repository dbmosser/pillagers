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
  {v:'15.31',what:
'@ @'
  {v:'15.32',what:'on a controller the extract prompt names the X button: with a pad connected, standing in a landed ring and lying down in one, the HUD tells him to hold X to extract and never E, the call prompts still name X, and with no pad the landed ring still names E standing and down (extraction audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof drawHUD!=='function'||typeof tickExtractPoints!=='function'||typeof keyLabel!=='function'||typeof padOn!=='function'||typeof standingRing!=='function'||typeof PAD==='undefined') return 'SKIP: no pad poll, HUD, extraction tick or key labels in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, g=null, p=null, z=null, keepZ=null, keepG=null, keepP=null, realFill=null, ownFill=false, seen=[], keepHaul=CFG.hauledAboard;
     var ZK=['open','beaconT','hold','holdMax','pullT','callT','siege','siegeSpawnT','siegeSpawned','siegeGreed','pingT','warned'];
     // Assembled, so the needles are never written out whole in the page.
     var HX=['HOLD','X','TO','EXTRACT'].join(' '), HE=['HOLD','E','TO','EXTRACT'].join(' '), CX=['HOLD','X','TO','CALL','FOR','EXTRACTION'].join(' ');
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     // A connected pad with every button up, or no pad at all, and one poll so PAD.on follows it.
     function pad(on){
       if(on){
         var bts=[],i;
         for(i=0;i<17;i++) bts.push({pressed:false,value:0,touched:false});
         var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
         navigator.getGamepads=function(){ return [fake]; };
       } else navigator.getGamepads=function(){ return []; };
       pollPad();
     }
     // Every ring quiet, then this one landed with a 20 s window or uncalled, him in the middle of it, standing or down.
     // The ring is staged and the extraction tick run at no time step, so the HUD mirrors come from the ring itself.
     function stage(landed,down){
       for(var qi=0;qi<g.zones.length;qi++){ var q=g.zones[qi]; q.beaconT=null; q.hold=null; q.pullT=null; q.callT=0; }
       z.open=true; z.siege=0; z.siegeSpawnT=0;
       if(landed){ z.beaconT=-1; z.hold=20; z.holdMax=20; }
       g.active=z;
       p.x=z.x; p.y=z.y; p.vx=0; p.vy=0; p.iv=99; p.revived=false;
       p.downed=!!down; p.downT=down?10:0;
       tickExtractPoints(0);
     }
     function drawn(){ seen.length=0; drawHUD(); return seen.slice(); }
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.sim||!g.zones||!g.zones.length) return 'SKIP: no live raid with an extraction point';
       p=g.player;
       for(var zi=0;zi<g.zones.length;zi++) if(g.zones[zi].closeAt===undefined){ z=g.zones[zi]; break; }
       if(!z) z=g.zones[0];
       keepZ=[]; for(var zk=0;zk<g.zones.length;zk++){ var kz={}; for(var ki=0;ki<ZK.length;ki++) kz[ZK[ki]]=g.zones[zk][ZK[ki]]; keepZ.push(kz); }
       keepG={active:g.active,beaconT:g.beaconT,shipHold:g.shipHold,shipHoldMax:g.shipHoldMax,siege:g.siege,siegeSpawnT:g.siegeSpawnT,siegeSpawned:g.siegeSpawned,ents:g.ents.slice()};
       keepP={x:p.x,y:p.y,vx:p.vx,vy:p.vy,iv:p.iv,downed:p.downed,downT:p.downT,revived:p.revived};
       g.ents.length=0;
       // Down in a landed ring the verb is only shown with automatic pickup off, the shipped default.
       CFG.hauledAboard=0;
       ownFill=Object.prototype.hasOwnProperty.call(ctx,'fillText');
       realFill=ctx.fillText;
       ctx.fillText=function(t){ seen.push(String(t)); return realFill.apply(ctx,arguments); };
       // CONTROL: the fake pad switches the controller labels on, and the extraction key is labelled X.
       pad(true);
       if(!padOn()) return 'SKIP: the fake pad did not switch the controller labels on';
       if(keyLabel('KeyE','E')!=='X') return 'SKIP: with a pad on, the extraction key is labelled '+keyLabel('KeyE','E')+' here, not X';
       // CONTROL: standing in an uncalled ring with the pad on, the call prompt names X on either build, so the trace sees the prompts.
       stage(false,false);
       if(standingRing()!==z) return 'SKIP: staging: another open ring covers the middle of this one here';
       var c0=drawn();
       if(c0.indexOf(CX)<0) return 'SKIP: standing in an uncalled ring with a pad on, the HUD did not draw the call prompt naming X, so this trace cannot see the extraction prompts';
       // THE FINDING, STANDING: the ring landed and him in it. The ring badge is skipped here, so the centre line is the only verb.
       stage(true,false);
       if(!(g.active===z&&g.beaconT!==null&&g.beaconT<=0&&g.shipHold===20)) return 'SKIP: staging: the landed ring did not reach the HUD mirrors here (beacon '+g.beaconT+', window '+g.shipHold+')';
       var s1=drawn();
       if(s1.indexOf(HE)>=0) bad.push('with a pad on, standing in a landed ring, the HUD told him to hold E to extract, a key the pad does not have');
       if(s1.indexOf(HX)<0) bad.push('with a pad on, standing in a landed ring, the HUD never told him to hold X to extract');
       // CONTROL: down in an uncalled ring with the pad on, the downed screen names X for the call on either build.
       stage(false,true);
       var c1=drawn();
       if(c1.indexOf(CX)<0) return skip('down in an uncalled ring with a pad on, the downed screen did not draw the call prompt naming X here');
       // THE FINDING, DOWN: the ring landed and him lying in it. The ring badge is not drawn while he is down.
       stage(true,true);
       if(typeof ringLanded==='function'&&!ringLanded(z)) return skip('staging: the ring he lies in does not read as landed here');
       var s2=drawn();
       if(s2.indexOf(HE)>=0) bad.push('with a pad on, down in a landed ring, the downed screen told him to hold E to extract, a key the pad does not have');
       if(s2.indexOf(HX)<0) bad.push('with a pad on, down in a landed ring, the downed screen never told him to hold X to extract');
       // THE KEYBOARD IS UNCHANGED: no pad, the same landed ring, standing and down, still names E.
       pad(false);
       if(padOn()) return skip('the fake pad did not let go');
       stage(true,false);
       var k1=drawn();
       if(k1.indexOf(HE)<0) bad.push('with no pad, standing in a landed ring, the HUD no longer told him to hold E to extract');
       stage(true,true);
       var k2=drawn();
       if(k2.indexOf(HE)<0) bad.push('with no pad, down in a landed ring, the downed screen no longer told him to hold E to extract');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFill){ if(ownFill) ctx.fillText=realFill; else delete ctx.fillText; } }catch(_r){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ CFG.hauledAboard=keepHaul; }catch(_h){}
       try{ if(g&&keepZ){ for(var rz=0;rz<keepZ.length&&rz<g.zones.length;rz++){ for(var rk in keepZ[rz]) g.zones[rz][rk]=keepZ[rz][rk]; } } }catch(_z){}
       try{
         if(g&&keepG){
           g.active=keepG.active; g.beaconT=keepG.beaconT; g.shipHold=keepG.shipHold; g.shipHoldMax=keepG.shipHoldMax;
           g.siege=keepG.siege; g.siegeSpawnT=keepG.siegeSpawnT; g.siegeSpawned=keepG.siegeSpawned;
           g.ents.length=0; for(var ke=0;ke<keepG.ents.length;ke++) g.ents.push(keepG.ents[ke]);
         }
       }catch(_g){}
       try{ if(p&&keepP){ for(var pk in keepP) p[pk]=keepP[pk]; } }catch(_pp){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
