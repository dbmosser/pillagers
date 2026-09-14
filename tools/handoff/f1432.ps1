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
  {v:'14.31',what:
'@ @'
  {v:'14.32',what:'the lightning flash runs out after the storm hands over: a flash with 0.3 s left is out after 0.5 s of drawn frames in weather with no lightning, as it is in a storm (weather audit finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof render2D!=='function'||typeof WEATHER==='undefined') return 'SKIP: no renderer or weather table in this build';
     var storm=null, calm=null;
     for(var i=0;i<WEATHER.length;i++){ if(WEATHER[i].lightning&&!storm) storm=WEATHER[i]; if(!WEATHER[i].lightning&&!calm) calm=WEATHER[i]; }
     if(!storm||!calm) return 'SKIP: no storm and calm weather to compare';
     var bad=[], g0=null, wx0=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g0=g; wx0=g.wx; g.wxNext=null; g.strikes=[];
       var draw=function(w){ g.wx=w; g.lightning=0.3; for(var f=0;f<5;f++) render2D(0.1); return g.lightning; };
       // CONTROL: in a storm, five drawn frames of 0.1 s put a 0.3 s flash out.
       var inStorm=draw(storm);
       if(!(inStorm<=0)) bad.push('control: in a storm the flash read '+inStorm+' after 0.5 s of drawn frames, so render2D did not reach the countdown here');
       // THE FIX: the same flash in weather with no lightning.
       var calmLeft=draw(calm);
       if(!(calmLeft<=0)) bad.push('with a 0.3 s flash left and '+calm.id+' weather, 0.5 s of drawn frames left it at '+calmLeft+', so the flash stays on for the rest of the raid');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g0){ g0.wx=wx0; g0.lightning=0; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
