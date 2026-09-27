from gen import patch, fixture
patch(1625, [
("""  p.hp-=amt;""",
"""  p.hp-=amt;
  if(NET.on&&!G.sim&&amt>0.5&&CFG.dmgNumbers!==0){ try{ netFxDmg(p.x,p.y-26,Math.round(amt),'#ff5a4a',p.hp<=0); }catch(_nfd){} }   // v16.25, his note: your teammate sees the damage you take, in red, over you"""),
], "YOUR TEAMMATE SEES THE DAMAGE YOU TAKE. His note. In co-op every hit that gets through your armour shows on your teammate screen as a red number over you. No number moved. Check 16.25 fails on v16.24",
"# YOUR TEAMMATE SEES THE DAMAGE YOU TAKE. His note of 2026-09-27.\n")
fixture(1625, r"""  {v:'16.25',what:'your teammate sees the damage you take: a hit on this player in a shared raid sends a red damage number to the party; alone nothing is sent',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof damagePlayer!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, sent=[], p;
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); G.sim=0; G.over=false; p=G.player; p.armor=0; p.hp=p.maxhp; p.iv=0;
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[{state:'in',seat:1,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       damagePlayer(12,'crawler','CRAWLER',p.x+50,p.y);
       var d=sent.filter(function(m){ return m.t==='fx'&&m.k==='d'; });
       if(!d.length) bad.push('a hit on this player in a shared raid sent no damage number to the party');
       else if(d[0].d[3]!=='#ff5a4a') bad.push('the damage number for a hit taken is not red ('+d[0].d[3]+')');
     }
     finally{
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
