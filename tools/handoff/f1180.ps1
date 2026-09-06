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

# v11.80 CHECK, inserted before the v11.79 entry. This fixture blocks
# AudioContext, so the bed's gain cannot be read; tickAmbience is wrapped
# instead and the target it would write is computed from its own arguments
# with its own formula, alive ? 0.16 + 0.30 * threat : 0. The wrapper still
# calls the real function, which returns at once for want of a context.
SubRx @'
  {v:'11.79',what:'four guns are on the crafting bench, two green and two blue, each priced in parts between what it sells for and what it costs to buy, and crafting one through the real row puts the gun in the stash and takes the parts (his order of 2026-09-06)',
'@ @'
  {v:'11.80',what:'after an extraction the ambient bed is driven to silence over the outcome card instead of back up to its floor, so nothing hums on the Undercroft floor afterwards (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__runPrep)) return 'SKIP: this fixture cannot deploy, end a raid and step the loop';
     if(typeof tickAmbience!=='function') return 'SKIP: no ambient bed in this build';
     var bad=[], log=[], orig=tickAmbience, i;
     tickAmbience=function(dt,threat,alive,dread){
       log.push({alive:!!alive,target:alive?(0.16+0.30*(threat||0)):0,over:!!(G&&G.over)});
       return orig.apply(this,arguments);
     };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.player.downed=false;
       var t0=performance.now();
       for(i=0;i<12;i++) __loop(t0+i*16.7);
       var before=log.length;
       if(!log.filter(function(e){ return e.target>0; }).length) bad.push('control: the bed was never driven above 0 during the raid, so silence afterwards would prove nothing');
       __endRaid('extract');
       for(i=0;i<30;i++) __loop(t0+(12+i)*16.7);
       var after=log.slice(before);
       if(!after.length) bad.push('control: the loop stopped driving the bed once the raid ended, so the level it holds cannot be measured here');
       var up=after.filter(function(e){ return e.target>0; });
       if(up.length) bad.push('after the raid ended the bed was driven back up '+up.length+' time(s), last target '+up[up.length-1].target.toFixed(2)+', which is the hum he hears on the floor');
       if(after.length&&after[after.length-1].target!==0) bad.push('the last level written over the card was '+after[after.length-1].target.toFixed(2)+' and not 0');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ tickAmbience=orig; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.79',what:'four guns are on the crafting bench, two green and two blue, each priced in parts between what it sells for and what it costs to buy, and crafting one through the real row puts the gun in the stash and takes the parts (his order of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
