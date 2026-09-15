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
// v9.11: the one thing on the counter. Named, priced and visible before he pays,
'@ @'
// v15.03, wirt audit finding: THE LIMITED TIME OFFER CARD KEEPS TIME WHILE THE PANEL IS OPEN. renderWirtLot reads the clock once,
// when it draws, and only renderGamble calls it (E at the counter, a roll, a buy). So a card left open froze its minutes, kept a
// lot whose window had turned, and a bought card never showed the next item or its Buy button until the panel was opened again.
// wirtLotTick is what renderWirtLot arms for the moment its minute changes: it redraws the card only while the panel is up, and
// with the panel closed it cancels its timer and stops.
var WIRTLOT_TM=null;
function wirtLotTick(){
  var gm=document.getElementById('gamblemodal');
  if(gm&&gm.classList.contains('on')){ renderWirtLot(); return; }
  if(WIRTLOT_TM) clearTimeout(WIRTLOT_TM);
  WIRTLOT_TM=null;
}
// v9.11: the one thing on the counter. Named, priced and visible before he pays,
'@
SubRx @'
  var left=wirtLotLeft(), mins=Math.ceil(left/60);
'@ @'
  var left=wirtLotLeft(), mins=Math.ceil(left/60);
  // v15.03, wirt audit finding: THE LIMITED TIME OFFER CARD KEEPS TIME WHILE THE PANEL IS OPEN. The minutes, the lot and the bought
  // mark were read once, here, and nothing redrew them. Arm wirtLotTick for 50 ms past the moment the minute drops; at one minute
  // that is 50 ms past the window turn, so the next lot draws. Armed after the empty-counter return and before the bought branch,
  // so both cards keep time. renderGamble is not called, so the vendor line does not rotate; a rebuilt Buy button keeps its pad place.
  if(WIRTLOT_TM) clearTimeout(WIRTLOT_TM);
  WIRTLOT_TM=setTimeout(wirtLotTick,Math.max(50,(WIRT_LOT_MS-(Date.now()%WIRT_LOT_MS))-(mins-1)*60000+50));
'@
SubRx @'
var VER='15.02';
'@ @'
var VER='15.03';
'@

$pat = "(?m)^  now:'v15\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.03: THE LIMITED TIME OFFER CARD KEEPS TIME WHILE THE PANEL IS OPEN. The offer card read the clock once when it was drawn, so left open its minutes froze, and a bought card never showed the next item until the panel was closed and opened again. It now redraws itself when its minute turns, only while the panel is up. Check 15.03 opens the panel on a stubbed clock, runs the redraw the card arms past its minute turn and reads the card; it fails on v15.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
