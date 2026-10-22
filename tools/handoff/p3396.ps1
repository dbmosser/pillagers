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

# FLOOR BAKE KEEPS ITS MODE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var _px=rx0+rw0*_rubH(RB.x+k*31,RB.y+k*17);
      var _py=ry0+rh0*_rubH(RB.x+k*19,RB.y+k*37);
      var _ps=7+19*_rubH(RB.x+k*43,RB.y+k*5);
      c.fillStyle=isDay()?'rgba(20,18,17,0.42)':'rgba(6,7,10,0.46)';
      c.fillRect(_px-_ps/2+2,_py-_ps/3+2,_ps,_ps*0.62);
      c.fillStyle=isDay()?hexA(RD.wallTop,0.62):hexA(darkHex(RD.wallTop,0.40),0.58);
      c.fillRect(_px-_ps/2,_py-_ps/3,_ps,_ps*0.62);
'@ @'
      // v28.xx (cw-cx-groundmode): the rubble x coordinate must not overwrite the pixel ground flag in this function scope.
      var _rubbleX=rx0+rw0*_rubH(RB.x+k*31,RB.y+k*17);
      var _py=ry0+rh0*_rubH(RB.x+k*19,RB.y+k*37);
      var _ps=7+19*_rubH(RB.x+k*43,RB.y+k*5);
      c.fillStyle=isDay()?'rgba(20,18,17,0.42)':'rgba(6,7,10,0.46)';
      c.fillRect(_rubbleX-_ps/2+2,_py-_ps/3+2,_ps,_ps*0.62);
      c.fillStyle=isDay()?hexA(RD.wallTop,0.62):hexA(darkHex(RD.wallTop,0.40),0.58);
      c.fillRect(_rubbleX-_ps/2,_py-_ps/3,_ps,_ps*0.62);
'@

SubRx @'
var VER='33.95';
'@ @'
var VER='33.96';
'@

$pat = "(?m)^  now:'v33\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.96: The rubble coordinate has its own name. The legacy floor stays full density, stamps land where they are measured, and the pixel floor keeps its requested density. The six pending checks run with their original numerical thresholds. Watch: with pixel look off, check that the floor stays stable while scorch and brass marks appear at their landing points. Check 33.96 fails on v33.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
