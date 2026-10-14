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

# STYLE SCORING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeKill(k,el,boss,x,y){
'@ @'
function arcadeKill(k,el,boss,x,y,ke){
'@

SubRx @'
  arcadeKillPerks();   // v23.31 (arcade10): half a magazine back, a Bandage every 3rd kill
'@ @'
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk){}   // v26.xx (party1): the style bonuses and medals
  arcadeKillPerks();   // v23.31 (arcade10): half a magazine back, a Bandage every 3rd kill
'@

SubRx @'
function careerKill(k,el,boss,x,y){
'@ @'
function careerKill(k,el,boss,x,y,ke){
'@

SubRx @'
  G.cs.s=(G.cs.s|0)+n; G.cs.k=(G.cs.k|0)+1;
'@ @'
  G.cs.s=(G.cs.s|0)+n; G.cs.k=(G.cs.k|0)+1;
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk2){}   // v26.xx (party1): the same style bonuses in a CAREER raid
'@

SubRx @'
arcadeKill(e.kind,(e.elite&&e.affix)?3:e.elite,e.boss,e.x,e.y); else if(G.career) careerKill(e.kind,(e.elite&&e.affix)?3:e.elite,e.boss,e.x,e.y);
'@ @'
arcadeKill(e.kind,(e.elite&&e.affix)?3:e.elite,e.boss,e.x,e.y,e); else if(G.career) careerKill(e.kind,(e.elite&&e.affix)?3:e.elite,e.boss,e.x,e.y,e);
'@

SubRx @'
e?e.x:NaN,e?e.y:NaN);
'@ @'
e?e.x:NaN,e?e.y:NaN,e);
'@

SubRx @'
        if(_me.hp<=0) _me.byPlayer=true;
'@ @'
        if(_me.hp<=0) _me.byPlayer=true;
        _me.blow='m'; _me.blowT=G.t;   // v26.xx (party1): the last blow on him was a swing
'@

SubRx @'
if(_fMine){ e.pHitT=.3; e.pHitSeat=0; }
'@ @'
if(_fMine){ e.pHitT=.3; e.pHitSeat=0; } if(_fMine){ e.blow='x'; e.blowT=G.t; }   // v26.xx (party1): and the last blow on him was a blast
'@

SubRx @'
en.pHitT=.3; en.pHitSeat=0;
'@ @'
en.pHitT=.3; en.pHitSeat=0; en.blow='g'; en.blowT=G.t;   // v26.xx (party1): and the last blow on him was a round
'@

SubRx @'
// The score changed: tell the other window now, or on the next flush inside the 250 ms limit. ev x (with n) is an extraction.
'@ @'
// v26.xx (party1), HIS YES (2026-10-14) to suggestion 37, STYLE SCORING: "a decaying combo ring at the cursor, style bonuses and short medal pop-ups". The same in DEMO and CAREER.
// THE RING. While a kill chain of two or more is live (the streak that already multiplies the score, ARCADE_STREAK_GAP, 4 s), a ring sits just outside
// the cursor's magazine and bloom rings and drains clockwise as the chain runs out, with its multiplier beside it (x2 to x5); it is amber, and
// hotter for the higher multipliers. THE STYLE BONUSES pay into the run score through scoreBonus(), on top of the kill: LONG SHOT (45 m or more away,
// 100), MELEE KILL (the last blow was a swing, 120), GRENADE DOUBLE (two kills in one blast, 200), MULTI-KILL (three kills inside 1.5 s, 150) and
// UNTOUCHED (30 s with no damage and at least one kill in them, 100, again every 30 s). The last blow on a body is marked where it lands (blow m,
// x or g and blowT on the body; the swing, the frag blast and the round), so a kill is read as it is credited. Each bonus is a short MEDAL: its
// name and the figure in a small plate that rises over the ring for 1.7 s, with a short note of its own (no voice). Nothing here draws from the
// seeded stream, nothing runs under G.sim, and the P2 window scores its own kills the same way (a mirror body carries no mark, so it scores the
// range, the burst and the calm).
var STY={long:100,longM:45,melee:120,gren:200,grenT:0.5,multi:150,multiN:3,multiT:1.5,calm:100,calmT:30,pop:1.7,max:3,fresh:1.5};
var STY_SND={
  'LONG SHOT':[[0,1568,1568,0.34,'sine',0.05],[0,2349,2349,0.2,'sine',0.014]],
  'MELEE KILL':[[0,150,70,0.16,'square',0.05],[0.05,660,660,0.18,'triangle',0.04]],
  'GRENADE DOUBLE':[[0,523,523,0.12,'triangle',0.05],[0.07,659,659,0.12,'triangle',0.05],[0.14,784,784,0.3,'triangle',0.05]],
  'MULTI-KILL':[[0,784,784,0.1,'triangle',0.05],[0.06,988,988,0.1,'triangle',0.05],[0.12,1175,1175,0.1,'triangle',0.05],[0.18,1568,1568,0.34,'triangle',0.05]],
  'UNTOUCHED':[[0,392,392,0.5,'sine',0.04],[0,494,494,0.5,'sine',0.03],[0,587,587,0.5,'sine',0.03]]
};
function styS(){ if(!G.sty) G.sty={pops:[],kt:[],gT:-9,gN:0,calmAt:STY.calmT,calmK:0,hp0:-1}; return G.sty; }
function styStreak(){ return (G&&G.career&&G.cs)?G.cs.streak:((typeof ARCADE==='object'&&ARCADE)?ARCADE.streak:null); }
// a short note on the sting bus: [start s, from Hz, to Hz, seconds, wave, peak level]
function styTone(notes){
  var a, t, out, i, n, o, g;
  if(!G||G.sim||!notes) return false;
  if(typeof NET==='object'&&NET&&NET.specTick) return false;
  try{
    a=ac(); if(!a) return false;
    out=sndBus('sting'); if(!out) return false;
    t=a.currentTime;
    for(i=0;i<notes.length;i++){
      n=notes[i]; o=a.createOscillator(); g=a.createGain(); o.type=n[4];
      o.frequency.setValueAtTime(n[1],t+n[0]); if(n[2]!==n[1]) o.frequency.exponentialRampToValueAtTime(n[2],t+n[0]+n[3]);
      g.gain.setValueAtTime(0.0001,t+n[0]); g.gain.linearRampToValueAtTime(n[5],t+n[0]+0.008); g.gain.exponentialRampToValueAtTime(0.0005,t+n[0]+n[3]);
      o.connect(g); g.connect(out); o.start(t+n[0]); o.stop(t+n[0]+n[3]+0.02);
    }
  }catch(_st){ return false; }
  return true;
}
// one medal: the figure into the score, the plate over the cursor ring, the note. Returns the figure paid.
function styMedal(txt,pts,x,y){
  var S=styS();
  if(!scoreBonus(pts,x,y-12,'')) return 0;
  S.pops.push({txt:txt,pts:pts,t:+G.t||0});
  if(S.pops.length>8) S.pops.shift();
  try{ styTone(STY_SND[txt]); }catch(_sn){}
  return pts;
}
// a kill was credited (the DEMO door and the CAREER door, the host and a partner each their own). e is the body, when there is one.
function styleKill(k,el,boss,x,y,e){
  var S, t, p, d, fresh, bl, paid=0;
  if(!G||G.sim||G.over||!G.player||!(G.arcade||G.career)) return 0;
  S=styS(); t=+G.t||0; p=G.player; S.calmK++;
  if(!isFinite(x)||!isFinite(y)){ x=p.x; y=p.y; }
  bl=e&&e.blow; fresh=!!(e&&typeof e.blowT==='number'&&t-e.blowT<STY.fresh&&t>=e.blowT);
  if(bl==='m'&&fresh) paid+=styMedal('MELEE KILL',STY.melee,x,y);
  else if(bl==='g'&&fresh){ d=metres(Math.hypot(x-p.x,y-p.y)); if(d>=STY.longM) paid+=styMedal('LONG SHOT',STY.long,x,y); }
  if(bl==='x'&&fresh){
    if(t-S.gT<STY.grenT&&t>=S.gT) S.gN++; else S.gN=1;
    S.gT=t;
    if(S.gN===2) paid+=styMedal('GRENADE DOUBLE',STY.gren,x,y);
  }
  S.kt.push(t); while(S.kt.length&&t-S.kt[0]>STY.multiT) S.kt.shift();
  if(S.kt.length>=STY.multiN){ paid+=styMedal('MULTI-KILL',STY.multi,x,y); S.kt.length=0; }
  return paid;
}
// every step of the player: the calm clock (damage is read off health and armour, so a dodged round does not count) and the old plates
function styleTick(p,dt){
  var S, t, hp, i;
  if(!G||G.sim||G.over||!p||!(G.arcade||G.career)||!(dt>0)) return;
  S=styS(); t=+G.t||0; hp=(+p.hp||0)+(+p.armor||0);
  if(S.hp0>=0&&hp<S.hp0-0.001){ S.calmAt=t+STY.calmT; S.calmK=0; }
  S.hp0=hp;
  if(t>=S.calmAt){
    if(S.calmK>0&&!p.downed&&!p.dying) styMedal('UNTOUCHED',STY.calm,p.x,p.y-30);
    S.calmAt+=STY.calmT; if(S.calmAt<=t) S.calmAt=t+STY.calmT;
    S.calmK=0;
  }
  for(i=S.pops.length-1;i>=0;i--) if(t-S.pops[i].t>STY.pop+0.5||t<S.pops[i].t) S.pops.splice(i,1);
}
// the ring and the medal plates, at the cursor (rx, ry are the cursor on the HUD canvas)
function styleDraw(c,p,rx,ry){
  var S=G&&G.sty, z, xs, r, s, f, mx, t, col, i, n, pp, age, a, y, str, tw, hh;
  if(!G||G.sim||!(G.arcade||G.career)||!isFinite(rx)||!isFinite(ry)) return;
  t=+G.t||0; z=Math.max(1,hudRes()); xs=xhSize();
  r=(8+7+4+10)*z*xs+bloomPx(p)*z*xs;
  s=styStreak();
  c.save();
  if(s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){
    f=1-(t-s.t)/ARCADE_STREAK_GAP; mx=arcadeStreakX(s.n);
    col=(mx>=4)?'255,96,58':((mx>=3)?'255,150,60':'255,192,74');
    c.lineCap='round'; c.lineWidth=3.2*z;
    c.strokeStyle='rgba('+col+',.2)'; c.beginPath(); c.arc(rx,ry,r,0,6.2832); c.stroke();
    c.strokeStyle='rgba('+col+',.95)'; c.beginPath(); c.arc(rx,ry,r,-1.5708,-1.5708+6.2832*f); c.stroke();
    c.font=hudFS(TYPE.micro); c.textAlign='left'; c.fillStyle='rgba('+col+',1)';
    hudText('x'+mx,Math.round(rx+r+7*z),Math.round(ry+4*z));
  }
  if(S&&S.pops&&S.pops.length){
    c.font=hudFS(TYPE.label); c.textAlign='center'; n=0;
    for(i=S.pops.length-1;i>=0&&n<STY.max;i--){
      pp=S.pops[i]; age=t-pp.t; if(age<0||age>STY.pop) continue;
      a=Math.min(1,age/0.12)*Math.min(1,(STY.pop-age)/0.4);
      y=ry-r-(14+n*24)*z-Math.min(age,0.5)*22*z;
      str=pp.txt+'  +'+arcadeCr(pp.pts); tw=c.measureText(str).width; hh=20*z;
      c.globalAlpha=0.78*a; c.fillStyle='rgba(12,14,18,1)'; c.fillRect(Math.round(rx-tw/2-9*z),Math.round(y-hh*0.72),Math.round(tw+18*z),Math.round(hh));
      c.globalAlpha=a; c.fillStyle='rgba(255,192,74,1)'; c.fillRect(Math.round(rx-tw/2-9*z),Math.round(y-hh*0.72),Math.round(3*z),Math.round(hh));
      c.fillStyle='rgba(255,236,196,1)'; hudText(str,Math.round(rx),Math.round(y));
      n++;
    }
  }
  c.restore();
}
// PARTY-MODULE-END (the next party builds add their code above this line)
// The score changed: tell the other window now, or on the next flush inside the 250 ms limit. ev x (with n) is an extraction.
'@

SubRx @'
  bloomTick(p,dt);   // v26.xx (feel19): how loose the aim is right now
'@ @'
  bloomTick(p,dt);   // v26.xx (feel19): how loose the aim is right now
  try{ styleTick(p,dt); }catch(_sty){}   // v26.xx (party1): the calm clock and the medal plates
'@

SubRx @'
xhDot(ctx,rx0,ry0,rState,rCol,_rz);
'@ @'
xhDot(ctx,rx0,ry0,rState,rCol,_rz);
    try{ styleDraw(ctx,p,rx0,ry0); }catch(_sdw){}   // v26.xx (party1): the combo ring and the medal plates
'@

SubRx @'
var VER='26.83';
'@ @'
var VER='26.84';
'@

$pat = "(?m)^  now:'v26\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.84: Kills now earn style bonuses and medals, and a combo ring drains around the cursor. Check 26.84 fails on v26.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
