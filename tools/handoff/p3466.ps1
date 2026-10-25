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

# RAID BACKPACK TITLE AND EMPTY CELLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
ctx.font=bFS(TYPE.head); ctx.fillStyle='#efe9dc';   // v28.xx (cw-bagpolish2)
'@ @'
ctx.font=bFS(TYPE.title); ctx.fillStyle='#efe9dc';   // v28.xx (cw-bagtiles2), the critic: the title is the guide title size like the item hero; (cw-bagpolish2)
'@

SubRx @'
ctx.fillStyle='#16191b'; ctx.fillRect(_ex,_ey,TILE,TILE); ctx.strokeStyle='#2e3337';
'@ @'
ctx.fillStyle='#1a1e21'; ctx.fillRect(_ex,_ey,TILE,TILE); ctx.strokeStyle='#3d444a';
'@

SubRx @'
ctx.fillText(String(_rw[_rr][1]),x+11+LH(64)*BZ,_ry);
'@ @'
ctx.fillText(String(_rw[_rr][1])==='armor'?'armour':String(_rw[_rr][1]),x+11+LH(64)*BZ,_ry);   // v28.xx (cw-bagtiles2): one spelling, armour
'@

SubRx @'
var VER='34.65';
'@ @'
var VER='34.66';
'@

$pat = "(?m)^  now:'v34\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.66: The raid backpack title is bigger and empty cells are easier to see. Check 34.66 fails on v34.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
