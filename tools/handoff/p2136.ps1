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

# THE RUN CARD BUTTON STRIP RUNS EDGE TO EDGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ocacts::before{ content:''; position:absolute; left:0; right:0; top:-14px; height:14px; pointer-events:none;   /* v19.50, from the review (2026-10-08): inside the 14px gap above the row, so on a card that does not scroll it no longer veils the note box */
    background:linear-gradient(180deg,rgba(0,0,0,0),var(--win-bot)); }
'@ @'
  .ocacts::before{ content:''; position:absolute; left:0; right:0; top:-14px; height:14px; pointer-events:none;   /* v19.50, from the review (2026-10-08): inside the 14px gap above the row, so on a card that does not scroll it no longer veils the note box */
    background:linear-gradient(180deg,rgba(0,0,0,0),var(--win-bot)); }
  /* v21.36, from the whole-game bug hunt of 2026-10-08 (W-E1), seen on the 4K run card screenshots: THE BUTTON STRIP RUNS THE
     FULL WIDTH OF THE CARD. The solid strip under the two buttons stopped at the card's 52 px side margins, and its flat colour is
     a shade off the card's own light from the top, so on every death and extract card it showed as a faint box inset behind LOG
     RUN AND RETURN and COPY REPORT. It now reaches both edges of the card, so the box has no sides to see. The buttons, the fade
     above them and the pinning on a card that scrolls are unchanged, and the card never scrolls sideways for it. */
  .ocacts{ width:calc(100% + 104px); margin-left:-52px; margin-right:-52px; }
  .ocwin{ overflow-x:hidden; }
'@

SubRx @'
var VER='21.35';
'@ @'
var VER='21.36';
'@

$pat = "(?m)^  now:'v21\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.36: The faint box behind the two buttons on the death and extract card is gone. Check 21.36 fails on v21.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
