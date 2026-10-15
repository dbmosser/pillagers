param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-exp4.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
# EXPERIMENTAL, the score builds: style medals and the combo ring, the power-ups, the team combo
Add "  // XF_ROWS_END" @'
  ['xfStyle','STYLE MEDALS','Style bonuses, medals and the combo ring at the cursor.','w'],
  ['xfPwr','POWER-UPS','Kills drop timed power-ups.','w'],
  ['xfTeam','TEAM COMBO','Kills by both players close together build a team multiplier. Two player DEMO.','w'],
  // XF_ROWS_END
'@.Replace("`r",'').TrimEnd("`n")
# style medals: the kill medals, the calm medal, the ring
Add "function styleKill(k,el,boss,x,y,e){`n  var S, t, p, d, fresh, bl, paid=0;`n  if(!G||G.sim||G.over||!G.player||!(G.arcade||G.career)) return 0;" "function styleKill(k,el,boss,x,y,e){`n  var S, t, p, d, fresh, bl, paid=0;`n  if(!G||G.sim||G.over||!G.player||!(G.arcade||G.career)) return 0;`n  if(!xf('xfStyle')) return 0;   // v27.xx (exp4): STYLE MEDALS is switched off in EXPERIMENTAL: no medal is paid"
Add "  if(t>=S.calmAt){`n    if(S.calmK>0&&!p.downed&&!p.dying) styMedal('UNTOUCHED',STY.calm,p.x,p.y-30);" "  if(xf('xfStyle')&&t>=S.calmAt){   // v27.xx (exp4): the calm medal is part of STYLE MEDALS`n    if(S.calmK>0&&!p.downed&&!p.dying) styMedal('UNTOUCHED',STY.calm,p.x,p.y-30);"
Add "  if(s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){`n    f=1-(t-s.t)/ARCADE_STREAK_GAP; mx=arcadeStreakX(s.n);" "  if(xf('xfStyle')&&s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){   // v27.xx (exp4): the combo ring is part of STYLE MEDALS`n    f=1-(t-s.t)/ARCADE_STREAK_GAP; mx=arcadeStreakX(s.n);"
# power-ups
Add "  if(!G||G.sim||G.over||!G.player||!(G.arcade||G.career)) return 0;`n  S=pwrS(); t=+G.t||0; p=G.player; n=S.kn++; S.since++;" "  if(!G||G.sim||G.over||!G.player||!(G.arcade||G.career)) return 0;`n  if(!xf('xfPwr')) return 0;   // v27.xx (exp4): POWER-UPS is switched off in EXPERIMENTAL: no kill drops one`n  S=pwrS(); t=+G.t||0; p=G.player; n=S.kn++; S.since++;"
# team combo
Add "function teamKill(x,y){`n  var now=Date.now(), mk, T, n, p, paid=0, lk=0;" "function teamKill(x,y){`n  var now=Date.now(), mk, T, n, p, paid=0, lk=0;`n  if(!xf('xfTeam')) return 0;   // v27.xx (exp4): TEAM COMBO is switched off in EXPERIMENTAL: no pairing, and no kill word is sent"
Add "function arcadeTeamTake(m){`n  var now=Date.now();" "function arcadeTeamTake(m){`n  var now=Date.now();`n  if(!xf('xfTeam')) return 'ignored';   // v27.xx (exp4)"
Add "function teamDraw(c,p,rx,ry){`n  var T, f, z, xs, r, col='95,245,228';" "function teamDraw(c,p,rx,ry){`n  var T, f, z, xs, r, col='95,245,228';`n  if(!xf('xfTeam')) return;   // v27.xx (exp4)"
$chk=@'
  {v:'VER',what:'his order (EXPERIMENTAL settings, exp4): style medals, power-ups and the team combo each have a row, and with one off a raid started that way pays no medal, drops no power-up, or pairs no team kill, while the others still work',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof styleKill!=='function'||typeof pwrKill!=='function'||typeof teamKill!=='function') return 'SKIP: this build lacks one of the three score systems';
     if(typeof XF_ROWS==='undefined') return 'there is no EXPERIMENTAL table in this build';
     var KEYS=['xfStyle','xfPwr','xfTeam'], bad=[], on, off, soloKeep=null;
     function arm(offKey){
       KEYS.forEach(function(k){ CFG[k]=1; }); if(offKey) CFG[offKey]=0;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return null;
       var g=__state(), p, r;
       if(!g||!g.player) return null;
       p=g.player; g.t=10;
       soloKeep=ARCADE.solo; ARCADE.solo=false; ARCADE.mk={x:p.x,y:p.y,at:Date.now(),used:0};
       r={style:styleKill('crawler',false,false,p.x,p.y,{blow:'m',blowT:g.t})|0, pwr:pwrKill('crawler',false,true,p.x+30,p.y,{})|0, team:teamKill(p.x,p.y)|0};
       ARCADE.solo=soloKeep; ARCADE.mk=null;
       __endRaid('abandon'); __topClear();
       return r;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       openSettings(); KEYS.forEach(function(k){ if(!document.getElementById('go_'+k)) bad.push('no row for '+k); }); __topClear();
       on=arm(null); if(!on) return bad.length?bad.join('; '):'SKIP: arcadeDeploy built no raid';
       if(!on.style) bad.push('control: with everything on a melee kill paid no medal');
       if(!on.pwr) bad.push('control: with everything on a boss kill dropped no power-up');
       if(!on.team) bad.push('control: with everything on a paired kill paid no team combo');
       if(bad.length) return bad.join('; ');
       off=arm('xfStyle'); if(!off||off.style) bad.push('STYLE MEDALS off still paid a medal'); else if(!off.pwr||!off.team) bad.push('STYLE MEDALS off took the power-ups or the team combo with it');
       off=arm('xfPwr'); if(!off||off.pwr) bad.push('POWER-UPS off still dropped one'); else if(!off.style||!off.team) bad.push('POWER-UPS off took the medals or the team combo with it');
       off=arm('xfTeam'); if(!off||off.team) bad.push('TEAM COMBO off still paired a kill'); else if(!off.style||!off.pwr) bad.push('TEAM COMBO off took the medals or the power-ups with it');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(soloKeep!==null) ARCADE.solo=soloKeep; ARCADE.mk=null; }catch(_a){}
       try{ __endRaid('abandon'); }catch(_e){}
       try{ __resetCfg(); xfSnap(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     } }},
'@
Draft 'EXPERIMENTAL: MEDALS, POWER-UPS, TEAM COMBO' 'His order: an experimental menu where he can turn the new features on and off. The score builds each get a switch in the EXPERIMENTAL section: style medals with the combo ring, the power-ups, and the team combo. A raid started with one off pays no medal, drops no power-up, or pairs no team kill, and the other two work as before. On is the default.' 'Style medals, power-ups and the team combo each have a switch in EXPERIMENTAL.' $chk
