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

# THE FASHION RACKS LINE UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
.cosreq{margin-top:2px;font-size:11px;opacity:.65;letter-spacing:1px;text-transform:uppercase}
'@ @'
.cosreq{margin-top:2px;font-size:11px;opacity:.65;letter-spacing:1px;text-transform:uppercase}
/* v21.29, from the whole-game bug hunt of 2026-10-08 (W-A1): THE OWNED LINE SITS LEVEL ACROSS A RACK. A rack tile was a plain box, so a
   name that broke over two lines (The Skeleton, The Tomb Explorer, The Street Poet on the 4K FASHION picture) pushed its OWNED or WORN
   line a whole line lower than the tiles beside it, and the OUTFIT rack read as a ragged row. A tile is a column now and its status
   line sits at the foot of the tile, so every status in a row lines up; the name stays right under the picture, and a row where every
   name fits on one line looks as it did. */
.costile{display:flex;flex-direction:column;align-items:center}
.costile .cosreq{margin-top:auto;padding-top:2px}
'@

SubRx @'
var VER='21.28';
'@ @'
var VER='21.29';
'@

$pat = "(?m)^  now:'v21\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.29: In Fashion, the OWNED and WORN words now line up across each rack, even under a two line name. Check 21.29 fails on v21.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
