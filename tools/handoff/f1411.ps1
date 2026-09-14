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
  {v:'14.10',what:
'@ @'
  {v:'14.11',what:'ring closure lines wait their turn: one extraction tick in which one ring closes and another is warned keeps both lines, showing or queued, while a ring closing alone says it is closed (raid HUD and map screen audit 2026-09-15, finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof tickExtractPoints!=='function') return 'SKIP: no extraction tick in this build';
     var bad=[];
     var CLOSED=['is','closed'].join(' '), WARN=['closes','in','two','minutes'].join(' ');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player||g.sim) return 'SKIP: no live raid';
       if(!(g.zones&&g.zones.length>=2)) return 'SKIP: fewer than two extraction points';
       g.ents.length=0;
       function reset(){ for(var i=0;i<g.zones.length;i++){ var z=g.zones[i]; z.open=true; z.warned=1; z.closeAt=-9999; z.beaconT=null; z.hold=null; z.pullT=null; } g.msg=''; g.msgT=0; g.msgQ=[]; }
       function lines(){ return [String(g.msg||'')].concat((g.msgQ||[]).map(String)); }
       // CONTROL: a ring closing alone says so.
       reset();
       g.zones[0].closeAt=g.timeLeft+5; g.zones[0].warned=1;
       tickExtractPoints(0.016);
       if(!lines().some(function(t){ return t.indexOf(CLOSED)>=0; })) return 'SKIP: a ring closing alone said nothing through the tick, so nothing here can be measured';
       // THE FINDING: one ring closes and another is warned in the same tick.
       reset();
       g.zones[0].closeAt=g.timeLeft+5; g.zones[0].warned=1;
       g.zones[1].closeAt=g.timeLeft-60; g.zones[1].warned=0;
       tickExtractPoints(0.016);
       var L=lines();
       var hasC=L.some(function(t){ return t.indexOf(CLOSED)>=0; }), hasW=L.some(function(t){ return t.indexOf(WARN)>=0; });
       if(!(hasC&&hasW)) bad.push('a closure and a two-minute warning said in the same tick left only: '+L.filter(function(t){return t;}).join(' | '));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
