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
window.__lockedOf=function(mi){ try{ return (FIXED_MAPS[mi]&&FIXED_MAPS[mi].locked)||[]; }catch(e){ return []; } };
'@ @'
window.__lockedOf=function(mi){ try{ return (FIXED_MAPS[mi]&&FIXED_MAPS[mi].locked)||[]; }catch(e){ return []; } };
// v10.85: how many times the ambient bed has been cut, and whether it is live.
// A counter and not a gain reading, because this fixture makes AudioContext
// throw so probe runs stay silent: there is no gain to read, but there is
// still a fact about whether the cut was reached.
window.__ambOff=function(){ return {calls:AMBOFF,live:!!AMB}; };
'@

SubRx @'
  {v:'10.84',what:'a machine standing inside a building can work out a route to somebody outside it, and opening those doorways did not move the world',
'@ @'
  {v:'10.85',what:'nothing goes on sounding after the raid that started it: the ambient bed is cut on every ending, and no sound source in the file is left running with nobody to turn it down',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy and end a raid';
     var bad=[];
     // THE FALLBACK IS THE OLD BUILD ON PURPOSE. Without the hook this must say
     // what the build before it was doing, not skip: a SKIP is not a PASS.
     var hook=window.__ambOff||function(){ return {calls:0,live:false}; };
     // 1. IT IS CUT ON EVERY ENDING, and there are three.
     var ways=['extract','dead','abandon'], w;
     for(w=0;w<ways.length;w++){
       __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var before=hook().calls;
       var t0=performance.now(), f;
       // Ordinary play. The bed is driven DOWN here by the raid loop itself, so
       // the cut must not be firing on these frames or it would be fighting the
       // thing that makes the room tighten.
       for(f=0;f<30;f++) __loop(t0+f*16.7);
       var during=hook().calls;
       if(during!==before) bad.push('the bed is being cut during ordinary play, '+(during-before)+' times in thirty frames, so the room can never tighten');
       __endRaid(ways[w]);
       var after=hook().calls;
       if(after<=during) bad.push('a raid that ended in '+ways[w]+' never cut the ambient bed, so its five voices hold their last level for as long as the page is open');
       else if(after-during>1) bad.push('a raid that ended in '+ways[w]+' cut the bed '+(after-during)+' times');
     }
     // 2. HIS RULE, GENERALISED: nothing may be left sounding with nobody to
     //    turn it down. Every oscillator in the file is either stopped, or it
     //    belongs to the bed, which is stopped by gain and now has a cut.
     //    The needle is assembled rather than written, or this check finds
     //    ITSELF in the page and reads its own text as the game's.
     var src=null;
     try{ src=(document.documentElement&&document.documentElement.innerHTML)||''; }catch(_s){ src=''; }
     if(src.length>20000){
       var mk=new RegExp('create'+'Oscillator'+'\\(\\)','g');
       var st=new RegExp('\\.'+'stop'+'\\(','g');
       var made=(src.match(mk)||[]).length, stopped=(src.match(st)||[]).length;
       // MEASURED at v10.85: 40 made, 38 stopped, and the two never stopped are
       // the bed's own 54 Hz and 81.5 Hz sines, which ambienceOff now cuts along
       // with the weather and dread layers. A sixth voice with no stop and no cut
       // is the next hum, so the gap is pinned rather than the totals.
       var gap=made-stopped;
       if(gap>2) bad.push(gap+' oscillators in the file are started and never stopped, against the 2 the ambient bed accounts for, so something is left sounding with nothing to turn it down');
       if(made<10) bad.push('control: only '+made+' oscillators found in the page, so this measured the wrong document');
     }
     // 3. CONTROL: the hook has to be real, or every line above passed on a stub.
     if(!window.__ambOff) bad.push('control: this build has no way to cut the ambient bed at all');
     return bad.length?bad.join('; '):null; }},
  {v:'10.84',what:'a machine standing inside a building can work out a route to somebody outside it, and opening those doorways did not move the world',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
