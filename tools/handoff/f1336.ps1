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

# v13.36 CHECK, inserted before the v13.35 entry.
#
# ON THE PLAY PATH: a fake controller in the standard layout, polled by the frame loop
# itself, so every press takes the path a thumb does. A control first proves the pad
# reaches the raid bindings (the held left stick click sets sprint); if it does not,
# the check skips rather than passing hollow. Machines and waves are removed (the
# r1334c lesson). The pad stub is removed and polled empty in finally.
SubRx @'
  {v:'13.35',what:'searching a box the way he does, with X held, shows where the item went: a better gun taken into the free second slot and a stim pinned to a free key on the tactical belt each get their line on screen once Took runs out, instead of both being written over by Took in the same frame (2026-09-13 hunt)',
'@ @'
  {v:'13.36',what:'on a controller a click of the right stick crouches and a second click stands him up, one change per click however long it is held, and a crouched walk on the stick is slower, as both controller key lists promise, while the keyboard C and the held left stick sprint are unchanged (audit 2026-09-13, hunt item 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid)) return 'SKIP: this fixture cannot drive a live frame';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof crouchHeld!=='function'||typeof pollPad!=='function') return 'SKIP: this build has no crouch reader or no pad poll';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, annWas=PAD.announced;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     var T0=performance.now(), RS=11, LS=10;
     // One fake pad in the standard layout. down is the one button held, -1 for none.
     function pad(down,ax0,ax1){
       var bts=[],i;
       for(i=0;i<16;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,
                 axes:[ax0||0,ax1||0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     // The frame loop polls the pad itself, so every press below takes the path a thumb does.
     function frames(n){ for(var f=0;f<n;f++){ T0+=16.7; __loop(T0); } }
     function clearKeys(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player||g.over) return 'SKIP: the raid did not start';
       var p=g.player;
       g.ents.length=0; g.waveT=-1e9;   // r1334c: an emptied raid is the urgent-wave condition
       p.downed=false; p.roll=0; p.ads=false; p.autoJog=false; p.stam=100; p.stamLock=0; p.stamRelease=0;
       clearKeys(); g.crouchTog=false;
       pad(-1); frames(2);                       // at rest, so every edge below is fresh
       var start={x:p.x,y:p.y};
       // CONTROL: THE RAID BINDINGS ARE REACHED. The left stick click is a held key
       // there; if it does not land, a window owns the pad and nothing below measures.
       pad(LS); frames(1);
       var shiftOn=!!__keysRef()['ShiftLeft'];
       pad(-1); frames(1);
       if(!shiftOn) return 'SKIP: holding the left stick click did not reach the raid bindings, so a window may own the pad and the right stick cannot be measured';
       if(__keysRef()['ShiftLeft']) bad.push('control: letting go of the left stick click left sprint held, so the left stick is no longer a hold');
       // 1. ONE CLICK CROUCHES. This is the finding.
       g.crouchTog=false;
       pad(RS); frames(1); pad(-1); frames(1);
       if(!crouchHeld())
         bad.push('a click of the right stick did not crouch him, so a controller player who does what both controller key lists say gets nothing and has no quiet way to move');
       else {
         if(__keysRef()['ControlLeft']) bad.push('the right stick click left its key held after release');
         // 2. HOLDING IT IS STILL ONE CLICK: one change, no flicker.
         var flips=0, last=crouchHeld(), f2, cur;
         pad(RS);
         for(f2=0;f2<12;f2++){ frames(1); cur=crouchHeld(); if(cur!==last){ flips++; last=cur; } }
         pad(-1); frames(1);
         if(flips!==1)
           bad.push('holding the right stick click for twelve frames changed the stance '+flips+' times, so it '+(flips?'flickers in and out of the crouch':'never stands him up')+' instead of one change per click');
         else if(crouchHeld()) bad.push('holding the right stick click from a crouch left him crouched');
         // 3. A THIRD CLICK CROUCHES AGAIN, and it stays with the button released.
         pad(RS); frames(1); pad(-1); frames(20);
         if(!crouchHeld()) bad.push('a click after standing up did not keep him crouched for twenty frames, so the right stick is not the toggle the keyboard has');
       }
       // 4. THE STANCE REACHES THE WORLD: a crouched walk on the stick is slower.
       function walk(ax0,ax1,crouched){
         p.x=start.x; p.y=start.y; p.vx=0; p.vy=0; p.roll=0; p.ads=false; p.stam=100; p.stamLock=0; p.stamRelease=0;
         g.crouchTog=false; clearKeys();
         pad(-1); frames(1);
         if(crouched){ pad(RS); frames(1); pad(-1); frames(1); }
         var was=crouchHeld();
         p.x=start.x; p.y=start.y; p.vx=0; p.vy=0;
         pad(-1,ax0,ax1); frames(24);
         var d=Math.sqrt((p.x-start.x)*(p.x-start.x)+(p.y-start.y)*(p.y-start.y));
         pad(-1); frames(1);
         return {d:d,crouched:was};
       }
       var dirs=[[1,0],[-1,0],[0,1],[0,-1]], di, base=0, dir=null, w0;
       for(di=0;di<dirs.length;di++){ w0=walk(dirs[di][0],dirs[di][1],false); if(w0.d>40){ base=w0.d; dir=dirs[di]; break; } }
       if(dir){
         var wc=walk(dir[0],dir[1],true);
         if(wc.crouched&&wc.d/base>0.8)
           bad.push('crouched from the right stick he still walked '+Math.round(wc.d/base*100)+'% as far on the stick, so the stance changed on paper and not in the world');
       }
       // CONTROL: THE KEYBOARD IS UNCHANGED. C flips the same toggle through the real
       // key handler, with the pad connected and at rest.
       p.x=start.x; p.y=start.y; g.crouchTog=false; clearKeys(); pad(-1); frames(1);
       try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyC'})); }catch(_k1){}
       try{ window.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyC'})); }catch(_k2){}
       frames(1);
       if(!crouchHeld()) bad.push('control: with a pad connected the keyboard C no longer crouches');
       g.crouchTog=false;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ PAD.announced=annWas; }catch(_a){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ var g3=__state(); if(g3){ g3.crouchTog=false; if(g3.player) g3.player.downed=false; if(!g3.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.35',what:'searching a box the way he does, with X held, shows where the item went: a better gun taken into the free second slot and a stim pinned to a free key on the tactical belt each get their line on screen once Took runs out, instead of both being written over by Took in the same frame (2026-09-13 hunt)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
