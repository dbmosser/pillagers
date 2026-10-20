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

# GROUND SHADOWS KEEP THEIR SPRITES ACROSS SCALES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(SHADSPR.ss!==ss){ SHADSPR.m={}; SHADSPR.n=0; SHADSPR.ss=ss; }
    R=[Math.round(rx),Math.round(ry),Math.round(a*100)]; k=R.join(',');

'@ @'
    // v28.xx (cw-shadowstore): the store used to empty whenever the sprite scale changed, and the world (ss 1) and the bigger figures (ss 2)
    // changed it twice a frame, so every shadow painted a new canvas every frame. ss is part of the key now; the 300 cap stays.
    R=[Math.round(rx),Math.round(ry),Math.round(a*100)]; k=ss+':'+R.join(',');

'@

SubRx @'
var VER='32.74';
'@ @'
var VER='32.75';
'@

$pat = "(?m)^  now:'v32\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.75: Ground shadows no longer repaint their sprites every frame; raids with many bodies and boxes run smoother. Check 32.75 fails on v32.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
