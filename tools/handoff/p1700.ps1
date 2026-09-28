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

# A CONTROLLER X PRESSED AFTER A PAD GAP, ANOTHER SCREEN OR DURING A ROLL SEARCHES THE BOX IN REACH INSTEAD OF RELOADING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padRelease(){
'@ @'
function padRelease(){
  // v17.00, co-op hunt 2026-09-28: AND THE X PRESS LATCH. PAD.xWas was written only in the raid branch, so a menu, another
  // screen or the stall between two X presses left it set, the next X was not seen as a new press, and the choice of the X
  // before (reload) was held again beside a box, which was then never searched until X was let go and pressed once more.
  PAD.xWas=false;
'@

SubRx @'
  if(!gp){ if(PAD.on) padRelease(); PAD.on=false; PAD.prev=[]; PAD.mx=0; PAD.my=0; return; }   // v8.39
'@ @'
  if(!gp){ if(PAD.on) padRelease(); PAD.on=false; PAD.prev=[]; PAD.xWas=false; PAD.xDownAt=null; PAD.xSearched=false; PAD.mx=0; PAD.my=0; return; }   // v8.39; v17.00, co-op hunt 2026-09-28: a pad gap forgets the X press too, but not xAfterTrade, which still spends an X held from the stall
'@

SubRx @'
    for(var b0=0;b0<bt.length;b0++) PAD.prev[b0]=pressed(b0);
    return;
'@ @'
    for(var b0=0;b0<bt.length;b0++) PAD.prev[b0]=pressed(b0);
    PAD.xWas=false;   // v17.00, co-op hunt 2026-09-28: an X pressed down here is a new press in the next raid
    return;
'@

SubRx @'
      if(_xDown&&!PAD.xWas){ var _xm=false; try{ _xm=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xe){} PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||_xm)?'KeyE':'KeyR'; }
'@ @'
      // v17.00, co-op hunt 2026-09-28: X PRESSED IN A ROLL CHOOSES WHEN THE ROLL ENDS. What is in reach is looked up near the end
      // of updatePlayer, which returns early for the whole roll, and pollPad runs before it, so a press in a roll chose from where
      // the roll began: X pressed while rolling onto a box held R for the whole hold and never searched. A roll reads neither E
      // nor R, so the choice now waits, holding nothing, until the reach has been looked up again after the press (G.nearN), and
      // the search grace starts then. Out of a roll, or downed, it is chosen on the press as before.
      if(_xDown&&!PAD.xWas){ PAD.xMode=null; PAD.xNearN=(G.player&&G.player.roll>0&&!G.player.downed)?(G.nearN||0):null; }
      if(_xDown&&PAD.xMode==null&&(PAD.xNearN==null||PAD.xNearN!==(G.nearN||0)||(G.player&&G.player.downed))){ var _xm=false; try{ _xm=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xe){} PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||_xm)?'KeyE':'KeyR'; if(PAD.xNearN!=null){ PAD.xDownAt=G.t; PAD.xNearN=null; _xSearch=!!(G.nearPad&&G.nearContainer); } }
'@

SubRx @'
  G.nearContainer=near;
'@ @'
  G.nearContainer=near; G.nearN=(G.nearN||0)+1;   // v17.00, co-op hunt 2026-09-28: one per look, so a pad X pressed in a roll can wait for the first look after it (pollPad)
'@

SubRx @'
var VER='16.99';
'@ @'
var VER='17.00';
'@

$pat = "(?m)^  now:'v16\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.00: Controller X search after a gap or a roll (co-op hunt 2026-09-28). X on a pad chooses on the press between E (search, open, call) and R (reload) and keeps that choice for the hold. The press latch PAD.xWas was written only in the raid branch of pollPad, so the no-pad branch (a pad that dropped out, or player 2 with no forwarded state), the menu path, other screens, the stall and the Undercroft all left it set: an X let go and pressed again during the gap was not a new press, and the reload choice was held again beside a box, so G.searching stayed empty until X was pressed once more. padRelease now clears PAD.xWas, the no-pad branch clears PAD.xWas, PAD.xDownAt and PAD.xSearched (not PAD.xAfterTrade, which must still spend an X held from the stall), and the Undercroft return clears PAD.xWas. Second, pollPad runs before updatePlayer and updatePlayer looks up what is in reach only after its early return for a roll, so X pressed during a roll chose from where the roll began and held R onto the box. A roll reads neither E nor R, so a press during a roll now holds nothing until updatePlayer has looked up the reach again after the press (a new counter G.nearN, one per look), then chooses and starts the 0.35 s search grace from then. Out of a roll, or downed, the choice is made on the press as before. No number moved and no player text changed. Check 17.00 fails on v16.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
