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

# LOW HEALTH: THICKER RED OUTLINE, STAMINA STEPS BACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var t=((typeof performance!=='undefined'&&performance.now)?performance.now():Date.now())/1000, a=0.55+0.4*Math.sin(t*6);
  ctx.save();
  ctx.strokeStyle='rgba(224,72,58,'+a.toFixed(2)+')'; ctx.lineWidth=2;
  ctx.strokeRect(x-1,y-1,w+2,h+2);

'@ @'
  var t=((typeof performance!=='undefined'&&performance.now)?performance.now():Date.now())/1000, a=0.78+0.22*Math.sin(t*6);   // v28.xx (cw-lowhp2): never dimmer than 0.56, the first cut was lost in a still picture
  ctx.save();
  ctx.strokeStyle='rgba(255,90,70,'+a.toFixed(2)+')'; ctx.lineWidth=3;
  ctx.strokeRect(x-1.5,y-1.5,w+3,h+3);
'@

SubRx @'
  bar(16,by-29,HBW,16,p.stam/100,_stc);   /* v28.xx (cw-barheight): 16 high like the armour bar, same bottom edge as before */   /* v28.xx (cw-barsame): same width as the health bar */

'@ @'
  var _lowDim=(p.hp>0&&p.hp/p.maxhp<0.25&&!p.stamLock);   // v28.xx (cw-lowhp2), the critic: stamina out-shouts a nearly dead health bar, so under a quarter health it steps back
  if(_lowDim) ctx.globalAlpha=0.45;
  bar(16,by-29,HBW,16,p.stam/100,_stc);   /* v28.xx (cw-barheight): 16 high like the armour bar, same bottom edge as before */   /* v28.xx (cw-barsame): same width as the health bar */
  ctx.globalAlpha=1;
'@

SubRx @'
var VER='31.46';
'@ @'
var VER='31.47';
'@

$pat = "(?m)^  now:'v31\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.47: At low health the red outline is bolder and the stamina bar dims. Check 31.47 fails on v31.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
