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

if ($s.Contains("  {v:'23.84',what:")) { throw "check 23.84 is in the fixture already" }

SubRx @'
  {v:'23.83',what:
'@ @'
  {v:'23.84',what:'his #45, impacts by material: matOf and entMat name what was hit, a round on a wall passes the wall material, a hit on a body passes the body material, glass shatters and flesh thuds on the stand-in context, and a clank with no material plays exactly the old single tick',
   run:function(){
     if(typeof _realBlip!=='function'||typeof sndBus!=='function') return 'SKIP: this fixture has no real blip or sound buses to stand in for';
     if(typeof matOf!=='function'||typeof entMat!=='function') return 'every impact sounds the same (no matOf): a tree, a window and a car door all give the same tick';
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
       if(matOf({tree:1})!=='wood'||matOf({furn:1})!=='wood') bad.push('a tree or furniture is not wood');
       if(matOf({win:1})!=='glass') bad.push('a window is not glass');
       if(matOf({wreck:1})!=='metal'||matOf({door:1})!=='metal') bad.push('a wreck or a door is not metal');
       if(matOf({x:0,y:0,w:20,h:200})!=='concrete') bad.push('a building wall is not concrete');
       if(entMat({kind:'raider'})!=='flesh'||entMat({kind:'bulwark'})!=='armor'||entMat({kind:'warden'})!=='armor'||entMat({kind:'crawler'})!=='metal') bad.push('the body materials are wrong');
       var src=[].slice.call(document.scripts).map(function(sc){ return sc.text||''; }).join('\n');
       var nw=src.split('sfx("clank",b.x,b.y,mat'+'Of(_struck))').length-1;
       if(nw<2) bad.push('a round striking a wall passes no wall material ('+nw+' of 2 sites)');
       if(src.indexOf('sfx("hit",en.x,en.y,ent'+'Mat(en))')<0) bad.push('a round striking a body passes no body material');
       kSim=(G?G.sim:null); fakeOn();
       var imp=sndBus('imp'), m0=MADE.length, made;
       _realBlip('clank',100,0,'glass'); made=MADE.slice(m0);
       if(!made.some(function(x){ return x.kind==='filter'&&x.type==='highpass'&&x.frequency.value>4000&&reach(x,imp); })) bad.push('a round on glass does not shatter');
       m0=MADE.length; _realBlip('hit',100,0,'flesh'); made=MADE.slice(m0);
       if(!made.some(function(x){ return x.kind==='filter'&&x.type==='lowpass'&&x.frequency.value<800; })) bad.push('a hit on flesh does not thud');
       m0=MADE.length; _realBlip('hit',100,0,'armor'); made=MADE.slice(m0);
       if(made.filter(function(x){ return x.kind==='osc'; }).length<2) bad.push('a hit on armour does not ring');
       m0=MADE.length; _realBlip('clank',100,0); made=MADE.slice(m0);
       if(made.filter(function(x){ return x.kind==='osc'; }).length!==1||made.some(function(x){ return x.kind==='filter'||x.kind==='src'; })) bad.push('a clank with no material no longer plays the old single tick');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ fakeOff(); }catch(_f){} }
     return bad.length?bad.join('; '):null; }},
  {v:'23.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
