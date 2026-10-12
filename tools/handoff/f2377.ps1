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

if ($s.Contains("  {v:'23.77',what:")) { throw "check 23.77 is in the fixture already" }

SubRx @'
  {v:'23.76',what:
'@ @'
  {v:'23.77',what:'his #45, punchy guns: a shot 100 away gets a bright 4 kHz snap and no far thump, a shot 800 away loses the snap, is dulled to 800 Hz and gets a low thump, the open answers with a roll and a building with slaps, and no layer schedules a buffer over 6000 samples',
   run:function(){
     if(typeof _realBlip!=='function'||typeof sndBus!=='function') return 'SKIP: this fixture has no real blip or sound buses to stand in for';
     if(typeof gunLayers!=='function') return 'a gun sounds the same near and far and in every place, only quieter (no gunLayers)';
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
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }     var bad=[];
     try{
       var n=gunLayers(100,'open'), f=gunLayers(800,'open'), fi=gunLayers(800,'inside');
       if(!(n.click>0)) bad.push('a shot 100 away has no close snap');
       if(f.click!==0||!(f.tailG>0)||f.tailKind!=='roll'||!(f.crackK<1)||f.farLp!==800||!(f.thump>0)) bad.push('a shot 800 away in the open is not dulled with a thump and a roll ('+JSON.stringify(f)+')');
       if(fi.tailKind!=='slap') bad.push('a shot 800 away inside a building does not slap ('+fi.tailKind+')');
       kSim=(G?G.sim:null); fakeOn();
       var gun=sndBus('gun'), m0=MADE.length, made, hp, lp, th;
       _realBlip('shot',100,0,'rifle'); made=MADE.slice(m0);
       hp=made.filter(function(x){ return x.kind==='filter'&&x.type==='highpass'&&x.frequency.value>3700; });
       if(!hp.length||!reach(hp[0],gun)) bad.push('a rifle 100 away plays no 4 kHz snap');
       if(made.some(function(x){ return x.kind==='osc'&&x.frequency.value>0&&x.frequency.value<45; })) bad.push('a rifle 100 away plays the far thump');
       m0=MADE.length; _realBlip('shot',800,0,'rifle'); made=MADE.slice(m0);
       if(made.some(function(x){ return x.kind==='filter'&&x.type==='highpass'&&x.frequency.value>3700; })) bad.push('a rifle 800 away still snaps');
       lp=made.filter(function(x){ return x.kind==='filter'&&x.type==='lowpass'&&x.frequency.value>=740&&x.frequency.value<=860; });
       if(!lp.length) bad.push('a rifle 800 away is not dulled to 800 Hz');
       th=made.filter(function(x){ return x.kind==='osc'&&x.frequency.value>0&&x.frequency.value<45; });
       if(!th.length||!reach(th[0],gun)) bad.push('a rifle 800 away has no low thump');
       var big=0, orig=FK.createBuffer;
       FK.createBuffer=function(c,l,sr){ if(l>big) big=l; return orig(c,l,sr); };
       ['rifle','sniper','shotgun','pistol'].forEach(function(w){ [0,100,400,800].forEach(function(dd){ _realBlip('shot',dd,0,w); }); });
       FK.createBuffer=orig;
       if(big>6000) bad.push('a gunshot layer schedules a '+big+' sample buffer');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ fakeOff(); }catch(_f){} }
     return bad.length?bad.join('; '):null; }},
  {v:'23.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
