import os, gen
from gen import patch, fixture
SRC=open(os.path.join(gen.H,'..','..','dark_raiders.html'),encoding='utf-8').read().split('\n')
SR=[l for l in SRC if l.startswith("  if(sr){ sr.style.display=NET.same?'':'none';")][0]
patch(1624, [
("""    try{ NET.sndG=a.createGain(); NET.sndG.gain.value=NET.sndOn?1:0; NET.sndG.connect(a.destination); NET.sndAc=a; }""",
"""    try{ NET.sndG=a.createGain(); NET.sndG.gain.value=NET.sndOn?1:0; NET.sndAc=a;
         // v16.24: through a stereo panner, so SPLIT SPEAKERS can put player 1 on the left and player 2 on the right
         NET.sndP=null; try{ if(a.createStereoPanner){ NET.sndP=a.createStereoPanner(); NET.sndG.connect(NET.sndP); NET.sndP.connect(a.destination); } }catch(_sp){ NET.sndP=null; }
         if(!NET.sndP) NET.sndG.connect(a.destination);
         netSndApply(); }"""),
("""function netSndApply(){ if(NET.sndG){ try{ NET.sndG.gain.value=NET.sndOn?1:0; }catch(e){} } return NET.sndOn; }""",
"""function netSndApply(){ if(NET.sndG){ try{ NET.sndG.gain.value=(NET.sndOn||netSndSplitOn())?1:0; }catch(e){} } if(NET.sndP){ try{ NET.sndP.pan.value=netSndSplitOn()?((NET.same==='p2')?1:-1):0; }catch(e2){} } return NET.sndOn; }
// v16.24, HIS NOTE: AN OPTION TO PUT PLAYER ONE'S SOUND IN THE LEFT SPEAKER AND PLAYER TWO'S IN THE RIGHT. SPLIT SPEAKERS in the
// sound row of the PARTY window, in a same machine mode: both windows play the world sound, player 1's window panned hard left and
// player 2's hard right, whatever SOUND ON or OFF says. It is one setting for the pair, kept in the browser; the other window picks
// up the change at once (the storage event), so pressing it in either window switches both. Off, everything is as before.
var NET_SPLIT_KEY='salvagerun:samesound:split';
function netSndSplitOn(){ var v=null; if(!NET.same) return false; try{ v=localStorage.getItem(NET_SPLIT_KEY); }catch(e){ v=null; } return v==='1'; }
function netSndSplitToggle(){ var on=!netSndSplitOn(); try{ localStorage.setItem(NET_SPLIT_KEY,on?'1':'0'); }catch(e){} netSndApply(); try{ renderParty(); }catch(e2){} return on; }
try{ window.addEventListener('storage',function(ev){ if(ev&&ev.key===NET_SPLIT_KEY&&NET.same){ netSndApply(); try{ renderParty(); }catch(e){} } }); }catch(_se){}"""),
("""    <button id="partysndbtn" style="padding:6px 16px">THIS WINDOW: SOUND ON</button>""",
"""    <button id="partysndbtn" style="padding:6px 16px">THIS WINDOW: SOUND ON</button>
    <button id="partysplitbtn" style="padding:6px 16px;margin-left:8px">SPLIT SPEAKERS: OFF</button>"""),
(SR, SR + """
  if(g('partysplitbtn')) g('partysplitbtn').textContent=netSndSplitOn()?'SPLIT SPEAKERS: ON (P1 LEFT, P2 RIGHT)':'SPLIT SPEAKERS: OFF';   // v16.24"""),
("""  if(g('partysndbtn')) g('partysndbtn').onclick=function(){ netSndToggle(); };   // v15.78: the SOUND row""",
"""  if(g('partysndbtn')) g('partysndbtn').onclick=function(){ netSndToggle(); };   // v15.78: the SOUND row
  if(g('partysplitbtn')) g('partysplitbtn').onclick=function(){ netSndSplitToggle(); };   // v16.24: player 1 left, player 2 right"""),
], "SPLIT SPEAKERS. His note. In two player co-op on one PC the PARTY window sound row has SPLIT SPEAKERS: both windows play sound, player 1 in the left speaker and player 2 in the right. Pressing it in either window switches both. No number moved. Check 16.24 fails on v16.23",
"# SPLIT SPEAKERS, player 1 left and player 2 right. His note of 2026-09-27.\n")
fixture(1624, r"""  {v:'16.24',what:'split speakers: with it on, player 1 window sound is panned hard left and player 2 window hard right and both play even with SOUND OFF; with it off, no pan and SOUND OFF is silent',
   run:function(){
     if(typeof NET!=='object'||!NET||typeof netSndOut!=='function') return 'SKIP: this build has no same machine sound';
     var bad=[], keep={same:NET.same,sndG:NET.sndG,sndAc:NET.sndAc,sndP:NET.sndP,sndOn:NET.sndOn}, v=null, K='salvagerun:samesound:split';
     function node(){ var o={gain:{value:1},pan:{value:0},connect:function(){}}; return o; }
     var fake={destination:{},createGain:function(){ return node(); },createStereoPanner:function(){ return node(); }};
     try{ v=localStorage.getItem(K); }catch(e){}
     try{
       if(typeof netSndSplitOn!=='function') return 'this build has no split speakers';
       NET.same='host'; NET.sndOn=false; NET.sndG=null; NET.sndAc=null; NET.sndP=null;
       try{ localStorage.setItem(K,'0'); }catch(e){}
       netSndOut(fake);
       if(!NET.sndP) return 'SKIP: no panner was made';
       if(NET.sndP.pan.value!==0||NET.sndG.gain.value!==0) bad.push('control: split off, player 1 window with SOUND OFF has pan '+NET.sndP.pan.value+' gain '+NET.sndG.gain.value);
       localStorage.setItem(K,'1'); netSndApply();
       if(NET.sndP.pan.value!==-1||NET.sndG.gain.value!==1) bad.push('split on, player 1 window has pan '+NET.sndP.pan.value+' gain '+NET.sndG.gain.value+', not hard left and playing');
       NET.same='p2'; netSndApply();
       if(NET.sndP.pan.value!==1||NET.sndG.gain.value!==1) bad.push('split on, player 2 window has pan '+NET.sndP.pan.value+' gain '+NET.sndG.gain.value+', not hard right and playing');
     }
     finally{
       try{ if(v===null) localStorage.removeItem(K); else localStorage.setItem(K,v); }catch(_s){}
       try{ NET.same=keep.same; NET.sndG=keep.sndG; NET.sndAc=keep.sndAc; NET.sndP=keep.sndP; NET.sndOn=keep.sndOn; }catch(_n){}
     }
     return bad.length?bad.join('; '):null; }},
""")
_p = os.path.join(gen.H, 'f1624.ps1'); _t = open(_p, encoding='ascii').read()
MK = open(os.path.join(gen.H, '..', 'mkfixture.ps1'), encoding='utf-8').read().split('\n')
extra = ''
for gv, msg in [('gH', "the master gain does not connect to the destination"), ('gP', "the player 2 master gain does not connect to the destination")]:
    a = "if(!has(%s.out,fk.destination)) bad.push('%s');" % (gv, msg)
    ln = [x for x in MK if a in x]; assert len(ln) == 1, a
    b = "if(!(has(%s.out,fk.destination)||(%s.out||[]).some(function(n){ return n&&n.out&&has(n.out,fk.destination); }))) bad.push('%s');   // v16.24: or through the split speakers panner" % (gv, gv, msg)
    extra += gen.sub(ln[0], ln[0].replace(a, b))
_t = _t.replace("\n$src = [IO.File]", "\n" + extra + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
