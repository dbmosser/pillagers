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

# FROM THE 2026-09-08 READ-ONLY AUDIT, confirmed by a skeptic against the source.
# THIS IS MY OWN v8.17 BUILD AGAIN: I added the confirm card and never noticed
# what raising it does to the window underneath.
#
# Raising a window closes every other one, which is right for windows and wrong
# for a card asking a question ABOUT the window you are standing in. Press "Hire
# nobody" at the bench and the bench closes behind the question. Answer "Not
# yet" and the card closes onto the bare floor: the tab, the grid and the man
# you were reading about are all gone for a question you declined, and you have
# to walk back to the station.
#
# Answer LET THEM GO and it is worse in a quieter way. The callback redraws the
# bench to clear the HIRED pill, and it draws into a window nobody is looking
# at, so the one irreversible action on that bench, a hire that is not refunded,
# shows its result nowhere except a toast that fades in five seconds.
SubRx @'
var ASKYES=null, ASKALT=null;
'@ @'
// v12.68, 2026-09-08 audit: AND WHAT TO PUT BACK. A card that asks about the
// window he is standing in closes that window to raise itself, so answering it
// either way used to leave him on the bare floor. Whoever raises the card can
// name the window to restore, and all three answers put it back before anything
// else runs, so a callback that redraws that window draws where he is looking.
var ASKYES=null, ASKALT=null, ASKBACK=null;
function askRestore(){
  if(!ASKBACK) return;
  var _b=ASKBACK; ASKBACK=null;
  var _e=document.getElementById(_b);
  if(_e) _e.classList.add('on');
}
'@

SubRx @'
  if(_a) _a.style.display='none';
  openModal('askmodal');
'@ @'
  if(_a) _a.style.display='none';
  ASKBACK='tradermodal';   // v12.68: this question is about the bench, so come back to it
  openModal('askmodal');
'@

SubRx @'
document.getElementById('askyes').onclick=function(){
  var f=ASKYES; ASKYES=null;
  document.getElementById('askmodal').classList.remove('on');
  if(f) f();
};
document.getElementById('askno').onclick=function(){
  ASKYES=null; ASKALT=null;
  document.getElementById('askmodal').classList.remove('on');
};
document.getElementById('askalt').onclick=function(){
  var f=ASKALT; ASKYES=null; ASKALT=null;
  document.getElementById('askmodal').classList.remove('on');
  if(f) f();
};
'@ @'
document.getElementById('askyes').onclick=function(){
  var f=ASKYES; ASKYES=null;
  document.getElementById('askmodal').classList.remove('on');
  askRestore();   // v12.68: BEFORE the callback, so a redraw of that window is seen
  if(f) f();
};
document.getElementById('askno').onclick=function(){
  ASKYES=null; ASKALT=null;
  document.getElementById('askmodal').classList.remove('on');
  askRestore();   // v12.68: a question he declined does not cost him the window
};
document.getElementById('askalt').onclick=function(){
  var f=ASKALT; ASKYES=null; ASKALT=null;
  document.getElementById('askmodal').classList.remove('on');
  askRestore();
  if(f) f();
};
'@

# NEW IN.
SubRx @'
  'SELLING SALVAGE MOVES YOUR LEVEL, not just your XP. The level was only worked out at the end of a raid, so the card showed a level that disagreed with the XP printed under it and the racks you had just earned stayed locked until you went up and came back.',
'@ @'
  'SELLING SALVAGE MOVES YOUR LEVEL, not just your XP. The level was only worked out at the end of a raid, so the card showed a level that disagreed with the XP printed under it and the racks you had just earned stayed locked until you went up and came back.',
  'ANSWERING THE HIRE BENCH QUESTION LEAVES YOU AT THE BENCH. Pressing Hire nobody closed the bench behind its own confirm card, so saying no put you on the bare floor and saying yes redrew the bench where you could not see it.',
'@

# STAMPS.
SubRx @'
var VER='12.67';
'@ @'
var VER='12.68';
'@
SubRx @'
var WHATSNEW_VER='12.67';
'@ @'
var WHATSNEW_VER='12.68';
'@
$cnt=([regex]::Matches($s,"now:'v12\.67:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.67 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.67:[^']*'",{ param($m) "now:'v12.68: from the 2026-09-08 read-only audit, and this is my own v8.17 build again: I added the confirm card and never noticed what raising it does to the window underneath. Raising a window closes every other one, which is right for windows and wrong for a card asking a question ABOUT the window he is standing in. Press Hire nobody at the bench and the bench closes behind the question; answer Not yet and the card closes onto the bare floor, with the tab, the grid and the man he was reading about all gone for a question he declined, and he has to walk back to the station. Answer LET THEM GO and it is worse in a quieter way, because the callback redraws the bench to clear the HIRED pill and draws into a window nobody is looking at, so the one irreversible action on that bench, a hire that is not refunded, shows its result nowhere except a toast that fades in five seconds. Whoever raises the card can now name the window to restore, and all three answers put it back BEFORE anything else runs, so a callback that redraws that window draws where he is looking. Check 12.68 presses the footer button, answers both ways, and requires the bench to be open again each time and the HIRED pill to be cleared where it can be seen, with a control that a card raised by something that is not a window still closes onto the floor as it always did; fails on v12.67.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
