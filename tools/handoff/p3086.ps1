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

# PLAYER 2 ARRIVES BESIDE PLAYER 1 IN THE UNDERCROFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    HB.player.x=140; HB.player.y=390; HB.player.face=-0.9;

'@ @'
    HB.player.x=140; HB.player.y=390; HB.player.face=-0.9;
    // v30.xx (cw-p1p2), HIS ORDER (2026-10-18): "players 1 and 2 should be able to see each other in the undercroft". Both windows arrived on this one spot, so each
    // body stood exactly under the other and neither could be seen until somebody walked. The player 2 window arrives one body beside the lamp, still inside its light.
    if(typeof NETP2!=='undefined'&&NETP2){ HB.player.x=182; HB.player.y=400; try{ collide(HB.player,HB.dwalls); }catch(_p2c){} }

'@

SubRx @'
var VER='30.85';
'@ @'
var VER='30.86';
'@

$pat = "(?m)^  now:'v30\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.86: Player 2 now arrives in the Undercroft standing beside player 1 instead of on top of him, so both can be seen at once. Check 30.86 fails on v30.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
