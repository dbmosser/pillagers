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

# ONE GRID, ONE RIGHT EDGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1h (his #50, from the AAA judge of the shop and Mainframe shots): ONE GRID, ONE RIGHT EDGE. The counter
     (the item grid and the detail card) was capped at 1720px and centred down the window, so in the shop a dead band of about 170px
     sat between the tabs and the first tile, and in the shop and the Mainframe the detail card stopped about 140px short of the
     right edge that the header, the tabs and the footer share. The counter now starts right under the tabs and runs the full
     width, so the detail card ends on that same right edge. Nothing else moved. */
  #root #tradermodal .tpane, #root #opmodal .tpane{ justify-content:flex-start; }
  #root #tradermodal .vend, #root #opmodal .vend{ max-width:none; width:100%; }
'@

SubRx @'
var VER='24.53';
'@ @'
var VER='24.54';
'@

$pat = "(?m)^  now:'v24\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.54: In the shop and the Mainframe the grid starts under the tabs and the detail card lines up with the right edge. Check 24.54 fails on v24.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
