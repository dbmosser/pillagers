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

# THE PLAYER IS A NEON GREEN CHEVRON ON THE BIG MAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.fillStyle='rgba(255,192,74,.18)';
  ctx.beginPath(); ctx.arc(_pmx,_pmy,15*_pmz,0,6.2832); ctx.fill();
  ctx.fillStyle='#120e0c';
  ctx.beginPath(); ctx.arc(_pmx,_pmy,11*_pmz,0,6.2832); ctx.fill();
  ctx.fillStyle='#ffc04a';
  ctx.beginPath(); ctx.arc(_pmx,_pmy,8*_pmz,0,6.2832); ctx.fill();
  ctx.strokeStyle='rgba(255,192,74,.85)'; ctx.lineWidth=2.5*_pmz;
  ctx.beginPath(); ctx.moveTo(_pmx,_pmy);
  ctx.lineTo(_pmx+Math.cos(p.face)*24*_pmz,_pmy+Math.sin(p.face)*24*_pmz); ctx.stroke();

'@ @'
  // v27.xx (mapchev), HIS ORDER (2026-10-15): "make the player a NEON green chevron n the big map (M key) so that player is easier to see".
  // It was a gold dot with a facing line, the same gold as the district blocks and the loot marks, so it sank into the map. Now it is a
  // neon green chevron pointing where he faces, outlined in ink over a soft green halo. Same place, same scale with the map (_pmz).
  var _pf=p.face||0;
  var _pv=function(a,r){ return [_pmx+Math.cos(_pf+a)*r*_pmz, _pmy+Math.sin(_pf+a)*r*_pmz]; };
  var _pt=_pv(0,17), _pl=_pv(2.45,13), _pn=_pv(Math.PI,5), _pr=_pv(-2.45,13);
  ctx.fillStyle='rgba(57,255,20,.18)';
  ctx.beginPath(); ctx.arc(_pmx,_pmy,20*_pmz,0,6.2832); ctx.fill();
  ctx.beginPath(); ctx.moveTo(_pt[0],_pt[1]); ctx.lineTo(_pl[0],_pl[1]); ctx.lineTo(_pn[0],_pn[1]); ctx.lineTo(_pr[0],_pr[1]); ctx.closePath();
  ctx.lineJoin='round'; ctx.strokeStyle='#0b0f0a'; ctx.lineWidth=5*_pmz; ctx.stroke();
  ctx.fillStyle='#39ff14'; ctx.fill();
  ctx.lineJoin='miter';

'@

SubRx @'
var VER='27.90';
'@ @'
var VER='27.91';
'@

$pat = "(?m)^  now:'v27\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.91: On the big map you are now a neon green chevron pointing where you face. Check 27.91 fails on v27.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
