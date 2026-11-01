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

# THE LAST MINUTE TURNS THE WORLD RED AND DROPS ASH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function render2D(dt){

'@ @'
// v37.xx (cw-burnash), HIS ANSWER g-48 ("Yes, ash and a red glow"): in the last minute the world slowly turns red and ash falls, so the burn coming reads on a TV.
// Render layer only, each window draws its own, no sound (no hum). 1) A full-frame red wash, 0 at 1:00 to 0.16 at 0:00 (no edge frame, no pulse).
// 2) Up to 70 grey flakes (fewer when the quality ladder sheds detail), 1.5 to 3 px times hudRes, falling 22 to 40 px/s and drifting 6 to 14 px/s,
// fading in over the first 3 s. Positions use Math.random, never rr or rnd, so the seed is untouched. BURN counts what the last frame drew.
// Reduce motion (job 137) has not shipped: when it does it should switch the ash off and keep the glow.
var BURN={ash:0,k:0,fl:[]};
function burnFx(c,dt,w,h){
  BURN.ash=0; BURN.k=0;
  if(!G||G.over||G.nuking||!raidClockOn()) return;
  var tl=+G.timeLeft;
  if(!(tl>0&&tl<=CLOCK_RED)) return;
  var f=1-tl/CLOCK_RED, k=0.16*f, r=Math.max(1,(typeof hudRes==='function')?hudRes():1), fl=BURN.fl;
  var n=Math.round(70*(0.4+0.6*GFXQ.detail)), fin=Math.min(1,(CLOCK_RED-tl)/3), i, q, s, t;
  BURN.k=k; dt=clamp(+dt||0,0,0.1);
  c.save(); c.globalCompositeOperation='source-over';
  c.globalAlpha=1; c.fillStyle='rgba(150,24,10,'+k.toFixed(4)+')'; c.fillRect(0,0,w,h);
  while(fl.length<n){ t=Math.random(); fl.push({x:Math.random()*w,y:Math.random()*h,s:1.5+1.5*Math.random(),vy:22+18*Math.random(),vx:6+8*Math.random(),a:0.3+0.25*Math.random(),c:'rgb('+Math.round(154-60*t)+','+Math.round(148-58*t)+','+Math.round(140-54*t)+')'}); }
  if(fl.length>n) fl.length=n;
  for(i=0;i<fl.length;i++){
    q=fl[i]; s=q.s*r;
    q.y+=q.vy*r*dt; q.x+=q.vx*r*dt;
    if(q.y>h+s){ q.y=-s; q.x=Math.random()*w; } else if(q.x>w+s) q.x=-s;
    c.globalAlpha=q.a*fin; c.fillStyle=q.c; c.fillRect(q.x,q.y,s,s); BURN.ash++;
  }
  c.restore();
}
function render2D(dt){

'@

SubRx @'
  gfxpMark('wx');
'@ @'
  try{ burnFx(wc,dt,W,H); }catch(_bfx){}   // v37.xx (cw-burnash): the last minute, red wash and falling ash, after the light, fog and flashes and before the HUD
  gfxpMark('wx');
'@

SubRx @'
var VER='37.10';
'@ @'
var VER='37.11';
'@

$pat = "(?m)^  now:'v37\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.11: The last minute of a raid slowly reddens the world and ash falls. Check 37.11 fails on v37.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
