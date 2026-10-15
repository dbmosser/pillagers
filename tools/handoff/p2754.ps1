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

# CREDITS AND XP ONLY WHERE THEY ARE SPENT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI CLEANUP uic6 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shots of the
     title, the run cards, the pause box and the full-screen windows): THE CREDITS AND XP READOUT IS FOR THE SCREENS THAT SPEND THEM. It was in
     the top right corner of every screen, over the title, the run cards, the pause box, the DEMO pages, and on the frame line of the welcome
     pack, the map select screen and Settings, where the numbers mean nothing. It stays on the Undercroft floor, the stash and the shop,
     craft, hire, Wirt, bar, Mainframe and Fashion windows. (In a raid it is the HUD's business.) Hidden, not removed: it keeps its place, so
     nothing under it moves. */
  body:has(#title.on) #topright, body:has(.outcome.on) #topright, body:has(.pausebox.on) #topright, body:has(#attract.on) #topright,
  body:has(#welcomemodal.on) #topright, body:has(#sectormodal.on) #topright, body:has(#settingsmodal.on) #topright, body:has(#keysmodal.on) #topright,
  body:has(#partymodal.on) #topright, body:has(#termsmodal.on) #topright{ visibility:hidden; }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
var VER='27.53';
'@ @'
var VER='27.54';
'@

$pat = "(?m)^  now:'v27\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.54: Credits and XP show only on the screens where you spend them. Check 27.54 fails on v27.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
