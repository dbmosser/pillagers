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

if ($s.Contains("  {v:'22.47',what:")) { throw "check 22.47 is in the fixture already" }

SubRx @'
  {v:'22.46',what:
'@ @'
  {v:'22.47',what:'the alert lane in the shooter voice: the in-ring hints read Hold [E] to call extraction, Inbound 17s then Stay in the ring, and All extractions closed, and the explaining details and narrated headlines of batch 3 are gone from the game',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof outHint!=='function'||typeof padOn!=='function') return 'SKIP: no hint here';
     var bad=[], g, p, z=null, i, h, src, olds, oPad=padOn;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.zones) return 'SKIP: staging: no raid';
       padOn=function(){ return false; };
       p=g.player;
       for(i=0;i<g.zones.length;i++){ g.zones[i].beaconT=null; g.zones[i].hold=null; }
       g.active=null; g.beaconT=null;
       for(i=0;i<g.zones.length;i++) if(g.zones[i].open!==false){ z=g.zones[i]; break; }
       if(!z) return 'SKIP: no open extraction ring here';
       p.x=z.x; p.y=z.y;
       h=outHint(1); if(h!=='Hold [E] to call extraction') bad.push('in a ring with nothing called the hint is '+JSON.stringify(h));
       z.beaconT=17; z.hold=null; g.active=z; g.beaconT=17;
       h=outHint(1); if(h!=='Inbound 17s \u00b7 Stay in the ring') bad.push('in a ring with the ride 17 s out the hint is '+JSON.stringify(h));
       z.beaconT=null; g.active=null; g.beaconT=null;
       for(i=0;i<g.zones.length;i++) g.zones[i].open=false;
       h=outHint(1); if(h!=='All extractions closed') bad.push('with every ring closed the hint is '+JSON.stringify(h));
       src=[].slice.call(document.scripts).map(function(x){ return x.text||''; }).join('\n');
       olds=["' does not like"+" that.'", "say('THE"+" SIEGE'", "'It closes in"+" two minutes.'", "say('EXTRACTION LEFT"+" WITHOUT YOU'", "'. Then hold"+" '", "'. The raid clock runs"+" out first.'", "' called for extraction"+" at '", "say('YOU ARE RUNNING"+" THE RAID'", "say('MORE PILLAGERS HAVE"+" COME UP'", "say('SOMETHING HUGE HAS"+" NOTICED YOU'", "'Get clear of"+" the blast.'"];
       for(i=0;i<olds.length;i++) if(src.indexOf(olds[i])>=0) bad.push('the game still says '+olds[i]);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       padOn=oPad;
       try{ var g2=__state(); if(g2&&g2.zones){ for(var zi=0;zi<g2.zones.length;zi++){ g2.zones[zi].beaconT=null; g2.zones[zi].hold=null; } g2.active=null; g2.beaconT=null; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
