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

# THE MAP HIDES THE HUD COMPLETELY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.fillStyle='rgba(9,12,34,.99)'; ctx.fillRect(0,0,W,H);   // v19.03, seen on the map screenshot (2026-10-07): at .94 the message toast under the map ghosted through across THE LONG DOCK; the map now hides what is under it
'@ @'
  // v21.04, from the whole-game bug hunt of 2026-10-08 (V-D2), seen on the 4K map screenshot: THE MAP BACKING IS SOLID. At .99 the
  // HUD under the map still ghosted through on a big screen (the controls card, STANDING, HP 100, CONCEALED and the extraction banner
  // all faintly readable down both sides of the map). The backing is the same colour, fully opaque.
  ctx.fillStyle='rgb(9,12,34)'; ctx.fillRect(0,0,W,H);   // v19.03, seen on the map screenshot (2026-10-07): at .94 the message toast under the map ghosted through across THE LONG DOCK; the map now hides what is under it
'@

SubRx @'
var VER='21.03';
'@ @'
var VER='21.04';
'@

$pat = "(?m)^  now:'v21\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.04: Nothing from the raid HUD shows through the open map any more. Check 21.04 fails on v21.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
