import os, gen
from gen import patch, fixture
patch(1645, [
("""      if(b) b.onclick=function(){ cycleGameOpt(k); renderSettings(); };""",
"""      if(b) b.onclick=function(){ var _rs0=CFG.raidSec; cycleGameOpt(k); gameOptRaidNow(_rs0); renderSettings(); };   // v16.45: a raid in hand changes at once"""),
("""      '<div class="hint">'+_gr.hint+(_gs?'':' Set by hand in the tuning console; click to put a word back on it.')+'</div></div>'+""",
"""      '<div class="hint">'+_gr.hint+(_gs?'':' Set by hand in the tuning console; click to put a word back on it.')+((G&&!G.over&&!G.sim&&(_gr.k==='raiders'||_gr.k==='robots'))?' In a raid this takes effect from the next raid.':'')+'</div></div>'+"""),
('''    <button id="resumebtn" style="padding:8px 22px">Resume run</button>''',
'''    <button id="resumebtn" style="padding:8px 22px">Resume run</button>
    <button id="pausesetbtn" style="padding:8px 22px">Settings</button>'''),
("""function abandonRepCost(el){ return Math.min(400,100+Math.round(el/10)); }""",
"""function abandonRepCost(el){ return Math.min(400,100+Math.round(el/10)); }
// v16.45, HIS ORDER: SETTINGS IN A RAID, CHANGING THE GAME IN REAL TIME. The pause box opens the same Settings window over the
// raid. Damage, loot value, extraction heat, Superhot and kid mode are read as they happen, so they change at once; the raid
// length moves the clock now, keeping the time already played (on a teammate window the host clock rules); the pillager and
// machine counts are the map as it was built and say they take effect from the next raid.
document.getElementById('pausesetbtn').onclick=function(){ openSettings(); };
function gameOptRaidNow(rs0){
  var el, nl;
  if(typeof G==='undefined'||!G||G.over||G.sim||!(G.raidLen>0)||!(rs0>0)||CFG.raidSec===rs0||!(CFG.raidSec>0)) return false;
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&netEntsPeer()) return false;
  el=elapsed();
  nl=Math.round(G.raidLen*CFG.raidSec/rs0);
  G.raidLen=nl; G.timeLeft=Math.max(30,nl-el);
  say('Raid clock changed: '+fmtMS(G.timeLeft)+' left.');
  return true;
}"""),
], "SETTINGS IN A RAID. His order: the Settings menu should be reachable in a raid and change the game in real time. The pause box has a Settings button that opens the same window over the raid. Damage, loot value, extraction heat, Superhot and kid mode already apply as they happen; the raid length now moves the clock at once, keeping the time played. The pillager and machine counts say they take effect from the next raid. Check 16.45 fails on v16.44",
"# SETTINGS IN A RAID (his order: reachable in a raid, changing the game in real time).\n")
fixture(1645, r"""  {v:'16.45',what:'settings in a raid: the pause box opens Settings, and a raid length change moves the running clock at once',
   run:function(){
     var b=document.getElementById('pausesetbtn');
     if(!b||typeof gameOptRaidNow!=='function') return 'the pause box has no way into Settings';
     var kG=G, kS=CFG.raidSec, kNet=NET.on, r, bad=[], oSay=say;
     try{
       say=function(){};
       NET.on=false;
       G={over:false,sim:false,raidLen:540,timeLeft:440,t:100};
       CFG.raidSec=900; r=gameOptRaidNow(540);
       if(!r||G.raidLen!==900||Math.abs(G.timeLeft-800)>1) bad.push('540 to 900 with 100 s played left '+G.timeLeft+' of '+G.raidLen);
       G={over:false,sim:false,raidLen:540,timeLeft:100,t:440};
       CFG.raidSec=360; gameOptRaidNow(540);
       if(G.timeLeft!==30) bad.push('shortening past the time played left '+G.timeLeft+' s, not the 30 s floor');
     } finally { G=kG; CFG.raidSec=kS; NET.on=kNet; say=oSay; }
     try{ b.click(); var m=document.getElementById('settingsmodal'); if(!m||!m.classList.contains('on')) bad.push('the Settings button did not open Settings'); if(m) m.classList.remove('on'); }catch(e){ bad.push('the Settings button threw '+e.message); }
     return bad.length?bad.join('; '):null; }},
""")
