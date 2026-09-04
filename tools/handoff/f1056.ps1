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
  {v:'10.55',what:'footprints follow ground covered: evenly spaced in the open at a walk and a sprint, none while pinned against a wall, none inside a wall',
'@ @'
  {v:'10.56',what:'every gun schedules its own voice, no two alike, each shot a little different from the last, and reload and dry fire schedule sounds of their own',
   run:function(){
     var bad=[];
     if(typeof _realBlip!=='function'||typeof WEAPONS==='undefined') return 'SKIP: this build has no real blip to trace';
     // A recording AudioContext: every node the synth builds is written down
     // with the numbers it was given, so what a shot IS can be compared without
     // anything being audible. The fixture blocks the real one.
     function param(v,log,name){ var o={value:v}; ['setValueAtTime','exponentialRampToValueAtTime','linearRampToValueAtTime','setTargetAtTime'].forEach(function(m){ o[m]=function(x){ log.push(name+':'+Math.round(x*100)); return o; }; }); return o; }
     function fake(){
       var L=[]; var node=function(kind,extra){ var o={kind:kind,connect:function(){ return o; },disconnect:function(){},start:function(){},stop:function(){}}; for(var k in extra) o[k]=extra[k]; return o; };
       var a={currentTime:0,sampleRate:48000,state:'running',destination:node('dest'),resume:function(){},
         log:L,
         createBuffer:function(ch,len){ L.push('buf:'+len); return {length:len,getChannelData:function(){ return new Float32Array(len); }}; },
         createBufferSource:function(){ var o=node('src'); o.buffer=null; return o; },
         createOscillator:function(){ var o=node('osc'); o.type='sine'; o.frequency=param(440,L,'osc'); o.detune=param(0,[],'det'); var st=o.start; o.start=function(){ L.push('osc:'+o.type); }; return o; },
         createBiquadFilter:function(){ var o=node('flt'); o.type='lowpass'; var fr=param(350,[],'f'); o.frequency={get value(){ return fr.value; }, set value(v){ fr.value=v; L.push('flt:'+o.type+':'+Math.round(v*100)); }, setValueAtTime:function(v){ L.push('flt:'+o.type+':'+Math.round(v*100)); }, exponentialRampToValueAtTime:function(v){ L.push('fltr:'+Math.round(v*100)); }, linearRampToValueAtTime:function(v){ L.push('fltr:'+Math.round(v*100)); }, setTargetAtTime:function(v){ L.push('fltr:'+Math.round(v*100)); }}; o.Q=param(1,[],'q'); return o; },
         createGain:function(){ var o=node('gain'); o.gain=param(1,[],'g'); return o; },
         createStereoPanner:function(){ var o=node('pan'); o.pan=param(0,[],'p'); return o; },
         createDelay:function(){ var o=node('dly'); o.delayTime=param(0,[],'d'); return o; }
       };
       return a;
     }
     var keepAC=AC, keepBUS=BUS, keepSim=(G?G.sim:null);
     var guns=Object.keys(WEAPONS).filter(function(k){ return WEAPONS[k].mag>0; });
     try{
       if(G) G.sim=false;   // blip is silent in a sim raid, and an earlier check may have left one
       var a=fake(); AC=a; BUS=a.createGain();
       function shot(id){ a.log.length=0; _realBlip('shot',0,undefined,id); return a.log.slice(); }
       function sig(log){ return log.filter(function(x){ return (/^(buf|flt|osc):/).test(x); }).map(function(x){ return x.replace(/:(\d+)$/,function(m,d){ return ':'+Math.round(+d/25)*25; }); }).join('|'); }
       var sigs={};
       for(var i=0;i<guns.length;i++){
         var lg=shot(guns[i]);
         if(!lg.length){ bad.push(WEAPONS[guns[i]].name+' schedules nothing'); continue; }
         var sg=sig(lg);
         for(var j in sigs) if(sigs[j]===sg) bad.push(WEAPONS[guns[i]].name+' and '+WEAPONS[j].name+' schedule the same voice');
         sigs[guns[i]]=sg;
         // Jitter: two shots of one gun differ somewhere, and stay within reach of each other.
         var lg2=shot(guns[i]);
         if(lg.join('|')===lg2.join('|')) bad.push(WEAPONS[guns[i]].name+' fires the identical waveform twice');
         var n1=lg.map(function(x){ return +(x.split(':').pop()); }), n2=lg2.map(function(x){ return +(x.split(':').pop()); });
         if(n1.length!==n2.length) bad.push(WEAPONS[guns[i]].name+' schedules a different number of nodes shot to shot');
         else for(var q=0;q<n1.length;q++){ if(n1[q]>50&&Math.abs(n1[q]-n2[q])>n1[q]*0.15){ bad.push(WEAPONS[guns[i]].name+' drifts more than 15% shot to shot ('+lg[q]+' vs '+lg2[q]+')'); break; } }
       }
       a.log.length=0; _realBlip('reload'); if(a.log.filter(function(x){ return (/^(buf|osc):/).test(x); }).length<2) bad.push('a reload schedules '+a.log.length+' nodes');
       a.log.length=0; _realBlip('reloadin'); if(!a.log.length) bad.push('a finished reload schedules nothing');
       a.log.length=0; _realBlip('dry'); if(!a.log.length) bad.push('a dry pull schedules nothing');
     } finally { AC=keepAC; BUS=keepBUS; if(G&&keepSim!==null) G.sim=keepSim; }
     return bad.length?bad.join('; '):null; }},
  {v:'10.55',what:'footprints follow ground covered: evenly spaced in the open at a walk and a sprint, none while pinned against a wall, none inside a wall',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
