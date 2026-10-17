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

# DOWNED BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function tickDowned(dt){
'@ @'
// v28.xx (downbar1), HIS WORDS (2026-10-16): "similar to the active reload mechanic, I want a mechanic when you are downed that is like a bar with a slider and if you click
// fire when the slider is in the right spot (middle), then it slows down how fast you bleed out", and "it like keeps going so you have to keep doing it maybe once a second".
// THE DOWNED BAR. While you bleed out a white slider sweeps a bar, one pass a second, with a red sweet spot in the middle (DB_ZA to DB_ZB, a fifth of the bar). A fresh press of
// fire (LMB, or RT on a pad; the trigger must be let go and pulled again, a trigger held down as you fell does not count) with the slider inside the spot is a HIT: the bleed-out
// runs at half speed (DB_RATE) for DB_STEADY seconds, and a hit renews that time, it does not stack, so a hit about every pass keeps the bleed slow. A press outside the spot is a
// MISS: a dull sound, a red flash and DB_LOCK seconds in which the trigger is dead, no other penalty. Everything else that reads fire sits below the downed return of
// updatePlayer, so the press does nothing more. Live play only (G.sim never runs it), and nothing here draws from the seeded stream: the slider runs on the downed clock.
var DB_ZA=0.40, DB_ZB=0.60, DB_PASS=1.0, DB_STEADY=1.2, DB_LOCK=0.3, DB_RATE=0.5, DB_DRAWS=0;
function downBarPos(t){ var u=t/DB_PASS; u-=2*Math.floor(u/2); return u<1?u:2-u; }
function downBarTick(p,dt){
  var dn=!!mouse.down, press, f;
  if(!G||G.sim||G.over||!p||!p.downed){ if(p&&p.dbOn) p.dbOn=0; return false; }
  if(p.dbOn!==1){ p.dbOn=1; p.dbT=0; p.dbSteady=0; p.dbLock=0; p.dbFlash=0; p.dbPulse=0; p.dbPrev=dn; }   // a trigger already held as he fell is not a press
  p.dbT+=dt;
  if(p.dbLock>0) p.dbLock=Math.max(0,p.dbLock-dt);
  if(p.dbFlash>0) p.dbFlash=Math.max(0,p.dbFlash-dt);
  if(p.dbPulse>0) p.dbPulse=Math.max(0,p.dbPulse-dt);
  press=dn&&!p.dbPrev; p.dbPrev=dn;
  if(!press||p.dbLock>0) return false;
  f=downBarPos(p.dbT);
  if(f<DB_ZA||f>DB_ZB){ p.dbLock=DB_LOCK; p.dbFlash=DB_LOCK; try{ blip('arMiss'); }catch(_dm){} return false; }
  p.dbSteady=DB_STEADY; p.dbPulse=0.25;
  try{ blip('arHit'); }catch(_dh){}
  return true;
}
// The bar, in the style of the reload bar (reloadBarDraw): a dark plate, a red zone with a line at each end, a white slider that lights the zone while it is inside.
// cx is the middle and yb the bottom edge. A miss flashes the plate red and dims the slider, a hit rings the zone, STEADY shows while the slow bleed runs.
function downBarDraw(cx,yb,p){
  var BW=240, BH=14, x0, y0, zx, zw, f, inz, lk, st;
  if(!p||p.dbOn!==1||!p.downed) return;
  DB_DRAWS++;
  x0=Math.round(cx-BW/2); y0=Math.round(yb-BH); zx=Math.round(x0+BW*DB_ZA); zw=Math.round(BW*(DB_ZB-DB_ZA));
  f=downBarPos(p.dbT); inz=(f>=DB_ZA&&f<=DB_ZB); lk=(p.dbLock>0); st=(p.dbSteady>0);
  ctx.save();
  ctx.fillStyle=(p.dbFlash>0)?'rgba(170,30,24,.92)':'rgba(6,9,13,.82)';
  ctx.fillRect(x0-3,y0-3,BW+6,BH+6);
  ctx.fillStyle='rgba(70,58,56,.9)'; ctx.fillRect(x0,y0,BW,BH);
  ctx.fillStyle=lk?'rgba(150,40,32,.60)':(inz?'rgb(255,150,138)':'rgb(232,58,44)');
  if(inz&&!lk){ ctx.shadowColor='rgba(255,90,70,.95)'; ctx.shadowBlur=9; }
  ctx.fillRect(zx,y0,zw,BH);
  ctx.shadowBlur=0; ctx.shadowColor='rgba(0,0,0,0)';
  ctx.fillStyle=lk?'rgba(255,69,56,.45)':(inz?'rgb(255,255,255)':'rgb(255,69,56)');
  ctx.fillRect(zx-1,y0-4,3,BH+8);
  ctx.fillRect(zx+zw-1,y0-4,3,BH+8);
  if(p.dbPulse>0){ ctx.strokeStyle='rgba(159,232,176,'+Math.min(1,p.dbPulse*4).toFixed(2)+')'; ctx.lineWidth=3; ctx.strokeRect(zx-4,y0-5,zw+8,BH+10); }
  ctx.fillStyle=lk?'rgba(255,255,255,.45)':'rgb(255,255,255)';
  ctx.fillRect(Math.round(x0+BW*f)-2,y0-5,4,BH+10);
  if(st){ ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#9fe8b0'; ctx.fillText('STEADY',cx,y0-10); }
  ctx.restore();
}
function tickDowned(dt){
'@

SubRx @'
  p.downT-=dt;
'@ @'
  var _ds=(p.dbSteady>0)?Math.min(dt,p.dbSteady):0;   // v28.xx (downbar1): the slice of this step that is a slow bleed
  if(_ds>0) p.dbSteady-=_ds;
  p.downT-=(dt-_ds)+_ds*DB_RATE;
'@

SubRx @'
    if(tickDowned(dt)) return;
'@ @'
    downBarTick(p,dt);   // v28.xx (downbar1): the slider and the press, before the bleed reads the steady time
    if(tickDowned(dt)) return;
'@

SubRx @'
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null; G.crouchTog=false; G.pCrouch=false; p.roll=0;
'@ @'
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null; G.crouchTog=false; G.pCrouch=false; p.roll=0; p.dbOn=0;   // v28.xx (downbar1): a fresh bar
'@

SubRx @'
  if(p.rollCd>0) p.rollCd-=dt;
'@ @'
  if(p.dbOn){ p.dbOn=0; p.dbSteady=0; p.dbLock=0; }   // v28.xx (downbar1): on his feet again, the downed bar is gone
  if(p.rollCd>0) p.rollCd-=dt;
'@

SubRx @'
ctx.fillStyle='#ff5a4a'; ctx.fillText('DOWN',W/2,_dy);
'@ @'
ctx.fillStyle='#ff5a4a'; ctx.fillText('DOWN',W/2,_dy);
    try{ downBarDraw(W/2,_dy-_hH-4,p); }catch(_dbd){}   // v28.xx (downbar1): the slider bar, above the title, inside the same scale
'@

SubRx @'
var VER='28.77';
'@ @'
var VER='28.78';
'@

$pat = "(?m)^  now:'v28\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.78: When downed, hit fire with the slider in the red to bleed out at half speed. Check 28.78 fails on v28.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
