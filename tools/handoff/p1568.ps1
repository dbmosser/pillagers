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

SubRx @'
      if(GRAB) return;                       // a drag ending on this cell is not a click
'@ @'
      if(GRAB) return;                       // a drag ending on this cell is not a click
      // v15.68, grid audit finding: DRAGGING A BACKPACK STACK AND LETTING GO ON ITS OWN CELL MOVES NOTHING. The line above
      // never fired: the document mouseup runs grabEnd, which sets GRAB to null, and the browser sends the click only after
      // that mouseup is done. So a stack pressed, dragged toward the stash and let go on its own cell ran act(1) here: on the
      // Stash screen one Medkit left the backpack with no word (the backpack drop takes only from the stash and does nothing),
      // and at the ascent check a kit cell put one back and a stash cell packed one. The mouseup now names the cell of a drag
      // that moved (GRABSKIP), and the click on that cell is dropped. A controller A press is a click with detail 0 and is
      // never a drag, so it still acts; any new press clears GRABSKIP, so the next real click on the cell acts as before.
      var _gs=(GRABSKIP===cell); GRABSKIP=null;
      if(_gs&&ev.detail!==0) return;
'@
SubRx @'
// can tell "took it out of the stash" from "put it back".
var GRAB=null;
'@ @'
// can tell "took it out of the stash" from "put it back".
var GRAB=null;
// v15.68, grid audit finding: DRAGGING A BACKPACK STACK AND LETTING GO ON ITS OWN CELL MOVES NOTHING. GRABSKIP is the cell a
// drag that really moved started on. The click the browser sends after a mouseup lands on that cell only when the drag was
// let go on it, and that click is the end of the drag, not a click. invCell reads it and clears it; a new press clears it.
var GRABSKIP=null;
'@
SubRx @'
    GRAB={key:key,from:from};
'@ @'
    // v15.68, grid audit finding: DRAGGING A BACKPACK STACK AND LETTING GO ON ITS OWN CELL MOVES NOTHING. The cell and the
    // press point are kept so the mousemove below can tell a drag from a click, and a new press forgets the last drag.
    GRAB={key:key,from:from,el:el,x:ev.clientX,y:ev.clientY}; GRABSKIP=null;
'@
SubRx @'
document.addEventListener('mousemove',function(ev){
  if(!GRAB) return;
'@ @'
document.addEventListener('mousemove',function(ev){
  if(!GRAB) return;
  // v15.68, grid audit finding: DRAGGING A BACKPACK STACK AND LETTING GO ON ITS OWN CELL MOVES NOTHING. Every press arms a
  // drag, so movement is the only difference between a click and a drag: more than 6 pixels from the press is a drag.
  if(Math.abs(ev.clientX-GRAB.x)+Math.abs(ev.clientY-GRAB.y)>6) GRAB.moved=1;
'@
SubRx @'
document.addEventListener('mouseup',function(ev){
  if(!GRAB) return;
  var held=GRAB;
'@ @'
document.addEventListener('mouseup',function(ev){
  if(!GRAB) return;
  var held=GRAB;
  // v15.68, grid audit finding: DRAGGING A BACKPACK STACK AND LETTING GO ON ITS OWN CELL MOVES NOTHING. grabEnd below clears
  // GRAB while this mouseup is still running, so the invCell guard if(GRAB) return; could never see the drag when its click
  // arrived. The cell of a drag that moved is remembered here, for that one click; a plain click leaves nothing behind.
  GRABSKIP=held.moved?(held.el||null):null;
'@
SubRx @'
var VER='15.67';
'@ @'
var VER='15.68';
'@

$pat = "(?m)^  now:'v15\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.68: DRAGGING A BACKPACK STACK AND LETTING GO ON ITS OWN CELL MOVES NOTHING. A stack in the backpack pressed, dragged toward the stash and let go back on its own cell unpacked one item with no word, because the drag ended before its click arrived and the click still counted; at the ascent check the same move put one back or packed one. A drag that moved now ends with no click on its cell, and a plain click still moves one. Check 15.68 drags a packed Medkit stack out and back on the Stash screen; it fails on v15.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
