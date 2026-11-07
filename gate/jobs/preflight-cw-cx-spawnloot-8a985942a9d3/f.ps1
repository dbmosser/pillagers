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

if ($s.Contains("  {v:'37.54',what:")) { throw "check 37.54 is in the fixture already" }

SubRx @'
  {v:'37.53',what:
'@ @'
  {v:'37.54',what:'every career spawn has unopened ordinary loot within 340 and clear sight, six seeds on both maps',
   run:function(){
     var oldCareer=CAREER_ON, seeds=[4242,17011,28123,39041,50153,61261], bad=[], g, mi, k, j;
     try{
       for(mi=0;mi<2;mi++) for(k=0;k<seeds.length;k++){
         __runPrep(); __topClear(); __resetCfg(); __pinDefaults(mi); __cleanProfile(); CAREER_ON=1;
         __deploy({kit:['gun_carbine'],mapIx:mi,seed:seeds[k],keepLegend:1});
         g=__state(); if(!g||!g.career||g.over) return 'career staging failed';
         for(j=0;j<g.map.spawns.length;j++){
           var s=g.map.spawns[j], ok=g.containers.some(function(c){
             return c&&!c.opened&&!c.dropped&&!c.cache&&!c.strong&&c.type!=='cache'&&c.type!=='vault'&&c.inLocked==null&&Math.hypot(c.x-s.x,c.y-s.y)<=340&&losClear(s.x,s.y,c.x,c.y,g.map.segs);
           });
           if(!ok) bad.push('map '+mi+' seed '+seeds[k]+' spawn '+j+' has no visible ordinary box');
         }
         if(typeof spawnLootSight==='function'){
           var rng=RNGS, n=g.containers.length;
           spawnLootSight(g);
           if(RNGS!==rng) bad.push('spawn loot moved the main random stream');
           if(g.containers.length!==n) bad.push('a second pass added more boxes');
         }
         __endRaid('abandon');
       }
       return bad.length?bad.join('; '):null;
     }finally{ CAREER_ON=oldCareer; try{__endRaid('abandon');}catch(e){} __topClear(); }
   }},
  {v:'37.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
