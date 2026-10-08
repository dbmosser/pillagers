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

# THE MAP WEATHER LINE KEEPS A CLEAR GAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(_trB>oy-10-_wfp&&_trL<_wxR+2) _wxR=Math.min(_wxR,_trL-14);
'@ @'
      // v19.33, seen on the 4K map screenshot after v19.32: 14 pixels read as touching beside the big 900 at 4K; the gap is a word wide now
      if(_trB>oy-10-_wfp&&_trL<_wxR+_wfp*1.6) _wxR=Math.min(_wxR,_trL-Math.max(14,_wfp*1.6));
'@

SubRx @'
var VER='19.32';
'@ @'
var VER='19.33';
'@

$pat = "(?m)^  now:'v19\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.33: The time and weather on the sector map stand clear of the credits. Check 19.33 fails on v19.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
