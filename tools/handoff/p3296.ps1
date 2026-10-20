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

# A FAULT THAT KEEPS REPEATING RELOADS THE GAME INTO THE TITLE WITH A SHORT NOTE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function noteCrash(kind,msg,where){

'@ @'
// v28.xx (cw-crashreload), HIS ANSWER (2026-10-12, Tech): "A crash reloads into the title with a note." One thrown error never kills the frame loop, so
// the trigger is the SAME fault repeating: same kind, same message (digits ignored) and same place, again within a second of the last, for 5 seconds
// or more and at least 10 times a second on average. One error, a short burst, a hidden page, the test pages (fixture has __runPrep) and anything
// after the first restart never trigger. The restart saves nothing more (the last good save stays), leaves a note in sessionStorage and reloads;
// the title shows "restarted after an error" for a few seconds and fades it.
var CRASH_LOOP_MS=5000, CRASH_RESTART=false, CRASH_RUN=null, CRASH_NOTE_KEY='salvagerun:crashnote';
function crashNow(){ return Date.now(); }
function crashHidden(){ return !!(typeof document!=='undefined'&&document.hidden); }
function crashReload(){ location.reload(); }
function crashLoopSeen(kind,msg,where,now){
  if(CRASH_RESTART) return false;
  if(crashHidden()){ CRASH_RUN=null; return false; }
  if(typeof __runPrep==='function'&&!window.__crashReloadTest) return false;
  var key=kind+'|'+String(msg).replace(/\d+/g,'#')+'|'+String(where).replace(/\d+/g,'#');
  var r=CRASH_RUN;
  if(!r||r.key!==key||now-r.last>1000){ CRASH_RUN={key:key,t0:now,last:now,n:1}; return false; }
  r.last=now; r.n++;
  var dur=now-r.t0;
  return dur>=CRASH_LOOP_MS&&r.n>=dur/100;
}
function crashRestart(){
  CRASH_RESTART=true;
  try{ sessionStorage.setItem(CRASH_NOTE_KEY,'restarted after an error'); }catch(_cn){}
  try{ crashReload(); }catch(_cr){}
}
try{
  var _crn=null; try{ _crn=sessionStorage.getItem(CRASH_NOTE_KEY); sessionStorage.removeItem(CRASH_NOTE_KEY); }catch(_c0){}
  if(_crn) setTimeout(function(){
    try{
      var d=document.createElement('div'); d.id='crashnote'; d.textContent=String(_crn).toLowerCase();
      d.style.cssText='position:fixed;left:50%;top:14%;transform:translateX(-50%);z-index:99999;pointer-events:none;font-size:24px;letter-spacing:.06em;color:#e8e4d8;opacity:1;transition:opacity 1.2s';
      document.body.appendChild(d);
      setTimeout(function(){ d.style.opacity='0'; },4000);
      setTimeout(function(){ if(d.parentNode) d.parentNode.removeChild(d); },5500);
    }catch(_c1){}
  },300);
}catch(_c2){}
function noteCrash(kind,msg,where){
'@

SubRx @'
    var now=Date.now(), hit=null;

'@ @'
    var now=crashNow(), hit=null;   // v28.xx (cw-crashreload)

'@

SubRx @'
    // v14.49: and a new entry saves at most once a second, so a burst of different errors cannot save every frame either.

'@ @'
    if(crashLoopSeen(kind,msg,where,now)){ crashRestart(); return; }   // v28.xx (cw-crashreload): the same fault for 5 s: no more saves, reload into the title
    // v14.49: and a new entry saves at most once a second, so a burst of different errors cannot save every frame either.

'@

SubRx @'
  if(SAVE_STALE) return;   // v17.24: another tab has written this save since this tab read it; writing now would wipe that

'@ @'
  if(SAVE_STALE) return;   // v17.24: another tab has written this save since this tab read it; writing now would wipe that
  if(typeof CRASH_RESTART!=='undefined'&&CRASH_RESTART) return;   // v28.xx (cw-crashreload): a restart after a repeating fault keeps the last good save

'@

SubRx @'
var VER='32.95';
'@ @'
var VER='32.96';
'@

$pat = "(?m)^  now:'v32\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.96: If the same error repeats for 5 seconds the game restarts into the title and says restarted after an error. Check 32.96 fails on v32.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
