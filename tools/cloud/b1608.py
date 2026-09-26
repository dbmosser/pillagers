from gen import patch, fixture
patch(1608, [
("""  ctx.lineWidth=1;
  // SURVEYED. Bottom left of the map, out of the way of every marker on it.""",
"""  ctx.lineWidth=1;
  try{ if(NET.on) netMapDots(ox,oy,sc,_pmz); }catch(_nmd){}   // v16.08: the party on the sector map (the net section)
  // SURVEYED. Bottom left of the map, out of the way of every marker on it."""),
("""function netEntsHost(){""",
"""// v16.08, MULTIPLAYER: THE PARTY ON THE SECTOR MAP (plan phase 4, map dots). The sector map drew only you, so a teammate out of
// sight was nowhere, and one who went down across the sector could not be found to pull up. Each of the party up top on this
// raid seed (netUpShown, from his state words) is drawn on the map as a blue dot with a line for where he faces and his name
// over it; one who is down is drawn red with DOWN under his name. Drawing only: nothing here moves or draws from the seeded stream.
function netMapDots(ox,oy,sc,z){
  var i, g, x, y, nm, n=0;
  z=(z>0)?z:1;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)) continue;
    x=ox+g.x*sc; y=oy+g.y*sc; nm=netSeatName(g.seat)||'PILLAGER';
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(x,y,9*z,0,6.2832); ctx.fill();
    ctx.fillStyle=g.dn?'#e2564a':'#6fb8ff'; ctx.beginPath(); ctx.arc(x,y,6*z,0,6.2832); ctx.fill();
    if(!g.dn){ ctx.strokeStyle='rgba(111,184,255,.85)'; ctx.lineWidth=2*z; ctx.beginPath(); ctx.moveTo(x,y); ctx.lineTo(x+Math.cos(g.f)*18*z,y+Math.sin(g.f)*18*z); ctx.stroke(); ctx.lineWidth=1; }
    ctx.font=FS(TYPE.micro); ctx.textAlign='center';
    ctx.fillStyle=g.dn?'#ff8a80':'#bfe0ff'; ctx.fillText(nm,x,y-13*z);
    if(g.dn) ctx.fillText('DOWN',x,y+20*z);
    ctx.textAlign='left'; n++;
  }
  return n;
}
function netEntsHost(){"""),
], "THE PARTY ON THE SECTOR MAP. Multiplayer. The sector map drew only you, so a teammate out of sight was nowhere and one who went down across the sector could not be found. Each of the party up top is now a blue dot on the map with his name and where he faces, and red with DOWN when he is down. Drawing only. No number moved. Check 16.08 fails on v16.07",
"# THE PARTY ON THE SECTOR MAP. Multiplayer, plan phase 4 (map dots).\n")
fixture(1608, r"""  {v:'16.08',what:'the party on the sector map: with the map open in a party raid, a teammate up top is drawn with his name, and one who is down with DOWN under it; control, alone the map names nobody else',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof drawMapOverlay!=='function'||!ctx) return 'SKIP: this fixture cannot open the sector map in a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, texts=[], oFill=ctx.fillText, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), p;
     function draw(){ texts=[]; ctx.fillText=function(t){ texts.push(String(t)); return oFill.apply(ctx,arguments); }; try{ drawMapOverlay(); } finally { if(own) ctx.fillText=oFill; else { try{ delete ctx.fillText; }catch(_d){ ctx.fillText=oFill; } } } return texts.join(' | '); }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); p=G.player; G.mapOpen=true;
       var solo=draw();
       if(solo.indexOf('ZQX MATE')>=0) bad.push('control: alone the map names a teammate');
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[{state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}}]; NET.upSeed=G.seed>>>0;
       NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}];
       NET.up=[]; NET.up[1]={seat:1,x:p.x+400,y:p.y+200,f:0,tx:p.x+400,ty:p.y+200,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,mv:0,roll:0,bob:0,cr:0,sp:0,w:''};
       var up=draw();
       if(up.indexOf('ZQX MATE')<0) bad.push('with the map open a teammate up top is not named on it');
       if(up.indexOf('DOWN')>=0) bad.push('a teammate on his feet is marked DOWN');
       NET.up[1].dn=1;
       var dn=draw();
       if(dn.indexOf('ZQX MATE')<0||dn.indexOf('DOWN')<0) bad.push('a teammate who is down is not marked DOWN on the map');
     }
     finally{
       try{ if(G) G.mapOpen=false; }catch(_m){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
