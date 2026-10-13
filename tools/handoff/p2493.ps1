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

# ONE BUTTON SIZE IN THE PAUSE BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI REDESIGN ui5q2e (his #50, from the AAA judge of the raid pause shot): ONE BUTTON SIZE IN THE PAUSE ROW. FEEDBACK (v24.50)
     came after the pause row was set to 48px buttons with 16px labels (ui5q1f), so it was the one small button in the row, clearly
     smaller at 4K. It matches SETTINGS and ABANDON RUN now. */
  #root #pausebox #fbbtn{ min-height:48px; padding:0 26px !important; font-size:16px; font-weight:700; letter-spacing:.1em; text-transform:uppercase; }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
var VER='24.92';
'@ @'
var VER='24.93';
'@

$pat = "(?m)^  now:'v24\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.93: FEEDBACK in the pause box is the same size as the buttons beside it. Check 24.93 fails on v24.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
