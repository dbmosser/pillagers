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

# HIS NOTE, 2026-09-12: "since esc isn't working, lets set it up to hit b to back
# out of any menu."
#
# ONE FUNCTION, ONE KEY, ONE INSERTION POINT. Escape's behaviour is spread over
# seven handlers with a carefully built front-most order, and bolting KeyB onto
# each of them is seven chances to get the order wrong. backOut() asks the same
# question once, in the same order, and returns whether it closed anything.
#
# B DOES NOT OPEN THE PAUSE BOX, and that is deliberate. He asked for a key that
# backs OUT of menus. Escape and P still raise the pause box when nothing is in
# front; B with nothing in front is not a menu key at all, which is what keeps
# the merc order below intact.
#
# WHICH MATTERS, because B is already the merc order key in a raid and his own
# gear card says so: "On the surface B cycles his orders." A B that closed
# something has done its job and stops there; a B with nothing to close falls
# through to the merc exactly as before.
#
# The text-edit box keeps Escape alone. B is a letter and that box is where you
# type letters.
SubRx @'
function escCloseTopModal(){
'@ @'
// v13.17, HIS NOTE: B backs out of whatever is in front. The order below is the
// same front-most order Escape follows, written once instead of seven times.
// Returns true if it closed something, which is what lets a B with nothing to
// close fall through to the merc order it has always had.
function backOut(){
  // A right-click menu is in front of everything, including its own panel.
  var im=document.querySelectorAll('.imenu');
  if(im.length){ for(var i=0;i<im.length;i++) if(im[i].parentNode) im[i].parentNode.removeChild(im[i]); return true; }
  if(escCloseTopModal()) return true;
  try{ if(typeof hubBagOpen!=='undefined'&&hubBagOpen){ hubBagOpenSet(false); return true; } }catch(_hb){}
  var hb=document.getElementById('hub');
  if(hb&&hb.classList.contains('on')){ hb.classList.remove('on'); return true; }
  if(G&&!G.over){
    if(G.trade){ G.trade=null; G.pedLock=1; return true; }
    if(G.emoteBar){ G.emoteBar=false; return true; }
    // Same rule and same order as the v12.89 Escape line: the map is in front of
    // the backpack, and a held drag goes with the bag.
    if(G.mapOpen){ G.mapOpen=false; return true; }
    if(G.bagOpen){ G.bagOpen=false; G.drag=null; return true; }
  }
  return false;
}
function escCloseTopModal(){
'@

SubRx @'
  if(e.code==='Backspace'&&!e.repeat){ restoreCursor(); e.preventDefault(); return; }
'@ @'
  if(e.code==='Backspace'&&!e.repeat){ restoreCursor(); e.preventDefault(); return; }
  // v13.17, HIS NOTE: B backs out of whatever is in front, anywhere. Above every
  // branch because the floor branch and the raid branch each return at their own
  // end, so a key answered in only one of them is dead in the other, which is the
  // exact fault the Backspace line above was added to fix.
  // It does NOT open the pause box: he asked for a way OUT of menus, and a B with
  // nothing to close belongs to the merc order it has always had.
  if(e.code==='KeyB'&&!e.repeat){
    if(backOut()){ e.preventDefault(); return; }
  }
'@

SubRx @'
var VER='13.16';
'@ @'
var VER='13.17';
'@

$pat = "(?m)^  now:'v13\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.17: HIS NOTE of 2026-09-12, since esc is not working, B backs out of any menu. ONE FUNCTION, ONE KEY, ONE INSERTION POINT: the Escape behaviour is spread over seven handlers with a carefully built front-most order, and bolting B onto each of them is seven chances to get the order wrong, so backOut asks the same question once in the same order and returns whether it closed anything. That order is the right-click menu, then the front-most window, then the Undercroft backpack, then the terminal panel, then in a raid the stall, the emote bar, the map and the backpack, with a held drag going with the bag exactly as the v12.89 Escape line does it. It sits above every branch of the key handler because the floor branch and the raid branch each return at their own end, so a key answered in only one of them is dead in the other, which is the exact fault the Backspace line above it was added to fix. B DOES NOT OPEN THE PAUSE BOX and that is deliberate: he asked for a key that backs OUT, Escape and P still raise the box when nothing is in front, and a B with nothing to close is not a menu key at all, which is what keeps the merc order intact, since B already cycles merc orders in a raid and his own gear card says so. The text-edit box keeps Escape alone, because B is a letter and that box is where you type letters. HIS ESCAPE REPORT IS NOT CLOSED BY THIS and I have not pretended it is: I cannot reproduce it, because a synthetic Escape is a known bad instrument here, it runs before the v11.04 closer and opens the box it then shuts, and his report is about fullscreen, which no fixture can enter',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
