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

# THE TEAM STRIP IS NOT BEHIND THE HOW TO PLAY CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcstrip{ font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--acc); }

'@ @'
body #attract .arcstrip{ font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--acc); }
/* v30.xx (cw-p1p2), HIS ORDER (2026-10-18): "there seem to be a lot of inconsistencies between p1 and p2 games, please coordinate them better". While a run is live the waiting window (player 2, or a benched player 1) showed JOIN YOUR TEAM at 28.5 percent from the bottom, and the how to play card now reaches down to 84 percent, so the strip was drawn behind the card rows and read through the card (the picture of the waiting player 2 window on the how to play page). With a page or the run over card up the strip sits on the bottom margin under the card, with no band, where nothing else is. Without a page (the clip) it stays where it was. */
body #attract[style*="block"]:has(.arcpage[style*="block"]) .arcstrip, body #attract[style*="block"]:has(.arcover[style*="block"]) .arcstrip{ bottom:calc(var(--sp-3) * var(--attz,1)); background:none; }
'@

SubRx @'
var VER='31.14';
'@ @'
var VER='31.15';
'@

$pat = "(?m)^  now:'v31\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.15: While a party run is live the waiting window shows Join your team on the bottom edge under the how to play card, not behind its rows. Check 31.15 fails on v31.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
