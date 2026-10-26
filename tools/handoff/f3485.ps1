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

if ($s.Contains("  {v:'34.85',what:")) { throw "check 34.85 is in the fixture already" }

SubRx @'
  {v:'34.84',what:
'@ @'
  {v:'34.85',what:'cw-shsiren, his note of 2026-10-25 ("weird noise lingering", played with Superhot on): in a live raid frame with Superhot on and a sentry locked on him, the lock-on siren fades out while no input holds time still (one second of audio clock passing, its scheduled gain read back), is back on the first frame time moves while the sentry still has him (with no second LOCKED ON), and sounds on while time moves: a key held, a teammate acting in two players, Superhot off',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)||typeof lastTs!=='number') return 'SKIP: this fixture cannot step a live raid frame';
     if(typeof tickMachSiren!=='function'||typeof MSIREN!=='object'||typeof machSirenLocked!=='function'||typeof mkSentry!=='function'||typeof netAnyActing!=='function'||typeof sndBus!=='function'||typeof losClear!=='function'||typeof say!=='function') return 'SKIP: no lock-on siren to stage in this build';
     var FK=null;
     // an audio param that keeps its schedule, so the gain is read at a given audio clock time (setTargetAtTime curves, cancelScheduledValues as the spec has it)
     function PR(v0){
       var q={ev:[],b:+v0||0};
       Object.defineProperty(q,'value',{get:function(){ return q.at(FK?FK.currentTime:0); },set:function(x){ q.b=+x||0; q.ev=[]; }});
       q.setValueAtTime=function(x,t){ q.ev.push({k:0,v:+x||0,t:+t||0}); return q; };
       q.linearRampToValueAtTime=function(x,t){ q.ev.push({k:0,v:+x||0,t:+t||0}); return q; };
       q.exponentialRampToValueAtTime=function(x,t){ q.ev.push({k:0,v:+x||0,t:+t||0}); return q; };
       q.setTargetAtTime=function(x,t,c){ q.ev.push({k:1,v:+x||0,t:+t||0,c:Math.max(1e-4,+c||0)}); return q; };
       q.cancelScheduledValues=function(t){ q.ev=q.ev.filter(function(e){ return e.t<t; }); return q; };
       q.cancelAndHoldAtTime=function(t){ return q.cancelScheduledValues(t); };
       q.at=function(T){
         var es=q.ev.map(function(e,i){ return {e:e,i:i}; }).sort(function(a,b){ return (a.e.t-b.e.t)||(a.i-b.i); }), cur=q.b, act=null, j, e;
         for(j=0;j<es.length;j++){ e=es[j].e; if(e.t>T) break; if(act) cur=act.v+(act.v0-act.v)*Math.exp(-(e.t-act.t)/act.c); if(e.k===0){ cur=e.v; act=null; } else act={v:e.v,t:e.t,c:e.c,v0:cur}; }
         if(act) cur=act.v+(act.v0-act.v)*Math.exp(-(T-act.t)/act.c);
         return cur;
       };
       return q;
     }
     function N(k,ps){ var o={kind:k,outs:[],stopped:0}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(){}; o.stop=function(){ o.stopped=1; }; (ps||[]).forEach(function(n){ o[n]=PR(n==='gain'?1:0); }); return o; }
     FK={currentTime:5,sampleRate:48000,state:'running',resume:function(){},suspend:function(){ return Promise.resolve(); },destination:N('dest'),
       createGain:function(){ return N('gain',['gain']); },
       createBiquadFilter:function(){ var o=N('filter',['frequency','Q','gain','detune']); o.type='lowpass'; return o; },
       createStereoPanner:function(){ return N('pan',['pan']); },
       createDynamicsCompressor:function(){ return N('comp',['threshold','knee','ratio','attack','release']); },
       createOscillator:function(){ var o=N('osc',['frequency','detune']); o.type='sine'; return o; },
       createDelay:function(){ return N('delay',['delayTime']); },
       createBufferSource:function(){ var o=N('src',['playbackRate','detune']); o.buffer=null; o.loop=false; return o; },
       createWaveShaper:function(){ var o=N('shaper'); o.curve=null; return o; },
       createBuffer:function(c,l,sr){ return {length:l,numberOfChannels:c,sampleRate:sr,duration:l/sr,getChannelData:function(){ return new Float32Array(l); }}; },
       decodeAudioData:function(){ return Promise.resolve({}); }};
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=(G?G.sim:null);
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     function fakeOn(){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(G) G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     var bad=[], g=null, p=null, E0=null, S=null, kMS={}, k, i, ang, sx, sy, faked=false, kTs=lastTs, kSH=CFG.superhot, kCap=CFG.fpsCap, kNAA=netAnyActing, kSay=say, saids=0, v1=null, lv=0, t0, tF, aF, hi=0, onF=0, nF=0, t4, off4=0, t5, off5=0, gb;
     for(k in MSIREN) kMS[k]=MSIREN[k];
     function keysOff(){ var K=__keysRef(), q; for(q in K) K[q]=false; if(typeof mouse!=='undefined'&&mouse) mouse.down=false; }
     // one raid frame of 1/60 s on the real loop: the audio clock always moves, game time only when the Superhot gate lets it; hold is a key nothing else reads
     function frame(hold){ keysOff(); if(hold) __keysRef().KeyK=true; p.iv=99; if(p.hp<90) p.hp=90; g.waveT=-1e9; FK.currentTime+=1/60; try{ __loop(lastTs+1000/60); } finally{ keysOff(); } }
     function gainAt(v,ahead){ return (v&&v.g&&v.g.gain&&v.g.gain.at)?v.g.gain.at(FK.currentTime+(ahead||0)):0; }
     function f4(x){ return (+x||0).toFixed(4); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.ents||!g.vseg) return 'SKIP: no live raid';
       g.paused=false; g.mapFirst=0; g.mapOpen=false; g.bagOpen=false; p.downed=false; p.roll=0; p.reloading=0; p.prep=null; p.prepA=null;
       E0=g.ents;
       for(i=0;i<16&&!S;i++){ ang=i*Math.PI/8; sx=p.x+Math.cos(ang)*220; sy=p.y+Math.sin(ang)*220; if(losClear(sx,sy,p.x,p.y,g.vseg)&&losClear(p.x,p.y,sx,sy,g.vseg)) S=mkSentry(sx,sy); }
       if(!S) return 'SKIP: staging: no open line 220 from him on this map';
       S.state='chase'; S.alert=2; S.face=Math.atan2(p.y-S.y,p.x-S.x); S.tx=p.x; S.ty=p.y; g.ents=[S];
       fakeOn(); faked=true; MSIREN.v=null; MSIREN.on=0; MSIREN.n=0; MSIREN.lvl=0; MSIREN.said=0;
       say=function(m,c,o){ if(o&&o.key==='msiren') saids++; return kSay.apply(this,arguments); };
       CFG.superhot=1; CFG.fpsCap=0;
       // ONE (control): Superhot on, a key held so time moves, the sentry finds him and locks on through its own sight
       t0=g.t; for(i=0;i<90;i++) frame(true);
       if(!(g.t-t0>1.2)) bad.push('staging: with a key held under Superhot the raid clock moved '+(g.t-t0).toFixed(2)+' s in 1.5 s');
       if(!machSirenLocked(S,p)) return 'staging: the sentry 220 from him never locked on in 1.5 s (state '+S.state+', last saw him '+(g.t-(S.sirenSeeT===undefined?-99:S.sirenSeeT)).toFixed(2)+' s ago)';
       v1=MSIREN.v; lv=MSIREN.lvl;
       if(!MSIREN.on||!v1||!(lv>0)||!(gainAt(v1)>0.5*lv)) bad.push('control: with time moving under Superhot (a key held) and the sentry on him for 1.5 s the lock-on siren is not sounding (on '+MSIREN.on+', gain '+f4(gainAt(v1))+' of '+f4(lv)+')');
       // TWO (his note): no input, Superhot holds time still for one second of audio clock while the sentry still has him
       tF=g.t; aF=FK.currentTime;
       for(i=0;i<60;i++){ frame(false); if(FK.currentTime-aF>0.4){ nF++; if(MSIREN.on) onF++; hi=Math.max(hi,gainAt(v1),gainAt(MSIREN.v)); } }
       if(Math.abs(g.t-tF)>1e-9) bad.push('staging: with no input under Superhot the raid clock still moved '+(g.t-tF).toFixed(3)+' s, so time did not stand still');
       if(!machSirenLocked(S,p)) bad.push('staging: the sentry let go of him during the freeze, so the freeze proves nothing');
       if(onF||!(hi<=0.05*lv)) bad.push('with Superhot holding time still and the sentry still on him, the lock-on siren wails on through one second of audio clock (on in '+onF+' of the last '+nF+' frames, gain up to '+f4(hi)+' of '+f4(lv)+')');
       // THREE: the first frame time moves again brings it back while the sentry still has him, and no second LOCKED ON
       frame(true);
       if(!(g.t>tF)) bad.push('staging: one frame with a key held did not move time');
       if(!MSIREN.on||!MSIREN.v||!(MSIREN.lvl>0)||!(gainAt(MSIREN.v,0.15)>0.5*MSIREN.lvl)) bad.push('the first frame time moves again does not bring the lock-on siren back while the sentry still has him (on '+MSIREN.on+', gain in 0.15 s '+f4(gainAt(MSIREN.v,0.15))+' of '+f4(MSIREN.lvl)+')');
       // FOUR (control, two players): no input in this window but a teammate acting, so time moves: the siren sounds on
       netAnyActing=function(){ return true; };
       t4=g.t; for(i=0;i<30;i++){ frame(false); if(!MSIREN.on) off4++; }
       netAnyActing=kNAA;
       if(!(g.t-t4>0.4)) bad.push('staging: with a teammate acting the raid clock moved only '+(g.t-t4).toFixed(2)+' s');
       if(off4||!(gainAt(MSIREN.v)>0.5*MSIREN.lvl)) bad.push('two players: with a teammate acting (time moving, no input in this window) the lock-on siren went quiet ('+off4+' of 30 frames off, gain '+f4(gainAt(MSIREN.v))+' of '+f4(MSIREN.lvl)+')');
       // FIVE (control): Superhot off, no input, time moves: the siren sounds on
       CFG.superhot=0; t5=g.t; for(i=0;i<30;i++){ frame(false); if(!MSIREN.on) off5++; }
       if(!(g.t-t5>0.4)) bad.push('staging: with Superhot off the raid clock moved only '+(g.t-t5).toFixed(2)+' s');
       if(off5||!(gainAt(MSIREN.v)>0.5*MSIREN.lvl)) bad.push('control: with Superhot off the lock-on siren went quiet ('+off5+' of 30 frames off, gain '+f4(gainAt(MSIREN.v))+' of '+f4(MSIREN.lvl)+')');
       if(saids!==1) bad.push('one lock-on said LOCKED ON '+saids+' times, not once');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ netAnyActing=kNAA; }catch(_n){}
       try{ say=kSay; }catch(_s){}
       try{ CFG.superhot=kSH; CFG.fpsCap=kCap; }catch(_c){}
       try{ keysOff(); }catch(_k){}
       try{ if(faked) fakeOff(); }catch(_f){}
       try{ for(k in kMS) MSIREN[k]=kMS[k]; }catch(_m){}
       try{ lastTs=kTs; }catch(_t){}
       try{ gb=__state(); if(gb){ if(E0) gb.ents=E0; if(!gb.over){ gb.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
