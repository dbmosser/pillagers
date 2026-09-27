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

# A PICKS UP, A PLACES: THE TACTICAL BELT ON A CONTROLLER IN THE STASH (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select');
'@ @'
  // v16.80, his report: A TACTICAL BELT KEY IS A CONTROL. The belt keys on the Stash screen and the ascent check are plain
  // [data-plan] divs, named nowhere in this list, so the highlight could never land on one and nothing packed could reach the
  // belt on a controller. They pass the same filters as a cell, and the greyed out freebie kit panel keeps them out (v15.71).
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select,[data-plan]');
'@

SubRx @'
  if(!md){ if(PAD.focus){ padSetFocus(null); PAD.focus=null; } return false; }
'@ @'
  // v16.80, his report: A PAD GRAB DOES NOT OUTLIVE ITS PANEL. Only B and a placing A ended one, so ESC on the Stash screen,
  // or a window opened over it, with an item picked up left the ghost on the screen and the next mouse release anywhere
  // dropped a stale item, the v8.14 hole again. No panel, or a different panel on top, lets a pad grab go before anything else.
  if(GRAB&&GRAB.pad&&(!md||(PAD.focusMd&&md!==PAD.focusMd))) grabEnd();
  if(!md){ if(PAD.focus){ padSetFocus(null); PAD.focus=null; } return false; }
'@

SubRx @'
  if(mv){ var nx=padStep(list,PAD.focus,mv[0],mv[1]); if(nx) padSetFocus(nx); }
'@ @'
  if(mv){ var nx=padStep(list,PAD.focus,mv[0],mv[1]); if(nx){ padSetFocus(nx); if(GRAB&&GRAB.pad){ GRAB.moved=1; stashPadGhost(); } } }   // v16.80: a held pad grab moves with the highlight
'@

SubRx @'
  if(tap(0)&&PAD.focus){ PAD.aSpent=1; PAD.focus.click(); }
'@ @'
  // v16.80, his report: A PICKS UP AND A PLACES. On the Stash screen and the ascent check A on a cell that can be dragged is
  // the mouse press that starts a drag (stashPadAct), the highlight is then the cursor, and A on the target is the release:
  // every backpack cell, stash cell and belt key, every rule and every word are the mouse drop. A control that cannot be
  // dragged, and A with nothing held on a button, is the click it always was.
  if(tap(0)&&PAD.focus){ PAD.aSpent=1; if(!stashPadAct(PAD.focus)) PAD.focus.click(); }
'@

SubRx @'
    var back=null,bs=md.querySelectorAll('button');
'@ @'
    if(GRAB&&GRAB.pad){ grabEnd(); return true; }   // v16.80: B lets a pad grab go, and closes nothing else on that press
    var back=null,bs=md.querySelectorAll('button');
'@

SubRx @'
function grabEnd(){
'@ @'
function grabEnd(){
  if(GRAB&&GRAB.pad&&GRAB.el) GRAB.el.style.boxShadow='';   // v16.80: the ring a pad grab put on its cell comes off with the grab
'@

SubRx @'
// Make an element draggable by pointer. key is the item, from is a label the drop
'@ @'
// v16.80, his report: A CONTROLLER PACKS, UNPACKS AND BUILDS THE TACTICAL BELT ON THE STASH SCREEN. Two helpers, written
// against what the mouse already does. stashPadAct is pad A on the highlighted control: with nothing held it is the mouse
// press that starts a drag from that cell (the very listener grabbable set), and the cell keeps a ring; with something held
// it is the release on the control under the highlight, through the drop function the mouse release runs (dropzone), so a
// belt key, the backpack, the stash, the swap, the unbind and every word said are the mouse rules, not a copy. Let go on its
// own cell without a step between is the click a press and release in place sends, so A twice on a cell still does what
// one A did before. Only what grabbable marked is ever pressed this way: a button, a dial or a hold-to-craft button never
// sees a synthetic press, and A on them stays the click it was. A drag the mouse itself holds is left to the mouse. 
// stashPadGhost puts the ghost on the highlight and lights the target under it, as the mouse move does.
function stashPadAct(el){
  if(!el) return false;
  if(!GRAB){
    if(el.style.cursor!=='grab') return false;
    var r=el.getBoundingClientRect();
    try{ el.dispatchEvent(new MouseEvent('mousedown',{button:0,cancelable:true,clientX:r.left+r.width/2,clientY:r.top+r.height/2})); }catch(_pe){}
    if(!GRAB) return false;
    GRAB.pad=1; el.style.boxShadow='inset 0 0 0 2px var(--amber)';
    stashPadGhost();
    return true;
  }
  if(!GRAB.pad) return false;   // a drag the mouse holds belongs to the mouse: A stays the click it was, the mouse release ends that drag
  var held=GRAB, z=el.closest?el.closest('[data-drop]'):null;
  grabEnd();
  if(el===held.el&&!held.moved){ try{ el.click(); }catch(_pc){} return true; }
  if(z&&typeof z.__grabDrop==='function') z.__grabDrop(held.key,held.from);
  return true;
}
function stashPadGhost(){
  var el=PAD.focus, g=document.getElementById('grabghost');
  if(!GRAB||!GRAB.pad||!el||!g) return;
  var r=el.getBoundingClientRect(), gz=parseFloat(g.style.zoom)||1;
  g.style.left=((r.left+r.width*0.6)/gz)+'px'; g.style.top=((r.top+r.height*0.6)/gz)+'px';
  document.querySelectorAll('[data-drop]').forEach(function(z){ z.style.outline=''; });
  var z=el.closest?el.closest('[data-drop]'):null;
  if(z) z.style.outline='1px solid var(--amber)';
}
// Make an element draggable by pointer. key is the item, from is a label the drop
'@

SubRx @'
          say2('Hover an item in the stash and press a number key to put it on your tactical belt.');
'@ @'
          say2((PAD&&PAD.on)?'Pick an item up with A first, then A on this key puts it there.':'Hover an item in the stash and press a number key to put it on your tactical belt.');   // v16.80: a pad player is told the pad way
'@

SubRx @'
var VER='16.84';
'@ @'
var VER='16.85';
'@

$pat = "(?m)^  now:'v16\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.85: A PICKS UP, A PLACES ON THE STASH SCREEN. His report during his co-op session: on the Stash screen a controller could only move things between the backpack and the stash, and the tactical belt was out of reach. Now A picks up the item under the highlight, the D-pad walks the highlight to a backpack cell, a stash cell or a belt key, and A there places it, exactly as a mouse drag does; B lets it go. Check 16.85 fails on v16.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
