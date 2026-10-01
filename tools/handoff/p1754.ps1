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

# THE WHAT IS NEW CARD NAMES THE SMOOTHER PARTY PLAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='17.48';
'@ @'
var WHATSNEW_VER='17.54';
'@

SubRx @'
  'TRADING, DROP-IN AND A BOSS. With the backpack open, T or Y offers the selected item to your teammate, who takes it with T or Y. A teammate in the Undercroft can JOIN THE RAID IN PROGRESS. THE OVERSEER guards the middle of every map. The stash has search and sort, Settings has Render resolution, Frame cap and Effects, and hits and deaths are animated.',
'@ @'
  'PLAYING TOGETHER, SMOOTHER. JOIN THE RAID IN PROGRESS now shows in the Undercroft while your host is up top, and going up at the lift as a teammate joins the raid too, even after your window was closed and opened again. An open trade offer stays on screen with the seconds left to take it. THE OVERSEER is drawn to its size.',
  'TRADING, DROP-IN AND A BOSS. With the backpack open, T or Y offers the selected item to your teammate, who takes it with T or Y. A teammate in the Undercroft can JOIN THE RAID IN PROGRESS. THE OVERSEER guards the middle of every map. The stash has search and sort, Settings has Render resolution, Frame cap and Effects, and hits and deaths are animated.',
'@

SubRx @'
var VER='17.53';
'@ @'
var VER='17.54';
'@

$pat = "(?m)^  now:'v17\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.54: The what is new card names the smoother party play: drop-in from the Undercroft or the lift, the trade offer line, and the boss drawn to its size. Check 17.54 fails on v17.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
