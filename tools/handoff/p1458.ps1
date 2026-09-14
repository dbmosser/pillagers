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
  if(G&&!G.over&&G.bagOpen&&G.bagCells&&!(G.player&&(G.player.downed||G.player.dying))){   // v14.57: not while down
'@ @'
  // v14.58, backpack audit finding 3: ONLY A LEFT CLICK PICKS UP A TILE. Any button started a drag here, but only a left
  // release ends one, so a wheel click (easy while zooming) or a thumb click stuck the item to the cursor, through closing
  // the backpack, until the next left click to shoot bound it to the belt cell under it or handed it to the hire.
  if(e.button===0&&G&&!G.over&&G.bagOpen&&G.bagCells&&!(G.player&&(G.player.downed||G.player.dying))){   // v14.57: not while down
'@
SubRx @'
    G.bagOpen=!G.bagOpen; G.bagSel=0;
    // v12.09: an arrow still held when the bag opens stops walking too.
'@ @'
    G.bagOpen=!G.bagOpen; G.bagSel=0; G.drag=null;   // v14.58: and B or I drops a held drag, as ESC, TAB and focus loss do
    // v12.09: an arrow still held when the bag opens stops walking too.
'@
SubRx @'
var VER='14.57';
'@ @'
var VER='14.58';
'@

$pat = "(?m)^  now:'v14\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.58: ONLY A LEFT CLICK PICKS UP A BACKPACK TILE. A wheel or thumb click started a drag that only a left release could end, so the item stuck to the cursor even after the backpack closed, and the next shot bound it to a belt key or handed it to the hire. Tiles now pick up on the left button only, and B or I drops any drag. Check 14.58 presses the middle and left buttons on a staged tile and toggles the backpack mid-drag; it fails on v14.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
