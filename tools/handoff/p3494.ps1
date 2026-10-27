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

# THE DIFFICULTY BUTTON HAS ARROWS LIKE EVERY SWITCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #setlist #set_auto::after, #root #setlist #set_share::after{ font-size:var(--fs-title); color:var(--tx-2); }
'@ @'
#root #setlist #set_auto::after, #root #setlist #set_share::after{ font-size:var(--fs-title); color:var(--tx-2); }
/* v28.xx (cw-diffarrow): the difficulty button had no arrows, so it read as a link to another page, not a switch like every row under it; it now has the same pair */
#root #setlist #set_diff{ display:inline-flex; align-items:center; justify-content:space-between; gap:10px; }
#root #setlist #set_diff::before{ content:'\2039'; }
#root #setlist #set_diff::after{ content:'\203A'; }
#root #setlist #set_diff::before, #root #setlist #set_diff::after{ font-size:var(--fs-title); color:var(--tx-2); line-height:1; }
#root #setlist #set_diff.padfocus::before, #root #setlist #set_diff.padfocus::after{ color:var(--acc); }
'@

SubRx @'
var VER='34.93';
'@ @'
var VER='34.94';
'@

$pat = "(?m)^  now:'v34\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.94: The difficulty button shows arrows on both sides, the same as the rows under it. Check 34.94 fails on v34.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
