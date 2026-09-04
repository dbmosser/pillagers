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
  {v:'10.57',what:'a step schedules heel then sole with the surface tell, no two alike, a sprint louder than a walk, left and right alternate, and an enemy step carries the surface under it',
'@ @'
  {v:'10.62',what:'each kind schedules its own death, a hit on plate and a hit on a man differ, the Bulwark has a voice, the idle voices never repeat exactly, and a death on the play path asks for the death sound',
   run:function(){
     var bad=[];
     if(typeof _realBlip!=='function'||typeof VOICE==='undefined'||!window.__startRaid||!window.__loop) return 'SKIP: this build has no real blip or live loop to trace';
     function param(v,log,name){ var o={_v:v}; Object.defineProperty(o,'value',{get:function(){ return o._v; },set:function(x){ o._v=x; log.push(name+'='+Math.round(x*100)); }}); ['setValueAtTime','exponentialRampToValueAtTime','linearRampToValueAtTime','setTargetAtTime'].forEach(function(m){ o[m]=function(x){ log.push(name+':'+Math.round(x*100)); return o; }; }); return o; }
     function fake(){
       var L=[]; var node=function(kind){ var o={kind:kind,connect:function(){ return o; },disconnect:function(){},start:function(){ L.push('start:'+kind); },stop:function(){}}; return o; };
       return {currentTime:0,sampleRate:48000,state:'running',destination:node('dest'),resume:function(){},log:L,
         createBuffer:function(ch,len){ L.push('buf:'+len); return {length:len,getChannelData:function(){ return new Float32Array(len); }}; },
         createBufferSource:function(){ return node('src'); },
         createOscillator:function(){ var o=node('osc'); o.type='sine'; o.frequency=param(440,L,'osc'); o.detune=param(0,[],'det'); return o; },
         createBiquadFilter:function(){ var o=node('flt'); o.type='lowpass'; o.frequency=param(350,L,'flt'); o.Q=param(1,[],'q'); return o; },
         createGain:function(){ var o=node('gain'); o.gain=param(1,[],'g'); return o; },
         createStereoPanner:function(){ var o=node('pan'); o.pan=param(0,[],'p'); return o; },
         createDelay:function(){ var o=node('dly'); o.delayTime=param(0,[],'d'); return o; }};
     }
     var keepAC=AC, keepBUS=BUS, keepSim=(G?G.sim:null), keepSfx=sfx;
     try{
       var a=fake(); AC=a; BUS=a.createGain();
       function call(type,arg){ a.log.length=0; _realBlip(type,0,undefined,arg); return a.log.slice(); }
       function sig(lg){ return lg.filter(function(x){ return (/^(buf|start|flt|osc)/).test(x); }).map(function(x){ return x.replace(/[:=](-?\d+)$/,function(m,d){ return ':'+Math.round(+d/1500)*1500; }); }).join('|'); }
       var kinds=['raider','crawler','sentry','snitch','warden','bulwark','listener'], sigs={};
       for(var i=0;i<kinds.length;i++){
         var lg=call('die',kinds[i]);
         if(!lg.length){ bad.push('a '+kinds[i]+' dies silently'); continue; }
         var sg=sig(lg);
         for(var j in sigs) if(sigs[j]===sg&&!((j==='warden'&&kinds[i]==='bulwark'))) bad.push('a '+kinds[i]+' and a '+j+' die with the same sound');
         sigs[kinds[i]]=sg;
       }
       var hm=call('hitm','sentry'), hr=call('hitr','raider');
       if(!hm.length) bad.push('a hit on plate schedules nothing');
       if(!hr.length) bad.push('a hit on a man schedules nothing');
       if(hm.length&&hr.length&&sig(hm)===sig(hr)) bad.push('a hit on plate and a hit on a man schedule the same sound');
       if(!VOICE.bulwark||VOICE.bulwark.v!=='grind') bad.push('the Bulwark has no voice of its own');
       var g1=call('grind',0), g2=call('grind',1);
       if(!g1.length) bad.push('the grind schedules nothing');
       if(g1.length&&sig(g1)===sig(g2)) bad.push('the Bulwark hunting sounds the same as the Bulwark idle');
       var s1=call('servo',0), s2=call('servo',0);
       if(s1.join('|')===s2.join('|')) bad.push('two servo sweeps in a row are identical');
       var d1=call('dish',0), d2=call('dish',0);
       if(d1.join('|')===d2.join('|')) bad.push('two dish creaks in a row are identical');
       // The play path: an entity at zero hit points asks for its death sound when the frame culls it.
       __startRaid({seed:4242,mapIx:0});
       if(!G||!G.ents||!G.ents.length) return 'no raid';
       G.sim=false;
       var asked=[]; sfx=function(t2,x,y,k){ asked.push(t2+':'+k); };
       // The nearest machine, and the operator moved beside it: a body past the
       // detail radius is not updated at all, so a far one would never be culled.
       var victim=null, vd=1e9, pp=G.player;
       for(i=0;i<G.ents.length;i++){ var e=G.ents[i]; if(e.kind!=='crawler'&&e.kind!=='sentry') continue; var dd=Math.hypot(e.x-pp.x,e.y-pp.y); if(dd<vd){ vd=dd; victim=e; } }
       if(!victim) return 'SKIP: no machine on the map to kill';
       var keepPx=pp.x, keepPy=pp.y; pp.x=victim.x+60; pp.y=victim.y;
       var vk=victim.kind; victim.hp=0; victim.byPlayer=true;
       var tt=performance.now(); for(i=0;i<3;i++){ tt+=16.7; __loop(tt); }
       pp.x=keepPx; pp.y=keepPy;
       if(asked.indexOf('die:'+vk)<0) bad.push('a '+vk+' at zero hit points was culled without asking for its death sound (asked: '+asked.join(',')+')');
     } finally { AC=keepAC; BUS=keepBUS; sfx=keepSfx; if(G&&keepSim!==null) G.sim=keepSim; }
     return bad.length?bad.join('; '):null; }},
  {v:'10.57',what:'a step schedules heel then sole with the surface tell, no two alike, a sprint louder than a walk, left and right alternate, and an enemy step carries the surface under it',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
