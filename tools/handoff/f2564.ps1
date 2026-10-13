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

if ($s.Contains("  {v:'25.64',what:")) { throw "check 25.64 is in the fixture already" }

SubRx @'
  {v:'25.63',what:
'@ @'
  {v:'25.64',what:'his order (the plop 50 percent quieter): the plain pick chirp that every belt key, equip, drag and menu press plays is at half its old gain at the source (.035, was .07), also with a distance; the green find keeps its old level; a belt key press never plays it louder',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof _realBlip!=='function'||typeof sndBus!=='function'||typeof setHot!=='function') return 'SKIP: this fixture cannot trace a sound';
     var bad=[], MADE=[], kSim=null, faked=false, g=null, p=null, i, sl, got, ix;
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.last=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.last=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
     function N(kn,ps){ var o={kind:kn,outs:[]}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(x){ o.at=x; }; o.stop=function(x){ o.end=x; }; (ps||[]).forEach(function(n){ o[n]=P(n==='gain'?1:0); }); MADE.push(o); return o; }
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
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=(typeof AMB!=='undefined')?AMB:null, kDuck=(typeof SND_DUCK!=='undefined')?SND_DUCK:null, kBlip=blip, kSay=say;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     function fakeOn(){ faked=true; AC=FK; BUS=null; REV=null; if(typeof AMB!=='undefined') AMB=null; if(typeof SND!=='undefined') SND=null; if(kDuck) SND_DUCK={}; if(G) G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ if(!faked) return; faked=false; AC=kAC; BUS=kBUS; REV=kREV; if(typeof AMB!=='undefined') AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(kDuck) SND_DUCK=kDuck; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     // the gain of the first sine voice that glides up from 660 (the pick chirp), started since m0; null when there is none
     function chirp(m0){ var o=MADE.slice(m0).filter(function(x){ return x.kind==='osc'&&x.type==='sine'&&Math.round(x.frequency.value)===660&&x.outs.length&&x.outs[0].gain; })[0]; return o?o.outs[0].gain.value:null; }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; kSim=g.sim; fakeOn(); say=function(){};
       i=MADE.length; _realBlip('pick'); got=chirp(i);
       if(got===null) bad.push('the pick chirp built no voice on the stand-in context');
       else if(Math.abs(got-0.035)>0.0002) bad.push('the pick chirp starts at gain '+got+', not half of the old .07');
       i=MADE.length; _realBlip('pick',225); got=chirp(i);
       if(got===null) bad.push('a pick at a distance built no voice');
       else if(Math.abs(got-0.035*(1-225/900))>0.0002) bad.push('a pick at 225 starts at gain '+got+', not half of the old level there');
       i=MADE.length; _realBlip('pickUnc'); got=chirp(i);
       if(got===null) bad.push('the green find built no chirp');
       else if(Math.abs(got-0.07)>0.0002) bad.push('the green find (pickUnc) starts at gain '+got+', it must keep the old .07');
       i=MADE.length; _realBlip('pickRare'); ix=MADE.slice(i).filter(function(x){ return x.kind==='osc'&&x.type==='triangle'&&Math.round(x.frequency.value)===784&&x.outs.length&&x.outs[0].gain; })[0];
       if(!ix) bad.push('the rare find built no voice'); else if(Math.abs(ix.outs[0].gain.value-0.075)>0.0002) bad.push('the rare find changed level: '+ix.outs[0].gain.value);
       // a belt key press: whatever pick chirp it plays is the new level, never the old one (a build may give the key a different sound)
       blip=_realBlip; sl=hotbarSlots();
       for(ix=0;ix<sl.length;ix++) if(ix!==G.hot&&sl[ix]){ i=MADE.length; setHot(ix); got=chirp(i); if(got!==null&&got>0.0351) bad.push('a belt key press plays the pick chirp at gain '+got+', over the new .035'); break; }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ blip=kBlip; say=kSay; }catch(_b){}
       fakeOff();
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
