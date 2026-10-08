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

# A CACHE TAG CLEARS ITS OWN RING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-15*_MZ,'#e6b4ff');
'@ @'
    mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-20*_MZ,'#e6b4ff');   // v19.65, seen on the 4K map (2026-10-08): clear of its own ring (up to 12 above the centre) at the grown text size
'@

SubRx @'
var VER='19.64';
'@ @'
var VER='19.65';
'@

$pat = "(?m)^  now:'v19\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.65: CACHE tags on the sector map sit clear of their rings. Check 19.65 fails on v19.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
