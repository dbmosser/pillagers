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

# SETTINGS PANE SKIPS ROWS UNDER THE TAB STRIP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  function vis(x){ var a=sl.getBoundingClientRect(), c=x.getBoundingClientRect(), m=(c.top+c.bottom)/2; return !a.height||(m>=a.top&&m<=a.bottom); }
'@ @'
  function vis(x){ var a=sl.getBoundingClientRect(), c=x.getBoundingClientRect(), m=(c.top+c.bottom)/2, bar=sl.querySelector('.setjump'), t=a.top+(bar?bar.getBoundingClientRect().height:0); return !a.height||(m>=t&&m<=a.bottom); }   // v28.xx (cw-setvis2) the sticky tab strip covers the top of the list: a row under it is not in view (after the Display tab the pane named the Controller row above it)
'@

SubRx @'
var VER='30.18';
'@ @'
var VER='30.19';
'@

$pat = "(?m)^  now:'v30\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.19: Settings detail names the first row below the tab strip. Check 30.19 fails on v30.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
