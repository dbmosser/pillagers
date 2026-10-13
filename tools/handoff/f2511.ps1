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

if ($s.Contains("  {v:'25.11',what:")) { throw "check 25.11 is in the fixture already" }

SubRx @'
  {v:'25.10',what:
'@ @'
  {v:'25.11',what:'his note 2026-10-12, random hums as ambience do not sound good: no machine hum loops (MACH_LOOP), the ambient bed holds no oscillator, and 3 s of a raid with a machine hunting out of sight start no oscillator that never stops, while the room noise and rain still play and ambienceOff still cuts the bed',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof losClear!=='function'||typeof sndBus!=='function'||typeof ambience!=='function'||typeof ambienceOff!=='function'||typeof AMB==='undefined'||typeof AMBOFF!=='number') return 'SKIP: this fixture cannot deploy a raid';
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.value=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.value=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
     var MADE=[], OSC=[];
     function N(k,ps){ var o={kind:k,outs:[],on:0,off:0}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(){ o.on=1; }; o.stop=function(){ o.off=1; }; (ps||[]).forEach(function(n){ o[n]=P(n==='gain'?1:0); }); MADE.push(o); return o; }
     var FK={currentTime:1,sampleRate:48000,state:'running',resume:function(){},destination:N('dest'),
       createGain:function(){ return N('gain',['gain']); },
       createBiquadFilter:function(){ var o=N('filter',['frequency','Q','gain','detune']); o.type='lowpass'; return o; },
       createStereoPanner:function(){ return N('pan',['pan']); },
       createDynamicsCompressor:function(){ return N('comp',['threshold','knee','ratio','attack','release']); },
       createOscillator:function(){ var o=N('osc',['frequency','detune']); o.type='sine'; OSC.push(o); return o; },
       createDelay:function(){ return N('delay',['delayTime']); },
       createBufferSource:function(){ var o=N('src',['playbackRate','detune']); o.buffer=null; o.loop=false; return o; },
       createWaveShaper:function(){ var o=N('shaper'); o.curve=null; return o; },
       createBuffer:function(c,l,sr){ return {length:l,numberOfChannels:c,sampleRate:sr,getChannelData:function(){ return new Float32Array(l); }}; },
       decodeAudioData:function(){ return Promise.resolve({}); }};
     function reach(n,t){ var q=[n],seen=[],i=0,x,j; while(i<q.length&&i<6000){ x=q[i++]; if(x===t) return true; if(!x||seen.indexOf(x)>=0) continue; seen.push(x); for(j=0;j<(x.outs||[]).length;j++) q.push(x.outs[j]); } return false; }
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=(G?G.sim:null);
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     function fakeOn(){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(G) G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     var bad=[], g=null, p=null, px=0, py=0, e=null, ex=0, ey=0, est='', s, i, k, M, n, L2, A, B2, C, hid=null, faked=false;
     var hasL=(typeof SND_LOOPS!=='undefined'), kL=hasL?SND_LOOPS:null, KINDS=['sentry','crawler','warden','snitch','listener','howler','bulwark'];
     var r0, o0, Am, srcN=0, live=0, cut0, tick=null, fr, cands;
     if(typeof MACH_LOOP!=='undefined') bad.push('the machine hum loops (MACH_LOOP) are still in the game');
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.map||!g.map.segs||!g.ents) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length&&!e;i++){ s=g.ents[i]; if(s&&KINDS.indexOf(s.kind)>=0&&s.hp>0&&!s.merc&&!s.friendly&&!s.neutral) e=s; }
       if(!e) return 'SKIP: no machine in this raid';
       p=g.player; px=p.x; py=p.y; ex=e.x; ey=e.y; est=e.state;
       for(i=0;i<g.map.segs.length&&!hid;i++){
         s=g.map.segs[i]; L2=Math.hypot(s.x2-s.x1,s.y2-s.y1); if(L2<60) continue;
         M={x:(s.x1+s.x2)/2,y:(s.y1+s.y2)/2}; n={x:-(s.y2-s.y1)/L2,y:(s.x2-s.x1)/L2};
         A={x:M.x+n.x*50,y:M.y+n.y*50}; B2={x:M.x-n.x*90,y:M.y-n.y*90};
         if(losClear(A.x,A.y,B2.x,B2.y,g.map.segs)) continue;
         C={x:A.x+n.x*200,y:A.y+n.y*200};
         if(!losClear(A.x,A.y,C.x,C.y,g.map.segs)) continue;
         hid=B2;
       }
       if(!hid) return 'SKIP: no wall here with open ground on one side';
       kSim=(G?G.sim:null); kAMB=AMB; fakeOn(); faked=true; if(hasL) SND_LOOPS=null;
       p.x=A.x; p.y=A.y; e.x=hid.x; e.y=hid.y; e.state='chase';
       r0=RNGS; o0=OSC.length;
       Am=ambience();
       if(!Am) bad.push('control: the ambient bed did not build on a stand-in audio context');
       else{
         if(OSC.length!==o0) bad.push('building the ambient bed made '+(OSC.length-o0)+' oscillators, a tone that runs the whole raid');
         for(k in Am) if(Am[k]&&OSC.indexOf(Am[k])>=0) bad.push('the ambient bed holds an oscillator voice ('+k+')');
         for(i=0;i<MADE.length;i++) if(MADE[i].kind==='src'&&MADE[i].loop&&MADE[i].on) srcN++;
         if(srcN<2) bad.push('the room tone and rain noise layers are gone ('+srcN+' looping noise voices)');
         if(!Am.g||!reach(Am.g,sndBus('amb'))) bad.push('the ambient bed does not reach the ambience bus');
       }
       cands=[window.__audio&&window.__audio.amb, tickAmbience];
       for(i=0;i<cands.length&&!tick;i++) if(typeof cands[i]==='function'&&String(cands[i]).indexOf('ambience(')>=0) tick=cands[i];
       for(fr=0;fr<180;fr++){
         if(tick) tick(1/60,0.9,true,0.8);
         if(typeof tickMachLoops==='function') tickMachLoops(1/60);
       }
       if(RNGS!==r0) bad.push('the ambience moved the seeded stream');
       for(i=0;i<OSC.length;i++) if(OSC[i].on&&!OSC[i].off) live++;
       if(live) bad.push(live+' oscillators started by the raid ambience over 3 s with a machine hunting out of sight never stop (a running hum)');
       cut0=AMBOFF;
       if(ambienceOff()!==true||AMBOFF!==cut0+1) bad.push('ambienceOff no longer cuts what is left of the bed');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(hasL) SND_LOOPS=kL; if(faked) fakeOff(); }catch(_f){}
       try{ if(p){ p.x=px; p.y=py; } if(e){ e.x=ex; e.y=ey; e.state=est; } }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
