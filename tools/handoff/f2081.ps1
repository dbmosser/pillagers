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

if ($s.Contains("  {v:'20.81',what:")) { throw "check 20.81 is in the fixture already" }

SubRx @'
  {v:'20.80',what:
'@ @'
  {v:'20.81',what:'a sound that leaves a ring is heard where its ring is: the touchdown 1000 away and at the edge of its ring and the inbound ping at the edge of its ring all play, within 450 the touchdown keeps the level it had, and a boarding blip 1000 away stays silent',
   run:function(){
     if(typeof _realBlip!=='function') return 'SKIP: this fixture has no real blip to trace';
     if(typeof AC==='undefined'||typeof BUS==='undefined'||typeof NOISEMARK==='undefined'||!NOISEMARK.touchdown||!NOISEMARK.inbound) return 'SKIP: this build has no audio context, bus or ring table to stand in for';
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
     function peak(type,d){ var m=0, q; gains.length=0; _realBlip(type,d); for(q=0;q<gains.length;q++) if(gains[q]>m) m=gains[q]; return m; }
     var keepAC=AC, keepBUS=BUS, keepSim=(G?G.sim:null), hasNet=(typeof NET==='object'&&!!NET), ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), st0=hasNet?NET.specTick:undefined;
     var tdH=NOISEMARK.touchdown.hear, inH=NOISEMARK.inbound.hear, t0, t300, t1000, tEdge, iEdge, b1000;
     try{
       AC=a; BUS=a.createGain(); if(G) G.sim=false; if(hasNet) NET.specTick=0;   // the real blip returns before making a node in a sim or a kept raid
       t0=peak('touchdown',0); t300=peak('touchdown',300); t1000=peak('touchdown',1000); tEdge=peak('touchdown',tdH-10); iEdge=peak('inbound',inH-10); b1000=peak('board',1000);
       if(!t0) return 'SKIP: the touchdown scheduled no gain at all on the stand-in context';
       if(Math.abs(t300/t0-(1-300/900))>1e-6) bad.push('control: the touchdown 300 away plays at '+(t300/t0).toFixed(4)+' of full, not the '+(1-300/900).toFixed(4)+' it always had');
       if(b1000) bad.push('control: a boarding blip 1000 away, past the reach of its ring, still played');
       if(!t1000) bad.push('the ship touching down 1000 away is silent while its ring is drawn out to '+tdH);
       if(!tEdge) bad.push('the touchdown at the edge of its ring, '+(tdH-10)+' away, is silent');
       if(!iEdge) bad.push('the inbound ping at the edge of its ring, '+(inH-10)+' away, is silent');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       AC=keepAC; BUS=keepBUS; if(G&&keepSim!==null) G.sim=keepSim;
       if(hasNet){ if(ownST) NET.specTick=st0; else delete NET.specTick; }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
