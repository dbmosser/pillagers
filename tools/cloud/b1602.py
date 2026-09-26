from gen import patch, fixture
patch(1602, [
("""  G.wxTurnsLeft--;""",
"""  G.wxTurnsLeft--;
  // v16.02, weather audit finding 10: PARTLY CLOUDY DOES NOT HOLD. A turn INTO partly with no turn left said This will not hold
  // and then held to extraction, since the rain-or-storm break above runs only when partly is the current sky. Partly exists to
  // turn, so a turn into it keeps one turn back for that break. No draw is added here; the break draws as it always has.
  if(nw.id==='partly'&&G.wxTurnsLeft<1) G.wxTurnsLeft=1;"""),
], "PARTLY CLOUDY DOES NOT HOLD. Weather audit finding 10. A weather turn into Partly Cloudy said This will not hold, and when it was the last turn of the raid it held to extraction. A turn into partly now keeps one turn back, so the rain or storm break it announces still comes. No number moved and map building is untouched. Check 16.02 fails on v16.01",
"# PARTLY CLOUDY DOES NOT HOLD. Weather audit finding 10 (audit-wwhovd0n0.json), its own fix.\n")
fixture(1602, r"""  {v:'16.02',what:'partly cloudy does not hold: a weather turn into Partly Cloudy on the last turn of a raid keeps one turn back for the break it announces; control, a last turn into rain leaves none',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof wxTick!=='function'||typeof pickWeather!=='function'||typeof WEATHER==='undefined') return 'SKIP: this fixture cannot stage the weather';
     var bad=[], oPick=pickWeather, keepPick=P.wxPick, W0=null, WP=null, WR=null, i, r;
     for(i=0;i<WEATHER.length;i++){ if(WEATHER[i].id==='clear') W0=WEATHER[i]; if(WEATHER[i].id==='partly') WP=WEATHER[i]; if(WEATHER[i].id==='rain') WR=WEATHER[i]; }
     if(!W0||!WP||!WR) return 'SKIP: this build has no clear, partly or rain sky';
     function turn(to){
       pickWeather=function(){ return to; };
       G.wx=W0; G.wxNext=null; G.wxT=0; G.wxTurnsLeft=1; G.wxAt=0; G.over=false;
       wxTick(0.05);
       return {next:G.wxNext?G.wxNext.id:null,left:G.wxTurnsLeft};
     }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); P.wxPick='any';
       if(!G) return 'SKIP: no raid staged';
       G.sim=1;
       r=turn(WR);
       if(r.next!=='rain'||r.left!==0) bad.push('control: the last turn into rain gave next '+r.next+' with '+r.left+' turns left');
       r=turn(WP);
       if(r.next!=='partly') bad.push('the staged turn did not go into partly (next '+r.next+')');
       else if(r.left<1) bad.push('the last turn went into Partly Cloudy, which says This will not hold, with '+r.left+' turns left, so it holds to extraction');
     }
     finally{
       try{ pickWeather=oPick; }catch(_pw){}
       try{ P.wxPick=keepPick; }catch(_wp){}
       try{ G=null; keys={}; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
