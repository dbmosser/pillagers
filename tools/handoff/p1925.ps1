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

# THE LIFT SMALL PRINT IS READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  <div id="sectorkit" style="margin-top:11px;font-size:11px;padding:8px 10px;
'@ @'
  <!-- v19.25, seen on the 4K lift screenshot (2026-10-08): what he takes up, and the no-armour warning, were 11 px, the smallest text on
       the page and the last thing read before going up; 15 now, and the day and weather hints 14 -->
  <div id="sectorkit" style="margin-top:11px;font-size:15px;line-height:1.5;padding:9px 12px;
'@

SubRx @'
    <span id="condhint" style="font-size:11px;color:var(--ash)"></span>
'@ @'
    <span id="condhint" style="font-size:14px;color:var(--ash)"></span>
'@

SubRx @'
    <span id="wxhint" style="font-size:11px;color:var(--ash)"></span>
'@ @'
    <span id="wxhint" style="font-size:14px;color:var(--ash)"></span>
'@

SubRx @'
var VER='19.24';
'@ @'
var VER='19.25';
'@

$pat = "(?m)^  now:'v19\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.25: The lift page says what you take up in text you can read from the couch. Check 19.25 fails on v19.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
