from gen import patch, fixture
patch(1622, [
("""                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*1.1),_dn,_dc,en.hp<=0);   // v8.35""",
"""                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*1.1),_dn,_dc,en.hp<=0);   // v8.35
                if(NET.on) netFxDmg(en.x,en.y-Math.round(en.r*1.1),_dn,_dc,en.hp<=0);   // v16.22: the party sees your numbers"""),
("""  if(m.k==='n'&&m.n&&m.n.length){""",
"""  if(m.k==='d'&&m.d&&m.d.length>=4){   // v16.22: a damage number one of the party put up
    a=m.d; try{ if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(+a[0]||0,+a[1]||0,Math.max(1,a[2]|0),(/^#[0-9a-fA-F]{3,8}$/).test(a[3])?a[3]:'#FFF6DC',!!a[4]); }catch(_dn){}
    return 'fx:d';
  }
  if(m.k==='n'&&m.n&&m.n.length){"""),
("""function netFxNoise(type,x,y,wid){""",
"""// v16.22, HIS NOTE: HE SHOULD SEE THE DAMAGE NUMBERS WHEN THE OTHER PLAYER DOES DAMAGE. Every number a player's round puts up is sent
// to the party (fast channel, the host passes it on) and drawn there with the same colour and the same kill mark.
function netFxDmg(x,y,n,c,dead){
  var i, m;
  if(!netUpShared()) return false;
  m={t:'fx',k:'d',s:NET.seat,d:[Math.round(x),Math.round(y),n|0,String(c||'#FFF6DC').slice(0,9),dead?1:0]};
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSendFast(NET.peers[i],m);
  return true;
}
function netFxNoise(type,x,y,wid){"""),
], "THE PARTY SEES EACH OTHERS DAMAGE NUMBERS. His note. In co-op every damage number a player puts up shows on every window, same colour, same kill mark. No number moved. Check 16.22 fails on v16.21",
"# THE PARTY SEES EACH OTHER'S DAMAGE NUMBERS. His note of 2026-09-27.\n".replace("'",""))
fixture(1622, r"""  {v:'16.22',what:'the party sees each other damage numbers: a number put up in a shared raid goes to the party, and one from the party is drawn here',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof dmgNum!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, sent=[], peer, oD=dmgNum, got=[], r;
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); G.sim=0; G.over=false;
       NET.on=true; NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       if(typeof netFxDmg!=='function'||!netFxDmg(100,100,37,'#ff8a3c',false)||!sent.some(function(m){ return m.t==='fx'&&m.k==='d'&&m.d[2]===37; })) bad.push('a damage number in a shared raid was not sent to the party');
       NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer];
       dmgNum=function(x,y,n,c,dead){ got.push(n); };
       r=netOnMsg(peer,JSON.stringify({t:'fx',k:'d',s:0,d:[120,140,52,'#FFF6DC',0]}));
       if(got.indexOf(52)<0) bad.push('a damage number from the party was not drawn here ('+r+')');
     }
     finally{
       try{ dmgNum=oD; }catch(_d){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
