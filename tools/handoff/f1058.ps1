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
  {v:'10.58',what:'nothing a gunshot schedules starts later than 0.30 s after it, no buffer runs past 6,000 samples, and the tail under a big gun is a tenth of its crack',
   run:function(){
     var bad=[];
     if(typeof _realBlip!=='function'||typeof WEAPONS==='undefined') return 'SKIP: this build has no real blip to trace';
     // A recording context that writes down WHEN each node starts, in
     // milliseconds after the call, and how long each buffer is.
     function param(v){ var o={value:v}; ['setValueAtTime','exponentialRampToValueAtTime','linearRampToValueAtTime','setTargetAtTime'].forEach(function(m){ o[m]=function(){ return o; }; }); return o; }
     function fake(){
       var L=[]; var node=function(kind){ var o={kind:kind,connect:function(){ return o; },disconnect:function(){},start:function(t){ L.push({kind:kind,at:Math.round(((t||0)-a.currentTime)*1000),len:(o.buffer&&o.buffer.length)||0,gain:o._g||0}); },stop:function(){}}; return o; };
       var a={currentTime:5,sampleRate:48000,state:'running',destination:node('dest'),resume:function(){},log:L,
         createBuffer:function(ch,len){ return {length:len,getChannelData:function(){ return new Float32Array(len); }}; },
         createBufferSource:function(){ var o=node('src'); o.buffer=null; o.connect=function(x){ if(x&&x.kind==='gain'){ o._gn=x; } else if(x&&x.kind==='flt'){ o._via=x; } return o; }; return o; },
         createOscillator:function(){ var o=node('osc'); o.type='sine'; o.frequency=param(440); o.detune=param(0); return o; },
         createBiquadFilter:function(){ var o=node('flt'); o.type='lowpass'; o.frequency=param(350); o.Q=param(1); return o; },
         createGain:function(){ var o=node('gain'); o.gain=param(1); return o; },
         createStereoPanner:function(){ var o=node('pan'); o.pan=param(0); return o; },
         createDelay:function(){ var o=node('dly'); o.delayTime=param(0); return o; }};
       return a;
     }
     var keepAC=AC, keepBUS=BUS, keepSim=(G?G.sim:null);
     var guns=Object.keys(WEAPONS).filter(function(k){ return WEAPONS[k].mag>0; });
     try{
       if(G) G.sim=false;
       var a=fake(); AC=a; BUS=a.createGain();
       for(var i=0;i<guns.length;i++){
         a.log.length=0; _realBlip('shot',0,undefined,guns[i]);
         var late=null, longest=0;
         for(var j=0;j<a.log.length;j++){ var e=a.log[j]; if(e.at>300&&(!late||e.at>late.at)) late=e; if(e.len>longest) longest=e.len; }
         if(late) bad.push(WEAPONS[guns[i]].name+' schedules a '+late.kind+' '+late.at+' ms after the shot');
         if(longest>6000) bad.push(WEAPONS[guns[i]].name+' schedules a '+longest+' sample buffer');
       }
       // The tail under the Longshot: at most a tenth of the crack, and no longer than it.
       // Measured from what the gain nodes are set to, read back off the buffer sources.
       a.log.length=0;
       var gains=[]; var origGain=a.createGain; a.createGain=function(){ var o=origGain(); Object.defineProperty(o.gain,'value',{get:function(){ return o._v; },set:function(v){ o._v=v; gains.push(v); }}); return o; };
       _realBlip('shot',0,undefined,'sniper');
       var bufs=a.log.filter(function(e){ return e.kind==='src'&&e.len>0; }).map(function(e){ return e.len; }).sort(function(x,y){ return y-x; });
       var crack=bufs[0]||0, tail=bufs[1]||0;
       if(tail>crack) bad.push('the Longshot tail ('+tail+' samples) runs longer than its crack ('+crack+')');
       var gs=gains.filter(function(v){ return v>0; }).sort(function(x,y){ return y-x; });
       if(gs.length>=2&&!(gs[gs.length-1]<=gs[0]*0.12)) bad.push('the quietest layer under the Longshot is '+(gs[gs.length-1]/gs[0]).toFixed(2)+' of the crack, not a tenth');
     } finally { AC=keepAC; BUS=keepBUS; if(G&&keepSim!==null) G.sim=keepSim; }
     return bad.length?bad.join('; '):null; }},
  {v:'10.57',what:'a step schedules heel then sole with the surface tell, no two alike, a sprint louder than a walk, left and right alternate, and an enemy step carries the surface under it',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
