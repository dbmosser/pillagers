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

# v12.22 CHECK, inserted before the v12.21 entry. The box is opened by the key
# with every timer the opening schedules caught and run at once, so the 40 ms
# focus the old build asked for has happened before the next line; the second
# P is sent to whatever holds the keyboard, as a real key is, and must resume.
# Three arms: P resumes; M with the box up leaves the map shut while M with it
# down opens the map (the key path is live); ESC from inside the note still
# closes the box (v7.68).
SubRx @'
  {v:'12.21',what:'the sector map says EXTRACT NOW with the seconds left under a landed ring, the banner wording, instead of OPEN TO EXTRACT (2026-09-06 review of v11.74)',
'@ @'
  {v:'12.22',what:'P resumes a paused raid as the pause box legend says: opening the box no longer hands the keyboard to its note, and while the box is up no other key reaches the raid (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var pb=document.getElementById('pausebox'), ta=document.getElementById('pausenote');
     if(!pb||!ta||typeof togglePauseBox!=='function'||typeof raidKey!=='function') return 'SKIP: no pause box in this build';
     var bad=[], realST=window.setTimeout, queued=[];
     function holder(){ var a=document.activeElement; return (a&&a!==document.documentElement)?a:document.body; }
     function press(code,tgt){ (tgt||document.body).dispatchEvent(new KeyboardEvent('keydown',{code:code,key:(code==='KeyP'?'p':(code==='KeyM'?'m':code)),bubbles:true,cancelable:true})); }
     // Opens the box by the key, with every timer the opening schedules caught and run at once.
     function openByKey(){ queued.length=0; window.setTimeout=function(fn){ queued.push(fn); return 0; }; try{ press('KeyP'); for(var i=0;i<queued.length;i++){ try{ queued[i](); }catch(_q){} } }finally{ window.setTimeout=realST; } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(pb.classList.contains('on')) togglePauseBox(false);
       ta.value=''; try{ ta.blur(); }catch(_b){}
       g.mapOpen=false;
       // ARM ONE: P opens, P closes, the second press sent to whatever holds the keyboard.
       openByKey();
       if(!pb.classList.contains('on')) bad.push('control: P did not open the pause box');
       if(!g.paused) bad.push('control: the raid is not paused with the box up');
       var h=holder();
       if(queued.length) bad.push('opening the box scheduled '+queued.length+' delayed call(s); that is how it used to hand the keyboard to the note');
       press('KeyP',h);
       if(pb.classList.contains('on')) bad.push('the second P did not resume the raid ('+(h.id||h.tagName)+' held the keyboard)');
       else if(g.paused) bad.push('the box closed and the raid stayed paused');
       // ARM TWO: with the box up, M does not open the map; with it down, the same M does.
       if(pb.classList.contains('on')) togglePauseBox(false);
       openByKey();
       press('KeyM',holder());
       if(g.mapOpen) bad.push('M opened the map while the pause box was up');
       if(pb.classList.contains('on')) togglePauseBox(false);
       g.mapOpen=false;
       press('KeyM');
       if(!g.mapOpen) bad.push('control: M with the box down did not open the map');
       g.mapOpen=false;
       // ARM THREE: ESC from inside the note still closes the box (v7.68), so a note writer is not trapped.
       openByKey();
       try{ ta.focus(); }catch(_f){}
       press('Escape',ta);
       if(pb.classList.contains('on')) bad.push('ESC from inside the note no longer closes the box');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       window.setTimeout=realST;
       try{ ta.value=''; ta.blur(); if(pb.classList.contains('on')){ togglePauseBox(false); pb.classList.remove('on'); } }catch(_c){}
       try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('extract'); } } }catch(_e){}
       keys={}; __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.21',what:'the sector map says EXTRACT NOW with the seconds left under a landed ring, the banner wording, instead of OPEN TO EXTRACT (2026-09-06 review of v11.74)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
