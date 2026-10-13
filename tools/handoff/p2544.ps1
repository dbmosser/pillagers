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

# A DOWNED PILLAGER GETS UP ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function raiderDownHp(){ return (CFG.raiderDownHp===undefined)?50:CFG.raiderDownHp; }   // v10.04, his answer 44: fifty
'@ @'
function raiderDownHp(){ return (CFG.raiderDownHp===undefined)?50:CFG.raiderDownHp; }   // v10.04, his answer 44: fifty
// pillrevive, HIS ORDER (2026-10-12): "downed pillager bots should be able to use their one-time revive if they haven't blown it
// already". A DOWNED PILLAGER GETS UP ONCE. Every pillager who goes down carries one self-revive per raid, as the player does
// (one per raid, then the floor is the end). He lies RAIDER_GETUP_WAIT seconds first (crawling for cover as before), then gets
// up over RAIDER_GETUP_T seconds: a bar over him fills, his body pushes off the floor and rises to a crouch, and a short pick-up
// sound plays where he lies. No word is said (pillagers say nothing). He stands with RAIDER_GETUP_HP of his health, the same
// share the self-revive gives the player (40 of 100), hostile and back in the fight. Shot or bled out before he is up, he dies
// for good, as always. A man someone is picking up does not get up on his own in the middle of it, and the revive of a man who
// was picked up is still unused. The second time he goes down he only bleeds out (or is picked up), as before. Nothing is
// scored on the fall or the get-up: the kill pays once, on the death, where it always has. No seeded draw is made.
var RAIDER_GETUP_WAIT=3, RAIDER_GETUP_T=2, RAIDER_GETUP_HP=0.4;
function raiderGetUpU(e){ return (e&&e.downed&&e.getUp>0)?clamp(e.getUp/RAIDER_GETUP_T,0,1):0; }
function raiderGetUpMode(e){ return (raiderGetUpU(e)>=0.5)?'crouch':'down'; }   // the second half of the get-up is drawn rising in a crouch
function raiderGetUpShake(e){ var u=raiderGetUpU(e); return (u>0&&u<0.5)?Math.sin((G.t||0)*38)*1.2:0; }   // the first half, pushing off the floor
// The get-up bar over him, between his head and his nameplate. Always true, so the draw chain goes on to draw his body.
function raiderGetUpBar(e){
  var u=raiderGetUpU(e), w=28, bx, by;
  if(!(u>0)) return true;
  bx=e.x-w/2; by=e.y-37;
  wc.fillStyle=INK; wc.fillRect(bx-1,by-1,w+2,5);
  wc.fillStyle='rgba(255,192,74,.22)'; wc.fillRect(bx,by,w,3);
  wc.fillStyle=e.hostile?'#ffc04a':'#4de3d0'; wc.fillRect(bx,by,w*u,3);
  return true;
}
'@

SubRx @'
        e.state='down'; e.alert=0; e.goal=null; e.cd=Math.max(e.cd||0,1);
'@ @'
        e.state='down'; e.alert=0; e.goal=null; e.cd=Math.max(e.cd||0,1);
        e.getUp=0; e.getUpIn=RAIDER_GETUP_WAIT; e.getUpOn=(e.selfRev||CFG.raiderGetUp===0)?0:1;   // pillrevive: his one self-revive, armed here while it is unused
'@

SubRx @'
      if(e.kind==='raider'&&e.hostile&&CFG.raiderCrawl!==0&&!G.sim){
'@ @'
      if(e.kind==='raider'&&e.hostile&&CFG.raiderCrawl!==0&&!G.sim&&!(e.getUp>0)){   // pillrevive: not while he gets up
'@

SubRx @'
      if(e.downT<=0){ e.downed=0; e.finished=1; e.hp=0; }
'@ @'
      if(e.downT<=0){ e.downed=0; e.finished=1; e.hp=0; }
      // pillrevive, HIS ORDER (2026-10-12): HIS ONE SELF-REVIVE. Armed when he fell with it unused (getUpOn). Someone picking him
      // up (reviveT) holds it and starts the get-up over; the wait runs out and he gets up over RAIDER_GETUP_T, still on the floor
      // and still bleeding, so a shot finishes him for good; at the end he stands, his revive spent. His next death is nobody's
      // until someone hits him again, as after any pick-up (v13.98), so the kill pays once.
      if(e.downed&&!e.finished&&e.kind==='raider'&&e.getUpOn&&e.hp>0){
        if(e.reviveT>0) e.getUp=0;
        else if(!(e.getUp>0)){
          e.getUpIn-=dt;
          if(e.getUpIn<=0){ e.getUp=1e-3; e.crawlTo=null; e.moving=false; if(!G.sim){ var _guE=earsOf(e.x,e.y); blip('pick',_guE.d,_guE.pan); } }
        }
        else{
          e.getUp+=dt;
          if(e.getUp>=RAIDER_GETUP_T){
            var _guMine=!!(e.byPlayer||e.bySeat>0);
            e.downed=0; e.getUp=0; e.getUpOn=0; e.selfRev=1; e.hp=Math.max(1,Math.round((e.maxhp||100)*RAIDER_GETUP_HP));
            e.byPlayer=false; e.bySeat=0; e.goal=null; e.crawlTo=null; e.cd=Math.max(e.cd||0,0.5);
            if(e.hostile&&_guMine&&p&&!p.downed){ e.state='chase'; e.alert=2.5; e.tx=p.x; e.ty=p.y; }
            else { e.state='loot'; e.alert=0; }
            if(G.tel) G.tel.raiderSelfRevives=(G.tel.raiderSelfRevives||0)+1;
          }
        }
      }
'@

SubRx @'
      else if(e2.kind==='raider')
        drawOp(e2.x,e2.y,e2.face,(e2.roll>0)?(1-e2.roll/.38)*12.6:(e2.step||0)*4,e2.coat,
          clamp((e2.bag?e2.bag.length:0)/7,0,1),e2.muzzle,(e2.downed||e2.state==='down')?'down':
'@ @'
      // pillrevive: a pillager getting up shows his bar, shakes off the floor, then rises in a crouch
      else if(e2.kind==='raider'&&raiderGetUpBar(e2))
        drawOp(e2.x+raiderGetUpShake(e2),e2.y,e2.face,(e2.roll>0)?(1-e2.roll/.38)*12.6:(e2.step||0)*4,e2.coat,
          clamp((e2.bag?e2.bag.length:0)/7,0,1),e2.muzzle,(e2.downed||e2.state==='down')?raiderGetUpMode(e2):
'@

SubRx @'
  if(e.parley>0) f|=2097152; if(e.blind>0) f|=4194304;
'@ @'
  if(e.parley>0) f|=2097152; if(e.blind>0) f|=4194304;
  if(e.downed&&e.getUp>0) f|=8388608;   // pillrevive: he is getting up
'@

SubRx @'
  e.sprintPool=(f&262144)?6:0; e.helped=(f&524288)?1:0; e.grudge=!!(f&1048576); e.parley=(f&2097152)?1:0; e.blind=(f&4194304)?1:0;
'@ @'
  e.sprintPool=(f&262144)?6:0; e.helped=(f&524288)?1:0; e.grudge=!!(f&1048576); e.parley=(f&2097152)?1:0; e.blind=(f&4194304)?1:0;
  if((f&8388608)&&e.downed){ if(!(e.getUp>0)){ e.getUp=1e-3; if(!G.sim){ try{ var _guN=earsOf(e.x,e.y); blip('pick',_guN.d,_guN.pan); }catch(_gun){} } } } else e.getUp=0;   // pillrevive: the host says he is getting up; the bar fills here
'@

SubRx @'
    if(e.overheat>0) e.overheat-=dt; if(e.shotT>0) e.shotT-=dt;
'@ @'
    if(e.overheat>0) e.overheat-=dt; if(e.shotT>0) e.shotT-=dt;
    if(e.downed&&e.getUp>0) e.getUp=Math.min(RAIDER_GETUP_T,e.getUp+dt);   // pillrevive
'@

SubRx @'
var VER='25.43';
'@ @'
var VER='25.44';
'@

$pat = "(?m)^  now:'v25\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.44: A downed pillager who still has his one self-revive gets up on his own after a few seconds: shoot him while he rises or he is back in the fight. Check 25.44 fails on v25.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
