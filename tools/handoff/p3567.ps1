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

# WARNING RED ENEMY TRACERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@ @'
// v34.xx (cw-redtracers): his g-88 answer, "Enemy tracers in a warning colour". Allies keep their gun tint; no seeded draw.
var ENEMY_TRACER='#ff3b2f';
function foeShot(sh,fromPlayer){ return !fromPlayer&&sh&&!sh.merc&&!sh.friendlyPC&&!sh.friendly&&sh.kind!=='stray'&&sh.kind!=='peddler'; }
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@

SubRx @'
      life:wep.rng/(wep.rkt?RKT_SPD:1180),player:!!fromPlayer,owner:sh,tint:wep.tint||'#ffd48a',
'@ @'
      life:wep.rng/(wep.rkt?RKT_SPD:1180),player:!!fromPlayer,owner:sh,tint:foeShot(sh,fromPlayer)?ENEMY_TRACER:(wep.tint||'#ffd48a'),   // v28.xx (cw-cx-redtracers): hostile machines and pillager bots, including forged guns, warn in red
'@

SubRx @'
    else if(!G.sim){ try{ if(_mzw) gfxShotFx(+a[9],+a[10]+12,Math.atan2(+a[3]||0,+a[2]||0),a[5],pixOn()?1:FIG_SCALE/0.8); /* v28.xx (cw-thirdsize): a teammate flash at the drawn muzzle is sized to his smaller gun */ else gfxShotFx(+a[0]||0,+a[1]||0,Math.atan2(+a[3]||0,+a[2]||0),a[5]); }catch(_gsx){} }   // v23.xx (gfx24): and its muzzle flash
'@ @'
    else if(!G.sim){ try{ if(_mzw) gfxShotFx(+a[9],+a[10]+12,Math.atan2(+a[3]||0,+a[2]||0),a[5]===ENEMY_TRACER?'#ffc27a':a[5],pixOn()?1:FIG_SCALE/0.8); /* v28.xx (cw-thirdsize): a teammate flash at the drawn muzzle is sized to his smaller gun */ else gfxShotFx(+a[0]||0,+a[1]||0,Math.atan2(+a[3]||0,+a[2]||0),a[5]===ENEMY_TRACER?'#ffc27a':a[5]); }catch(_gsx){} }   // v23.xx (gfx24): and its muzzle flash   // v28.xx (cw-cx-redtracers): the warning tint belongs to the tracer; both packet shapes keep a warm flash
'@

SubRx @'
var VER='35.66';
'@ @'
var VER='35.67';
'@

$pat = "(?m)^  now:'v35\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.67: Enemy rounds warn in red in both windows; allied rounds keep their gun colours. Check 35.67 fails on v35.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
