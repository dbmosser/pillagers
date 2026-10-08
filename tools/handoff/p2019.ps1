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

# THE TERMS NAMES STAND OUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    nm.innerHTML=T.name+'<div style="font-size:14px;color:var(--ash);font-weight:400">'+
'@ @'
    nm.innerHTML='<b style="font-weight:700;letter-spacing:.03em">'+T.name+'</b><div style="font-size:14px;color:var(--ash);font-weight:400">'+   // v20.19, seen on the 4K TERMS screenshot (2026-10-08): the name in bold over its line, so the list scans
'@

SubRx @'
var VER='20.18';
'@ @'
var VER='20.19';
'@

$pat = "(?m)^  now:'v20\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.19: The TERMS list is easier to scan. Check 20.19 fails on v20.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
