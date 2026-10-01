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

# THE WHAT IS NEW CARD NAMES KNOWING WHERE YOUR TEAMMATE IS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='17.54';
'@ @'
var WHATSNEW_VER='17.65';
'@

SubRx @'
  'PLAYING TOGETHER, SMOOTHER. JOIN THE RAID IN PROGRESS now shows in the Undercroft while your host is up top, and going up at the lift as a teammate joins the raid too, even after your window was closed and opened again. An open trade offer stays on screen with the seconds left to take it. THE OVERSEER is drawn to its size.',
'@ @'
  'KNOWING WHERE YOUR TEAMMATE IS. You are told when your teammate joins the raid and when he is out of it (killed, extracted or abandoned). JOIN THE RAID IN PROGRESS is bigger, and a teammate who joins late sees the walls already blown open and the map markers already placed, and is charged only for the time he played. In a party raid the backpack says Y (or T) offers an item. Pings and the kill feed name THE OVERSEER.',
  'PLAYING TOGETHER, SMOOTHER. JOIN THE RAID IN PROGRESS now shows in the Undercroft while your host is up top, and going up at the lift as a teammate joins the raid too, even after your window was closed and opened again. An open trade offer stays on screen with the seconds left to take it. THE OVERSEER is drawn to its size.',
'@

SubRx @'
var VER='17.64';
'@ @'
var VER='17.65';
'@

$pat = "(?m)^  now:'v17\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.65: The what is new card names the party notices, the late join fixes, the backpack offer hint and the boss by name. Check 17.65 fails on v17.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
