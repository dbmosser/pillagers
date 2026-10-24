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

# DOWNED WASH LIGHTER, ONE RED ACCENT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
ctx.fillStyle='rgba(60,8,5,.45)'; ctx.fillRect(0,0,W,H);
'@ @'
ctx.fillStyle='rgba(60,8,5,.30)'; ctx.fillRect(0,0,W,H);   // v34.40 (cw-downedcard3), critic on screen 34 (P1 'the heavy red wash tints every HUD colour'): the downed wash is 30 percent, was 45, so the HUD keeps its contrast
'@

SubRx @'
bar(W/2-100,_barY,200,10,p.downT/CFG.downTime,UIC.danger);
'@ @'
bar(W/2-100,_barY,200,10,p.downT/CFG.downTime,UIC.tx_2);   // v34.40 (cw-downedcard3), critic on screen 34 (P1 'three red elements stacked, use one accent per card'): the bleed bar is neutral, the danger red stays on the label and the slider
'@

SubRx @'
var VER='34.43';
'@ @'
var VER='34.44';
'@

$pat = "(?m)^  now:'v34\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.44: The red tint while downed is lighter and the card keeps red only on the label and the slider. Check 34.44 fails on v34.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
