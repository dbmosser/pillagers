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

# THE PLAYER 2 SAVE STAYS SHUT WHILE ITS WINDOW IS OPEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function slotBlocked(sn){
  var p2=null;
  if(typeof NETP2!=='undefined'&&NETP2) return sn===p1SlotNow();
  if(typeof NET==='object'&&NET&&NET.same==='host'){ try{ p2=localStorage.getItem(p2PtrKey()); }catch(e){ p2=null; } return !!p2&&sn===p2; }
  return false;
}
'@ @'
// v18.55, FROM THE CODE COMB (2026-10-07): THE PLAYER 2 SAVE STAYS SHUT WHILE ITS WINDOW IS OPEN, EVEN AFTER PLAYER 1 RELOADS. The
// host window knew the player 2 save was in use only while it sat in a same machine mode (NET.same), and a reload of the host
// window drops the mode: player 1 could then load or erase the save the player 2 window still had open and was still saving to.
// The player 2 window now leaves a mark (salvagerun:p2live, the time, every 2 seconds, taken off when it closes), and a mark
// under 75 seconds old (a covered window's timers can run once a minute) keeps that save shut in the other window too.
function p2LiveKey(){ return 'salvagerun:p2live'; }
function p2LiveBeat(){ try{ localStorage.setItem(p2LiveKey(),String(Date.now())); return true; }catch(_b){ return false; } }
function p2LiveNow(){ var t=0; try{ t=+localStorage.getItem(p2LiveKey())||0; }catch(_g){ t=0; } return !!(t&&Math.abs(Date.now()-t)<75000); }
if(typeof NETP2!=='undefined'&&NETP2){
  p2LiveBeat(); try{ setInterval(p2LiveBeat,2000); }catch(_si){}
  try{ window.addEventListener('pagehide',function(){ try{ localStorage.removeItem(p2LiveKey()); }catch(_r){} }); }catch(_ph){}
}
function slotBlocked(sn){
  var p2=null;
  if(typeof NETP2!=='undefined'&&NETP2) return sn===p1SlotNow();
  if((typeof NET==='object'&&NET&&NET.same==='host')||p2LiveNow()){ try{ p2=localStorage.getItem(p2PtrKey()); }catch(e){ p2=null; } return !!p2&&sn===p2; }
  return false;
}
'@

SubRx @'
var VER='18.54';
'@ @'
var VER='18.55';
'@

$pat = "(?m)^  now:'v18\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.55: After a reload of player 1 window, player 2 save still shows IN USE BY PLAYER 2 while their window is open. Check 18.55 fails on v18.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
