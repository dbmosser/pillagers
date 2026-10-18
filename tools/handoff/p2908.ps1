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

# PLAYER 2 SEES HIS TEAMMATE'S FLASH AT THE MUZZLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(NET.on) netFxShot(G.bullets[G.bullets.length-1]);   // v16.21: the rest of the party sees this round
'@ @'
    if(NET.on) netFxShot(G.bullets[G.bullets.length-1],sh,wep,ang);   // v16.21: the rest of the party sees this round   // v28.xx (cw-muzzlenet), CLOUD HUNT 2026-10-15: with the gun, for where its flash is drawn
'@

SubRx @'
function netFxShot(b){
'@ @'
function netFxShot(b,sh,wep,ang){ var mz=null;   // v28.xx (cw-muzzlenet), CLOUD HUNT 2026-10-15: the word carried only the spawn point, so the other windows drew the flash and started the tracer inside the gun (17 out) while the shooter own window draws them at the drawn muzzle
'@

SubRx @'
,b._rico?1:0]};
'@ @'
,b._rico?1:0]}; if(sh&&wep&&isFinite(ang)){ try{ mz=gunMuzzleAt(sh,wep,ang); }catch(_mz){} } if(mz&&isFinite(mz.x)&&isFinite(mz.y)) m.b.push(+(+b.mzd||0).toFixed(2),+mz.x.toFixed(1),+mz.y.toFixed(1));   /* v28.xx (cw-muzzlenet), CLOUD HUNT 2026-10-15: fields 9 to 11: the tracer muzzle distance and the flash point; an old window reads the first eight */
'@

SubRx @'
tint:(/^#[0-9a-fA-F]{3,8}$/).test(a[5])?a[5]:'#ffd48a',owner:1,fx:1,elw:a[6]?1:0});
'@ @'
tint:(/^#[0-9a-fA-F]{3,8}$/).test(a[5])?a[5]:'#ffd48a',owner:1,fx:1,elw:a[6]?1:0}); var _mzw=(a.length>=11&&isFinite(a[8])&&isFinite(a[9])&&isFinite(a[10])&&Math.abs(a[9]-a[0])<120&&Math.abs(a[10]-a[1])<120)?1:0, _fb=G.fxBullets[G.fxBullets.length-1]; if(_mzw&&(+a[8])>0&&_fb&&_fb.fx&&_fb.x===(+a[0]||0)){ var _fv=Math.hypot(_fb.vx,_fb.vy)||1; _fb.mzd=Math.min(80,+a[8]); _fb.sx=_fb.x-_fb.vx/_fv*17; _fb.sy=_fb.y-_fb.vy/_fv*17; }   // v28.xx (cw-muzzlenet), CLOUD HUNT 2026-10-15: a word that carries the drawn muzzle starts the tracer there, as the shooter window does
'@

SubRx @'
else if(!G.sim){ try{ gfxShotFx(+a[0]||0,+a[1]||0,
'@ @'
else if(!G.sim){ try{ if(_mzw) gfxShotFx(+a[9],+a[10]+12,Math.atan2(+a[3]||0,+a[2]||0),a[5]); else gfxShotFx(+a[0]||0,+a[1]||0,
'@

SubRx @'
var VER='29.07';
'@ @'
var VER='29.08';
'@

$pat = "(?m)^  now:'v29\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.08: In co-op your teammates muzzle flash and tracer start at the end of his gun, as they do on his screen. Check 29.08 fails on v29.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
