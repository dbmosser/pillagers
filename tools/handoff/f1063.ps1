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
  {v:'10.62',what:'each kind schedules its own death, a hit on plate and a hit on a man differ, the Bulwark has a voice, the idle voices never repeat exactly, and a death on the play path asks for the death sound',
'@ @'
  {v:'10.63',what:'a door, a heal, a menu click and a Depot sale each schedule their own voice, none of them the pickup chirp, and a pickup in a raid keeps the chirp',
   run:function(){
     var bad=[];
     if(typeof _realBlip!=='function'||!window.__startRaid) return 'SKIP: this build has no real blip to trace';
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
     var keepAC=AC, keepBUS=BUS, keepG=G;
     try{
       var a=fake(); AC=a; BUS=a.createGain();
       function call(type){ a.log.length=0; _realBlip(type); return a.log.slice(); }
       function sig(lg){ return lg.filter(function(x){ return (/^(buf|start|flt|osc)/).test(x); }).map(function(x){ return x.replace(/[:=](-?\d+)$/,function(m,d){ return ':'+Math.round(+d/1500)*1500; }); }).join('|'); }
       // In a raid: the pickup keeps its chirp, and the four new voices differ from it and from each other.
       __startRaid({seed:4242,mapIx:0});
       if(!G) return 'no raid';
       G.sim=false;
       var pick=call('pick'), voices={door:call('door'),heal:call('heal'),ui:call('ui'),cache:call('cache')};
       if(!pick.length) bad.push('a pickup in a raid schedules nothing');
       var seen={pick:sig(pick)};
       for(var k in voices){
         if(!voices[k].length){ bad.push('a '+k+' schedules nothing'); continue; }
         var sg=sig(voices[k]);
         for(var j in seen) if(seen[j]===sg) bad.push('a '+k+' and a '+j+' schedule the same sound');
         seen[k]=sg;
       }
       // In the Undercroft, no raid: the pickup name is routed to the tick.
       G=null;
       var menu=call('pick');
       if(!menu.length) bad.push('a menu click schedules nothing');
       else if(sig(menu)!==seen.ui) bad.push('a menu click is not the tick');
       else if(sig(menu)===seen.pick) bad.push('a menu click is still the pickup chirp');
     } finally { AC=keepAC; BUS=keepBUS; G=keepG; }
     return bad.length?bad.join('; '):null; }},
  {v:'10.62',what:'each kind schedules its own death, a hit on plate and a hit on a man differ, the Bulwark has a voice, the idle voices never repeat exactly, and a death on the play path asks for the death sound',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
