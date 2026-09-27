from gen import patch, fixture
l1=open('/tmp/l1').read(); l2=open('/tmp/l2').read(); l3=open('/tmp/l3').read()
patch(1626, [
(l1, l1.replace("ac:Math.round(armorCap()||0)};","ac:Math.round(armorCap()||0),dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0};")),
(l2, l2.replace("g.ac=+m.ac||0; }","g.ac=+m.ac||0; g.dt=+m.dt||0; }")),
(l3, l3.replace("out.ac=g.ac; }","out.ac=g.ac; out.dt=g.dt; }")),
("""  ctx.fillText('HP  '+Math.round(p.hp),24,by+18);""",
"""  ctx.fillText('HP  '+Math.round(p.hp),24,by+18);
  try{ if(NET.on) netTeamHud(by); }catch(_nth){}   // v16.26: your teammates, their health and armour, above your own"""),
("""function netAllPaused(){""",
"""// v16.26, THE QUEUE (his order for the niceties of the genre): YOUR TEAMMATES ON THE HUD. Above your own health, bottom left, one
// row per teammate up top on the party seed: his name, a health bar and an armour bar from his state word (hp, mh, ar, ac), and
// when he is down a red DOWN with the seconds he has left to be picked up (dt). Drawing only.
function netTeamHud(by){
  var i, g, n=0, x=16, w=150, y, f, t;
  if(typeof G==='undefined'||!G||G.over) return 0;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)) continue;
    y=by-96-n*40; n++;
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(x-4,y-15,w+8,36);
    ctx.font=FS(TYPE.label); ctx.textAlign='left';
    ctx.fillStyle=g.dn?'#ff8a80':'#bfe0ff'; ctx.fillText(netSeatName(g.seat)||'PILLAGER',x,y);
    if(g.dn){ t=(g.dt>0)?(' '+g.dt+'s'):''; ctx.fillStyle='#ff5a4a'; ctx.textAlign='right'; ctx.fillText('DOWN'+t,x+w,y); ctx.textAlign='left'; }
    f=(g.mh>0)?clamp((g.hp||0)/g.mh,0,1):0;
    ctx.fillStyle='rgba(255,255,255,.12)'; ctx.fillRect(x,y+5,w,7);
    ctx.fillStyle=g.dn?'#8a2a22':(f<0.35?'#e2564a':'#6fe0a0'); ctx.fillRect(x,y+5,w*f,7);
    if(g.ac>0){ ctx.fillStyle='rgba(255,255,255,.10)'; ctx.fillRect(x,y+14,w,4); ctx.fillStyle='#6fb8ff'; ctx.fillRect(x,y+14,w*clamp((g.ar||0)/g.ac,0,1),4); }
  }
  return n;
}
function netAllPaused(){"""),
], "YOUR TEAMMATES ON THE HUD. The queue. Above your own health, each teammate in the raid has a row: his name, a health bar and an armour bar, and when he is down a red DOWN with the seconds he has left to be picked up. Drawing only. No number moved. Check 16.26 fails on v16.25",
"# YOUR TEAMMATES ON THE HUD (queue items 1 and 5, 2026-09-27).\n")
fixture(1626, r"""  {v:'16.26',what:'your teammates on the HUD: the state word carries the seconds left when down; in a party raid the HUD names a teammate, and a downed one shows DOWN with his seconds; alone it names nobody',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof drawHUD!=='function'||!ctx) return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, texts=[], oF=ctx.fillText, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), p, peer;
     function draw(){ texts=[]; ctx.fillText=function(t){ texts.push(String(t)); return oF.apply(ctx,arguments); }; try{ drawHUD(); }catch(e){ texts.push('THREW '+e); } finally{ if(own) ctx.fillText=oF; else { try{ delete ctx.fillText; }catch(_d){ ctx.fillText=oF; } } } return texts.join(' | '); }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); G.sim=0; G.over=false; p=G.player;
       if(draw().indexOf('ZQX MATE')>=0) bad.push('control: alone the HUD names a teammate');
       NET.on=true; NET.role='host'; NET.seat=0; peer={state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}}; NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       netOnMsg(peer,JSON.stringify({t:'st',k:'r',sd:NET.upSeed>>>0,x:p.x+300,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:1,w:'',pz:0,hp:0,mh:100,ar:10,ac:100,dt:9}));
       if(!NET.up[1]) return 'SKIP: the staged state word was not filed';
       if(NET.up[1].dt!==9) bad.push('the state word does not carry the seconds he has left down ('+NET.up[1].dt+')');
       NET.up[1].n=5; NET.up[1].age=0;
       var t=draw();
       if(t.indexOf('ZQX MATE')<0) bad.push('in a party raid the HUD does not name the teammate');
       if(t.indexOf('DOWN 9s')<0) bad.push('the HUD does not show the downed teammate with his seconds ('+t.slice(0,120)+')');
     }
     finally{
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
