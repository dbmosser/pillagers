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

if ($s.Contains("  {v:'27.90',what:")) { throw "check 27.90 is in the fixture already" }

SubRx @'
  {v:'27.89',what:
'@ @'
  {v:'27.90',what:'his answer 41: a quiet low alarm (not music) loops through the extraction countdown: a called ring plays it every 1.8 s, an uncalled one never, and the sound is a short low throb',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof tickExtractPoints!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, z=null, rb=blip, n=0, i, a0, lg, os, mx=0, lo=1e9, hi=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       z=g.zones&&g.zones[0]; if(!z) return 'SKIP: staging: no extraction zone';
       g.player.iv=99;
       blip=function(k){ if(k==='xalarm') n++; };
       z.beaconT=null; z.hold=null; g.active=z; n=0;
       for(i=0;i<60;i++) tickExtractPoints(0.05);
       if(n!==0) bad.push('the alarm sounded '+n+' times with no ring called');
       z.beaconT=20; z.pingT=0; z.alarmT=undefined; g.active=z; g.beaconT=20; n=0;
       for(i=0;i<100;i++) tickExtractPoints(0.05);
       if(!(n>=2&&n<=4)) bad.push('in a 5 second countdown the alarm sounded '+n+' times, not 2 to 4');
       z.beaconT=null; z.hold=null; n=0;
       for(i=0;i<60;i++) tickExtractPoints(0.05);
       if(n!==0) bad.push('the alarm kept sounding after the call ended ('+n+')');
       blip=rb;
       if(typeof __audio==='object'&&__audio.record&&__audio.blipRaw){
         lg=__audio.record(function(){ __audio.blipRaw('xalarm'); });
         os=(lg&&lg.osc)||[];
         if(!os.length) bad.push('the alarm schedules no sound');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       blip=rb;
       try{ if(z){ z.beaconT=null; z.hold=null; z.alarmT=undefined; } }catch(_z){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
