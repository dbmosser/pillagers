import os, gen
from gen import patch, fixture
patch(1635, [
("""  if(side!=='p2') return (pick>=0&&pick<n&&gps[pick]&&gps[pick].connected)?pick:-1;""",
"""  if(side!=='p2'){
    if(pick>=0) return (pick<n&&gps[pick]&&gps[pick].connected)?pick:-1;
    // v16.35, HIS RULE of 2026-09-27: player 1 plays keyboard and mouse, player 2 takes the first controller, and a second
    // controller goes to player 1. With no pick the host plays the first connected pad player 2 is not on.
    taken=netPadFor('p2',taken,-1,gps);
    for(i=0;i<n;i++) if(i!==taken&&gps[i]&&gps[i].connected) return i;
    return -1;
  }"""),
("""  if(NET.same==='host') return netPadIxOk(NET.padIx);""",
"""  if(NET.same==='host') return (netPadIxOk(NET.padIx)>=0)?NET.padIx:-2;   // v16.35: with no pick, the second controller player 2 hands over"""),
("""  return (side==='p2')?'THE FIRST FREE CONTROLLER':'NO CONTROLLER, KEYBOARD AND MOUSE';""",
"""  return (side==='p2')?'THE FIRST FREE CONTROLLER':'KEYBOARD AND MOUSE, AND A SECOND CONTROLLER';   // v16.35"""),
], "A SECOND CONTROLLER GOES TO PLAYER 1. His rule: player 1 plays keyboard and mouse, player 2 takes the first controller, and a second controller goes to player 1. The host with no pick played no pad at all; it now plays the first connected pad player 2 is not on, in front or handed over. A pick on the CONTROLLER row still wins. Check 15.77 restaged on the two lines that asserted the old rule. Check 16.35 fails on v16.34",
"# A SECOND CONTROLLER GOES TO PLAYER 1 (his controller rule of 2026-09-27).\n")
fixture(1635, r"""  {v:'16.35',what:'his controller rule: player 2 takes the first controller and a second controller goes to player 1, who otherwise plays keyboard and mouse',
   run:function(){
     if(typeof netPadFor!=='function'||typeof netPadWant!=='function'||typeof NET==='undefined') return 'SKIP: this build has no same machine controllers';
     function pd(ix){ return {connected:true,index:ix,id:'probe',buttons:[],axes:[]}; }
     var two=[pd(0),pd(1)], one=[pd(0)], bad=[], keep=NET.same, keepIx=NET.padIx;
     if(netPadFor('p2',-1,-1,two)!==0) bad.push('player 2 with no pick is not on the first controller ('+netPadFor('p2',-1,-1,two)+')');
     if(netPadFor('host',-1,-1,two)!==1) bad.push('player 1 with no pick is not on the second controller ('+netPadFor('host',-1,-1,two)+')');
     if(netPadFor('host',-1,-1,one)!==-1) bad.push('with one controller player 1 took it from player 2');
     if(netPadFor('host',-1,1,two)!==0) bad.push('with player 2 on controller 2 by pick, player 1 is not on controller 1');
     if(netPadFor('host',1,-1,two)!==1) bad.push('a player 1 pick is not kept');
     try{ NET.same='host'; NET.padIx=-1; if(netPadWant()!==-2) bad.push('player 1 with no pick takes no controller handed over ('+netPadWant()+')'); }
     finally{ NET.same=keep; NET.padIx=keepIx; }
     return bad.length?bad.join('; '):null; }},
""")
_p = os.path.join(gen.H, 'f1635.ps1'); _t = open(_p, encoding='ascii').read()
subs = [
("       if(PAD.on) bad.push('the host with no controller picked plays a pad (buttons down '+downs()+')');",
 "       if(!PAD.on||!PAD.prev[0]||PAD.prev[3]) bad.push('the host with no controller picked does not play the second controller, his rule of 2026-09-27 (buttons down '+downs()+')');   // v16.35"),
("       if(keys.KeyF||keys.KeyE) bad.push('the host with no controller picked holds a key from a pad (F '+!!keys.KeyF+', E '+!!keys.KeyE+')');",
 "       if(keys.KeyF) bad.push('the host with no controller picked holds a key from the player 2 pad (F '+!!keys.KeyF+')');   // v16.35"),
("       if(netSameOnMsg(fwd(0,1,[2]))!=='padnone') bad.push('the host with no pick took a state handed over');",
 "       if(netSameOnMsg(fwd(0,1,[2]))!=='pad') bad.push('the host with no pick refused the second controller player 2 handed over');   // v16.35"),
]
_t = _t.replace("\n$src = [IO.File]", "\n" + "".join(gen.sub(a, b) for a, b in subs) + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
