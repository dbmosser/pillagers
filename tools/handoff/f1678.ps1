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

if ($s.Contains("  {v:'16.78',what:")) { throw "check 16.78 is in the fixture already" }

SubRx @'
  {v:'16.77',what:
'@ @'
  {v:'16.78',what:'the clock alarms are a quarter of their v16.30 level: the 5 minutes left warning and every other mark peak at .01 and the last ten seconds tick at .0075, read off a stand-in audio context; the machine alarm keeps its .06',
   run:function(){
     if(typeof _realBlip!=='function') return 'SKIP: this fixture has no real blip to trace';
     if(typeof AC==='undefined'||typeof BUS==='undefined') return 'SKIP: this build has no audio context or bus to stand in for';
     var bad=[], gains=[];
     // A stand-in audio context that writes down every value a gain is set to; nothing else is recorded.
     function quiet(v){ var o={value:v}; ['setValueAtTime','exponentialRampToValueAtTime','linearRampToValueAtTime','setTargetAtTime','cancelScheduledValues'].forEach(function(m){ o[m]=function(){ return o; }; }); return o; }
     function loud(v){ var o=quiet(v); o.setValueAtTime=function(x){ gains.push(+x); return o; }; return o; }
     function node(kind){ var o={kind:kind}; o.connect=function(){ return o; }; o.disconnect=function(){}; o.start=function(){}; o.stop=function(){}; return o; }
     var a={currentTime:0,sampleRate:48000,state:'running',destination:node('dest'),resume:function(){},
       createGain:function(){ var o=node('gain'); o.gain=loud(1); return o; },
       createOscillator:function(){ var o=node('osc'); o.type='sine'; o.frequency=quiet(440); o.detune=quiet(0); return o; },
       createBiquadFilter:function(){ var o=node('flt'); o.type='lowpass'; o.frequency=quiet(350); o.Q=quiet(1); return o; },
       createStereoPanner:function(){ var o=node('pan'); o.pan=quiet(0); return o; },
       createDelay:function(){ var o=node('dly'); o.delayTime=quiet(0); return o; },
       createBuffer:function(ch,len){ return {length:len,getChannelData:function(){ return new Float32Array(len); }}; },
       createBufferSource:function(){ var o=node('src'); o.buffer=null; o.playbackRate=quiet(1); return o; }};
     function peak(type){ var m=0, q; gains.length=0; _realBlip(type); for(q=0;q<gains.length;q++) if(gains[q]>m) m=gains[q]; return m; }
     function near(x,y){ return Math.abs(x-y)<1e-6; }
     var keepAC=AC, keepBUS=BUS, keepSim=(G?G.sim:null);
     try{
       AC=a; BUS=a.createGain(); if(G) G.sim=false;   // the real blip returns before making a node in a sim
       var warn=peak('clockwarn'), tick=peak('clocktick'), mach=peak('alarm');
       if(!warn||!tick) bad.push('control: the clock warning or the tick scheduled no gain at all ('+warn+', '+tick+')');
       if(!near(mach,.06)) bad.push('control: the machine alarm moved, it peaks at '+mach+' not .06');
       if(!near(warn,.01)) bad.push('the clock warning (5 minutes left and the other marks) peaks at '+warn+', not .01, a quarter of the v16.30 level');
       if(!near(tick,.0075)) bad.push('the last ten seconds tick peaks at '+tick+', not .0075, a quarter of the v16.30 level');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ AC=keepAC; BUS=keepBUS; if(G&&keepSim!==null) G.sim=keepSim; }
     return bad.length?bad.join('; '):null; }},
  {v:'16.77',what:
'@

$src
# v16.30 tested the levels it set; the quarter cut moves them and the check reads the new numbers.
SubRx @'
  {v:'16.30',what:'quieter clock alarms and inbound: the clock warning plays a triangle tone at .04, the tick at .03, and the extraction banner says INBOUND',
'@ @'
  {v:'16.30',what:'quieter clock alarms and inbound: the clock warning plays a triangle tone (.04 then, .01 since the quarter cut), the tick (.03 then, .0075 since the quarter cut), and the extraction banner says INBOUND',
'@
SubRx @'
     if(src.indexOf("cwg.gain.setValueAtTime(.04*vol,cwt)")<0) bad.push('the clock warning is not at .04');
     if(src.indexOf("ckg.gain.setValueAtTime(.03*vol,t)")<0) bad.push('the clock tick is not at .03');
'@ @'
     if(src.indexOf("cwg.gain.setValueAtTime(.01*vol,cwt)")<0) bad.push('the clock warning is not at .01, a quarter of the v16.30 level');
     if(src.indexOf("ckg.gain.setValueAtTime(.0075*vol,t)")<0) bad.push('the clock tick is not at .0075, a quarter of the v16.30 level');
'@

 = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
