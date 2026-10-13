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

if ($s.Contains("  {v:'24.73',what:")) { throw "check 24.73 is in the fixture already" }

SubRx @'
  {v:'24.72',what:
'@ @'
  {v:'24.73',what:'his #45, machine loops: a machine on you behind a wall within 900 holds a running voice in fight mode (louder and faster than searching), the same machine in sight holds none, nothing plays under G.sim, the seeded stream does not move and the voice goes silent when the raid ends',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof losClear!=='function'||typeof sndBus!=='function'||typeof canSee!=='function') return 'SKIP: this fixture cannot deploy a raid';
     if(typeof tickMachLoops!=='function'||typeof SND_LOOPS==='undefined') return 'a machine on you out of sight has no running voice (no tickMachLoops): between its one-shots the ear loses it';
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
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }     var bad=[], g=null, p=null, px=0, py=0, pf=0, s, i, M, n, L2, A, B2, C, hid=null, open=null, e=null, ex=0, ey=0, est='', kL=SND_LOOPS, r0, sl, slot, lvF, lvS;
     function slotOf(x){ var j; if(!SND_LOOPS) return null; for(j=0;j<SND_LOOPS.slots.length;j++) if(SND_LOOPS.slots[j].e===x) return SND_LOOPS.slots[j]; return null; }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.map||!g.map.segs||!g.ents) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i]&&MACH_LOOP[g.ents[i].kind]&&g.ents[i].hp>0) e=g.ents[i];
       if(!e) return 'SKIP: no machine in this raid';
       p=g.player; px=p.x; py=p.y; pf=p.face; ex=e.x; ey=e.y; est=e.state;
       for(i=0;i<g.map.segs.length&&!hid;i++){
         s=g.map.segs[i]; L2=Math.hypot(s.x2-s.x1,s.y2-s.y1); if(L2<60) continue;
         M={x:(s.x1+s.x2)/2,y:(s.y1+s.y2)/2}; n={x:-(s.y2-s.y1)/L2,y:(s.x2-s.x1)/L2};
         A={x:M.x+n.x*50,y:M.y+n.y*50}; B2={x:M.x-n.x*90,y:M.y-n.y*90};
         if(losClear(A.x,A.y,B2.x,B2.y,g.map.segs)) continue;
         C={x:A.x+n.x*200,y:A.y+n.y*200};
         if(!losClear(A.x,A.y,C.x,C.y,g.map.segs)) continue;
         hid=B2; open=C; break;
       }
       if(!hid) return 'SKIP: no wall here with open ground on one side';
       kSim=(G?G.sim:null); fakeOn(); SND_LOOPS=null;
       p.x=A.x; p.y=A.y; e.x=hid.x; e.y=hid.y; e.state='chase';
       r0=RNGS;
       tickMachLoops(0.3);
       if(RNGS!==r0) bad.push('the machine voices moved the seeded stream');
       slot=slotOf(e);
       if(!slot) bad.push('a '+e.kind+' on you behind a wall 140 away holds no running voice');
       else {
         if(slot.mode!=='fight') bad.push('a '+e.kind+' on you plays in mode '+slot.mode+', not fight');
         lvF=slot.lvl;
         if(!(slot.lp.frequency.value<=1500)) bad.push('the voice behind a wall is not muffled ('+slot.lp.frequency.value+' Hz)');
         if(!reach(slot.g,sndBus('mach'))) bad.push('the voice does not reach the machine bus');
         e.state='investigate'; SND_LOOPS.t=0; tickMachLoops(0.3); lvS=slot.lvl;
         if(slotOf(e)!==slot||slot.mode!=='search') bad.push('a searching machine is not played as searching ('+slot.mode+')');
         else if(!(lvS<lvF)) bad.push('searching is not quieter than on you ('+lvS+' vs '+lvF+')');
       }
       e.state='chase'; e.x=open.x; e.y=open.y; p.face=Math.atan2(open.y-p.y,open.x-p.x);
       if(canSee(p.x,p.y,p.face,e.x,e.y,G.vseg||G.map.segs)){
         SND_LOOPS.t=0; tickMachLoops(0.3);
         if(slotOf(e)) bad.push('a machine in plain sight still holds a running voice');
       }
       e.x=hid.x; e.y=hid.y; G.sim=true; SND_LOOPS=null; tickMachLoops(0.3);
       if(SND_LOOPS) bad.push('the machine voices ran under G.sim');
       G.sim=false; tickMachLoops(0.3); sl=slotOf(e);
       if(sl){ G.over=true; tickMachLoops(0.3); G.over=false; if(slotOf(e)||sl.lvl>0) bad.push('the machine voice kept playing after the raid ended'); }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ SND_LOOPS=kL; fakeOff(); }catch(_f){}
       try{ if(e){ e.x=ex; e.y=ey; e.state=est; } if(p){ p.x=px; p.y=py; p.face=pf; } var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
