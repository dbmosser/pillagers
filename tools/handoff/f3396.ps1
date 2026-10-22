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

if ($s.Contains("  {v:'33.96',what:")) { throw "check 33.96 is in the fixture already" }

SubRx @'
  {v:'33.95',what:
'@ @'
  {v:'33.96',what:'cw-cx-groundmode: ruins preserve floor density; scorch, brass, frag, belt and ruined-floor checks plus the isolated flashing check pass',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__REGRESS))return 'floor validation hooks missing';
     var oldPix=CFG.xfPix,bad=[],g=null,i,j,t,r,ruins,ids=['24.00','24.17','24.39','26.50','18.34','10.82'];
     try{
       // v28.xx (cw-cx-groundmode): a real ruined building runs the colliding rubble loop in both entry modes.
       for(i=0;i<2;i++){
         __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();CFG.xfPix=i;
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();
         if(!g||g.over||!g.ground){bad.push('mode '+i+' built no live floor');continue;}
         ruins=0;for(j=0;j<g.map.buildings.length;j++)if(g.map.buildings[j].ruined)ruins++;
         if(!ruins)bad.push('control: mode '+i+' did not paint any rubble');
         if((g.ground._pe||1)!==(i?PIX_ENV:1))bad.push('mode '+i+' has wrong floor density '+g.ground._pe);
         if(g.ground.width!==(i?Math.ceil(WORLD_W/PIX_ENV):WORLD_W)||g.ground.height!==(i?Math.ceil(WORLD_H/PIX_ENV):WORLD_H))bad.push('mode '+i+' has wrong floor dimensions');
         if(!i&&(g.ground._pq||g.ground._pg))bad.push('legacy floor entered the pixel queue after painting rubble');
         __endRaid('abandon');__topClear();
       }
       // All six retain their pixel thresholds and negative controls; the flashing check isolates its muzzle-only comparison from other emitters.
       for(i=0;i<ids.length;i++){
         t=null;for(j=0;j<__REGRESS.length;j++)if(__REGRESS[j].v===ids[i]){t=__REGRESS[j];break;}
         if(!t){bad.push('missing original check '+ids[i]);continue;}
         __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
         try{r=t.run();}catch(e){r='threw '+String(e&&e.message||e);}
         if(r)bad.push('v'+ids[i]+': '+String(r).slice(0,240));
       }
       return bad.length?bad.join('; '):null;
     }finally{
       try{if(__state()&&!__state().over)__endRaid('abandon');}catch(_e){}
       keys={};__topClear();__resetCfg();__cleanProfile();CFG.xfPix=oldPix;
     }
   }},
  {v:'33.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
