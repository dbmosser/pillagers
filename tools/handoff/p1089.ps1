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

# ============ HIS NOTE: X TO CHANGE WEAPONS IS NOT NEEDED ANY MORE.
# ============
# ============ "X to change weapons i don't think is necessary any more given the
# ============ hotbar, we can remove concept of x to change weapons", 2026-09-04.
# ============
# ============ REPRODUCED: in a raid holding an SMG with a carbine stowed, one X
# ============ press swaps them, smg to carbine and carbine to smg.
# ============
# ============ WHAT GOES: the key, its entry in the list of keys the page swallows
# ============ so the browser does not act on them, the bracketed [X] in front of
# ============ the stowed gun on the HUD, and the two legend lines that taught it.
# ============
# ============ WHAT STAYS, and this is the part worth being careful about. The
# ============ swap FUNCTION has four other callers and every one of them is a
# ============ way he still wants: dragging a gun onto the one in your hands,
# ============ bringing a stowed gun up from the hotbar, and two in the bot, which
# ============ pulls its sidearm when the primary runs dry and upgrades to a
# ============ better gun it finds. Deleting the function would silently take all
# ============ four. Only the KEY goes.
# ============
# ============ THE STOWED GUN IS STILL SHOWN. It was never a secret and the note
# ============ is about the key, not the readout, so the line keeps the name and
# ============ the ammo and loses only the bracket promising a key that is gone.
# ============
# ============ AND THE SPRINT LEGEND WAS ALREADY WRONG. v10.87 made sprint a hold
# ============ and the legend still read "sprint on/off", which is the previous
# ============ build's own leftover and is corrected here rather than left to be
# ============ read by his friends.
# ============
# ============ NOT TOUCHED: the controller. Its X is a FACE BUTTON that means
# ============ search, mapped through a different table, and the pad legends that
# ============ say X are about that button. Removing them would take search off
# ============ the controller.
SubRx @'
  if(code==='KeyX'&&G&&!G.over&&!G.paused&&!repeat) swapGuns();
'@ @'
'@
SubRx @'
  if(['Tab','Space','KeyE','KeyR','KeyF','KeyG','KeyQ','KeyI','KeyM','KeyP','KeyH','KeyX','KeyV','KeyC','Backspace','ControlLeft','ShiftLeft'].indexOf(code
'@ @'
  if(['Tab','Space','KeyE','KeyR','KeyF','KeyG','KeyQ','KeyI','KeyM','KeyP','KeyH','KeyV','KeyC','Backspace','ControlLeft','ShiftLeft'].indexOf(code
'@
SubRx @'
  // the sidearm waiting on X, so the second gun is not a secret
  if(p.sec){
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#7d8894';
    ctx.fillText('['+keyLabel('KeyX','X')+'] '+p.sec.name+'  '+p.secAmmo,W-16,by-LH(52));
  }
'@ @'
  // v10.89, HIS NOTE: the stowed gun is still shown, because it was never meant
  // to be a secret, but the bracket in front of it promised a key that no longer
  // exists. The hotbar is how a gun comes up now.
  if(p.sec){
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#7d8894';
    ctx.fillText('STOWED  '+p.sec.name+'  '+p.secAmmo,W-16,by-LH(52));
  }
'@
SubRx @'
  ['FIGHT',[['MOUSE','aim'],['LMB','fire'],['RMB','aim down sights'],['R','reload'],['X','swap weapon'],['F','melee strike, whatever you are holding']]],
'@ @'
  ['FIGHT',[['MOUSE','aim'],['LMB','fire'],['RMB','aim down sights'],['R','reload'],['F','melee strike, whatever you are holding']]],
'@
SubRx @'
  ['R','reload'],['X','swap gun'],
'@ @'
  ['R','reload'],
'@
SubRx @'
  ['MOVE',[['WASD','move'],['SHIFT','sprint on/off'],['CTRL / C','crouch on/off, near silent'],['SPACE','dodge roll']]],
'@ @'
  ['MOVE',[['WASD','move'],['SHIFT','hold to sprint'],['CTRL / C','crouch on/off, near silent'],['SPACE','dodge roll']]],
'@

SubRx @'
var VER='10.88';
'@ @'
var VER='10.89';
'@
SubRx @'
var WHATSNEW_VER='10.88';
'@ @'
var WHATSNEW_VER='10.89';
'@
SubRx @'
  now:'v10.88: FIRST TIME OUT is gone, your note. The window, its eighteen cards, the under-the-fold cue, the never-show tick box, the close handler and the css are all deleted, thirty-two references down to none. The welcome pack and the share question still run, in that order.',
'@ @'
  now:'v10.89: X no longer swaps weapons, your note. The key, its legend lines and the bracket in front of the stowed gun are gone; the hotbar is how a gun comes up. The swap itself is kept, because dragging a gun onto the one in your hands and the bot pulling its sidearm both use it.',
'@
SubRx @'
var WHATSNEW=[
'@ @'
var WHATSNEW=[
  'X NO LONGER SWAPS WEAPONS. The hotbar does that job, so the key is gone along with its legend lines. Your stowed gun and its ammo are still shown, just without a key in front of them. On a controller, X is still search.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
if (([regex]::Matches($script:s, "KeyX")).Count -ne 0) { throw "KeyX still appears in the file" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
