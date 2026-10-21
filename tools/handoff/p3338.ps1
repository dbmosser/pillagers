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

# RAID CORNER MONEY BLOCK IS COMPACT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
g.n=n; g.bw=trBW(); g.rh=16+LH(13); g.x=W-16-g.bw;
'@ @'
g.n=(n+1)>>1; g.bw=trBW(); g.ls=LH(13)+3; g.rh=16+LH(13)+(g.n>0?g.n-1:0)*g.ls; g.x=W-16-g.bw;   // v33.xx (cw-cornercompact), HIS ORDER (2026-10-20): "this takes up way too much of the screen, figure out how to make it much more compact". The four plates are ONE plate now: figures in two columns on short lines (n is the lines, rh the plate's height), about a third of the old block
'@

SubRx @'
g.yE=Math.ceil((g.y0+(n?n*g.rh+(n-1)*g.gp+g.gp:0))*g.z);
'@ @'
g.yE=Math.ceil((g.y0+(n?g.rh+g.gp:0))*g.z);
'@

SubRx @'
var g=TRG, y=g.y0+i*(g.rh+g.gp), by=y+8+LH(8);
'@ @'
var g=TRG, y=g.y0, by=y+8+LH(8)+(i>>1)*g.ls, cw=(g.bw-28)/2, cx=g.x+8+(i&1)*(cw+12);   // v33.xx (cw-cornercompact): cell i sits on line i>>1, left or right half
'@

SubRx @'
trPlate(g.x,y,g.bw,g.rh);
'@ @'
if(i===0) trPlate(g.x,y,g.bw,g.rh);
'@

SubRx @'
ctx.textAlign='left'; ctx.fillStyle=UIC.tx_2; ctx.fillText(lab,g.x+8,by);
'@ @'
ctx.textAlign='left'; ctx.fillStyle=UIC.tx_2; ctx.fillText(lab,cx,by);
'@

SubRx @'
ctx.textAlign='right'; ctx.fillStyle=UIC.tx_1; ctx.fillText(val,g.x+g.bw-8,by);
'@ @'
ctx.textAlign='right'; ctx.fillStyle=UIC.tx_1; ctx.fillText(val,cx+cw,by);
'@

SubRx @'
var VER='33.37';
'@ @'
var VER='33.38';
'@

$pat = "(?m)^  now:'v33\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.38: The raid corner shows money, xp, stash and backpack on two short lines in one plate instead of four tall plates. Check 33.38 fails on v33.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
