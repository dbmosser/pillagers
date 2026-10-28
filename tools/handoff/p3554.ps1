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

# DOWNED HITS FOLLOW DAMAGE CUTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // v21.97 (K7): and on a raid this window joined and took over when the host left
  if(typeof NET==='object'&&NET&&((NET.on&&NET.role==='join')||(typeof G!=='undefined'&&G&&G.netWasJoin))&&isFinite(amt)) amt*=netKidMul();   // v16.44, his order: kid mode, player 2 takes less
  if(typeof G!=='undefined'&&G&&G.arcade&&isFinite(amt)) amt*=ARCADE_DMG;   // v23.31 (arcade10): arcade hits take half
'@ @'
  // v28.xx (cw-cx-downcuts): retain the same kid and demo factors for seconds lost on the floor; a taken-over join keeps kid mode.
  var _hitMul=1;
  if(typeof NET==='object'&&NET&&((NET.on&&NET.role==='join')||(typeof G!=='undefined'&&G&&G.netWasJoin))) _hitMul*=netKidMul();
  if(typeof G!=='undefined'&&G&&G.arcade) _hitMul*=ARCADE_DMG;
  if(isFinite(amt)) amt*=_hitMul;
'@

SubRx @'
    p.downT-=3; blip('hit');
'@ @'
    p.downT-=3*_hitMul*CFG.eDmg*easyDmgMul(); blip('hit');   // v28.xx (cw-cx-downcuts): the standing damage factors also cut the base 3 seconds, in live play and sim.
'@

SubRx @'
var VER='35.53';
'@ @'
var VER='35.54';
'@

$pat = "(?m)^  now:'v35\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.54: Downed hits follow the same damage factors as standing hits. Check 35.54 fails on v35.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
