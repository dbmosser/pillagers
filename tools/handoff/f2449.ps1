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

if ($s.Contains("  {v:'24.49',what:")) { throw "check 24.49 is in the fixture already" }

SubRx @'
  {v:'24.48',what:
'@ @'
  {v:'24.49',what:'his #45, menu sounds: on the HUD bus a moved highlight ticks (move), a pressed button clicks (ok), a CLOSE button falls (back), a locked cell buzzes (deny), the pause box opening rises (open), and none of it plays under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof sndBus!=='function'||typeof padSetFocus!=='function'||typeof togglePauseBox!=='function') return 'SKIP: this fixture cannot run these menus';
     if(typeof sndUi!=='function'||typeof SND_UI_LAST==='undefined') return 'the menus are silent (no sndUi): a press on a pad or the arrows gives no sign it landed';
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
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }     var bad=[], box=null, b1, b2, b3, c1, f0=(typeof PAD!=='undefined'&&PAD)?PAD.focus:null, made, m0, ui, n0, g=null;
     function fresh(){ SND_UI_LAST=''; SND_UI_AT=-1; }
     try{
       __topClear(); __runPrep();
       kSim=(G?G.sim:null); fakeOn(); ui=sndBus('ui');
       box=document.createElement('div'); box.style.cssText='position:fixed;left:0;top:0;z-index:1';
       b1=document.createElement('button'); b1.textContent='ALPHA'; b2=document.createElement('button'); b2.textContent='BRAVO';
       b3=document.createElement('button'); b3.textContent='CLOSE'; c1=document.createElement('div'); c1.className='cell locked'; c1.textContent='X';
       box.appendChild(b1); box.appendChild(b2); box.appendChild(b3); box.appendChild(c1); document.body.appendChild(box);
       fresh(); padSetFocus(b1); fresh(); m0=MADE.length; padSetFocus(b2);
       if(SND_UI_LAST!=='move') bad.push('a moved highlight plays '+(SND_UI_LAST||'nothing')+', not move');
       made=MADE.slice(m0);
       if(!made.some(function(x){ return x.kind==='osc'&&reach(x,ui); })) bad.push('the move tick does not reach the HUD bus');
       fresh(); b2.click(); if(SND_UI_LAST!=='ok') bad.push('a pressed button plays '+(SND_UI_LAST||'nothing')+', not ok');
       fresh(); b3.click(); if(SND_UI_LAST!=='back') bad.push('a CLOSE button plays '+(SND_UI_LAST||'nothing')+', not back');
       fresh(); c1.click(); if(SND_UI_LAST!=='deny') bad.push('a locked cell plays '+(SND_UI_LAST||'nothing')+', not deny');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(g&&!g.over){
         fresh(); togglePauseBox(true); if(SND_UI_LAST!=='open') bad.push('the pause box opening plays '+(SND_UI_LAST||'nothing')+', not open');
         fresh(); togglePauseBox(false); if(SND_UI_LAST!=='close') bad.push('the pause box closing plays '+(SND_UI_LAST||'nothing')+', not close');
         G.sim=true; fresh(); n0=SND_UI_N; padSetFocus(b1); b1.click();
         if(SND_UI_N!==n0) bad.push('menu sounds play under G.sim'); G.sim=false;
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ fakeOff(); }catch(_f){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_t){}
       try{ padSetFocus(null); PAD.focus=null; if(f0) padSetFocus(f0); }catch(_p){}
       try{ if(box&&box.parentNode) box.parentNode.removeChild(box); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
