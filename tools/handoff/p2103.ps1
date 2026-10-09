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

# THE EXTRACT NAMES ON THE MAP READ CLEARLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ctx.fillText('EXTRACT '+String.fromCharCode(65+_fz),ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(24));
'@ @'
      // v21.03, from the whole-game bug hunt of 2026-10-08 (V-D1), seen on the 4K map screenshot: THE EXTRACTION NAME AND THE LINE
      // UNDER IT NEVER TOUCH. Both lines are drawn in the map type, which grows with the screen (_MZ, about 2 at 4K), but the room
      // between them was a fixed LH(18), so at 4K EXTRACT C sat on closes in 2 min 57 sec and EXTRACT B on STAYS OPEN. The two
      // offsets grow by the same _MZ now. At 1080p _MZ is 1 and nothing moves.
      ctx.fillText('EXTRACT '+String.fromCharCode(65+_fz),ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(24)*_MZ);
'@

SubRx @'
      ctx.fillText(_zSub,ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(6));
'@ @'
      ctx.fillText(_zSub,ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(6)*_MZ);
'@

SubRx @'
var VER='21.02';
'@ @'
var VER='21.03';
'@

$pat = "(?m)^  now:'v21\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.03: On a big screen the extract names on the map no longer touch the countdown under them. Check 21.03 fails on v21.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
