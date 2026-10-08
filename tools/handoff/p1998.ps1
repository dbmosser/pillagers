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

# THE STASH SHOWS MORE AT ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #hub[data-slayout="6"] .invgrid{ grid-template-columns:repeat(auto-fill,minmax(230px,1fr)) !important; gap:8px !important; }
'@ @'
  /* v19.98, HIS ORDER (2026-10-08, "fix this then", his pick: Medium): the default layout's 230px tiles, times the menu zoom, showed
     about 3 across and 5 on a TV, with 435 things in his stash. Six columns now share the width at every screen size
     (the menu zoom differs by window, so a fixed tile size could not), never under 96px; about three rows show on a 4K TV. */
  #hub[data-slayout="6"] .invgrid{ grid-template-columns:repeat(auto-fill,minmax(max(96px,calc((100% - 40px) / 6)),1fr)) !important; gap:8px !important; }
'@

SubRx @'
var VER='19.97';
'@ @'
var VER='19.98';
'@

$pat = "(?m)^  now:'v19\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.98: The stash shows about 6 tiles across instead of 3, so much more fits on screen. Check 19.98 fails on v19.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
