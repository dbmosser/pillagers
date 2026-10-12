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

if ($s.Contains("  {v:'23.91',what:")) { throw "check 23.91 is in the fixture already" }

SubRx @'
  {v:'23.90',what:
'@ @'
  {v:'23.91',what:'his #45, the hit marker is heard: a fresh hit marker plays the hit tick once in the frame that ages it, a kill marker plays the kill confirm, and both ride the HUD bus',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)||typeof lastTs!=='number'||typeof _realBlip!=='function'||typeof sndBus!=='function') return 'SKIP: this fixture cannot deploy and step a live frame';
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
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }     var bad=[], g=null, keepBlip=blip, keepTs=lastTs, heard=[], ents=null;
     function frame(){ var K=__keysRef(), k; for(k in K) K[k]=false; heard.length=0; g.waveT=-1e9; g.player.iv=99; __loop(lastTs+16); return heard.slice(); }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       ents=g.ents.slice(); g.ents.length=0;
       blip=function(t){ heard.push(String(t)); };
       g.hitMark={t:0,life:.26,kill:false};
       var h1=frame();
       if(h1.indexOf('hitmark')<0) bad.push('a fresh hit marker plays no hit tick ('+(h1.join(',')||'nothing')+')');
       var h2=frame();
       if(h2.indexOf('hitmark')>=0) bad.push('the same hit marker ticked twice');
       g.hitMark={t:0,life:.44,kill:true};
       var h3=frame();
       if(h3.indexOf('killconf')<0) bad.push('a kill marker plays no kill confirm ('+(h3.join(',')||'nothing')+')');
       blip=keepBlip;
       kSim=(G?G.sim:null); fakeOn();
       var ui=sndBus('ui'), m0=MADE.length, made;
       _realBlip('killconf'); made=MADE.slice(m0);
       if(made.filter(function(x){ return x.kind==='osc'; }).length<3||!made.some(function(x){ return x.kind==='osc'&&reach(x,ui); })) bad.push('the kill confirm is not a tick, a thunk and a ding on the HUD bus');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       blip=keepBlip;
       try{ fakeOff(); }catch(_f){}
       try{ lastTs=keepTs; }catch(_t){}
       try{ if(g&&ents){ g.ents.length=0; Array.prototype.push.apply(g.ents,ents); } var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
