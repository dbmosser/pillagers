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

# STEADY HAND AND BEAST MODE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arSetHeldGun(p,w){
  if(p.wep!==w){ p.arStk=0; p.arBonus=0; p.arGun=null; p.arHot=0; }
  p.wep=w;
}
'@ @'
// v28.xx (cw-cx-damagestreaks), HIS WORDS (2026-10-29): "steady hand" and "beast mode", 1% per kill, up to 15 each.
// v28.xx (cw-cx-damagestreaks): each window owns its player; the host kill and the addressed net kill use the same door.
// v28.xx (cw-cx-damagestreaks): air strike kills count. The five seconds use raid time, like the other combat timers. No seeded draws, no sim.
function dmgStreakTick(p){
  if(!G||G.sim||!p) return;
  if((p.bmStk||0)>0&&G.t>=(p.bmUntil||0)){ p.bmStk=0; p.bmUntil=0; }
}
function dmgStreakKill(p,kind){
  if(!G||G.sim||G.over||!p||p.specOut||p.dying||p.downed||!(p.hp>0)||kind==='stray'||kind==='peddler') return;
  dmgStreakTick(p);
  p.shStk=Math.min(15,(p.shStk||0)+1);
  p.bmStk=Math.min(15,(p.bmStk||0)+1); p.bmUntil=G.t+5;
}
function dmgStreakHurt(p,amt){
  if(G&&!G.sim&&p&&amt>0) p.shStk=0;
}
function dmgStreakMul(p){
  if(!G||G.sim||!p) return 1;
  dmgStreakTick(p);
  return (1+0.01*(p.shStk||0))*(1+0.01*(p.bmStk||0));
}
function arSetHeldGun(p,w){
  if(p.wep!==w){ p.arStk=0; p.arBonus=0; p.arGun=null; p.arHot=0; if(G&&!G.sim) p.shStk=0; }
  p.wep=w;
}
'@

SubRx @'
      vx:Math.cos(ang)*(wep.rkt?RKT_SPD:1180),vy:Math.sin(ang)*(wep.rkt?RKT_SPD:1180),dmg:wep.dmg*((sh&&sh.elite)?(CFG.eliteDmg===undefined?1.6:CFG.eliteDmg):1)*((fromPlayer&&!G.sim&&G.player.arBonus>0)?(G.player.arMul||AR_BONUS):1)*pwrMul('dmg',fromPlayer),   // v26.xx (feel11): the active reload bonus
'@ @'
      vx:Math.cos(ang)*(wep.rkt?RKT_SPD:1180),vy:Math.sin(ang)*(wep.rkt?RKT_SPD:1180),dmg:wep.dmg*((sh&&sh.elite)?(CFG.eliteDmg===undefined?1.6:CFG.eliteDmg):1)*((fromPlayer&&!G.sim&&G.player.arBonus>0)?(G.player.arMul||AR_BONUS):1)*((fromPlayer&&!G.sim)?dmgStreakMul(sh):1)*pwrMul('dmg',fromPlayer),   // v28.xx (cw-cx-damagestreaks): active reload, steady hand and beast mode multiply onto this round
'@

SubRx @'
function updatePlayer(dt){
  var p=G.player,T=G.tel;
'@ @'
function updatePlayer(dt){
  var p=G.player,T=G.tel;
  dmgStreakTick(p);   // v28.xx (cw-cx-damagestreaks): expire before any early return or shot.
'@

SubRx @'
        T.kills[e.kind]++; contractKill(e.kind);
'@ @'
        dmgStreakKill(G.player,e.kind);   // v28.xx (cw-cx-damagestreaks): a credited enemy death, including the air strike.
        T.kills[e.kind]++; contractKill(e.kind);
'@

SubRx @'
  if(!k) return 'bad';
  if(T.kills&&T.kills[k]!==undefined) T.kills[k]++;
'@ @'
  if(!k) return 'bad';
  if(T.kills&&T.kills[k]!==undefined) T.kills[k]++;
  dmgStreakKill(G.player,k);   // v28.xx (cw-cx-damagestreaks): only this addressed seat receives its own streak.
'@

SubRx @'
  amt*=CFG.eDmg*easyDmgMul();   // v28.xx (cw-easymode): a third off once he said yes to easy mode
'@ @'
  amt*=CFG.eDmg*easyDmgMul();   // v28.xx (cw-easymode): a third off once he said yes to easy mode
  dmgStreakHurt(p,amt);   // v28.xx (cw-cx-damagestreaks): any health or armour hit, before the plate absorbs it.
'@

SubRx @'
  if(G&&!G.sim&&G.player&&pwrOn('shield')){ try{ pwrShieldHit(sx,sy); }catch(_psh){} return; }   // v26.xx (party3): the shield bubble takes the hit
'@ @'
  if(G&&!G.sim&&G.player&&pwrOn('shield')){ dmgStreakHurt(G.player,amt); try{ pwrShieldHit(sx,sy); }catch(_psh){} return; }   // v26.xx (party3): the shield bubble takes the hit
'@

SubRx @'
  {id:'ar',    nm:'active reload x1', col:'#9fe8b0', bad:0},
'@ @'
  {id:'ar',    nm:'active reload x1', col:'#9fe8b0', bad:0},
  // v28.xx (cw-cx-damagestreaks): the existing status list, immediately after active reload.
  {id:'sh',    nm:'steady hand', col:'#9fe8b0', bad:0},
  {id:'bm',    nm:'beast mode', col:'#ffd25a', bad:0},
'@

SubRx @'
    } else if(E.id==='rest'){
'@ @'
    } else if(E.id==='sh'||E.id==='bm'){
      // v28.xx (cw-cx-damagestreaks): names carry the exact percent; beast mode uses the shared shrinking ring and seconds.
      if(!G.sim){
        dmgStreakTick(p); k=(E.id==='sh')?(p.shStk||0):(p.bmStk||0);
        if(k>0){
          E.on=true; t=(E.id==='sh'?'steady hand':'beast mode')+' +'+k+'%';
          if(E.nm!==t){ E.nm=t; E.nf=''; }
          t='damage';
          if(E.id==='bm'){ n=Math.max(0,p.bmUntil-G.t); E.f=clamp(n/5,0,1); t=Math.ceil(n)+'s'; }
          if(E.vk!==t){ E.vk=t; E.v=t; }
        }
      }
    } else if(E.id==='rest'){
'@

SubRx @'
  if(id==='ar'){
'@ @'
  // v28.xx (cw-cx-damagestreaks): a steady crosshair and three claw marks in the existing plain-path glyph family.
  if(id==='sh'){
    ctx.lineWidth=u*0.22; ctx.arc(cx,cy,u*0.55,0,6.2832); ctx.stroke(); ctx.beginPath();
    ctx.moveTo(cx-u,cy); ctx.lineTo(cx-u*0.35,cy); ctx.moveTo(cx+u*0.35,cy); ctx.lineTo(cx+u,cy);
    ctx.moveTo(cx,cy-u); ctx.lineTo(cx,cy-u*0.35); ctx.moveTo(cx,cy+u*0.35); ctx.lineTo(cx,cy+u); ctx.stroke();
  } else if(id==='bm'){
    ctx.lineWidth=u*0.25; ctx.lineCap='round';
    for(var claw=-1;claw<=1;claw++){ ctx.moveTo(cx+claw*u*0.6+u*0.25,cy-u*0.85); ctx.lineTo(cx+claw*u*0.6-u*0.25,cy+u*0.85); }
    ctx.stroke(); ctx.lineCap='butt';
  } else if(id==='ar'){
'@

SubRx @'
var VER='36.26';
'@ @'
var VER='36.27';
'@

$pat = "(?m)^  now:'v36\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.27: Steady hand adds 1% damage per kill until hit or gun change. Beast mode adds 1% per kill within five seconds. Both cap at 15 and multiply with active reload. Check 36.27 fails on v36.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
