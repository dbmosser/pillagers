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

# LOW HEALTH PULSES A RED OUTLINE ON THE HEALTH BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function bar(x,y,w,h,f,c,bg){

'@ @'
// v28.xx (cw-lowhp), the critic on the low health shot (2026-10-19, P0): 'low-health state is weak, the player does not notice they are nearly dead'.
// Under a quarter health the health bar gets a pulsing 2px red outline, so the thing that kills you shouts louder than stamina. Returns true when it drew.
function drawLowHpRing(x,y,w,h,hp,mx){
  if(!(hp>0)||!(mx>0)||hp/mx>=0.25) return false;
  var t=((typeof performance!=='undefined'&&performance.now)?performance.now():Date.now())/1000, a=0.55+0.4*Math.sin(t*6);
  ctx.save();
  ctx.strokeStyle='rgba(224,72,58,'+a.toFixed(2)+')'; ctx.lineWidth=2;
  ctx.strokeRect(x-1,y-1,w+2,h+2);
  ctx.restore();
  return true;
}
function bar(x,y,w,h,f,c,bg){

'@

SubRx @'
  ctx.fillText('HP  '+Math.round(p.hp),24,(_hpx>_hpm)?Math.round(by+HBH/2+_hpm*0.36):by+18);

'@ @'
  ctx.fillText('HP  '+Math.round(p.hp),24,(_hpx>_hpm)?Math.round(by+HBH/2+_hpm*0.36):by+18);
  drawLowHpRing(16,by,HBW,HBH,p.hp,p.maxhp);   // v28.xx (cw-lowhp)

'@

SubRx @'
var VER='31.43';
'@ @'
var VER='31.44';
'@

$pat = "(?m)^  now:'v31\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.44: Under a quarter health the health bar pulses a red outline. Check 31.44 fails on v31.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
