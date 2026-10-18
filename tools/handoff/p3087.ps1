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

# FLAT HUD BARS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    try{ gr=ctx.createLinearGradient(0,y,0,y+h); gr.addColorStop(0,litHex(c,0.22,true)); gr.addColorStop(0.5,c); gr.addColorStop(1,darkHex(c,0.80)); ctx.fillStyle=gr; }catch(_g){ ctx.fillStyle=c; }
'@ @'
    ctx.fillStyle=c;   // v28.xx (cw-flatbars): flat fill, no gradient (the critic, 10-19: bars are still glossy gradients; the style guide wants flat bars)
'@

SubRx @'
    if(h>=6){ ctx.fillStyle='rgba(255,255,255,.16)'; ctx.fillRect(x,y+1,fw,Math.max(1,h*0.12)); }
'@ @'
    // v28.xx (cw-flatbars): the light line along the top of the fill is gone with the gloss
'@

SubRx @'
var VER='30.86';
'@ @'
var VER='30.87';
'@

$pat = "(?m)^  now:'v30\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.87: The health, armour and stamina bars are flat colour with no gloss. Check 30.87 fails on v30.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
