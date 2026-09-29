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

# PICKING A SAME MACHINE ROW AGAIN NO LONGER RELOADS THE LIVE PLAYER 2 WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(NET.same==='p2'||NET.role==='join'){ netModeMsg('This window is player 2 already.'); return 'p2'; }
'@ @'
  if(NET.same==='p2'||NET.role==='join'){ netModeMsg('This window is player 2 already.'); return 'p2'; }
  // v17.35, co-op hunt 2026-09-28: A LINKED PLAYER 2 WINDOW IS NEVER OPENED AGAIN. It keeps its name, so the open below navigated
  // the live player 2 page: his raid went as a page-away and a run card held only in memory was lost. With a peer linked the row
  // only brings his window forward and starts this side; another mode waits until that window is closed. A window that never
  // linked is still opened again, since that reload is how RETRY gets it back.
  if(NET.same==='host'&&netInCount()>0){
    if(mode!==NET.mode){ netModeMsg('Player 2 is already linked in '+netModeName(NET.mode)+'. Close the player 2 window to change mode.'); return 'linked'; }
    try{ if(NET.p2win&&!NET.p2win.closed) NET.p2win.focus(); }catch(_pf){}
    netModeMsg('');
    if(typeof go==='function') go();
    return 'linked';
  }
'@

SubRx @'
var VER='17.34';
'@ @'
var VER='17.35';
'@

$pat = "(?m)^  now:'v17\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.35: Same machine rows, co-op hunt 2026-09-28: netSamePick refused only in the player 2 window, so a host already paired went straight to window.open with the fixed name pillagers_p2, and the browser navigated the live player 2 page. The title is reachable while player 2 is still up top (the host spectates with G null, and RETURN TO CHARACTER SELECTION only tests G), and the player 2 window has no guard against being unloaded, so his raid went as a page-away and the host then ended the kept raid when his link dropped. netSamePick now, when this window is the host and a peer is linked (netInCount), never opens the window again: the same mode only brings the player 2 window forward and runs the title start, and another mode is refused with a sentence on the title (close the player 2 window to change mode), instead of quietly keeping the old mode. The guard reads a linked peer, not the window, so a player 2 window that is open but never linked is still opened again, since that reload is how RETRY brings it back. No number moved. Check 17.35 fails on v17.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
