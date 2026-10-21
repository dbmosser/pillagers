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

if ($s.Contains("  {v:'33.35',what:")) { throw "check 33.35 is in the fixture already" }

SubRx @'
  {v:'33.34',what:
'@ @'
  {v:'33.35',what:'his order 10-20: the extraction siren sounds only for the first 4 s after the call and the last 4 s before the ship arrives, none in between and none while the ship holds',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof tickExtractPoints!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, z=null, rb=blip, t=0, hits=[], i, early=0, late=0, mid=0, hold=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       z=g.zones&&g.zones[0]; if(!z) return 'SKIP: staging: no extraction zone';
       g.player.iv=99;
       blip=function(k){ if(k==='xalarm') hits.push(t); };
       z.beaconT=20; z.hold=null; z.pingT=0; z.alarmT=undefined; z.alarmAge=0; g.active=z; g.beaconT=20;
       for(i=0;i<396;i++){ t+=0.05; if(z.beaconT>0) tickExtractPoints(0.05); }
       for(i=0;i<hits.length;i++){ if(hits[i]<=4.1) early++; else if(hits[i]>=16) late++; else mid++; }
       if(!early) bad.push('no siren in the first 4 s after the call');
       if(!late) bad.push('no siren in the last 4 s before the ship arrives');
       if(mid) bad.push('the siren sounded '+mid+' times between the two windows');
       hits.length=0; z.beaconT=0; z.hold=20; g.beaconT=0;
       for(i=0;i<60;i++){ t+=0.05; tickExtractPoints(0.05); }
       hold=hits.length;
       if(hold) bad.push('the siren sounded '+hold+' times while the ship held');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       blip=rb;
       try{ if(z){ z.beaconT=null; z.hold=null; z.alarmT=undefined; z.alarmAge=0; } }catch(_z){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
