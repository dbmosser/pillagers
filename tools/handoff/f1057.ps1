$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'10.56',what:'every gun schedules its own voice, no two alike, each shot a little different from the last, and reload and dry fire schedule sounds of their own',
'@ @'
  {v:'10.57',what:'a step schedules heel then sole with the surface tell, no two alike, a sprint louder than a walk, left and right alternate, and an enemy step carries the surface under it',
   run:function(){
     var bad=[];
     if(typeof _realBlip!=='function'||!window.__enemyAudioReal||!window.__stepsReal) return 'SKIP: this build has no real blip or steps to trace';
     if(!(window.__startRaid)) return 'SKIP: no raid starter';
     function param(v,log,name){ var o={_v:v}; Object.defineProperty(o,'value',{get:function(){ return o._v; },set:function(x){ o._v=x; log.push(name+'='+Math.round(x*1000)); }}); ['setValueAtTime','exponentialRampToValueAtTime','linearRampToValueAtTime','setTargetAtTime'].forEach(function(m){ o[m]=function(x){ log.push(name+':'+Math.round(x*1000)); return o; }; }); return o; }
     function fake(){
       var L=[]; var node=function(kind){ var o={kind:kind,connect:function(){ return o; },disconnect:function(){},start:function(){ L.push('start:'+kind); },stop:function(){}}; return o; };
       return {currentTime:0,sampleRate:48000,state:'running',destination:node('dest'),resume:function(){},log:L,
         createBuffer:function(ch,len){ L.push('buf:'+len); return {length:len,getChannelData:function(){ return new Float32Array(len); }}; },
         createBufferSource:function(){ return node('src'); },
         createOscillator:function(){ var o=node('osc'); o.type='sine'; o.frequency=param(440,L,'osc'); o.detune=param(0,[],'det'); return o; },
         createBiquadFilter:function(){ var o=node('flt'); o.type='lowpass'; o.frequency=param(350,L,'flt'); o.Q=param(1,[],'q'); return o; },
         createGain:function(){ var o=node('gain'); o.gain=param(1,L,'gain'); return o; },
         createStereoPanner:function(){ var o=node('pan'); o.pan=param(0,L,'pan'); return o; },
         createDelay:function(){ var o=node('dly'); o.delayTime=param(0,[],'d'); return o; }};
     }
     var keepAC=AC, keepBUS=BUS, keepSim=(G?G.sim:null), keepBlip=blip;
     try{
       blip=_realBlip;   // the fixture stubs blip to a counter; the real steps and the enemy tick call blip, not _realBlip
       var a=fake(); AC=a; BUS=a.createGain(); a.log.length=0;
       function foot(surf,stance){ a.log.length=0; _realBlip('foot',180,0,surf,stance); return a.log.slice(); }
       function sig(lg){ return lg.filter(function(x){ return (/^(buf|start|flt[:=]|osc[:=])/).test(x); }).map(function(x){ return x.replace(/[:=](-?\d+)$/,function(m,d){ return ':'+Math.round(+d/2000)*2000; }); }).join('|'); }
       function maxGain(lg){ var m=0; lg.forEach(function(x){ var mm=/^gain[:=](-?\d+)$/.exec(x); if(mm) m=Math.max(m,+mm[1]); }); return m; }
       var S=['stone','wood','metal','leaf','water'], sigs={};
       for(var i=0;i<S.length;i++){
         var l1=foot(S[i],'walk');
         if(l1.filter(function(x){ return (/^start:src/).test(x); }).length<2) bad.push(S[i]+' schedules '+l1.length+' nodes, not a heel and a sole');
         var sg=sig(l1);
         for(var j in sigs) if(sigs[j]===sg) bad.push(S[i]+' and '+j+' schedule the same step');
         sigs[S[i]]=sg;
         var l2=foot(S[i],'walk');
         if(l1.join('|')===l2.join('|')) bad.push(S[i]+' schedules the identical step twice');
       }
       var gw=maxGain(foot('stone','walk')), gs=maxGain(foot('stone','sprint')), gc=maxGain(foot('stone','crouch'));
       if(!(gs>gw*1.15)) bad.push('a sprint step ('+gs+') is not louder than a walk ('+gw+')');
       if(!(gc<gw*0.85)) bad.push('a crouch step ('+gc+') is not softer than a walk ('+gw+')');
       // Left and right: two real player steps pan opposite ways.
       __startRaid({seed:4242,mapIx:0});
       if(!G||!G.player) return 'no raid';
       if(G) G.sim=false;
       var p=G.player; var keepMov=p.moving, keepDown=p.downed, keepRoll=p.roll;
       p.moving=true; p.downed=false; p.roll=0; PSTEP=0;
       a.log.length=0; __stepsReal(0.016); var pan1=a.log.filter(function(x){ return (/^pan=/).test(x); });
       PSTEP=0; a.log.length=0; __stepsReal(0.016); var pan2=a.log.filter(function(x){ return (/^pan=/).test(x); });
       p.moving=keepMov; p.downed=keepDown; p.roll=keepRoll;
       if(!pan1.length||!pan2.length) bad.push('a real step did not place itself in the ear ('+pan1.length+','+pan2.length+')');
       else if(pan1[0]===pan2[0]) bad.push('two steps in a row pan the same way ('+pan1[0]+')');
       // An enemy on boards: the nearest moving enemy stands in a building, and its step carries wood.
       var B=(G.map.buildings||[])[0]; if(!B) return 'SKIP: no building on this map';
       var ex=B.x+B.w/2, ey=B.y+B.h/2;
       if(surfAt(ex,ey)!=='wood') return 'SKIP: the first building does not read as wood at its centre';
       var fakeE={x:ex,y:ey,kind:'raider',moving:true,state:'idle',hp:100};
       var keepPx=p.x,keepPy=p.y; p.x=ex+40; p.y=ey;
       var mv=[]; for(i=0;i<G.ents.length;i++){ mv.push(G.ents[i].moving); G.ents[i].moving=false; }
       G.ents.push(fakeE); STEP_T=0; a.log.length=0;
       __enemyAudioReal(0.016);
       G.ents.pop(); for(i=0;i<mv.length;i++) G.ents[i].moving=mv[i];
       p.x=keepPx; p.y=keepPy;
       // the wood body is 150 hertz with eight percent of jitter, logged in thousandths: 138000 to 162000
       var woodBody=a.log.filter(function(x){ return (/^osc:1[3-6]\d{4}$/).test(x); }).length;
       if(!a.log.length) bad.push('an enemy step in a building scheduled nothing (STEP_T '+STEP_T+', ents '+G.ents.length+', operator '+Math.round(p.x)+','+Math.round(p.y)+' vs '+Math.round(ex)+','+Math.round(ey)+', sim '+G.sim+', over '+G.over+')');
       else if(!woodBody) bad.push('an enemy step in a building carries no wood body (150 hertz); it scheduled '+a.log.slice(0,16).join(',')+' with surface '+surfAt(ex,ey));
     } finally { AC=keepAC; BUS=keepBUS; blip=keepBlip; if(G&&keepSim!==null) G.sim=keepSim; }
     return bad.length?bad.join('; '):null; }},
  {v:'10.56',what:'every gun schedules its own voice, no two alike, each shot a little different from the last, and reload and dry fire schedule sounds of their own',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
