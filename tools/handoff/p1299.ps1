$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FINDING 14 OF THE 2026-09-11 AUDIT. It is his machine only, in the authoring mode he
# demonstrably leaves on, which is where his 67 text edits came from.
#
# WHAT HAPPENS. Edit the words is on. He clicks a line inside any window, the yellow
# box opens over it, he changes his mind and presses ESC to back out. The capture
# handler that gives Escape to the front window runs first, finds a modal open, stops
# the event dead and closes that window. The event never reaches the box, so the one
# gesture that means CANCEL THIS EDIT destroys the panel the edit was being made in,
# and leaves the editor it was supposed to dismiss sitting over the game with the
# keyboard. The box outlives the panel because it is appended to the document body
# rather than inside the screen, so closing the panel cannot take it along.
#
# HE HAS TO PRESS ESC A SECOND TIME to be rid of the box, and by then the window he
# was editing is gone.
#
# WHY THE HANDLER IS RIGHT AND STILL WRONG. Its own comment states the rule: if a
# window is open, Escape belongs to that window and not to what is underneath. The
# editor sits ABOVE the window at z-index 99999, so by the handler's own rule Escape
# belongs to the editor. It simply had no way to know the editor was there.
#
# THE FIX GOES AT THE TOP OF THAT HANDLER, not in another one further down the chain:
# anything downstream never runs, because this one stops propagation before the box
# can hear the key.
SubRx @'
document.addEventListener('keydown',function(e){
  if(e.code!=='Escape') return;
  var open=document.querySelectorAll('.modal.on');
  if(!open.length) return;
'@ @'
document.addEventListener('keydown',function(e){
  if(e.code!=='Escape') return;
  // v12.99, audit finding 14: THE EDIT BOX IS IN FRONT OF THE WINDOW, so by the rule
  // in the comment above Escape belongs to it. It is appended to the body rather
  // than inside the screen, so it survives its own panel being closed and kept the
  // keyboard afterwards; and it is handled HERE rather than in its own listener
  // because this one stops propagation before the box can hear the key at all.
  if(typeof TXBOX!=='undefined'&&TXBOX&&document.activeElement===TXBOX){
    e.preventDefault(); e.stopPropagation();
    try{ txClose(); }catch(_tx){}
    return;
  }
  var open=document.querySelectorAll('.modal.on');
  if(!open.length) return;
'@

# NEW IN.
SubRx @'
  'THE LAST POUR SHOWS THE ONE BONUS IT ACTUALLY PAYS.
'@ @'
  'ESC OUT OF AN EDIT BOX CLOSES THE EDIT BOX. With Edit the words on, backing out of an edit shut the window you were editing instead and left the yellow box sitting over the game holding the keyboard, so it took a second ESC to be rid of it and the window was gone by then.',
  'THE LAST POUR SHOWS THE ONE BONUS IT ACTUALLY PAYS.
'@

# STAMPS.
SubRx @'
var VER='12.98';
'@ @'
var VER='12.99';
'@
SubRx @'
var WHATSNEW_VER='12.98';
'@ @'
var WHATSNEW_VER='12.99';
'@
$cnt=([regex]::Matches($s,"now:'v12\.98:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.98 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.98:[^']*'",{ param($m) "now:'v12.99: finding 14 of the 2026-09-11 audit, his machine only, in the authoring mode he demonstrably leaves on, which is where his 67 text edits came from. Edit the words is on; he clicks a line inside any window, the yellow box opens over it, he changes his mind and presses ESC to back out, and the capture handler that gives Escape to the front window runs first, finds a modal open, stops the event dead and closes that window. The event never reaches the box, so the one gesture that means CANCEL THIS EDIT destroys the panel the edit was being made in and leaves the editor it was supposed to dismiss sitting over the game with the keyboard; the box outlives the panel because it is appended to the document body rather than inside the screen, so closing the panel cannot take it along, and he has to press ESC a second time to be rid of it, by which point the window he was editing is gone. The handler is right and still wrong: its own comment states the rule, that if a window is open Escape belongs to that window and not to what is underneath, and the editor sits ABOVE the window at z-index 99999, so by the handler own rule Escape belongs to the editor; it simply had no way to know the editor was there. The fix goes at the top of that handler rather than in another one further down the chain, because anything downstream never runs: this one stops propagation before the box can hear the key. Check 12.99 opens a window, opens the edit box over it, presses the real key and requires the box gone and the window still open, with controls that ESC with a window open and no box still closes the window and that the box is still what a second press would have reached; fails on v12.98.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
