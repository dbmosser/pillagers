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

# The window in front takes the keys (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v16.89, from his playtest report (player 1 could not extract while downed after player 2 had extracted): IN A SAME MACHINE
// PAIR THE KEYBOARD ALWAYS DRIVES PLAYER 1. Player 1 plays the keyboard and mouse, player 2 a controller (his rule of v16.35).
// The browser gives the keyboard to the window last clicked, so after a click on the player 2 window every key went there:
// E, WASD and the rest moved player 2 and did nothing for player 1. The player 2 window now hands every key it receives to
// the player 1 window over the pair channel and does not act on it; the player 1 window plays it as its own key. A text box
// in the player 2 window still types. The mouse is not handed over: it acts where it points.
function netKeyFwd(ev){
  if(!(typeof NET==='object'&&NET&&NET.same==='p2'&&NET.pair)) return;
  var tn=(ev.target&&ev.target.tagName)||'', up=(ev.type==='keyup'), cd=String(ev.code||'');
  // v22.06, from the whole-game bug hunt of 2026-10-08 (K17): F11 BELONGS TO THIS WINDOW. Every key pressed here was handed to the
  // player 1 window and stopped, F11 too, so the v17.92 toggle never ran in the player 2 window: F11 there never fullscreened it,
  // and in the player 1 window it ran the toggle, which took a fullscreen player 1 out of fullscreen. F11, down and up, now stays
  // here and fullscreens this window. Every other key still goes to player 1.
  if(cd==='F11') return;
  // v16.92, co-op hunt 2026-09-28: A KEY HELD HERE IS LET GO IN THE PLAYER 1 WINDOW. A key let go over a text box was dropped
  // here, and a key still down when this window lost focus sent its keyup to another program, so player 1 kept walking,
  // sprinting or holding E with no key down. This window now remembers what it handed down, a keyup for it is handed on even
  // over a text box (the box still sees it), and netKeyLetGo below hands up whatever is left when the keyboard goes.
  var box=(tn==='INPUT'||tn==='TEXTAREA'||tn==='SELECT');
  if(box&&!(up&&netKeyHeld[cd])) return;
  if(up) delete netKeyHeld[cd]; else if(cd) netKeyHeld[cd]=1;
  netSamePost({t:'key',pair:NET.pair,ty:up?'keyup':'keydown',code:cd,key:String(ev.key||''),rep:!!ev.repeat,sh:!!ev.shiftKey,ct:!!ev.ctrlKey});
  if(box) return;
  ev.preventDefault(); ev.stopImmediatePropagation();
}
var netKeyHeld={};   // v16.92: the codes this player 2 window handed down to player 1 and has not yet handed up
'@ @'
// v16.89, from his playtest report (player 1 could not extract while downed after player 2 had extracted), used to be: IN A SAME MACHINE PAIR THE
// KEYBOARD ALWAYS DRIVES PLAYER 1. The player 2 window handed every key it received to the player 1 window over the pair channel and did not act on it.
// v30.xx (cw-p2keys), HIS ORDER (2026-10-18): "if I bring the 2nd player screen to the front, it should take my key input, e.g. keys control whatever
// screen is to the top". THE WINDOW IN FRONT PLAYS THE KEYS AS ITS OWN PLAYER. netKeyFwd no longer posts a key to the pair and no longer stops it, so
// this window own handlers run: in the player 2 window the keyboard drives player 2, in the player 1 window player 1. The mouse acts where it points
// (the player 2 window takes the crosshair from its pad once it is in front, see the mousemove and mousedown listeners) and F11 stays local, as before.
// The function and its listeners stay so nothing else breaks, the player 1 window can still play a key word it is handed (netSameOnMsg), and
// netKeyLetGo below still hands up anything left in netKeyHeld, which is normally empty now. The window blur and focus listeners (releaseAllKeys)
// let go of every key held in whichever window loses the keyboard, so neither player keeps walking after a click on the other window.
function netKeyFwd(ev){ return false; }
var netKeyHeld={};   // v16.92, now normally empty (v30.xx, cw-p2keys): the codes this window once handed down to player 1 and has not yet handed up
'@

SubRx @'
if(typeof PAD!=='undefined'&&PAD&&!(typeof NET!=='undefined'&&NET&&NET.same==='p2')) PAD.curOwn=0;
'@ @'
if(typeof PAD!=='undefined'&&PAD&&(!(typeof NET!=='undefined'&&NET&&NET.same==='p2')||netPadFocused())) PAD.curOwn=0;   // v30.xx (cw-p2keys), HIS ORDER (2026-10-18): "keys control whatever screen is to the top". The player 2 window took the crosshair back from its pad never, so its mouse could not aim while a pad was on there (the pad placed the crosshair again every frame). In front, the mouse takes it back as in the player 1 window; a pointer only crossing a window that is not in front still leaves the pad crosshair alone
'@

SubRx @'
cv.addEventListener('mousedown',function(e){
'@ @'
cv.addEventListener('mousedown',function(e){
  // v30.xx (cw-p2keys), HIS ORDER (2026-10-18): "keys control whatever screen is to the top" and the mouse acts in the window it points at. A click in the player 2 window
  // is a deliberate use of the mouse there, so it takes the crosshair from that window pad at once and aims where it landed, in front yet or not (the first click on a window behind
  // it focuses it, and its mousemove cannot take the crosshair before that).
  if(typeof PAD!=='undefined'&&PAD&&typeof NET!=='undefined'&&NET&&NET.same==='p2'){ PAD.curOwn=0; try{ var _p2r=cv.getBoundingClientRect(); mouse.x=e.clientX-_p2r.left; mouse.y=e.clientY-_p2r.top; }catch(_p2m){} }
'@

SubRx @'
  if(ARCADE.role!=='host') return false;   // player 2 joins with A on its own pad; its keys go on to player 1 (netKeyFwd)
'@ @'
  // v30.xx (cw-p2keys), HIS ORDER (2026-10-18): "keys control whatever screen is to the top". The player 2 window used to let its keys go on to player 1 (netKeyFwd), so only A on its pad
  // joined it. A plain key or click in the player 2 window now asks to drop in, the same ask as A (arcadePadAtt, below); a raid, the operator menu and the easy mode question took their keys above.
  if(ARCADE.role!=='host'&&ARCADE.role!=='p2') return false;
'@

SubRx @'
  if(!arcadeBenched()&&arcadeOverAdvance()) return true;   // v25.xx (demoendboard): a press on the RUN OVER card shows the board first
'@ @'
  if(ARCADE.role==='p2'){ try{ arcadePadAtt(true,true); }catch(_p2a){} return true; }   // v30.xx (cw-p2keys): player 2 asks to drop in with a key or a click, as with A on its pad (the guards and the ask repeat live in arcadePadAtt and arcadeAttTick)
  if(!arcadeBenched()&&arcadeOverAdvance()) return true;   // v25.xx (demoendboard): a press on the RUN OVER card shows the board first
'@

SubRx @'
var VER='30.67';
'@ @'
var VER='30.68';
'@

$pat = "(?m)^  now:'v30\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.68: The keyboard now controls whichever game window is in front, so the player 2 window plays its own keys. Check 30.68 fails on v30.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
