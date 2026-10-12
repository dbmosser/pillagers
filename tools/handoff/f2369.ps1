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

if ($s.Contains("  {v:'23.69',what:")) { throw "check 23.69 is in the fixture already" }

SubRx @'
  {v:'23.68',what:
'@ @'
  {v:'23.69',what:'his #45, ducking: a blast 100 away pulls the bed to 0.35 or less, the machines and the footsteps down, never the HUD; the bed holds, then comes back up through the frame tick; a blast 800 away ducks nothing; a hit on you pulls the bed down',
   run:function(){
     if(typeof _realBlip!=='function'||typeof AC==='undefined'||typeof BUS==='undefined'||typeof REV==='undefined'||typeof AMB==='undefined'||typeof sndBus!=='function') return 'SKIP: this fixture has no real blip or sound buses to stand in for';
     if(typeof sndDuck!=='function'||typeof SND_DUCK==='undefined') return 'nothing ducks (no sndDuck): a blast beside you lands on top of the bed, the machines and your feet at full level';
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
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }     var bad=[], kDuck=SND_DUCK;
     try{
       fakeOn(); SND_DUCK={};
       var amb=sndBus('amb'), ui=sndBus('ui'), mach=sndBus('mach'), foley=sndBus('foley');
       if(!amb||!SND) return 'no sound buses on the stand-in context';
       _realBlip('boom',100,0);
       if(!(amb.gain.value<=0.4)) bad.push('a blast 100 away left the bed at '+amb.gain.value);
       if(!(mach.gain.value<=0.65)) bad.push('a blast 100 away left the machines at '+mach.gain.value);
       if(!(foley.gain.value<=0.75)) bad.push('a blast 100 away left the footsteps at '+foley.gain.value);
       if(ui.gain.value!==1) bad.push('a blast ducked the HUD bus to '+ui.gain.value);
       tickVerb(0.3);
       if(!(amb.gain.value<=0.4)) bad.push('the bed came back before the hold was over ('+amb.gain.value+')');
       tickVerb(2.5);
       if(!(amb.gain.value>=0.95)) bad.push('the frame tick did not bring the bed back up ('+amb.gain.value+' after 2.8 s)');
       if(!(mach.gain.value>=0.95)) bad.push('the frame tick did not bring the machines back up ('+mach.gain.value+')');
       _realBlip('boom',800,0);
       if(amb.gain.value<0.95) bad.push('a blast 800 away ducked the bed to '+amb.gain.value);
       voxGrunt(true);
       if(!(amb.gain.value<=0.75)) bad.push('a hit on you left the bed at '+amb.gain.value);
       if(ui.gain.value!==1) bad.push('the HUD bus moved ('+ui.gain.value+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ SND_DUCK=kDuck; fakeOff(); }catch(_f){} }
     return bad.length?bad.join('; '):null; }},
  {v:'23.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
