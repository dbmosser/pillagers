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

if ($s.Contains("  {v:'18.06',what:")) { throw "check 18.06 is in the fixture already" }

SubRx @'
  {v:'18.05',what:
'@ @'
  {v:'18.06',what:'the extraction siege sends fewer big robots (his son, 2026-10-03): the arrivals cap is 5 + 7 x greed (was 6 + 8 x greed) and about three in ten arrivals are sentries (was one in two), measured on a pinned seed',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof tickExtractPoints!=='function'||typeof srand!=='function') return 'SKIP: this fixture cannot deploy';
     var bad=[], g, Z=null, i, born, sn=0, v0=CFG.siegeVol, GR, want, share;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={};
       for(i=0;i<(g.zones||[]).length&&!Z;i++) if(g.zones[i].open) Z=g.zones[i];
       if(!Z) return 'SKIP: no open ring';
       for(i=0;i<g.ents.length;i++) g.ents[i].siegeBorn=0;
       CFG.siegeVol=1; Z.beaconT=25; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=null; g.active=Z; g.beaconT=25;
       srand(777);
       for(i=0;i<60;i++){ Z.siegeSpawnT=99; tickExtractPoints(0.016); }
       GR=Z.siegeGreed; want=Math.round(5+7*GR);
       born=g.ents.filter(function(e){ return e.siegeBorn; });
       if(born.length!==want) bad.push('the ring sent '+born.length+' machines at greed '+(+GR).toFixed(2)+', not '+want);
       for(i=0;i<born.length;i++) born[i].siegeBorn=0;
       CFG.siegeVol=10; Z.siegeSpawned=0; Z.siegeGreed=null; Z.beaconT=25; srand(777);
       for(i=0;i<140;i++){ Z.siegeSpawnT=99; tickExtractPoints(0.016); }
       born=g.ents.filter(function(e){ return e.siegeBorn; });
       for(i=0;i<born.length;i++) if(born[i].kind==='sentry') sn++;
       share=born.length?sn/born.length:0;
       if(born.length<30) bad.push('control: only '+born.length+' arrivals to measure the mix on');
       else if(!(share<=0.42&&share>=0.14)) bad.push('sentries are '+Math.round(share*100)+' percent of '+born.length+' arrivals');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ CFG.siegeVol=v0; keys={}; try{ __resetCfg(); }catch(_c){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
