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

# beast mode replaces kill streak rewards (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ANNC={busy:-1,n:0,last:''}, ANN_STREAK={'DOUBLE KILL':'DOUBLEKILL','TRIPLE KILL':'TRIPLEKILL','MULTI KILL':'MULTIKILL','RAMPAGE':'RAMPAGE','UNSTOPPABLE':'UNSTOPPABLE'};
'@ @'
var ANNC={busy:-1,n:0,last:''};
'@

SubRx @'
var SPK_MEDALS={'DOUBLE KILL':1,'TRIPLE KILL':2,'MULTI KILL':3,'RAMPAGE':4,'UNSTOPPABLE':5,DOUBLEKILL:1,TRIPLEKILL:2,MULTIKILL:3,'LONG SHOT':1,'MELEE KILL':1,'UNTOUCHED':2,'GRENADE DOUBLE':2,'MULTI-KILL':3};
'@ @'
var SPK_MEDALS={'LONG SHOT':1,'MELEE KILL':1,'UNTOUCHED':2};
'@

SubRx @'
var FEEDMEDALS=/^(DOUBLE KILL|TRIPLE KILL|MULTI KILL|MULTI-KILL|RAMPAGE|UNSTOPPABLE|NEW HIGH SCORE)/;
'@ @'
var FEEDMEDALS=/^(NEW HIGH SCORE)/;
'@

SubRx @'
// v28.xx (cw-chaintick), HIS YES (100 picks, 72 "pitch-climbing kill chain", replacing the announcer with sounds that are not words): every kill that CHAINS
// (the second kill inside the streak gap, the existing chain) plays one small soft tick, a sine pluck, a note higher than the one before on an E minor
// pentatonic (E5 G5 A5 B5 D6 E6 G6 A6, the key of the medal pops). The chain breaking starts the count again, because the step is read from the
// streak count itself (the second kill is step 0). Past the eighth step it holds the top note. On the sting bus, so nothing ducks it, and each tick
// is only a few thousandths of full scale (0.06 plus a 0.012 octave), under a medal pop (0.22). Cosmetic: no game state, no seeded draw.
var CHAIN_NOTES=[659.3,784,880,987.8,1174.7,1318.5,1568,1760];
function chainTickStep(n){ n=n|0; return (n>=2)?Math.min(CHAIN_NOTES.length-1,n-2):-1; }
function chainTickPlay(n){
  var s=chainTickStep(n);
  if(s<0) return '';
  try{ blip('chainTick'+s); }catch(_ct){}
  return 'chainTick'+s;
}
(function(){
  var i;
  for(i=0;i<CHAIN_NOTES.length;i++){
    (function(step){
      var nm='chainTick'+step, f=CHAIN_NOTES[step];
      SPK_CAT[nm]='sting';
      SPK_INFO[nm]={grp:'medals',lab:'KILL CHAIN tick '+(step+1)+' of '+CHAIN_NOTES.length,len:0.14,kind:'synth',uses:[]};
      SPK_GEN[nm]=function(a,OUT,vol,t){
        var M, o;
        if(!spkGate('chainTick',0.04,t)) return null;
        M=spkMaster(a,OUT,vol,t);
        o=spkOsc(a,M,{ty:'sine',f0:f,dur:0.1,g:0.06,at:t,atk:0.002});
        spkOsc(a,M,{ty:'triangle',f0:f*2,dur:0.05,g:0.012,lp:3600,at:t,atk:0.002});
        return spkH(M,o,t+0.14);
      };
    })(i);
  }
})();

'@ @'
// v28.xx (cw-cx-nokillstreak), HIS WORDS (2026-10-28): "beast mode replaces all that".

'@

SubRx @'
// v23.38, HIS ORDER (2026-10-11), build 15 of 20 (arcade15): POPUPS AND STREAKS. A walk-up player should see every kill pay. Each
// credited kill now puts its points (+50, +100...) up as a popup over the body, and kills less than 4 s apart (game time) chain
// into a streak that multiplies the award: 2 in a row x2 (DOUBLE KILL), 3 x3 (TRIPLE KILL), 4 x3 (MULTI KILL), 5 to 7 x4
// (RAMPAGE), 8 and up x5 (UNSTOPPABLE). The callout is said once as the chain reaches its row, in the ext lane (the alert slot),
// with the multiplier as its detail. An elite still counts twice before the multiplier. While a streak of 2 or more is live its
// multiplier shows as a badge beside TEAM SCORE. The streak belongs to this window and starts again with every arcade drop.
// Only arcade raids reach arcadeKill, so a normal raid is unchanged.
var ARCADE_STREAK_GAP=4;
var ARCADE_STREAK=[[8,5,'UNSTOPPABLE'],[5,4,'RAMPAGE'],[4,3,'MULTI KILL'],[3,3,'TRIPLE KILL'],[2,2,'DOUBLE KILL']];
function arcadeStreakX(n){ var i; for(i=0;i<ARCADE_STREAK.length;i++) if(n>=ARCADE_STREAK[i][0]) return ARCADE_STREAK[i][1]; return 1; }
function arcadeStreakCall(n){ var i; for(i=0;i<ARCADE_STREAK.length;i++) if(n===ARCADE_STREAK[i][0]) return ARCADE_STREAK[i][2]; return ''; }
// the multiplier the badge shows now: 1 when no streak of 2 or more is live
function arcadeStreakLive(){
  var s=(G&&G.career&&G.cs)?G.cs.streak:ARCADE.streak, t=(G&&+G.t)||0;   // v24.xx (feat0h2): a CAREER raid keeps its own streak
  if(!s||!(s.n>=2)||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) return 1;
  return arcadeStreakX(s.n);
}

'@ @'
// v28.xx (cw-cx-nokillstreak), HIS WORDS (2026-10-28): "beast mode replaces all that".
// v28.xx (cw-cx-nokillstreak): kills keep their base score and kill-feed figure; no score chain.

'@

SubRx @'
function scoreKill(st,k,el,boss,x,y){
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)||!st) return 0;
  s=st.streak;
  if(!s||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) s=st.streak={n:0,t:t};
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
  // v28.xx (cw-cx-hotkill): his 10-28 decision, "should just be 1.05", after the streak in either window.
  var hot=G.hotZone&&Number.isFinite(x)&&Number.isFinite(y)&&Math.hypot(x-G.hotZone.x,y-G.hotZone.y)<=G.hotZone.r;
  if(hot) n=Math.round(n*HOT_KILLX);
  try{ feedKillSp('+'+arcadeCr(n)+(hot?' hot':'')); }catch(_alb){}   // v35.xx (cw-clockcard): on the kill line only
  c=arcadeStreakCall(s.n);
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak is a medal pop that climbs, DOUBLE KILL medal1 to UNSTOPPABLE medal5
  try{ chainTickPlay(s.n); }catch(_ctk){}   // v28.xx (cw-chaintick): a rising tick for each kill in the chain
  return n;
}
'@ @'
function scoreKill(st,k,el,boss,x,y){
  var n=arcadeKillPts(k,el,boss);
  if(!(n>0)||!st) return 0;
  // v28.xx (cw-cx-nokillstreak), HIS WORDS (2026-10-28): "beast mode replaces all that".
  // v28.xx (cw-cx-hotkill): his 10-28 decision, "should just be 1.05", in either window.
  var hot=G.hotZone&&Number.isFinite(x)&&Number.isFinite(y)&&Math.hypot(x-G.hotZone.x,y-G.hotZone.y)<=G.hotZone.r;
  if(hot) n=Math.round(n*HOT_KILLX);
  try{ feedKillSp('+'+arcadeCr(n)+(hot?' hot':'')); }catch(_alb){}   // v35.xx (cw-clockcard): on the kill line only
  return n;
}
'@

SubRx @'
function arcadeKill(k,el,boss,x,y,ke){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  try{ flowKill(k,el,boss); }catch(_fk1){}   // v26.xx (flow3): the run goals count what died
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)) return 0;
  s=ARCADE.streak;   // v23.38 (arcade15): the chain, the multiplier, the popup and the callout
  if(!s||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) s=ARCADE.streak={n:0,t:t};
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
  // v28.xx (cw-cx-hotkill): his 10-28 decision, "should just be 1.05", after the streak in either window.
  var hot=G.hotZone&&Number.isFinite(x)&&Number.isFinite(y)&&Math.hypot(x-G.hotZone.x,y-G.hotZone.y)<=G.hotZone.r;
  if(hot) n=Math.round(n*HOT_KILLX);
  if(arcadeRushOn()) n=Math.round(n*1.05);   // v28.xx (cw-cx-finalrush): kill SP only, after streak and hot ground, in either window.
  try{ arcadeBmKill(s.n,x,y); }catch(_bmk){}   // v23.xx (his answer 20): the best streak and the longest shot
  try{ feedKillSp('+'+arcadeCr(n)+(hot?' hot':'')); }catch(_alb){}   // v35.xx (cw-clockcard): on the kill line only (v23.56, arcade31, was a float over the body)
  c=arcadeStreakCall(s.n);
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak plays a medal pop that climbs (it was a chime ladder)
  try{ chainTickPlay(s.n); }catch(_ctk){}   // v28.xx (cw-chaintick): a rising tick for each kill in the chain
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.kills=(ARCADE.kills|0)+1;
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk){}   // v26.xx (party1): the style bonuses and medals
  try{ pwrKill(k,el,boss,x,y,ke); }catch(_pk){}   // v26.xx (party2): a kill may drop a power-up
  try{ teamKill(x,y); }catch(_tk){}   // v26.xx (party4): a kill within 2 s and a short way of the partner's builds the TEAM combo
  arcadeKillPerks();   // v23.31 (arcade10): half a magazine back, a Bandage every 3rd kill
  arcadeScSend();
  return n;
}
'@ @'
function arcadeKill(k,el,boss,x,y,ke){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  try{ flowKill(k,el,boss); }catch(_fk1){}   // v26.xx (flow3): the run goals count what died
  var n=arcadeKillPts(k,el,boss);
  if(!(n>0)) return 0;
  // v28.xx (cw-cx-nokillstreak), HIS WORDS (2026-10-28): "beast mode replaces all that".
  // v28.xx (cw-cx-hotkill): his 10-28 decision, "should just be 1.05", in either window.
  var hot=G.hotZone&&Number.isFinite(x)&&Number.isFinite(y)&&Math.hypot(x-G.hotZone.x,y-G.hotZone.y)<=G.hotZone.r;
  if(hot) n=Math.round(n*HOT_KILLX);
  if(arcadeRushOn()) n=Math.round(n*1.05);   // v28.xx (cw-cx-finalrush): kill SP only, after hot ground, in either window.
  try{ arcadeBmKill(0,x,y); }catch(_bmk){}   // v23.xx (his answer 20): the longest shot
  try{ feedKillSp('+'+arcadeCr(n)+(hot?' hot':'')); }catch(_alb){}   // v35.xx (cw-clockcard): on the kill line only (v23.56, arcade31, was a float over the body)
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.kills=(ARCADE.kills|0)+1;
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk){}   // v26.xx (party1): the style bonuses and medals
  try{ pwrKill(k,el,boss,x,y,ke); }catch(_pk){}   // v26.xx (party2): a kill may drop a power-up
  try{ teamKill(x,y); }catch(_tk){}   // v26.xx (party4): a kill within 2 s and a short way of the partner's builds the TEAM combo
  arcadeKillPerks();   // v23.31 (arcade10): half a magazine back, a Bandage every 3rd kill
  arcadeScSend();
  return n;
}
'@

SubRx @'
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

'@ @'
// v28.xx (cw-cx-nokillstreak), HIS WORDS (2026-10-28): "beast mode replaces all that".
// v28.xx (cw-cx-nokillstreak): long shot, melee kill and untouched keep their medals and bonuses.

'@

SubRx @'
var STY={long:100,longM:45,melee:120,gren:200,grenT:0.5,multi:150,multiN:3,multiT:1.5,calm:100,calmT:30,pop:4.2,max:3,fresh:1.5};   // v27.38 (partyp1): a medal stays up 4.2 s, not 1.7
'@ @'
var STY={long:100,longM:45,melee:120,calm:100,calmT:30,pop:4.2,max:3,fresh:1.5};   // v27.38 (partyp1): a medal stays up 4.2 s, not 1.7
'@

SubRx @'
var STY_SND={
  'LONG SHOT':[[0,1568,1568,0.34,'sine',0.05],[0,2349,2349,0.2,'sine',0.014]],
  'MELEE KILL':[[0,150,70,0.16,'square',0.05],[0.05,660,660,0.18,'triangle',0.04]],
  'GRENADE DOUBLE':[[0,523,523,0.12,'triangle',0.05],[0.07,659,659,0.12,'triangle',0.05],[0.14,784,784,0.3,'triangle',0.05]],
  'MULTI-KILL':[[0,784,784,0.1,'triangle',0.05],[0.06,988,988,0.1,'triangle',0.05],[0.12,1175,1175,0.1,'triangle',0.05],[0.18,1568,1568,0.34,'triangle',0.05]],
  'UNTOUCHED':[[0,392,392,0.5,'sine',0.04],[0,494,494,0.5,'sine',0.03],[0,587,587,0.5,'sine',0.03]]
};
'@ @'
var STY_SND={
  'LONG SHOT':[[0,1568,1568,0.34,'sine',0.05],[0,2349,2349,0.2,'sine',0.014]],
  'MELEE KILL':[[0,150,70,0.16,'square',0.05],[0.05,660,660,0.18,'triangle',0.04]],
  'UNTOUCHED':[[0,392,392,0.5,'sine',0.04],[0,494,494,0.5,'sine',0.03],[0,587,587,0.5,'sine',0.03]]
};
'@

SubRx @'
var STY_ICON={
  'LONG SHOT':'M12 4a8 8 0 1 0 0 16a8 8 0 1 0 0-16zM12 1v6M12 17v6M1 12h6M17 12h6M12 11.2a.8.8 0 1 0 0 1.6a.8.8 0 1 0 0-1.6z',
  'MELEE KILL':'M20 3.5L10.5 13M5.5 12l6.5 6.5M9 15L3.5 20.5M14 21a9 9 0 0 0 7.5-8',
  'GRENADE DOUBLE':'M12 8.5a5.2 6.3 0 1 0 0 12.6a5.2 6.3 0 1 0 0-12.6zM10 8.5V5.5h4v3M14 6l4.6-1.9M7.2 14.8h9.6M19.6 3a1.4 1.4 0 1 0 0 2.8a1.4 1.4 0 1 0 0-2.8z',
  'MULTI-KILL':'M12 3a8 8 0 0 0-8 8c0 3 1.5 4.8 3 5.8V20h10v-3.2c1.5-1 3-2.8 3-5.8a8 8 0 0 0-8-8zM9 11h1M14 11h1M10 20v-2M14 20v-2M8 22.6h2M11 22.6h2M14 22.6h2',
  'UNTOUCHED':'M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6zM8.5 12l2.5 2.5L16 9.5',
  'SCREEN CLEAR':'M12 9.5a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1',
  'TEAM COMBO':'M9 8a3 3 0 1 0 0 6a3 3 0 1 0 0-6zM17 9a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM3 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4'
};
'@ @'
var STY_ICON={
  'LONG SHOT':'M12 4a8 8 0 1 0 0 16a8 8 0 1 0 0-16zM12 1v6M12 17v6M1 12h6M17 12h6M12 11.2a.8.8 0 1 0 0 1.6a.8.8 0 1 0 0-1.6z',
  'MELEE KILL':'M20 3.5L10.5 13M5.5 12l6.5 6.5M9 15L3.5 20.5M14 21a9 9 0 0 0 7.5-8',
  'UNTOUCHED':'M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6zM8.5 12l2.5 2.5L16 9.5',
  'SCREEN CLEAR':'M12 9.5a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1',
  'TEAM COMBO':'M9 8a3 3 0 1 0 0 6a3 3 0 1 0 0-6zM17 9a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM3 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4'
};
'@

SubRx @'
var STY_TIER={'MELEE KILL':1,'LONG SHOT':2,'UNTOUCHED':2,'MULTI-KILL':2,'TEAM COMBO':2,'GRENADE DOUBLE':3,'SCREEN CLEAR':3};
'@ @'
var STY_TIER={'MELEE KILL':1,'LONG SHOT':2,'UNTOUCHED':2,'TEAM COMBO':2,'SCREEN CLEAR':3};
'@

SubRx @'
function styleKill(k,el,boss,x,y,e){
  var S, t, p, d, fresh, bl, paid=0;
  if(!xf('xfStyle')) return 0;   // v32.xx (cw-expmenu3): switched off, no style medals are paid
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
'@ @'
function styleKill(k,el,boss,x,y,e){
  var S, t, p, d, fresh, bl, paid=0;
  if(!xf('xfStyle')) return 0;   // v32.xx (cw-expmenu3): switched off, no style medals are paid
  if(!G||G.sim||G.over||!G.player||!(G.arcade||G.career)) return 0;
  S=styS(); t=+G.t||0; p=G.player; S.calmK++;
  if(!isFinite(x)||!isFinite(y)){ x=p.x; y=p.y; }
  bl=e&&e.blow; fresh=!!(e&&typeof e.blowT==='number'&&t-e.blowT<STY.fresh&&t>=e.blowT);
  if(bl==='m'&&fresh) paid+=styMedal('MELEE KILL',STY.melee,x,y);
  else if(bl==='g'&&fresh){ d=metres(Math.hypot(x-p.x,y-p.y)); if(d>=STY.longM) paid+=styMedal('LONG SHOT',STY.long,x,y); }
  // v28.xx (cw-cx-nokillstreak), HIS WORDS (2026-10-28): "beast mode replaces all that".
  return paid;
}
'@

SubRx @'
// v28.21 (partyp3), HIS WORDS on the combo ring (2026-10-14, the party playtest): "i didn't notice it at all, so not sure". It must be noticeable without clutter.
// The ring is bolder (STYR.w, a dark underlay behind it so it reads on a bright floor and a glow on its sweep), its multiplier is a number on a plate of its
// own (twice the old print; the x4 and x5 bigger again) beside it, and it MOVES: when the chain grows the ring flashes outward and the number pops (STYR.pulse,
// 0.4 s), and in the last 30 percent of the chain (STYR.low) the sweep shifts toward red and flickers (STYR.hz) while the number shivers, so he sees it is about to
// run out. The sweep is still the last arc drawn at the cursor. Cosmetic only.
var STYR={w:5.2,low:0.3,hz:18,pulse:0.4,flash:14,bump:0.32};
// the ring at the cursor (the medals are the row at the left edge now, styMedalDraw)
function styleDraw(c,p,rx,ry){
  var S=G&&G.sty, z, xs, r, s, f, mx, t, col, i, n, pp, age, a, y, str, tw, hh;
  if(!G||G.sim||!(G.arcade||G.career)||!isFinite(rx)||!isFinite(ry)) return;
  t=+G.t||0; z=Math.max(1,hudRes()); xs=xhSize();
  r=(8+7+4+10)*z*xs+bloomPx(p)*z*xs;
  s=styStreak();
  c.save();
  if(xf('xfStyle')&&s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){
    f=1-(t-s.t)/ARCADE_STREAK_GAP; mx=arcadeStreakX(s.n);
    // v28.21 (partyp3): the ring is bold, it carries its multiplier on a plate, it pulses when the chain grows and hurries when it is about to run out
    var gp=Math.max(0,1-(t-s.t)/STYR.pulse), lo=(f<STYR.low), fl=lo?(0.6+0.4*Math.sin(t*STYR.hz)):1, hot=lo?Math.min(1,(STYR.low-f)/STYR.low):0, cb, cs;
    cb=(mx>=4)?[255,96,58]:((mx>=3)?[255,150,60]:[255,192,74]);
    cs='255,'+Math.round(cb[1]+(70-cb[1])*hot)+','+Math.round(cb[2]+(56-cb[2])*hot);
    c.lineCap='round';
    c.lineWidth=(STYR.w+3.6)*z; c.strokeStyle='rgba(6,8,10,.5)'; c.beginPath(); c.arc(rx,ry,r,0,6.2832); c.stroke();
    c.lineWidth=STYR.w*z; c.strokeStyle='rgba('+cs+',.26)'; c.beginPath(); c.arc(rx,ry,r,0,6.2832); c.stroke();
    if(gp>0){
      c.globalCompositeOperation='lighter'; c.lineWidth=(2+5*gp)*z; c.strokeStyle='rgba(255,240,200,'+(0.85*gp).toFixed(3)+')';
      c.beginPath(); c.arc(rx,ry,r+(1-gp)*STYR.flash*z,0,6.2832); c.stroke(); c.globalCompositeOperation='source-over';
    }
    c.globalCompositeOperation='lighter'; c.lineWidth=(STYR.w+5)*z; c.strokeStyle='rgba('+cs+','+(0.2*fl).toFixed(3)+')';
    c.beginPath(); c.arc(rx,ry,r,-1.5708,-1.5708+6.2832*f); c.stroke(); c.globalCompositeOperation='source-over';
    // cw-nomult, HIS ORDER (2026-10-18): "i don't like the multiplier next to the reticule, get rid of that". The number and its plate beside the ring are gone;
    // the ring, its sweep, the flash and the flicker stay (his survey pick q17 keeps the ring at the cursor). The multiplier still shows left of the score.    c.lineWidth=STYR.w*z; c.strokeStyle='rgba('+cs+','+(0.98*fl).toFixed(3)+')'; c.beginPath(); c.arc(rx,ry,r,-1.5708,-1.5708+6.2832*f); c.stroke();
  }
  // v27.38 (partyp1): the medal plates that rose over the ring are gone; the medals are the emblem row at the left edge (styMedalDraw)
  c.restore();
}

'@ @'
// v28.xx (cw-cx-nokillstreak), HIS WORDS (2026-10-28): "beast mode replaces all that".
// v28.xx (cw-cx-nokillstreak): the former score-chain ring has no drawing pass.
function styleDraw(c,p,rx,ry){}

'@

SubRx @'
      sx=arcadeStreakLive(),w,gx,pw,bot,side=0,sw=0,apo=false;
'@ @'
      w,gx,pw,bot,side=0,apo=false;
'@

SubRx @'
  if(sx>1){ctx.font=fb;sw=ctx.measureText('x'+sx).width+Math.round(10*z);}

'@ @'

'@

SubRx @'
  pw=Math.ceil(Math.max(100*z,w/2+pad+Math.max(side,sw)));
'@ @'
  pw=Math.ceil(Math.max(100*z,w/2+pad+side));
'@

SubRx @'
  if(sx>1){ctx.font=fb;ctx.textAlign='right';ctx.fillStyle='#ffc04a';hudText('x'+sx,Math.round(cx-w/2-10*z),scoreY);}

'@ @'

'@

SubRx @'
    if(m.st&&m.st.v>=2) rows.push(['BEST STREAK',m.st.v+' KILLS',m.st.who]);

'@ @'

'@

SubRx @'
  'ARCADE PARTY. Waves come to you, kills chain into streaks, and the best runs go on the board with your initials.',
'@ @'
  'arcade party. waves come to you, quick kills build beast mode, and the best runs go on the board with your initials.',
'@

SubRx @'
  'PARTY MODE. Style medals and a combo ring, timed power-ups from kills, a TEAM combo for two, and NEW PARTY locks one seed for the night.',
'@ @'
  'party mode. style medals, beast mode, timed power-ups from kills, a team combo for two, and new party locks one seed for the night.',
'@

SubRx @'
  ['xfStyle','style medals','medals and the combo ring','w'],
'@ @'
  ['xfStyle','style medals','long shot, melee kill and untouched','w'],
'@

SubRx @'
      SPK_INFO[nm]={grp:'medals',lab:'MEDAL tier '+tier+' ('+['DOUBLE KILL','TRIPLE KILL','MULTI KILL','RAMPAGE','UNSTOPPABLE'][tier-1]+')',len:SPK_MEDL[tier-1],kind:'synth',uses:[]};
'@ @'
      SPK_INFO[nm]={grp:'medals',lab:'medal tier '+tier,len:SPK_MEDL[tier-1],kind:'synth',uses:[]};
'@

SubRx @'
// v24.xx (feat0h2), HIS MODE DESIGN AND HIS RULE (2026-10-12): "high score is still an objective" in CAREER, and the scoring is "EXACTLY
// THE SAME IN DEMO AND CAREER". THE KILL SCORE IN A CAREER RAID. The DEMO points table, streak and multiplier, +$ popup where
// the body fell and streak callout (as arcadeKill does them) are scoreKill over a CAREER score store, G.cs, in a CAREER raid
// (careerKill, from the same kill credit as the DEMO, the host and a co-op partner each scoring their own player). The DEMO newcomer
// perks (half a magazine back, a Bandage every 3rd kill) stay in the DEMO: CAREER is his own kit. The score reads at the clock as in
// the DEMO: SCORE over the figure, the streak multiplier beside it and the 10 minute clock under it.

'@ @'
// v24.xx (feat0h2), HIS MODE DESIGN AND HIS RULE (2026-10-12): "high score is still an objective" in CAREER, and the scoring is "EXACTLY
// THE SAME IN DEMO AND CAREER". THE KILL SCORE IN A CAREER RAID. The DEMO points table, +$ popup where
// the body fell are scoreKill over a CAREER score store, G.cs, in a CAREER raid
// (careerKill, from the same kill credit as the DEMO, the host and a co-op partner each scoring their own player). The DEMO newcomer
// perks (half a magazine back, a Bandage every 3rd kill) stay in the DEMO: CAREER is his own kit. The score reads at the clock as in
// the DEMO: SCORE over the figure, the 10 minute clock under it.

'@

SubRx @'
var VER='36.39';
'@ @'
var VER='36.40';
'@

$pat = "(?m)^  now:'v36\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.40: kills pay base sp without score chains, multiplier badges or kill-count medals; beast mode rewards quick kills. Check 36.40 fails on v36.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
