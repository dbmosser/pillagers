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

# THE RING LABEL KEEPS CLEAR OF THE SCREEN EDGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var zcx=(zwid+24<W)?clamp(zs.x,zwid/2+12,W-zwid/2-12):zs.x;
    var _zr=Math.max(1,hudRes());
'@ @'
    // v21.06, from the whole-game bug hunt of 2026-10-08 (V-D4), seen on the 4K raid screenshot: THE RING LABEL KEEPS ITS MARGIN AT 4K.
    // The words stopped 12 pixels from the screen edge, but the dark plate behind them reaches 6 pixels past the words times the screen
    // growth, so at 4K the plate ran right up to the edge of the screen (EXTRACTION POINT - SOUND THE ALARM TO BEGIN COUNTDOWN on the
    // right edge). The margin grows with the screen too. At 1080p _zr is 1 and nothing moves.
    var _zr=Math.max(1,hudRes());
    var zcx=(zwid+24*_zr<W)?clamp(zs.x,zwid/2+12*_zr,W-zwid/2-12*_zr):zs.x;
'@

SubRx @'
var VER='21.05';
'@ @'
var VER='21.06';
'@

$pat = "(?m)^  now:'v21\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.06: On a big screen the extraction label no longer runs up against the edge of the screen. Check 21.06 fails on v21.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
