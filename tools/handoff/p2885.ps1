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

# OPERATORS CAST A SOFT SHADOW TO THE LOWER RIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  shadowE(x,y+1,10,4,.38);
  var _SEAT=seatMarkOf(st);
'@ @'
  // v28.xx (cw-castshadow), art build step (char-art-build-brief): "a soft cast shadow". Light is top-left, so the body shadow sits a little right and
  // down of the feet and a small second lobe trails off toward the far side. Both are cached stamps, two drawImage calls, no new path fills.
  shadowE(x+1.5,y+1.5,10,4,.34);
  shadowE(x+6,y+2.5,6.5,2.5,.18);
  var _SEAT=seatMarkOf(st);
'@

SubRx @'
var VER='28.84';
'@ @'
var VER='28.85';
'@

$pat = "(?m)^  now:'v28\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.85: Operators now throw a soft shadow to the lower right. Check 28.85 fails on v28.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
