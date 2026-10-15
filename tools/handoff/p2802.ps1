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

# THE ANSWER LINE STAYS OFF THE BUTTONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI CLEANUP uic4 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shots of the
     map select screen and the Undercroft floor): THE ANSWER LINE STAYS OFF THE BUTTONS. The line sat 38 px up in the middle of the screen
     whatever was open, so it landed on ASCEND TO THIS SECTOR (the whole bottom of the map select screen is that one button) and, on the
     floor, on the middle cells of the tactical belt (TROPHY EARNED over gun key 4). On the map select screen it rides under the heading
     now; on the bare floor and in a raid it sits above the belt. Windows with a footer that has room keep their own place (v20.89). */
  body:has(#sectormodal.on) #hubtoast{ bottom:auto; top:50px; }
  body:not(:has(.modal.on)):not(:has(#hub.on)):not(:has(#title.on)):not(:has(.outcome.on)):not(:has(.pausebox.on)):not(:has(#attract.on)) #hubtoast{ bottom:150px; }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
var VER='28.01';
'@ @'
var VER='28.02';
'@

$pat = "(?m)^  now:'v28\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.02: The answer line no longer covers ASCEND TO THIS SECTOR or the tactical belt. Check 28.02 fails on v28.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
