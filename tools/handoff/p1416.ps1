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
document.addEventListener('keydown',function(ev){
  if(!INVHOVER) return;
  if(ev.ctrlKey||ev.altKey||ev.metaKey) return;
'@ @'
document.addEventListener('keydown',function(ev){
  if(!INVHOVER) return;
  // v14.16, Undercroft audit finding 2: THE HOVER KEY STAYS ON THE SCREEN IT WAS SET ON. INVHOVER is cleared only by the
  // cell's mouseleave, and a key press rebuilds the grid under the cursor, so the old cell never fires it. Closed with ESC
  // or TAB without moving the mouse, every 1-9 anywhere (in a raid too, where the digits also switch belt slots) packed and
  // bound that item, and J anywhere tagged it as junk for Sell all salvage. Only the stash screen and the ascent check own it.
  var _ihHub=document.getElementById('hub'), _ihStg=document.getElementById('stagemodal');
  if(!((_ihHub&&_ihHub.classList.contains('on'))||(_ihStg&&_ihStg.classList.contains('on')))){ INVHOVER=null; return; }
  if(ev.ctrlKey||ev.altKey||ev.metaKey) return;
'@
SubRx @'
var VER='14.15';
'@ @'
var VER='14.16';
'@

$pat = "(?m)^  now:'v14\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.16: THE STASH HOVER KEY STAYS ON THE STASH SCREEN. The item under the cursor was forgotten only on mouseleave, and a key press rebuilds the grid under the cursor, so closing the stash with ESC or TAB left it set: every 1-9 anywhere, in a raid too, packed and bound it, and J anywhere tagged it as junk. The key listener now answers only while the stash screen or the ascent check is open, and forgets the item otherwise. Check 14.16 presses J and 7 with both closed, then J on the stash screen; it fails on v14.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
