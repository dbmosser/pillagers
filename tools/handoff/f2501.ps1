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

if ($s.Contains("  {v:'25.01',what:")) { throw "check 25.01 is in the fixture already" }

SubRx @'
  {v:'25.00',what:
'@ @'
  {v:'25.01',what:'his order 2026-10-12, the lock-on beeping is annoying and inconsistent when machines get together, make it a low siren: with 1, 3 and 6 machines on him there is one siren voice that wails (pitch inside 200 to 400 Hz, period inside 1.2 to 1.6 s), a little louder and no slower with more, toward the nearest, on the machine bus; nothing plays with none on him, under the pause box or under G.sim; no machine beeps on its own; the seeded stream does not move',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof mkSentry!=='function'||typeof sndBus!=='function'||typeof updateEnts!=='function') return 'SKIP: this fixture cannot deploy a raid';
     if(typeof tickMachSiren!=='function'||typeof MSIREN!=='object') return 'machines that lock on are not one siren (no tickMachSiren): each still beeps on its own, a scatter of chirps when they get together';
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.value=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.value=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
     var MADE=[], OSC=[];
     function N(k,ps){ var o={kind:k,outs:[]}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(){}; o.stop=function(){}; (ps||[]).forEach(function(n){ o[n]=P(n==='gain'?1:0); }); MADE.push(o); return o; }
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
     var bad=[], g=null, p=null, E0=null, M=[], i, k, n, v=null, v1=null, pt, lo, hi, per, lv={}, pr={}, kMS={}, kPause=false, faked=false, oSfx=sfx, own=false, heard=[], r0, S, f, NS=[1,3,6];
     for(k in MSIREN) kMS[k]=MSIREN[k];
     function stage(cnt){ var j, q; for(j=0;j<M.length;j++){ M[j].state=(j<cnt)?'chase':'patrol'; M[j].alert=(j<cnt)?2:0; } g.ents=M.slice(); for(q=0;q<4;q++) tickMachSiren(1/60); return MSIREN.v; }
     function parts(){ var r={tone:null,lfo:null,dep:null}, j, m; for(j=0;j<OSC.length;j++) for(m=0;m<MADE.length;m++) if(MADE[m].kind==='gain'&&MADE[m].outs.indexOf(OSC[j].frequency)>=0){ r.tone=OSC[j]; r.dep=MADE[m]; } if(r.dep) for(j=0;j<OSC.length;j++) if(OSC[j].outs.indexOf(r.dep)>=0) r.lfo=OSC[j]; return r; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.ents) return 'SKIP: no live raid';
       p.iv=99; kPause=!!g.paused; g.paused=false;
       for(i=0;i<6;i++) M.push(mkSentry(p.x+Math.cos(i*Math.PI/3)*(200+i*50),p.y+Math.sin(i*Math.PI/3)*(200+i*50)));
       E0=g.ents;
       kSim=(G?G.sim:null); fakeOn(); faked=true; MSIREN.v=null; MSIREN.on=0; MSIREN.n=0;
       r0=RNGS;
       v=stage(0);
       if(OSC.length||(v&&v.g&&v.g.gain.value>0)) bad.push('with no machine on him the siren started ('+OSC.length+' oscillators)');
       for(i=0;i<NS.length;i++){
         n=NS[i]; v=stage(n);
         if(!v){ bad.push('with '+n+' machines on him no siren plays'); continue; }
         if(!v1) v1=v; else if(v!==v1) bad.push('with '+n+' machines on him the siren is a new voice, not the same one');
         if(OSC.length>2) bad.push('with '+n+' machines on him '+OSC.length+' oscillators run, more than one siren voice');
         pt=parts();
         if(!pt.tone||!pt.lfo||!pt.dep){ bad.push('the siren does not wail: no tone swept by a slow oscillator ('+OSC.length+' oscillators)'); continue; }
         lo=pt.tone.frequency.value-Math.abs(pt.dep.gain.value); hi=pt.tone.frequency.value+Math.abs(pt.dep.gain.value);
         if(!(lo>=200&&hi<=400)) bad.push('with '+n+' on him the siren sweeps '+Math.round(lo)+' to '+Math.round(hi)+' Hz, outside 200 to 400');
         if(!(hi-lo>=40)) bad.push('the siren hardly moves ('+Math.round(lo)+' to '+Math.round(hi)+' Hz): a hum, not a wail');
         if(pt.tone.type==='square'||pt.tone.type==='sawtooth') bad.push('the siren tone is a '+pt.tone.type+' buzz');
         per=1/pt.lfo.frequency.value; pr[n]=per;
         if(!(per>=1.2-1e-6&&per<=1.6+1e-6)) bad.push('with '+n+' on him the siren period is '+per.toFixed(2)+' s, outside 1.2 to 1.6');
         lv[n]=(v.g&&v.g.gain)?v.g.gain.value:0;
         if(!(lv[n]>0)) bad.push('with '+n+' on him the siren is silent');
       }
       if(lv[1]>0&&lv[6]>0&&!(lv[6]>=lv[1]&&lv[6]<=lv[1]*1.6)) bad.push('six on him is not a little louder than one ('+lv[1].toFixed(3)+' to '+lv[6].toFixed(3)+')');
       if(pr[1]&&pr[6]&&!(pr[6]<=pr[1])) bad.push('six on him wail slower than one ('+pr[6].toFixed(2)+' vs '+pr[1].toFixed(2)+' s)');
       if(v1){
         if(!reach(v1.g,sndBus('mach'))) bad.push('the siren does not reach the machine bus');
         if(v1.pn&&!(v1.pn.pan.value>0)) bad.push('the nearest machine on him is to his right but the siren pans '+v1.pn.pan.value);
       }
       v=stage(0);
       if(v&&v.g&&v.g.gain.value>0) bad.push('the siren plays on after no machine is on him ('+v.g.gain.value+')');
       if(MSIREN.on) bad.push('the siren still counts itself on with none on him');
       stage(3); g.paused=true; tickMachSiren(1/60);
       if(MSIREN.v&&MSIREN.v.g&&MSIREN.v.g.gain.value>0) bad.push('the siren plays under the pause box');
       g.paused=false;
       if(RNGS!==r0) bad.push('the siren moved the seeded stream');
       MSIREN.v=null; MSIREN.on=0; k=OSC.length; G.sim=true; stage(3); G.sim=false;
       if(OSC.length!==k||MSIREN.v) bad.push('the siren ran under G.sim');
       if(typeof SND_CAT==='object'&&SND_CAT&&SND_CAT.lockon) bad.push('the old per-machine lock-on beep is still in the sound table');
       stage(0); MSIREN.v=null;
       S=M[0]; S.state='patrol'; S.alert=0; S.face=Math.atan2(p.y-S.y,p.x-S.x); S.tx=S.x; S.ty=S.y; g.ents=[S];
       sfx=function(t){ heard.push(String(t)); }; own=true;
       for(f=0;f<4&&S.state!=='chase';f++) updateEnts(0.016);
       if(heard.indexOf('lockon')>=0) bad.push('a machine that locks on still beeps on its own');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(own) sfx=oSfx; }catch(_o){}
       try{ if(faked) fakeOff(); }catch(_f){}
       try{ for(k in kMS) MSIREN[k]=kMS[k]; }catch(_m){}
       try{ var g2=__state(); if(g2){ if(E0) g2.ents=E0; g2.paused=kPause; if(!g2.over){ g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
