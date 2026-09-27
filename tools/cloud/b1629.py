from gen import patch, fixture
patch(1629, [
("""function netSndSplitOn(){ var v=null; if(!NET.same) return false; try{ v=localStorage.getItem(NET_SPLIT_KEY); }catch(e){ v=null; } return v==='1'; }""",
"""function netSndSplitOn(){ var v=null; if(!NET.same) return false; try{ v=localStorage.getItem(NET_SPLIT_KEY); }catch(e){ v=null; } return (v===null)?true:(v==='1'); }   // v16.29, his note: player 2 heard nothing; split is the default until switched off"""),
], "PLAYER 2 HEARS THE GAME. His note: player 2 heard nothing at all, since the second window started with its sound off. Two player co-op on one PC now starts with SPLIT SPEAKERS on: both windows play, player 1 in the left speaker and player 2 in the right. It can still be switched off in the PARTY window. No number moved. Check 16.29 fails on v16.28",
"# PLAYER 2 HEARS THE GAME: split speakers by default. His note of 2026-09-27.\n")
fixture(1629, r"""  {v:'16.29',what:'player 2 hears the game: with no split setting saved, a same machine pair starts split (player 2 window playing, panned right); switched off it stays off',
   run:function(){
     if(typeof NET!=='object'||!NET||typeof netSndOut!=='function'||typeof netSndSplitOn!=='function') return 'SKIP: this build has no split speakers';
     var bad=[], keep={same:NET.same,sndG:NET.sndG,sndAc:NET.sndAc,sndP:NET.sndP,sndOn:NET.sndOn}, v=null, K='salvagerun:samesound:split';
     function node(){ return {gain:{value:1},pan:{value:0},connect:function(){}}; }
     var fake={destination:{},createGain:function(){ return node(); },createStereoPanner:function(){ return node(); }};
     try{ v=localStorage.getItem(K); }catch(e){}
     try{
       try{ localStorage.removeItem(K); }catch(e){}
       NET.same='p2'; NET.sndOn=false; NET.sndG=null; NET.sndAc=null; NET.sndP=null;
       netSndOut(fake);
       if(!NET.sndP) return 'SKIP: no panner was made';
       if(NET.sndG.gain.value!==1||NET.sndP.pan.value!==1) bad.push('with nothing saved the player 2 window starts silent or unpanned (gain '+NET.sndG.gain.value+', pan '+NET.sndP.pan.value+')');
       localStorage.setItem(K,'0'); netSndApply();
       if(NET.sndG.gain.value!==0) bad.push('control: split switched off, the player 2 window with SOUND OFF still plays');
     }
     finally{
       try{ if(v===null) localStorage.removeItem(K); else localStorage.setItem(K,v); }catch(_s){}
       try{ NET.same=keep.same; NET.sndG=keep.sndG; NET.sndAc=keep.sndAc; NET.sndP=keep.sndP; NET.sndOn=keep.sndOn; }catch(_n){}
     }
     return bad.length?bad.join('; '):null; }},
""")
import os, gen
_p = os.path.join(gen.H, 'f1629.ps1'); _t = open(_p, encoding='ascii').read()
extra = gen.sub("""     var fk=fake(), km;
     try{""", """     var fk=fake(), km, _splitKeep=null;
     try{ _splitKeep=localStorage.getItem('salvagerun:samesound:split'); localStorage.setItem('salvagerun:samesound:split','0'); }catch(_sk){}   // v16.29: this check reads SOUND ON and OFF with split speakers off
     try{""")
extra += gen.sub("""       try{ NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; }catch(_n){}""", """       try{ NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; }catch(_n){}
       try{ if(_splitKeep===null) localStorage.removeItem('salvagerun:samesound:split'); else localStorage.setItem('salvagerun:samesound:split',_splitKeep); }catch(_sk2){}""")
_t = _t.replace("\n$src = [IO.File]", "\n" + extra + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
