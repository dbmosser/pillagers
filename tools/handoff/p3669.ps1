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

# TIMELORD KEY NEEDS A HOLD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var keys={},mouse={x:0,y:0,down:false},pauseOpen=false,tuneOpen=false;
'@ @'
var keys={},mouse={x:0,y:0,down:false},pauseOpen=false,tuneOpen=false;
// v28.xx (cw-cx-timelordhold), his 10-31 report: "sometimes the game randomly cuts timelord mode on". A continuous 0.6 s hold, once per release; no demo shortcut.
var SHKEY={down:false,done:false,at:0,g:null,scene:''};
function shKeyCancel(){ SHKEY.down=false; SHKEY.done=false; SHKEY.g=null; }
function shKeyStart(e){
  if(e.repeat||SHKEY.down||demoKeysOn()) return;
  SHKEY.down=true; SHKEY.done=false; SHKEY.at=statusNow(); SHKEY.g=G; SHKEY.scene=state;
}
function shKeyProgress(){
  if(!SHKEY.down||SHKEY.done||demoKeysOn()||SHKEY.g!==G||SHKEY.scene!==state) return -1;
  return clamp((statusNow()-SHKEY.at)/0.6,0,1);
}
function shKeyTick(){
  if(!SHKEY.down) return;
  var el=document.activeElement, tag=(el&&el.tagName)||'';
  if(demoKeysOn()||SHKEY.g!==G||SHKEY.scene!==state||document.hidden||tag==='INPUT'||tag==='TEXTAREA'){ shKeyCancel(); return; }
  if(SHKEY.done||statusNow()-SHKEY.at<0.6) return;
  SHKEY.done=true;
  if(cycleGameOpt('superhot')===false) return;
  try{ var sm=document.getElementById('settingsmodal'); if(sm&&sm.classList.contains('on')) renderSettings(); }catch(_shkr){}
  shSay(CFG.superhot);
}
window.addEventListener('keyup',function(e){ if(e.code==='Backquote') shKeyCancel(); },true);
window.addEventListener('keydown',function(e){ if(e.code==='ShiftLeft'||e.code==='ShiftRight') shKeyCancel(); },true);
'@

SubRx @'
  if(e.code==='Backquote'){ e.preventDefault();
    if(e.shiftKey){ toggleTune(); return; }
    if(!e.repeat){
      if(cycleGameOpt('superhot')===false) return;   // v16.74, his order: on a linked window the host word rules; cycleGameOpt said so, and there is no dial of its own to report
      // v15.15, dials audit finding 7: THE SUPERHOT KEY REDRAWS AN OPEN SETTINGS ROW. The Settings rows are drawn only by
      // renderSettings, and this key moved the dial, saved and said so without calling it, so with Settings open the Superhot
      // row kept its old word. Closed on Off, the next raid ran in Superhot. Clicked to turn it on, the row steps from the live
      // dial, so the click turned Superhot off and the row redrew as Off, as if the click did nothing. Redrawn only while the
      // window is open, the same guard toggleTune uses when the console closes over Settings.
      try{ var _smB=document.getElementById('settingsmodal'); if(_smB&&_smB.classList.contains('on')) renderSettings(); }catch(_rsB){}
      // v30.xx (cw-shkey), HIS NOTE (2026-10-18): "superhot mode needs a toggle key." The key left of 1 has toggled Superhot since v7.23, but nothing on screen named it
      // (only CHANGE KEYS did), and its line could read the wrong state: the lines it said were not replaced, so on, off, on within a second left OFF on top and OFF
      // last in the feed with Superhot on. shSay keeps one line, the state just set; the key is named on the F1 list and beside the Settings row.
      shSay(CFG.superhot);
    }
    return;
  }

'@ @'
  if(e.code==='Backquote'){ e.preventDefault();
    // v28.xx (cw-cx-timelordhold): Shift keeps its tuning chord; a tap never reaches the saved dial.
    if(e.shiftKey){ shKeyCancel(); toggleTune(); return; }
    shKeyStart(e);
    return;
  }

'@

SubRx @'
function loop(ts){
'@ @'
function loop(ts){
  try{ shKeyTick(); }catch(_shkt){ shKeyCancel(); } // v28.xx (cw-cx-timelordhold): wall time, before the frame cap or timelord slows the simulation.
'@

SubRx @'
function releaseAllKeys(soft){
'@ @'
function releaseAllKeys(soft){
  shKeyCancel(); // v28.xx (cw-cx-timelordhold): focus loss, hiding and cursor reset cancel an unfinished hold.
'@

SubRx @'
['timelord mode','LEFT OF 1']
'@ @'
['timelord mode','HOLD LEFT OF 1']
'@

SubRx @'
['LEFT OF 1','timelord on/off']
'@ @'
['HOLD LEFT OF 1','timelord on/off']
'@

SubRx @'
key: left of 1</div>
'@ @'
key: hold left of 1</div>
'@

SubRx @'
  var A=ansUp(), p=G&&G.player, ps, hr, f, px, t, tw, al, x, y, bw, bh, k;
'@ @'
  // v28.xx (cw-cx-timelordhold): a transient preview uses the existing status bubble without saving or saying anything on a tap.
  var hold=shKeyProgress(), A=hold>=0?{m:'timelord '+(CFG.superhot?'on':'off'),at:statusNow()-0.2}:ansUp(), p=G&&G.player, ps, hr, f, px, t, tw, al, x, y, bw, bh, k;
'@

SubRx @'
tw=ctx.measureText(TX(t)).width; bw=Math.round(tw+LH(16)*hr); bh=Math.round(px*1.45);
'@ @'
tw=ctx.measureText(TX(t)).width; bw=Math.round(tw+LH(16)*hr+(hold>=0?LH(64)*hr:0)); bh=Math.round(px*1.45);
'@

SubRx @'
hudText(t,x,Math.round(y+px*0.36));
'@ @'
hudText(t,x-(hold>=0?LH(32)*hr:0),Math.round(y+px*0.36));
    // v28.xx (cw-cx-timelordhold): a short fill bar beside the current state; the state changes only when the hold completes.
    if(hold>=0){ ctx.fillStyle='#4a5257'; ctx.fillRect(x+bw/2-LH(56)*hr,y-2*hr,LH(40)*hr,4*hr); ctx.fillStyle='#e6ff3d'; ctx.fillRect(x+bw/2-LH(56)*hr,y-2*hr,LH(40)*hr*hold,4*hr); }
'@

SubRx @'
var VER='36.68';
'@ @'
var VER='36.69';
'@

$pat = "(?m)^  now:'v36\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.69: A tap does nothing. Hold the key left of 1 for 0.6 seconds to switch timelord mode once. The demo ignores the shortcut; Shift still opens tuning. LOCAL: no linked review. Check 36.69 fails on v36.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
