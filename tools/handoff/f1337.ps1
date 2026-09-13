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

# v13.37 CHECK, inserted before the v13.36 entry.
#
# ON THE PLAY PATH: a fake controller polled by the frame loop. Controls come first and
# skip rather than pass hollow: a tap of B must roll a standing player (the pad reaches
# the raid), and the space bar must be able to surrender in this staging. Every key is
# cleared before every frame, so a Space held inside a frame was written by the frame
# itself. Downed staging sets downed, revived AND downT (the lesson of the first probe),
# and removes machines, waves and landed extractions.
SubRx @'
  {v:'13.36',what:'on a controller a click of the right stick crouches and a second click stands him up, one change per click however long it is held, and a crouched walk on the stick is slower, as both controller key lists promise, while the keyboard C and the held left stick sprint are unchanged (audit 2026-09-13, hunt item 2)',
'@ @'
  {v:'13.37',what:'on a controller, holding B while downed with the self-revive spent fills the surrender bar and ends the raid as the downed screen says, while a tap of B still rolls a standing player, a short hold still does not surrender, an unspent revive still refuses it, and letting go of B lets go of the key (audit, 2026-09-13)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid)) return 'SKIP: this fixture cannot drive a live frame';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, and this check steps frames that draw';
     if(typeof pollPad!=='function'||typeof giveUpTick!=='function') return 'SKIP: this build has no pad poll or no surrender';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     // One button down, or none (-1). Button 1 is B on the standard layout.
     function padWith(down){
       var bts=[],i;
       for(i=0;i<16;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,
                 axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     var keepTs=lastTs, clk=0;
     function nowMs(){ return (typeof performance!=='undefined'&&performance.now)?performance.now():0; }
     function step(){ clk+=16.7; __loop(clk); }
     // A fresh raid with nothing in it that can end the run: no machines, no wave
     // (an emptied raid is the urgent-wave condition), and no extraction on the
     // ground anywhere, so the surrender is never the refused kind.
     function raid(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_f){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       g.ents.length=0; g.waveT=-1e9;
       if(g.zones){ for(var z=0;z<g.zones.length;z++){ g.zones[z].beaconT=null; g.zones[z].hold=null; } }
       g.beaconT=null; g.shipHold=null;
       clk=Math.max(clk,nowMs(),(lastTs||0)+100);
       return g;
     }
     // Downed for secs of real frames with pad button btn held (-1 for none), the
     // space bar held as well when kb, and the revive spent when spent. Every key is
     // cleared BEFORE every frame, so a Space held inside the frame was written there
     // by the frame itself and not left over by the keyboard or an earlier check.
     function downFor(secs,btn,kb,spent){
       var g=__state(), p=g.player, K, k, peak=0, i, fr=Math.round(secs/0.0167);
       p.giveT=0; p.prep=null; p.prepA=null; p.roll=0;
       padWith(btn);
       for(i=0;i<fr;i++){
         if(p.hp<=0||g.over) break;
         p.iv=9999; p.downed=true; if(p.downT<5) p.downT=17;
         p.revived=spent; p.pendKiller='sentry';
         K=__keysRef(); for(k in K) K[k]=false; if(kb) K['Space']=true;
         step();
         if((p.giveT||0)>peak) peak=p.giveT||0;
       }
       return {fired:p.hp<=0, killer:(g.tel||{}).deathKiller||null, peak:peak};
     }
     // One frame with the pad at rest and the keys NOT cleared, so a key the pad
     // left held down is still there to be seen afterwards.
     function letGo(spent){
       var p=__state().player;
       padWith(-1);
       p.iv=9999; p.downed=true; if(p.downT<5) p.downT=17; p.revived=spent; p.pendKiller='sentry';
       step();
       return {space:!!__keysRef()['Space'], giveT:p.giveT||0};
     }
     try{
       var g=raid();
       if(!g) return 'SKIP: the raid did not start';
       if(CFG.giveUp===0) return 'SKIP: the surrender is switched off in this build, so there is nothing to hold';
       var p=g.player, K0=__keysRef(), k0;
       // CONTROL FIRST: THE FAKE PAD REACHES THE RAID, AND B STILL ROLLS. A tap of B
       // on a standing man is the binding the fix must keep, and it proves pollPad
       // took the raid branch rather than a menu or the floor.
       for(k0 in K0) K0[k0]=false;
       p.prep=null; p.prepA=null;
       padWith(-1); step();
       p.stam=100; p.roll=0; p.rollCd=0;
       padWith(1); step();
       var rolled=(p.roll>0||p.rollCd>0);
       padWith(-1); step();
       if(!rolled) return 'SKIP: a tap of pad B did not roll a standing player, so the fake pad is not reaching the raid and nothing below would be measured';
       if(__keysRef()['Space']) bad.push('control: after a tap of pad B on a standing player the space key is still held down, so the roll button now latches');
       // CONTROL TWO: THE STAGING CAN SURRENDER AT ALL. The space bar, with the pad
       // connected at rest. If this does not end it, a silent pad below means nothing.
       var kb=downFor(2.5,-1,true,true);
       if(!kb.fired) return 'SKIP: holding the space bar for 2.5 seconds downed with the revive spent did not surrender here either, so this staging cannot surrender and proves nothing about the pad';
       // That body is dead: a fresh raid for the pad.
       g=raid();
       if(!g) return 'SKIP: the second raid did not start';
       // CONTROL THREE, HIS CONDITION: with the revive unspent, holding B ends nothing.
       var keep=downFor(2.5,1,false,false);
       if(keep.fired) bad.push('control: holding pad B ended the raid while he still had his self-revive, the one state v9.71 says the surrender must never work in');
       letGo(false);
       // CONTROL FOUR: A HOLD, NOT A TAP, and letting go lets go.
       var shortH=downFor(1.0,1,false,true);
       if(shortH.fired) bad.push('control: one second of pad B surrendered, so it is a tap and not the hold the downed screen asks for');
       var rel=letGo(true);
       if(rel.space) bad.push('letting go of pad B leaves the space key held down, so the surrender keeps filling with no hand on the controller');
       if(rel.giveT>0) bad.push('letting go of pad B does not empty the surrender bar');
       // THE FINDING: downed, revive spent, B held for 2.5 seconds, which is what the
       // downed screen tells a controller player to do. On v13.36 the bar never moved.
       var padH=downFor(2.5,1,false,true);
       if(!padH.fired)
         bad.push('holding pad B for 2.5 seconds downed with the self-revive spent did not surrender (the bar reached '+padH.peak.toFixed(2)+' of '+GIVEUP_HOLD()+' seconds), so the downed screen tells a controller player to hold a button that does nothing and he can only bleed out');
       else if(padH.killer!=='sentry')
         bad.push('the pad surrender filed the death under '+padH.killer+' rather than what put him down');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ lastTs=keepTs; }catch(_t2){}
       try{ var g3=__state(); if(g3&&g3.player){ g3.player.downed=false; g3.player.downT=0; g3.player.giveT=0; g3.player.iv=0; g3.player.revived=false; }
            if(g3&&!g3.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.36',what:'on a controller a click of the right stick crouches and a second click stands him up, one change per click however long it is held, and a crouched walk on the stick is slower, as both controller key lists promise, while the keyboard C and the held left stick sprint are unchanged (audit 2026-09-13, hunt item 2)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
