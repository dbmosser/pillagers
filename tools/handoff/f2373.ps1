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

if ($s.Contains("  {v:'23.73',what:")) { throw "check 23.73 is in the fixture already" }

SubRx @'
  {v:'23.72',what:
'@ @'
  {v:'23.73',what:'his #45, walls and distance: a sound behind a building wall is placed as hidden with a 900 to 1500 Hz lowpass and a blip under it plays through that lowpass, a sound in the open with a clear line has none, and sfx asks for the place of every positioned sound',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof _realBlip!=='function'||typeof losClear!=='function'||typeof sndBus!=='function') return 'SKIP: this fixture cannot deploy a raid or has no real blip';
     if(typeof sndPlace!=='function'||typeof SND_CTX==='undefined') return 'a sound behind a wall is placed exactly like one in the open (no sndPlace): nothing muffles it';
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
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }     var bad=[], g=null, p=null, px=0, py=0, s, i, M, n, L2, A, B2, hid=null, open=null;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.map||!g.map.segs) return 'SKIP: no live raid';
       p=g.player; px=p.x; py=p.y;
       for(i=0;i<g.map.segs.length&&!hid;i++){
         s=g.map.segs[i]; L2=Math.hypot(s.x2-s.x1,s.y2-s.y1); if(L2<60) continue;
         M={x:(s.x1+s.x2)/2,y:(s.y1+s.y2)/2}; n={x:-(s.y2-s.y1)/L2,y:(s.x2-s.x1)/L2};
         A={x:M.x+n.x*50,y:M.y+n.y*50}; B2={x:M.x-n.x*90,y:M.y-n.y*90};
         if(losClear(A.x,A.y,B2.x,B2.y,g.map.segs)) continue;
         var C={x:A.x+n.x*260,y:A.y+n.y*260};
         if(!losClear(A.x,A.y,C.x,C.y,g.map.segs)) continue;
         hid=B2; open=C; p.x=A.x; p.y=A.y;
       }
       if(!hid) return 'SKIP: no wall here with open ground on one side';
       if(typeof SND_OCC!=='undefined'){ SND_OCC={}; SND_OCC_N=0; }
       var h=sndPlace(hid.x,hid.y), o=sndPlace(open.x,open.y);
       if(h.occ!==1) bad.push('a sound behind a wall is not placed as hidden ('+JSON.stringify(h)+')');
       if(!(h.lp>=900&&h.lp<=1500)) bad.push('a sound behind a wall gets no 900 to 1500 Hz lowpass ('+h.lp+')');
       if(o.occ!==0||o.lp!==0) bad.push('a sound in the open with a clear line is muffled ('+JSON.stringify(o)+')');
       kSim=(G?G.sim:null); fakeOn();
       var gun=sndBus('gun'), m0=MADE.length, made;
       SND_CTX=h; _realBlip('shot',h.d,0.2,'rifle'); SND_CTX=null; made=MADE.slice(m0);
       var lpf=made.filter(function(x){ return x.kind==='filter'&&x.type==='lowpass'&&x.frequency.value===h.lp; })[0];
       if(!lpf||!reach(lpf,gun)) bad.push('a shot behind a wall does not play through the wall lowpass');
       else if(!made.some(function(x){ return x.kind==='src'&&reach(x,lpf); })) bad.push('the shot itself does not go through the wall lowpass');
       m0=MADE.length; _realBlip('shot',h.d,0.2,'rifle'); made=MADE.slice(m0);
       if(made.some(function(x){ return x.kind==='filter'&&x.type==='lowpass'&&x.frequency.value===h.lp&&x.Q.value===0.7; })) bad.push('a shot with no place still plays through a wall lowpass');
       var src=[].slice.call(document.scripts).map(function(sc){ return sc.text||''; }).join('\n');
       var at=src.indexOf('function sf'+'x(type,wx,wy,wid){'), body=at>=0?src.slice(at,at+1600):'';
       if(body.indexOf('SND_CTX'+'=sndPlace(')<0) bad.push('sfx does not ask where a positioned sound is');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ SND_CTX=null; fakeOff(); }catch(_f){}
       try{ if(p){ p.x=px; p.y=py; } var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
