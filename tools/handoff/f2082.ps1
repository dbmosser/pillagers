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

if ($s.Contains("  {v:'20.82',what:")) { throw "check 20.82 is in the fixture already" }

SubRx @'
  {v:'20.81',what:
'@ @'
  {v:'20.82',what:'the siege a spectating host runs for his party sends three sentries in ten, as every other siege does: a draw of .4 brings a crawler and a draw of .2 a sentry',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof netSpecRings!=='function'||typeof netNearDist!=='function'||typeof freeSpot!=='function'||typeof rr!=='function') return 'SKIP: no rings of the kept raid in this build';
     var bad=[], oRR=rr, oFS=freeSpot, oND=netNearDist, q=[], g0=null, g, z, i, a, b, arrive;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.zones||!g.zones.length) return 'SKIP: no live raid with rings';
       g0=g; z=g.zones[0]; CFG.siegeVol=1;
       for(i=0;i<g.zones.length;i++){ g.zones[i].beaconT=null; }
       freeSpot=function(){ return {x:g.player.x+1500,y:g.player.y}; };
       netNearDist=function(){ return 5000; };
       rr=function(){ return q.length?q.shift():oRR(); };
       arrive=function(v){ var n=g.ents.length; z.beaconT=20; z.siegeGreed=0; z.siegeSpawnT=1e6; z.siegeSpawned=0; z.siege=0; q=[v]; netSpecRings(0.01); q=[]; return (g.ents.length===n+1&&g.ents[n])?String(g.ents[n].kind):'none'; };
       a=arrive(0.4); b=arrive(0.2);
       if(a==='none'||b==='none') return 'SKIP: staging: the kept raid ring sent no arrival ('+a+', '+b+')';
       if(a!=='crawler') bad.push('a draw of .4 brought a '+a+', so half the arrivals of the kept raid siege are sentries, not three in ten');
       if(b!=='sentry') bad.push('control: a draw of .2 brought a '+b+', not a sentry');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       rr=oRR; freeSpot=oFS; netNearDist=oND;
       try{ if(g0){ for(i=0;i<g0.zones.length;i++){ g0.zones[i].beaconT=null; } if(g0.player) g0.player.downed=false; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
