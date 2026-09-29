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

# A CONTROLLER CAN PUT A GUN IN GUN 1 OR GUN 2, OR TAKE IT OUT OF HIS HANDS, ON THE STASH SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padOpenModal(){
  var ms=document.querySelectorAll('.modal.on');
'@ @'
function padOpenModal(){
  // v17.16, co-op hunt 2026-09-28: THE ITEM AND GUN MENU IS A PANEL TOO. It is drawn over whatever opened it, so it is checked
  // first, and only off a raid, so a stray right-click menu never takes the pad out of a fight.
  if(typeof IMENU!=='undefined'&&IMENU&&IMENU.parentNode&&state!=='raid') return IMENU;
  var ms=document.querySelectorAll('.modal.on');
'@

SubRx @'
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select,[data-plan]');
'@ @'
  // v17.16, co-op hunt 2026-09-28: the live rows of the item and gun menu are controls; a greyed out row is not.
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select,[data-plan],.imenurow:not(.dim)');
'@

SubRx @'
  var _pix=list.indexOf(PAD.focus); if(_pix>=0) PAD.focusIx=_pix; PAD.focusMd=md;
'@ @'
  // v17.16, co-op hunt 2026-09-28: the menu does not take over the place kept for the panel under it, so when it shuts, or a
  // row rebuilds the Stash screen, the highlight goes back to the cell that opened it and not to the first control.
  if(md!==IMENU){ var _pix=list.indexOf(PAD.focus); if(_pix>=0) PAD.focusIx=_pix; PAD.focusMd=md; }
'@

SubRx @'
    if(GRAB&&GRAB.pad){ grabEnd(); return true; }   // v16.80: B lets a pad grab go, and closes nothing else on that press
'@ @'
    if(GRAB&&GRAB.pad){ grabEnd(); return true; }   // v16.80: B lets a pad grab go, and closes nothing else on that press
    if(md===IMENU){ closeItemMenu(); padSetFocus(null); PAD.focus=null; return true; }   // v17.16, co-op hunt 2026-09-28: B shuts the menu, which has no button to find
'@

SubRx @'
  if(el===held.el&&!held.moved){ try{ el.click(); }catch(_pc){} return true; }
'@ @'
  // v17.16, co-op hunt 2026-09-28: A CONTROLLER PUTS AN ARMOURY GUN IN A HAND. Put in gun 1, Put in gun 2 and Take it out of
  // your hands are rows of the gun menu, which only a right-click on the armoury cell opened, and a pad has no right-click:
  // A in place on an armoury gun was a click on a cell with no click, so a pad player could never choose gun 1, fill gun 2 or
  // empty a hand at home. A picked up and A again in place on an armoury gun now opens that same menu at the cell, the menu
  // is a pad panel (padOpenModal), A presses a row and B shuts it. A drag to anywhere else is unchanged.
  if(el===held.el&&!held.moved&&held.from==='rack'&&typeof openGunMenu==='function'){
    var _gr=el.getBoundingClientRect();
    try{ openGunMenu(_gr.left+_gr.width/2,_gr.top+_gr.height/2,String(held.key).slice(4)); }catch(_pg){}
    return true;
  }
  if(el===held.el&&!held.moved){ try{ el.click(); }catch(_pc){} return true; }
'@

SubRx @'
var VER='17.15';
'@ @'
var VER='17.16';
'@

$pat = "(?m)^  now:'v17\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.16: Every verb that changes P.equipped or P.equippedSec at home was behind a right-click: openGunMenu opened only from the contextmenu listener on the armoury cell, and padMenu reads only A, B and the D-pad or stick, so on a controller a second A in place on a picked up armoury gun ran el.click() on a cell with no click handler and nothing happened. stashPadAct now opens openGunMenu at the centre of the cell when a rack grab is let go in place, padOpenModal returns the open .imenu first (off a raid), padFocusables lists the live .imenurow rows so the D-pad walks them and A runs the row onclick the mouse runs, B on the menu calls closeItemMenu instead of hunting for a button it does not have, and while the menu is up padMenu does not write PAD.focusMd or PAD.focusIx, so when it shuts, or a row rebuilds the Stash screen, the highlight goes back to the same armoury cell rather than to the first control. A drag of an armoury gun to anywhere else, and A in place on every other cell, are unchanged. No player text, no number and no seeded draw moved. Check 17.16 fails on v17.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
