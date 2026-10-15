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

# THE KEY LISTS USE THE WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI CLEANUP uic10 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shots of CHANGE
     KEYS and CHANGE PAD BUTTONS): THE KEY LISTS USE THE WINDOW. The list was one column 1100 px wide in a 1920 px window with the right 40 percent
     empty, and 30 key rows meant scrolling. It is two columns across the window now, each section head across both, so the same rows fit
     in half the height. The rows, the keycaps, REBIND and the note above are unchanged; the pad walks them by place as before. */
  #root #keyslist{ max-width:1500px; display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); column-gap:36px; align-content:start; }
  #root #keyslist .keysec{ grid-column:1 / -1; }
  #root #keysnote{ max-width:1500px; }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
var VER='27.57';
'@ @'
var VER='27.58';
'@

$pat = "(?m)^  now:'v27\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.58: CHANGE KEYS and CHANGE PAD BUTTONS list the actions in two columns. Check 27.58 fails on v27.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
