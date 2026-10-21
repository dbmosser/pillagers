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

# MACHINES A THIRD LARGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function spriteTop(e){
'@ @'
// v28.xx (cw-machbig), HIS ORDER (2026-10-20 evening): "enemies need to be like 33% larger". The machines (sentry, crawler, warden, choir, snitch, listener, howler, bulwark) are DRAWN FIG_MACH times bigger around the foot point and a round hits them at FIG_MACH times the body radius; walking, doors and the nav grid keep the old radius, so nothing sticks in a doorway. Pillager bots, the peddler and the survivor keep their size. FIG_MACH is the one number to change.
var FIG_MACH=1.33, MACH_KIND={sentry:1,crawler:1,warden:1,choir:1,snitch:1,listener:1,howler:1,bulwark:1};
function machMul(e){ return (e&&MACH_KIND[e.kind]===1)?FIG_MACH:1; }
function machScaleBegin(e){ var m=machMul(e); if(m===1) return 0; wc.save(); wc.translate(e.x,e.y); wc.scale(m,m); wc.translate(-e.x,-e.y); return 1; }
function machScaleEnd(n){ if(n) wc.restore(); }
function spriteTop(e){ return spriteTop0(e)*machMul(e); }   // the name plate, alert mark and health pip ride the taller body
function spriteTop0(e){
'@

SubRx @'
      var _kb=animHitShift(e2); if(_kb){ wc.save(); _svd++; wc.translate(_kb.x,_kb.y); }   // v17.47: his pick 29, the hit jolt
'@ @'
      var _mm=machScaleBegin(e2); _svd+=_mm;   // v28.xx (cw-machbig): the machine body, shadow, elite ring, affix mark, windup glow and weak points all ride the bigger body
      var _kb=animHitShift(e2); if(_kb){ wc.save(); _svd++; wc.translate(_kb.x,_kb.y); }   // v17.47: his pick 29, the hit jolt
'@

SubRx @'
      if(eLift>0) wc.restore();
'@ @'
      machScaleEnd(_mm); _svd-=_mm;
      if(eLift>0) wc.restore();
'@

SubRx @'
if(dist(b,en)<en.r+3){
'@ @'
if(dist(b,en)<en.r*machMul(en)+3){   // v28.xx (cw-machbig): a round hits the machine you see
'@

SubRx @'
var W=L[i],pt=weakPos(e,W), qx=bx, qy=by, t;
'@ @'
var W=L[i],pt=weakPos(e,W), qx=bx, qy=by, t, mm=machMul(e); if(mm!==1){ pt={x:e.x+(pt.x-e.x)*mm,y:e.y+(pt.y-e.y)*mm}; W={id:W.id,name:W.name,ang:W.ang,rf:W.rf,rad:W.rad*mm,mult:W.mult,eff:W.eff,c:W.c}; }   // v28.xx (cw-machbig): the opening rides the bigger body
'@

SubRx @'
var VER='33.25';
'@ @'
var VER='33.26';
'@

$pat = "(?m)^  now:'v33\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.26: Machines draw a third larger and are easier to hit. Check 33.26 fails on v33.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
