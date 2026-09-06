$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\handoff\dry\mk.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.80 CHECK, inserted before the v11.79 entry. THE ORDER IS THE BUG: the
# extraction hold calls endRaid from inside updatePlayer, and the frame that
# is already inside the raid block runs on to tickAmbience after the cut. A
# check that ends the raid BETWEEN frames never sees it (my first draft did
# exactly that and read a silent bed on the broken build). So the raid is
# ended from inside updatePlayer, where the hold ends it, by wrapping it for
# one frame. This fixture stubs tickAmbience and blocks AudioContext, so the
# wrapper computes the target from the arguments with the function's own
# formula, alive ? 0.16 + 0.30 * threat : 0, and records the frame order.
SubRx @'
  {v:'11.79',what:'four guns are on the crafting bench, two green and two blue, each priced in parts between what it sells for and what it costs to buy, and crafting one through the real row puts the gun in the stash and takes the parts (his order of 2026-09-06)',
'@ @'
  {v:'11.80',what:'when the extraction hold ends the raid from inside the player update, the rest of that frame drives the ambient bed to silence instead of back up to its floor, so nothing hums on the Undercroft floor afterwards (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__runPrep)) return 'SKIP: this fixture cannot deploy and step the loop';
     if(typeof tickAmbience!=='function'||typeof updatePlayer!=='function'||typeof endRaid!=='function') return 'SKIP: no ambient bed or player update in this build';
     var bad=[], log=[], origTA=tickAmbience, origUP=updatePlayer, ended=false, i;
     tickAmbience=function(dt,threat,alive,dread){
       log.push({target:alive?(0.16+0.30*(threat||0)):0,over:!!(G&&G.over),ended:ended});
       return origTA.apply(this,arguments);
     };
     // The hold ends the raid from inside updatePlayer; so does this, once.
     updatePlayer=function(dt){
       var r=origUP.apply(this,arguments);
       if(!ended&&G&&!G.over&&G.t>0.5){ ended=true; endRaid('extract'); }
       return r;
     };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __state().player.downed=false;
       var t0=performance.now();
       for(i=0;i<60&&!ended;i++) __loop(t0+i*16.7);
       if(!ended) bad.push('control: the raid was never ended from inside the player update, so the frame order cannot be measured');
       for(var j=0;j<30;j++) __loop(t0+(i+j)*16.7);
       var before=log.filter(function(e){ return !e.ended; }), after=log.filter(function(e){ return e.ended; });
       if(!before.filter(function(e){ return e.target>0; }).length) bad.push('control: the bed was never driven above 0 before the end, so silence afterwards would prove nothing');
       if(!after.length) bad.push('control: the bed was not driven at all on the frame that ended the raid, so the order cannot be measured here');
       var up=after.filter(function(e){ return e.target>0; });
       if(up.length) bad.push('on the frame that ended the raid the bed was driven back up to '+up[up.length-1].target.toFixed(2)+' after the cut, which is the level it then holds on the floor');
       if(after.length&&after[after.length-1].target!==0) bad.push('the last level written after the end was '+after[after.length-1].target.toFixed(2)+' and not 0');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ tickAmbience=origTA; updatePlayer=origUP; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.79',what:'four guns are on the crafting bench, two green and two blue, each priced in parts between what it sells for and what it costs to buy, and crafting one through the real row puts the gun in the stash and takes the parts (his order of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
