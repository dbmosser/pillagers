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
  {v:'10.85',what:'nothing goes on sounding after the raid that started it: the ambient bed is cut on every ending, and no sound source in the file is left running with nobody to turn it down',
'@ @'
  {v:'10.86',what:'the ambient bed ducks when the pause box opens and comes back when you resume, once each time and not every frame',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop)) return 'SKIP: this fixture cannot deploy and step a raid';
     var bad=[];
     // The old build has no way to cut the bed at all, so the fallback reports
     // that rather than skipping: a SKIP is not a PASS.
     var raw=window.__ambOff;
     function cuts(){ var r=null; try{ r=raw?raw():null; }catch(e){ r=null; } return r?r.calls:-1; }
     if(cuts()<0) return 'this build has no way to cut the ambient bed at all, so a pause leaves it holding its last level under the menu';
     __runPrep(); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), t0=performance.now(), f=0;
     function step(k){ for(var i=0;i<k;i++){ __loop(t0+(f++)*16.7); } }
     g.paused=false;
     step(20);
     var a=cuts();
     // 1. PLAYING IS NOT PAUSING. A duck that fired during play would fight the
     //    thing that makes the room tighten as something closes on you.
     if(a!==cuts()) bad.push('control: the reading moved on its own');
     var base=cuts();
     step(20);
     if(cuts()!==base) bad.push('the bed is being ducked during ordinary play, '+(cuts()-base)+' times in twenty frames, so the room can never tighten');
     // 2. THE PAUSE DUCKS IT, ONCE.
     g.paused=true;
     step(1);
     var afterFirst=cuts();
     if(afterFirst!==base+1) bad.push('opening the pause box ducked the bed '+(afterFirst-base)+' times, and it should be exactly once');
     step(40);
     if(cuts()!==afterFirst) bad.push('the bed is re-ducked every frame while paused, '+(cuts()-afterFirst)+' more times in forty frames');
     // 3. RESUMING DOES NOT DUCK, and arms the next pause.
     g.paused=false;
     step(20);
     if(cuts()!==afterFirst) bad.push('resuming ducked the bed '+(cuts()-afterFirst)+' times');
     if(g._ambDuck) bad.push('the duck flag is still set after resuming, so the next pause will not duck at all');
     // 4. AND THE SECOND PAUSE DUCKS AGAIN. Without this a build that ducks once
     //    per raid and never again would pass every line above.
     g.paused=true;
     step(1);
     if(cuts()!==afterFirst+1) bad.push('a second pause ducked the bed '+(cuts()-afterFirst)+' times rather than once, so only the first pause in a raid is quiet');
     g.paused=false; step(2);
     return bad.length?bad.join('; '):null; }},
  {v:'10.85',what:'nothing goes on sounding after the raid that started it: the ambient bed is cut on every ending, and no sound source in the file is left running with nobody to turn it down',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
