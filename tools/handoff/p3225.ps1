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

# THE FEED HIDES BEHIND THE OPEN MAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(!G||G.sim||!G.player||G.over) return 0;
  R=feedRect();
'@ @'
if(!G||G.sim||!G.player||G.over) return 0;
  if(G.mapOpen) return 0;   // v28.xx (cw-feedmap), the critic on screen 22 (2026-10-19): toasts ("running slowly", codex entry) sat on top of the open map. The feed waits behind the map and is back when it closes.
  R=feedRect();
'@

SubRx @'
var VER='32.24';
'@ @'
var VER='32.25';
'@

$pat = "(?m)^  now:'v32\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.25: With the map open the bottom left feed is hidden; shut the map and the lines are back. Check 32.25 fails on v32.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
