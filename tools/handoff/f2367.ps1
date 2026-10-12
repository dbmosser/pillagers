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

if ($s.Contains("  {v:'23.67',what:")) { throw "check 23.67 is in the fixture already" }

SubRx @'
  {v:'23.66',what:
'@ @'
  {v:'23.67',what:'his #45, pro sound mix: each kind of sound rides its own bus, the world runs through a compressor and then a limiter into BUS, the HUD sounds skip them, and BUS stays the master (player 1 left, player 2 right kept)',
   run:function(){
     if(typeof _realBlip!=='function'||typeof AC==='undefined'||typeof BUS==='undefined'||typeof REV==='undefined'||typeof AMB==='undefined') return 'SKIP: this fixture has no real blip or audio holders to stand in for';
     if(typeof sndBus!=='function'||typeof SND==='undefined') return 'there is no bus for each kind of sound (no sndBus): every sound still goes raw into BUS with no compressor or limiter';
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
       fakeOn();
       var B=bus(), gun=sndBus('gun'), ui=sndBus('ui'), amb=sndBus('amb'), foley=sndBus('foley');
       if(!B||!SND||!gun||!ui) return 'no bus or no sound buses on the stand-in context';
       if(gun===B||ui===B||gun===ui) bad.push('a kind of sound has no bus of its own');
       if(gun.outs[0]!==SND.world) bad.push('the gun bus does not feed the world mix');
       if(!SND.comp||!SND.lim||SND.world.outs.indexOf(SND.comp)<0||SND.comp.outs.indexOf(SND.lim)<0||!reach(SND.lim,B)) bad.push('the world mix does not run through a compressor and then a limiter into BUS');
       else {
         if(!(SND.comp.ratio.value>1&&SND.comp.threshold.value<0)) bad.push('the compressor does not compress ('+SND.comp.ratio.value+' to 1 at '+SND.comp.threshold.value+')');
         if(!(SND.lim.ratio.value>=10)) bad.push('the limiter ratio is only '+SND.lim.ratio.value);
       }
       if(ui.outs[0]!==B||reach(ui,SND.comp)) bad.push('the HUD sounds run through the compressor instead of straight into BUS');
       if(B.outs.indexOf(FK.destination)<0) bad.push('BUS no longer reaches the speakers outside a same machine mode');
       var m0=MADE.length, made;
       _realBlip('shot',100,0,'rifle'); made=MADE.slice(m0);
       if(!made.length) bad.push('a rifle shot made no sound on the stand-in context');
       else if(!made.some(function(n){ return n.kind==='src'&&reach(n,gun); })) bad.push('a rifle shot does not ride the gun bus');
       m0=MADE.length; _realBlip('pick',100,0); made=MADE.slice(m0);
       if(!made.some(function(n){ return (n.kind==='osc'||n.kind==='src')&&reach(n,ui); })) bad.push('a pickup does not ride the HUD bus');
       if(made.some(function(n){ return reach(n,SND.comp); })) bad.push('a pickup is squashed by the world compressor');
       m0=MADE.length; _realBlip('foot',100,0,'stone','walk'); made=MADE.slice(m0);
       if(!made.some(function(n){ return n.kind==='src'&&reach(n,foley); })) bad.push('a footstep does not ride the foley bus');
       var A=ambience(); if(!A||!reach(A.g,amb)) bad.push('the ambient bed does not ride its own bus');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ fakeOff(); }catch(_f){} }
     return bad.length?bad.join('; '):null; }},
  {v:'23.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
