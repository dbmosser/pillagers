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

if ($s.Contains("  {v:'24.57',what:")) { throw "check 24.57 is in the fixture already" }

SubRx @'
  {v:'24.56',what:
'@ @'
  {v:'24.57',what:'his #45 and answer 26 b, voice barks: the page carries a WAV clip for RELOADING, a reload (blipMine reload) asks for RELOADING and a dry gun for NOAMMO, a bark plays through the voice bus, a second bark inside 1.2 s is dropped, and nothing plays under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof sndBus!=='function'||typeof blipMine!=='function') return 'SKIP: this fixture cannot run a raid';
     if(typeof voxBark!=='function'||typeof VOX_BARKS!=='object') return 'no voice barks (no voxBark): reloading, going dry and going down are said only on the screen';
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
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }     var bad=[], g=null, kV=voxBark, own=false, asked=[], keep=null, made, m0, src, s, n0;
     try{
       ['RELOADING','NOAMMO','FRAGOUT','TRIPWIRE','DOWN','HEALING'].forEach(function(k){ var w=''; try{ w=atob(String(VOX_BARKS[k]||'')).slice(0,4); }catch(_a){} if(w!=='RI'+'FF') bad.push('the '+k+' bark is not a WAV clip'); });
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player) return 'SKIP: no live raid';
       voxBark=function(k){ asked.push(k); return true; }; own=true;
       blipMine('reload'); blipMine('dry');
       voxBark=kV; own=false;
       if(asked.indexOf('RELOADING')<0) bad.push('a reload does not ask for the RELOADING bark ('+asked.join(',')+')');
       if(asked.indexOf('NOAMMO')<0) bad.push('a dry gun does not ask for the OUT OF AMMO bark ('+asked.join(',')+')');
       keep={buf:VOX.buf,dec:VOX.dec,busy:VOX.busy,n:VOX.n,last:VOX.last};
       kSim=(G?G.sim:null); fakeOn();
       VOX.buf={RELOADING:{duration:0.4},NOAMMO:{duration:0.5}}; VOX.dec=1; VOX.busy=-1; n0=VOX.n;
       m0=MADE.length;
       if(!voxBark('RELOADING')) bad.push('a ready RELOADING bark did not play');
       made=MADE.slice(m0); src=made.filter(function(x){ return x.kind==='src'; })[0];
       if(!src||!reach(src,sndBus('vox'))) bad.push('the bark does not play through the voice bus');
       else if(!made.some(function(x){ return x.kind==='filter'&&x.type==='lowpass'&&x.frequency.value<=3400&&reach(src,x); })) bad.push('the bark has no radio band');
       voxBark('NOAMMO');
       if(VOX.n!==n0+1) bad.push('two barks inside 1.2 s both played ('+(VOX.n-n0)+')');
       VOX.busy=-1; G.sim=true; s=voxBark('RELOADING'); G.sim=false;
       if(s) bad.push('a bark played under G.sim');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) voxBark=kV;
       try{ fakeOff(); }catch(_f){}
       try{ if(keep){ VOX.buf=keep.buf; VOX.dec=keep.dec; VOX.busy=keep.busy; VOX.n=keep.n; VOX.last=keep.last; } }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
