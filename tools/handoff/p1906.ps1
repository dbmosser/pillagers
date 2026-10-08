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

# THE PAUSE KEY LINE NEVER BREAKS AN ENTRY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function keysLegendApply(){ var el=document.getElementById('pausekeys'); if(!el) return false; el.innerHTML=keysLegendHtml(); return true; }
'@ @'
function keysLegendApply(){ var el=document.getElementById('pausekeys'); if(!el) return false; el.innerHTML=String(keysLegendHtml()).split(' &nbsp; ').map(function(p){ return '<span style="white-space:nowrap">'+p+'</span>'; }).join(' &nbsp; '); return true; }   // v19.06, seen on the 4K pause screenshot (2026-10-07): an entry broke in two at the line end (TAB back / out); each key and its words now stay on one line
'@

SubRx @'
var VER='19.05';
'@ @'
var VER='19.06';
'@

$pat = "(?m)^  now:'v19\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.06: The keys on the pause box wrap only between entries, never inside one. Check 19.06 fails on v19.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
