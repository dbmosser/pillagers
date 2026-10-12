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

if ($s.Contains("  {v:'23.90',what:")) { throw "check 23.90 is in the fixture already" }

SubRx @'
  {v:'23.89',what:
'@ @'
  {v:'23.90',what:'his #45, footsteps: a real player step passes one of the five surfaces fourth and a finer ground sixth, its noise in the world keeps the same radius, and a step on grit or in the wet plays an extra layer that a plain step does not',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof _realBlip!=='function'||!window.__stepsReal||typeof sndBus!=='function'||typeof ping!=='function') return 'SKIP: this fixture has no real steps or blip to trace';
     if(typeof surfFine!=='function') return 'every street, yard and puddle gives the same step (no surfFine): the ground is only ever one of five surfaces';
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
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }     var bad=[], keepBlip=blip, keepPing=ping, calls=[], pings=[], g=null, p=null, kMov, kDown, kRoll, kSpr, kTog;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       p=g.player; kMov=p.moving; kDown=p.downed; kRoll=p.roll; kSpr=g.sprinting; kTog=g.crouchTog;
       blip=function(){ calls.push([].slice.call(arguments)); };
       ping=function(x,y,r){ pings.push(r); };
       p.moving=true; p.downed=false; p.roll=0; g.sprinting=false; g.crouchTog=false; if(g.sim) g.sim=false; PSTEP=0;
       __stepsReal(0.016);
       blip=keepBlip; ping=keepPing;
       var st=calls.filter(function(c){ return c[0]==='foot'; })[0];
       if(!st) return 'SKIP: a real step played nothing here';
       var surf=st[3];
       if(['stone','wood','metal','leaf','water'].indexOf(surf)<0) bad.push('the fourth argument of a step is no longer one of the five surfaces ('+surf+')');
       if(['wet','grit','concrete','tile','boards','grate','leaf','water'].indexOf(st[5])<0) bad.push('a real step passes no finer ground ('+st[5]+')');
       var want=170*(surf==='water'?1.55:(surf==='metal'?1.30:(surf==='leaf'?1.20:1)));
       if(Math.abs((pings[0]||0)-want)>1e-6) bad.push('the step noise radius moved to '+pings[0]+' from '+want);
       kSim=(G?G.sim:null); fakeOn();
       var foley=sndBus('foley'), m0=MADE.length, plain, grit, wet;
       _realBlip('foot',180,0,'stone','walk'); plain=MADE.slice(m0).filter(function(x){ return x.kind==='src'; }).length;
       m0=MADE.length; _realBlip('foot',180,0,'stone','walk','grit'); var mg=MADE.slice(m0); grit=mg.filter(function(x){ return x.kind==='src'; }).length;
       m0=MADE.length; _realBlip('foot',180,0,'stone','walk','wet'); wet=MADE.slice(m0).filter(function(x){ return x.kind==='src'; }).length;
       if(!(grit>plain)||!(wet>plain)) bad.push('a step on grit or in the wet plays nothing more than a plain step ('+plain+', '+grit+', '+wet+')');
       if(!mg.some(function(x){ return x.kind==='filter'&&x.type==='highpass'&&x.frequency.value>4000&&reach(x,foley); })) bad.push('grit underfoot has no crunch on the foley bus');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       blip=keepBlip; ping=keepPing;
       try{ fakeOff(); }catch(_f){}
       try{ if(p){ p.moving=kMov; p.downed=kDown; p.roll=kRoll; } if(g){ g.sprinting=kSpr; g.crouchTog=kTog; } PSTEP=0; var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
