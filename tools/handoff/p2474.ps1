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

# THE METERS AND THE BELT IN GRAPHITE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  rp(x+.5,y+.5,w-1,h-1); ctx.strokeStyle='rgba(127,146,216,.38)'; ctx.lineWidth=1; ctx.stroke();
'@ @'
  rp(x+.5,y+.5,w-1,h-1); ctx.strokeStyle='rgba(74,82,87,.9)'; ctx.lineWidth=1; ctx.stroke();   // vNN.xx (ui5q1t, his #35): the graphite hairline of the HUD plate, not periwinkle
'@

SubRx @'
rp(x,y,w,h); ctx.fillStyle=bg||'rgba(6,9,13,.8)'; ctx.fill();
'@ @'
rp(x,y,w,h); ctx.fillStyle=bg||'rgba(10,11,12,.82)'; ctx.fill();
'@

SubRx @'
_bg.addColorStop(0,on?'rgba(70,56,28,.96)':'rgba(28,36,64,.86)');
'@ @'
_bg.addColorStop(0,on?'rgba(70,56,28,.96)':'rgba(30,34,37,.9)');   /* vNN.xx (ui5q1t, his #35): a belt key is graphite like the HUD plate, not navy */
'@

SubRx @'
var VER='24.73';
'@ @'
var VER='24.74';
'@

$pat = "(?m)^  now:'v24\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.74: The health bars and the belt keys match the graphite raid panels. Check 24.74 fails on v24.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
