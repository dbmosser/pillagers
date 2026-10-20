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

# LOW HEALTH RED IS AN EDGE VIGNETTE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillStyle='rgba(200,30,20,'+(.10+.09*Math.sin(G.t*hpFlashRate()))+')';
    ctx.fillRect(0,0,W,H);
'@ @'
    // v32.xx (cw-lowhpedge): the critic on the low health shot (screen 36, P0): a screen-edge vignette. The flat red wash covered the whole picture, so the middle
    // of the fight went red too; it is now clear in the middle and red at the edges, same pulse, same rate.
    var _lv=ctx.createRadialGradient(W/2,H/2,H*.38,W/2,H/2,Math.max(W,H)*.62), _la=.30+.16*Math.sin(G.t*hpFlashRate());
    _lv.addColorStop(0,'rgba(200,30,20,0)'); _lv.addColorStop(1,'rgba(200,30,20,'+_la.toFixed(3)+')');
    ctx.fillStyle=_lv; ctx.fillRect(0,0,W,H);
'@

SubRx @'
var VER='32.05';
'@ @'
var VER='32.06';
'@

$pat = "(?m)^  now:'v32\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.06: Under 32 health the screen edges pulse red and the middle stays clear. Check 32.06 fails on v32.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
