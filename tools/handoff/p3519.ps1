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

# PILLAGER BACK TO FULL SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var FIG_SCALE=1.25/3, FIG_UP=Math.round(45*FIG_SCALE)-32, 
'@ @'
var FIG_SCALE=1, FIG_UP=12, /* cw-figone, HIS NOTE 10-27: "Character is too small now. Increase size to get him back to the original size that we had him at for a long long time (weeks)": back to the size 1 art he played from launch to 10-20 and again 10-20 to 10-25 (FIG_UP 12 as then); never shrink again unless he asks */ 
'@

SubRx @'
var _cf=figK1(), _sd=(_cf!==1&&Math.cos(+face||0)<0)?-1:1;
'@ @'
var _cf=figK1(), _sd=((figOn()&&!pixOn())&&Math.cos(+face||0)<0)?-1:1; /* cw-figone: the smooth look flips the mark away from his aim at size 1 too, so it never covers his gun (same as before wherever the figure is not size 1) */
'@

SubRx @'
if(mz&&isFinite(mz.x)&&isFinite(mz.y)) m.b.push(+(+b.mzd||0).toFixed(2),+mz.x.toFixed(1),+mz.y.toFixed(1));
'@ @'
if(mz&&isFinite(mz.x)&&isFinite(mz.y)) m.b.push(+(+b.mzd||0).toFixed(2),+mz.x.toFixed(1),+mz.y.toFixed(1)); if(m.b.length===11&&b.ly>0) m.b.push(+(+b.ly).toFixed(1)); /* cw-figone: field 12, the height its tracer is drawn at, so the partner window draws it at the gun line of the body that fired it (an old window reads eleven) */
'@

SubRx @'
if(_mzw&&_fb&&_fb.fx&&_fb.x===(+a[0]||0)&&!pixOn()) _fb.ly=20*FIG_SCALE;
'@ @'
if(_mzw&&_fb&&_fb.fx&&_fb.x===(+a[0]||0)&&!pixOn()) _fb.ly=(a.length>=12&&isFinite(a[11])&&(+a[11])>0&&(+a[11])<60)?+a[11]:20*FIG_SCALE; /* cw-figone: the height the shooter window drew it at (field 12); 20 times the figure size from an older window */
'@

SubRx @'
var _sp=w2s(_se.x,pixOn()?40:figHudLift(66),_se.y), 
'@ @'
var _sp=w2s(_se.x,pixOn()?40:(figHudLift(66)-5*figKS('lean')[1]*(ZOOM()||1)),_se.y) /* cw-figone: a found survivor is drawn crouched (5 lower in body units, lean build), so the give prompt lifts from his crouched head and keeps one gap over it at every screen and zoom at size 1 */, 
'@

SubRx @'
var VER='35.18';
'@ @'
var VER='35.19';
'@

$pat = "(?m)^  now:'v35\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.19: pillagers are back to their old full size Check 35.19 fails on v35.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
