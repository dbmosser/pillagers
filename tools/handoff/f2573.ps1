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

if ($s.Contains("  {v:'25.73',what:")) { throw "check 25.73 is in the fixture already" }

SubRx @'
  {v:'25.72',what:
'@ @'
  {v:'25.73',what:'his order (no spoken sounds, game sounds instead): the page carries no announcer clip or voice, and each big moment (a wave, the five kill streaks, NEW HIGH SCORE, EXTRACTED, the two and one minute marks) plays one oscillator sound on the sting bus, never a recorded clip, once, climbing with the streak level, nothing under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof sndBus!=='function'||typeof tickClockWarn!=='function') return 'SKIP: this fixture cannot run a raid';
     if(typeof annCue!=='function'||typeof annSpec!=='function'||typeof ANNC!=='object') return 'the moments have no game sounds (no annCue): the announcer clips still speak them';
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.last=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.last=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
     var MADE=[];
     function N(k,ps){ var o={kind:k,outs:[]}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(){}; o.stop=function(){}; (ps||[]).forEach(function(n){ o[n]=P(n==='gain'?1:0); }); MADE.push(o); return o; }
     var FK={currentTime:1,sampleRate:48000,state:'running',resume:function(){},destination:N('dest'),
       createGain:function(){ return N('gain',['gain']); },
       createBiquadFilter:function(){ var o=N('filter',['frequency','Q','gain','detune']); o.type='lowpass'; return o; },
       createStereoPanner:function(){ return N('pan',['pan']); },
       createDynamicsCompressor:function(){ return N('comp',['threshold','knee','ratio','attack','release']); },
       createOscillator:function(){ var o=N('osc',['frequency','detune']); o.type='sine'; return o; },
       createDelay:function(){ return N('delay',['delayTime']); },
       createBufferSource:function(){ var o=N('src',['playbackRate','detune']); o.buffer=null; o.loop=false; return o; },
       createWaveShaper:function(){ var o=N('shaper'); o.curve=null; return o; },
       createBuffer:function(c,l,sr){ return {length:l,numberOfChannels:c,sampleRate:sr,getChannelData:function(){ return new Float32Array(l); }}; },
       decodeAudioData:function(){ return Promise.resolve({}); }};
     function reach(n,t){ var q=[n],seen=[],i=0,x,j; while(i<q.length&&i<6000){ x=q[i++]; if(x===t) return true; if(!x||seen.indexOf(x)>=0) continue; seen.push(x); for(j=0;j<(x.outs||[]).length;j++) q.push(x.outs[j]); } return false; }
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=(G?G.sim:null), kSay=say, kAnn={busy:ANNC.busy,n:ANNC.n,last:ANNC.last};
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     function fakeOn(){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(G) G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     var KS=['DOUBLEKILL','TRIPLEKILL','MULTIKILL','RAMPAGE','UNSTOPPABLE','HISCORE','EXTRACTED','TWOMIN','ONEMIN','WAVE'];
     var bad=[], g=null, m0, made, osc, firsts={}, counts={}, i, j, q, k, sp, peak, sum, cur, s, src;
     try{
       for(k in window){ try{ if(window[k]&&typeof window[k]==='object'&&typeof window[k].DOUBLEKILL==='string') bad.push('a table of recorded announcer clips ('+k+') is still in the page'); }catch(_w){} }
       if(typeof window['VOX'+'_ANN']!=='undefined') bad.push('the announcer clip table is still in the page');
       if(typeof window['vox'+'Call']!=='undefined') bad.push('the announcer player is still in the page');
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       say=function(){};
       fakeOn();
       for(i=0;i<KS.length;i++){
         k=KS[i]; ANNC.busy=-1; m0=MADE.length; j=ANNC.n;
         s=annCue(k);
         made=MADE.slice(m0); osc=made.filter(function(x){ return x.kind==='osc'; });
         if(!s||ANNC.n!==j+1) bad.push(k+' did not play once ('+ANNC.n+' vs '+j+')');
         if(made.some(function(x){ return x.kind==='src'; })) bad.push(k+' plays a recorded clip');
         if(!osc.length) bad.push(k+' builds no oscillator');
         else if(!osc.every(function(x){ return reach(x,sndBus('sting')); })) bad.push(k+' does not play on the sting bus');
         if(osc.length){ firsts[k]=Math.round(osc[0].frequency.value); counts[k]=osc.length; }
         sp=annSpec(k); sum=0; for(j=0;j<sp.notes.length;j++){ peak=sp.notes[j][5]; if(peak>0.12) bad.push(k+' has a note at '+peak); cur=0; for(q=0;q<sp.notes.length;q++) if(sp.notes[q][0]<=sp.notes[j][0]+1e-9&&sp.notes[q][0]+sp.notes[q][3]>sp.notes[j][0]) cur+=sp.notes[q][5]; sum=Math.max(sum,cur); }
         if(sum>0.34) bad.push(k+' sums to '+sum.toFixed(2)+', too loud at once under gunfire');
       }
       ANNC.busy=-1; annCue('WAVE'); j=ANNC.n; annCue('ONEMIN'); if(ANNC.n!==j) bad.push('a second cue over a playing one also played');
       for(i=1;i<5;i++) if(!(firsts[KS[i]]>firsts[KS[i-1]])||!(counts[KS[i]]>counts[KS[i-1]])) bad.push('the streak ladder does not climb from '+KS[i-1]+' to '+KS[i]+' ('+firsts[KS[i-1]]+' to '+firsts[KS[i]]+' Hz, '+counts[KS[i-1]]+' to '+counts[KS[i]]+' voices)');
       if(typeof ARCADE_STREAK!=='undefined') for(i=0;i<ARCADE_STREAK.length;i++) if(!ANN_STREAK[ARCADE_STREAK[i][2]]) bad.push('the streak '+ARCADE_STREAK[i][2]+' has no sound');
       ANNC.busy=-1; j=ANNC.n; tickClockWarn(120.5,119.9); if(ANNC.last!=='TWOMIN'||ANNC.n!==j+1) bad.push('two minutes left plays '+ANNC.last+' ('+(ANNC.n-j)+')');
       ANNC.busy=-1; j=ANNC.n; tickClockWarn(60.5,59.9); if(ANNC.last!=='ONEMIN'||ANNC.n!==j+1) bad.push('one minute left plays '+ANNC.last+' ('+(ANNC.n-j)+')');
       ANNC.busy=-1; j=ANNC.n; if(typeof arcadeHiSay==='function'){ arcadeHiSay(1000); if(ANNC.last!=='HISCORE'||ANNC.n!==j+1) bad.push('NEW HIGH SCORE plays '+ANNC.last+' ('+(ANNC.n-j)+')'); }
       ANNC.busy=-1; G.sim=true; j=ANNC.n; s=annCue('WAVE'); G.sim=false; if(s||ANNC.n!==j) bad.push('a cue played under G.sim');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ say=kSay; }catch(_s){}
       try{ fakeOff(); }catch(_f){}
       try{ ANNC.busy=kAnn.busy; ANNC.n=kAnn.n; ANNC.last=kAnn.last; }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,6).join('; '):null; }},
  {v:'25.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
