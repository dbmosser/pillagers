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

if ($s.Contains("  {v:'24.04',what:")) { throw "check 24.04 is in the fixture already" }

SubRx @'
  {v:'24.03',what:
'@ @'
  {v:'24.04',what:'his #45 and answer 26 b, the announcer: the page carries the calls, the two and one minute marks call TWOMIN and ONEMIN, NEW HIGH SCORE calls HISCORE, every streak callout has a call, a call plays on the sting bus, a second call while one plays is dropped, and nothing plays under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof sndBus!=='function'||typeof tickClockWarn!=='function') return 'SKIP: this fixture cannot run a raid';
     if(typeof voxCall!=='function'||typeof VOX_ANN!=='object') return 'no announcer (no voxCall): a streak, a high score and the last minutes are only written';
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.value=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.value=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
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
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=(G?G.sim:null);
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     function fakeOn(){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(G) G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }     var bad=[], g=null, kV=voxCall, own=false, asked=[], keep=null, made, m0, src, s, n0, rs=say, ownS=false, i;
     try{
       ['DOUBLEKILL','TRIPLEKILL','MULTIKILL','RAMPAGE','UNSTOPPABLE','HISCORE','EXTRACTED','TWOMIN','ONEMIN','WAVE'].forEach(function(k){ var w=''; try{ w=atob(String(VOX_ANN[k]||'')).slice(0,4); }catch(_a){} if(w!=='RI'+'FF') bad.push('the '+k+' call is not a WAV clip'); });
       if(typeof ARCADE_STREAK!=='undefined') for(i=0;i<ARCADE_STREAK.length;i++) if(!VOX_STREAK[ARCADE_STREAK[i][2]]) bad.push('the streak '+ARCADE_STREAK[i][2]+' has no call');
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player) return 'SKIP: no live raid';
       say=function(){}; ownS=true;
       voxCall=function(k){ asked.push(k); return true; }; own=true;
       tickClockWarn(120.5,119.9); tickClockWarn(60.5,59.9);
       if(typeof arcadeHiSay==='function') arcadeHiSay(1000);
       voxCall=kV; own=false;
       if(asked.indexOf('TWOMIN')<0) bad.push('two minutes left is not called ('+asked.join(',')+')');
       if(asked.indexOf('ONEMIN')<0) bad.push('one minute left is not called ('+asked.join(',')+')');
       if(typeof arcadeHiSay==='function'&&asked.indexOf('HISCORE')<0) bad.push('NEW HIGH SCORE is not called ('+asked.join(',')+')');
       keep={buf:VOXA.buf,busy:VOXA.busy,n:VOXA.n,dec:VOXA.dec};
       kSim=(G?G.sim:null); fakeOn();
       VOXA.buf={WAVE:{duration:0.8},ONEMIN:{duration:0.5}}; VOXA.dec=1; VOXA.busy=-1; n0=VOXA.n;
       m0=MADE.length;
       if(!voxCall('WAVE')) bad.push('a ready WAVE INCOMING call did not play');
       made=MADE.slice(m0); src=made.filter(function(x){ return x.kind==='src'; })[0];
       if(!src||!reach(src,sndBus('sting'))) bad.push('the call does not play on the sting bus');
       voxCall('ONEMIN');
       if(VOXA.n!==n0+1) bad.push('a second call over a playing one also played ('+(VOXA.n-n0)+')');
       VOXA.busy=-1; G.sim=true; s=voxCall('WAVE'); G.sim=false;
       if(s) bad.push('a call played under G.sim');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) voxCall=kV;
       if(ownS) say=rs;
       try{ fakeOff(); }catch(_f){}
       try{ if(keep){ VOXA.buf=keep.buf; VOXA.busy=keep.busy; VOXA.n=keep.n; VOXA.dec=keep.dec; } }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
