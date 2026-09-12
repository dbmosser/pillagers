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

# FINDING 2 OF THE 2026-09-11 AUDIT, AND IT IS BIGGER THAN THE AUDIT SAID.
#
# WHAT THE AUDIT FOUND. Restoring a backup from a file never re-applies the stash
# layout, so the Settings row prints the restored number over a grid still drawn
# in the old one, and they disagree until he happens to reload.
#
# WHAT IS ACTUALLY WRONG. That is one of at least five. Boot has a block that runs
# after the profile exists, and it does five things: the saved zoom, the stash
# layout, the game options, the menu zoom, and the contracts. The restore path
# runs NONE of them. It calls renderHub and renderSettings and stops. Boot already
# learned this once, at v8.15, for the stash layout alone; restoring is the second
# place a whole profile arrives and it never got the same treatment.
#
# SO THE FIX IS NOT A FIFTH CALL, IT IS THE RELOAD its two siblings already do.
# The restore-code path has reloaded since v11.04. The UNDO button added at v12.85
# reloads. The file path was the odd one out, and adding applyStashLayout to it
# would have closed the one symptom the audit looked for and left the other four.
#
# AND IT IS ONE PLACE NOW, not three. Every path that replaces the whole profile
# ends in finishRestore: re-draw, say so, and arm the SAME cancellable reload the
# v11.04 path uses, so anything driving a restore can see it coming and stop it.
SubRx @'
function renderSettings(){
'@ @'
// v12.86: THE ONE PLACE A RESTORE FINISHES. Three paths replace the whole profile
// now, a backup file, a friend's restore code, and the UNDO button, and each was
// ending its own way. Everything on the floor was built from the profile that is
// gone, so the page comes back rather than being patched up piece by piece.
// RESTORE_RELOAD and RESTORE_TIMER are the v11.04 handles: 0 none, 1 armed, 2
// fired, and the timer can be cancelled by anything that does not want the page
// to go.
function finishRestore(line){
  try{ renderHub(); }catch(_fr1){}
  try{ renderSettings(); }catch(_fr2){}
  say(line+' The game is reloading.');
  RESTORE_RELOAD=1;
  try{ RESTORE_TIMER=setTimeout(function(){ RESTORE_RELOAD=2; try{ location.reload(); }catch(_fr3){} },400); }
  catch(_fr4){ RESTORE_RELOAD=2; try{ location.reload(); }catch(_fr5){} }
}
function renderSettings(){
'@

SubRx @'
    storeSet(JSON.stringify(d3));
    say('Put back: '+(d3.runs||0)+' runs, '+'$'+(d3.credits||0).toLocaleString()+'. Reloading.');
    setTimeout(function(){ try{ location.reload(); }catch(_e3){} },700);
'@ @'
    storeSet(JSON.stringify(d3));
    finishRestore('Put back: '+(d3.runs||0)+' runs, '+'$'+(d3.credits||0).toLocaleString()+'.');
'@

SubRx @'
        loadProfile().then(function(){
          try{ renderHub(); }catch(e4){}
          try{ renderSettings(); }catch(e5){}
          say('Restored. '+(P.runs||0)+' runs, '+'$'+(P.credits||0).toLocaleString()+'.');
        });
'@ @'
        // v12.86: the read-back stays, so the profile in memory is the profile in
        // storage even on a host where the reload never happens.
        loadProfile().then(function(){
          finishRestore('Restored. '+(P.runs||0)+' runs, '+'$'+(P.credits||0).toLocaleString()+'.');
        });
'@

# NEW IN.
SubRx @'
  'RESTORING A BACKUP CAN BE UNDONE, WHICH THE SETTINGS ROW HAS BEEN PROMISING FOR A WHILE. Your outgoing profile was already being kept, and nothing in the game could read it back. There is an UNDO button on that row now, and it only appears when there is something behind it.',
'@ @'
  'RESTORING A BACKUP CAN BE UNDONE, WHICH THE SETTINGS ROW HAS BEEN PROMISING FOR A WHILE. Your outgoing profile was already being kept, and nothing in the game could read it back. There is an UNDO button on that row now, and it only appears when there is something behind it.',
  'RESTORING FROM A FILE REBUILDS THE SCREEN INSTEAD OF HALF OF IT. The stash grid, the saved zoom, the game options and the contracts were all still the ones belonging to the profile you had just replaced, so the Settings rows and the screen disagreed until you happened to reload. Every way of replacing your whole profile now ends the same way.',
'@

# STAMPS.
SubRx @'
var VER='12.85';
'@ @'
var VER='12.86';
'@
SubRx @'
var WHATSNEW_VER='12.85';
'@ @'
var WHATSNEW_VER='12.86';
'@
$cnt=([regex]::Matches($s,"now:'v12\.85:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.85 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.85:[^']*'",{ param($m) "now:'v12.86: finding 2 of the 2026-09-11 audit, and it is bigger than the audit said. The audit found that restoring a backup from a file never re-applies the stash layout, so the Settings row prints the restored number over a grid still drawn in the old one and they disagree until he happens to reload. That is one of at least five. Boot has a block that runs after the profile exists and it does five things: the saved zoom, the stash layout, the game options, the menu zoom and the contracts. The restore path runs none of them; it calls renderHub and renderSettings and stops. Boot already learned this once, at v8.15, for the stash layout alone, and restoring is the second place a whole profile arrives and never got the same treatment. So the fix is not a fifth call, it is the reload its two siblings already do: the restore-code path has reloaded since v11.04 and the UNDO button added at v12.85 reloads, and the file path was the odd one out, so adding applyStashLayout to it would have closed the one symptom the audit looked for and left the other four. It is one place now rather than three: every path that replaces the whole profile ends in finishRestore, which re-draws, says so, and arms the same cancellable reload the v11.04 path uses, so anything driving a restore can see it coming and stop it. Check 12.86 requires one shared finish for a restore, calls it and requires the reload armed rather than fired with a real handle to cancel, and presses UNDO and requires the same arming, which is the arm that fails on v12.85 where UNDO reloads on a timer nothing can see or cancel.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
