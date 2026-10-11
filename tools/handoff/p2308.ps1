$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# SYSTEM LABELS IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(code==='NumpadAdd'){ setZoom(zoomTarget()*1.15); if(G&&!G.over) say('Zoom '+Math.round(ZT*100)+'%'); }
'@ @'
  if(code==='NumpadAdd'){ setZoom(zoomTarget()*1.15); if(G&&!G.over) say('ZOOM '+Math.round(ZT*100)+'%','sys'); }   // v22.xx (R55): a system label in caps
'@

SubRx @'
  if(code==='NumpadSubtract'){ setZoom(zoomTarget()/1.15); if(G&&!G.over) say('Zoom '+Math.round(ZT*100)+'%'); }
'@ @'
  if(code==='NumpadSubtract'){ setZoom(zoomTarget()/1.15); if(G&&!G.over) say('ZOOM '+Math.round(ZT*100)+'%','sys'); }   // v22.xx (R55): a system label in caps
'@

SubRx @'
  if(code==='Digit0'||code==='Numpad0'){ setZoom(1); if(G&&!G.over) say('Zoom 100%'); }
'@ @'
  if(code==='Digit0'||code==='Numpad0'){ setZoom(1); if(G&&!G.over) say('ZOOM 100%','sys'); }   // v22.xx (R55): a system label in caps
'@

SubRx @'
  if(G&&!G.over&&!G.sim) say(_ups); else if(typeof say2==='function') say2(_ups);
'@ @'
  if(G&&!G.over&&!G.sim) say(_ups.toUpperCase(),'sys'); else if(typeof say2==='function') say2(_ups);   // v22.xx (R55): HUD SIZE 100% in a raid; the Undercroft line is unchanged
'@

SubRx @'
    if(G&&!G.over&&!G.sim) say(_shL); else if(typeof say2==='function') say2(_shL);
'@ @'
    if(G&&!G.over&&!G.sim) say('SUPERHOT FOLLOWS THE HOST','sys'); else if(typeof say2==='function') say2(_shL);   // v22.xx (R55): in a raid; the Undercroft line is unchanged
'@

SubRx @'
    if(e.button===2){ G.waypoint=null; say('Waypoint cleared'); try{ if(NET.on) netWpSend(); }catch(_wc){} return; }
'@ @'
    if(e.button===2){ G.waypoint=null; say('WAYPOINT CLEARED','sys'); try{ if(NET.on) netWpSend(); }catch(_wc){} return; }   // v22.xx (R55): a system label in caps
'@

SubRx @'
        blip('pick'); say('Waypoint marked');
'@ @'
        blip('pick'); say('WAYPOINT SET','sys');   // v22.xx (R55): a system label in caps
'@

SubRx @'
  blip('pick'); say((typeof NET==='object'&&NET&&NET.on)?'Marker placed. Your party can see it.':'Waypoint marked');
'@ @'
  blip('pick'); say('WAYPOINT SET','sys',(typeof NET==='object'&&NET&&NET.on)?{sub:'Your party can see it.'}:null);   // v22.xx (R55): Waypoint, never Marker (his Marked Waypoint)
'@

SubRx @'
    if(G&&!G.over) say('Controller connected. Left stick moves, right stick aims.');
'@ @'
    if(G&&!G.over) say('CONTROLLER CONNECTED','sys');   // v22.xx (R55): a system label in caps
'@

SubRx @'
  if(typeof G!=='undefined'&&G&&!G.over&&!G.sim&&typeof state!=='undefined'&&state==='raid'){ try{ if(!pauseOpen) togglePauseBox(true); }catch(_pd){} try{ say('Controller disconnected. Plug it in, then resume.'); }catch(_pd2){} }
'@ @'
  if(typeof G!=='undefined'&&G&&!G.over&&!G.sim&&typeof state!=='undefined'&&state==='raid'){ try{ if(!pauseOpen) togglePauseBox(true); }catch(_pd){} try{ say('CONTROLLER DISCONNECTED','sys',{sub:'Plug it in, then resume.'}); }catch(_pd2){} }   // v22.xx (R55): a system label in caps
'@

SubRx @'
  if(G&&!G.over) say('Cursor reset.');
'@ @'
  if(G&&!G.over) say('CURSOR RESET','sys');   // v22.xx (R55): a system label in caps
'@

SubRx @'
function recTell(s){ try{ if(typeof G!=='undefined'&&G&&!G.over&&!G.sim) say(s); else if(typeof hubToast==='function') hubToast(s); }catch(e){} }
'@ @'
function recTell(s,sub){ try{ if(typeof G!=='undefined'&&G&&!G.over&&!G.sim) say(s,'sys',sub?{sub:sub}:null); else if(typeof hubToast==='function') hubToast(s+(sub?('  \u00b7  '+sub):'')); }catch(e){} }   // v22.xx (R55): a caps label with a short detail
'@

SubRx @'
  if(typeof MediaRecorder==='undefined'||!HTMLCanvasElement.prototype.captureStream){ recTell('This browser cannot record the game.'); return false; }
'@ @'
  if(typeof MediaRecorder==='undefined'||!HTMLCanvasElement.prototype.captureStream){ recTell('THIS BROWSER CANNOT RECORD'); return false; }
'@

SubRx @'
  try{ REC.mr=new MediaRecorder(REC.cv.captureStream(30),o); }catch(e){ recTell('This browser cannot record the game.'); return false; }
'@ @'
  try{ REC.mr=new MediaRecorder(REC.cv.captureStream(30),o); }catch(e){ recTell('THIS BROWSER CANNOT RECORD'); return false; }
'@

SubRx @'
  try{ REC.mr.start(1000); }catch(e){ REC.on=false; recTell('This browser cannot record the game.'); return false; }
'@ @'
  try{ REC.mr.start(1000); }catch(e){ REC.on=false; recTell('THIS BROWSER CANNOT RECORD'); return false; }
'@

SubRx @'
  recTell('Recording. Press F9 again to stop (it stops by itself after 3 minutes).');
'@ @'
  recTell('RECORDING','[F9] stops it, or it stops at 3:00.');   // v22.xx (R55): a system label in caps
'@

SubRx @'
  if(!b||b.size<20000){ recTell('That recording was too short to keep.'); return; }
'@ @'
  if(!b||b.size<20000){ recTell('RECORDING TOO SHORT TO KEEP'); return; }   // v22.xx (R55): a system label in caps
'@

SubRx @'
  attClipPut(b,function(ok){ recTell(ok?('Recording kept: it plays on the title when nobody is playing. A copy is in your downloads.'):'This browser could not keep the recording; a copy is in your downloads.'); });
'@ @'
  attClipPut(b,function(ok){ recTell(ok?'RECORDING KEPT':'RECORDING NOT KEPT','A copy is in your downloads.'); });   // v22.xx (R55): a system label in caps
'@

SubRx @'
      var _loanLn='You are carrying a loaner. Equip your own gun from the stash before your next ascent.';
'@ @'
      var _loanLn='YOU CARRY A LOANER';   // v22.xx (R55): a system label in caps
'@

SubRx @'
      sayWhenFree(_loanLn);   // v13.33: through the queue, so nothing writes over it
'@ @'
      sayWhenFree(_loanLn,'info',{sub:'Equip your own gun at The Stash.'});   // v13.33: through the queue, so nothing writes over it
'@

SubRx @'
   cap:'BLACKOUT',turn:'GRID GOING DOWN',sub:'Every lamp on the map is dead'},
'@ @'
   cap:'BLACKOUT',turn:'GRID GOING DOWN',sub:'Every lamp up top is dead'},   // v22.xx (R55): up top is the place, never the map
'@

SubRx @'
var VER='23.07';
'@ @'
var VER='23.08';
'@

$pat = "(?m)^  now:'v23\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.08: Zoom, HUD size, Waypoint, controller, cursor, recorder and loaner lines read as caps system labels, and Waypoint is the one marker word. Check 23.08 fails on v23.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
