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

# ARCADE: SPAWN SHIELD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// Run from startRaid right after the build, in every window that builds the arcade raid, so both builds stay identical.
function arcadePostBuild(g){
'@ @'
// v23.30, HIS ORDER (2026-10-11), build 9 of 20 (arcade9): SPAWN SHIELD. A walk-up player is put down at every arcade drop, respawn and
// re-drop with a shield (p.arcSh): damagePlayer takes nothing while it is up, above every hit stamp (no grunt, no hit ring, no log
// line), and the hit sparks teal on the bubble instead. It stays until he does something: movement input over 0.25 (keys, arrows or
// the left stick), a roll, a shot or a throw. Aiming alone and searching keep it, so a newcomer can try the stick while he reads.
// While it is up a pulsing teal bubble and the tag SHIELD . MOVE TO START sit on him, and his st word carries sh 1, so the other
// window draws the same bubble on him. Only arcade raids ever set it, so a normal raid is unchanged.
function arcadeShieldOff(){
  if(!G||!G.player||!G.player.arcSh) return false;
  G.player.arcSh=0;
  return true;
}
// The bubble on a shielded player (own: this window, which also gets the tag under him). Drawn on the world canvas.
function arcadeShieldRing(x,y,own){
  if(!G||!G.arcade||!wc||!isFinite(x)||!isFinite(y)) return;
  var pu=0.5+0.5*Math.sin((G.t||0)*5), rx=21+pu*2.5, ry=rx*1.3, cy=y-18, tg, tw;
  wc.save();
  wc.globalAlpha=0.12+0.10*pu; wc.fillStyle='#3fe0d0';
  wc.beginPath(); wc.ellipse(x,cy,rx,ry,0,0,6.2832); wc.fill();
  wc.globalAlpha=0.55+0.35*pu; wc.strokeStyle='#5ff5e4'; wc.lineWidth=2;
  wc.beginPath(); wc.ellipse(x,cy,rx,ry,0,0,6.2832); wc.stroke();
  if(own){
    tg='SHIELD \u00b7 MOVE TO START';
    wc.globalAlpha=1; wc.font=FS(TYPE.micro); tw=wc.measureText(tg).width;
    wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(x-tw/2-4,y+14,tw+8,13);
    wc.fillStyle='#5ff5e4'; wc.fillText(tg,x-tw/2,y+24);
  }
  wc.restore();
}
// Run from startRaid right after the build, in every window that builds the arcade raid, so both builds stay identical.
function arcadePostBuild(g){
'@

SubRx @'
  arcadeKitApply(g.player,g,'drop');
'@ @'
  arcadeKitApply(g.player,g,'drop');
  g.player.arcSh=1;   // v23.30 (arcade9): the spawn shield
'@

SubRx @'
  arcadeKitApply(p,G,why||'dead');
'@ @'
  arcadeKitApply(p,G,why||'dead');
  p.arcSh=1;   // v23.30 (arcade9): the spawn shield
'@

SubRx @'
  arcadeKitApply(p,G,'redrop');
'@ @'
  arcadeKitApply(p,G,'redrop');
  p.arcSh=1;   // v23.30 (arcade9): the spawn shield
'@

SubRx @'
  if(G&&G.player&&G.player.specOut) return;
  // v4.28: the direction of the hit, stamped for the ring around the body.
'@ @'
  if(G&&G.player&&G.player.specOut) return;
  // v23.30 (arcade9): the arcade spawn shield takes the hit, above every stamp, and sparks teal on the bubble
  if(G&&G.arcade&&G.player&&G.player.arcSh){ if(!G.sim){ var _sa=(sx!==undefined&&isFinite(sx)&&isFinite(sy))?Math.atan2(sy-G.player.y,sx-G.player.x):-1.5708; try{ spark(G.player.x+Math.cos(_sa)*22,G.player.y-18+Math.sin(_sa)*28,'#5ff5e4',8,160); }catch(_ss){} } return; }
  // v4.28: the direction of the hit, stamped for the ring around the body.
'@

SubRx @'
    ana=Math.min(1,Math.sqrt(mx*mx+my*my));
  }
var mg=Math.sqrt(mx*mx+my*my);
'@ @'
    ana=Math.min(1,Math.sqrt(mx*mx+my*my));
  }
var mg=Math.sqrt(mx*mx+my*my);
  if(G.arcade&&p.arcSh&&mg>0.25) arcadeShieldOff();   // v23.30 (arcade9): moving drops the spawn shield
'@

SubRx @'
  p.roll=.38; p.rollCd=.85; p.iv=Math.max(p.iv,.30); p.stam-=ROLLSTAM;
'@ @'
  p.roll=.38; p.rollCd=.85; p.iv=Math.max(p.iv,.30); p.stam-=ROLLSTAM;
  if(G.arcade&&p.arcSh) arcadeShieldOff();   // v23.30 (arcade9)
'@

SubRx @'
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@ @'
function fireWeapon(sh,wep,tx,ty,fromPlayer){
  if(fromPlayer&&G&&G.arcade&&G.player&&G.player.arcSh) arcadeShieldOff();   // v23.30 (arcade9): a shot drops the spawn shield
'@

SubRx @'
function throwFrom(tk,cookT){
  var p=G.player;
'@ @'
function throwFrom(tk,cookT){
  var p=G.player;
  if(G.arcade&&p.arcSh) arcadeShieldOff();   // v23.30 (arcade9)
'@

SubRx @'
  p.cooking=1; p.cookT=0; p.cookKind=tk;
'@ @'
  p.cooking=1; p.cookT=0; p.cookKind=tk;
  if(G.arcade&&p.arcSh) arcadeShieldOff();   // v23.30 (arcade9)
'@

SubRx @'
      if(pLift>0){ wc.restore(); _svd--; }
    } else {
      var e2=it.e;
'@ @'
      if(G.arcade&&p.arcSh) arcadeShieldRing(p.x,p.y,1);   // v23.30 (arcade9): the spawn shield
      if(pLift>0){ wc.restore(); _svd--; }
    } else {
      var e2=it.e;
'@

SubRx @'
  if(NET.role==='host') msg.s=NET.seat;   // a friend names no seat: the host files him under the seat of his link
  lk=netLook(); ls=JSON.stringify(lk);
  if(ls!==NET.lkSent||NET.upN%10===0){ msg.lk=lk; NET.lkSent=ls; }
'@ @'
  if(NET.role==='host') msg.s=NET.seat;   // a friend names no seat: the host files him under the seat of his link
  lk=netLook(); ls=JSON.stringify(lk);
  if(ls!==NET.lkSent||NET.upN%10===0){ msg.lk=lk; NET.lkSent=ls; }
  if(G.arcade&&p.arcSh) msg.sh=1;   // v23.30 (arcade9): only while shielded
'@

SubRx @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
'@ @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
  if(up&&(m.sh||g.sh)) g.sh=m.sh?1:0;   // v23.30 (arcade9): the teammate spawn shield
'@

SubRx @'
       gloves:lk.gloves,pack:lk.pack,patch:lk.patch,tattoo:lk.tattoo,outfit:lk.outfit,build:lk.build});
  }catch(e){}
'@ @'
       gloves:lk.gloves,pack:lk.pack,patch:lk.patch,tattoo:lk.tattoo,outfit:lk.outfit,build:lk.build});
    if(g.sh&&G&&G.arcade) arcadeShieldRing(g.x,g.y,0);   // v23.30 (arcade9)
  }catch(e){}
'@

SubRx @'
var VER='23.29';
'@ @'
var VER='23.30';
'@

$pat = "(?m)^  now:'v23\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.30: In the arcade every drop, respawn and re-drop is shielded until the player moves, rolls, shoots or throws. Check 23.30 fails on v23.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
