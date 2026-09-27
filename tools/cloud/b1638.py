import os, gen
from gen import patch, fixture
SHOWN = "function netUpShown(g){ return !!g&&g.n>0&&g.age<NET_HUB_STALE&&g.seat!==NET.seat&&netSeatName(g.seat)!==null&&!!NET.upSeed&&g.sd===(NET.upSeed>>>0); }"
BLEED = '  <div id="pausebleed" style="display:none;font-size:13.5px;color:var(--rust);margin-top:8px;text-align:center;max-width:620px;line-height:1.7">YOU ARE DOWNED.  You can extract while downed</div>'
patch(1638, [
(SHOWN, SHOWN + """
// v16.38, HIS NOTE: the host screen should clearly say You are hosting, do not quit. Is this window hosting a raid its party is in?
// Then the pause box says so, and closing the window asks first (the browser's own leave page question).
function netHostHolds(){
  return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&netInCount()>0&&NET.upSeed&&typeof G!=='undefined'&&G&&!G.sim&&(!G.over||G===NET.specG));
}
window.addEventListener('beforeunload',function(e){ if(netHostHolds()){ e.preventDefault(); e.returnValue=''; return ''; } });"""),
(BLEED, BLEED + """
  <div id="pausehost" style="display:none;font-size:13.5px;color:var(--amber);margin-top:8px;text-align:center;max-width:620px;line-height:1.7">YOU ARE HOSTING. Closing this window or ending the party ends the raid for your whole party.</div>"""),
("""    if(_bl) _bl.style.display=(_inRaid&&_downNow)?'':'none';""",
"""    if(_bl) _bl.style.display=(_inRaid&&_downNow)?'':'none';
    var _hw=document.getElementById('pausehost'); if(_hw) _hw.style.display=netHostHolds()?'':'none';   // v16.38: the host is told what quitting costs the party"""),
], "YOU ARE HOSTING. His note: the host screen should clearly say you are hosting, do not quit. With a party up top on the host raid, the host pause box now reads YOU ARE HOSTING. Closing this window or ending the party ends the raid for your whole party, and closing the host window asks first. Abandoning still makes the host spectate (his ruling of 2026-09-26). Check 16.38 fails on v16.37",
"# YOU ARE HOSTING (his note: the host screen clearly says you are hosting, do not quit).\n")
fixture(1638, r"""  {v:'16.38',what:'the host is told it is hosting: the pause box line shows while its party is in its raid, and closing the host window asks first',
   run:function(){
     var el=document.getElementById('pausehost');
     if(!el||typeof netHostHolds!=='function') return 'this build never tells the host it is hosting';
     if(String(el.textContent).indexOf('YOU ARE HOSTING')!==0||String(el.textContent).indexOf('ends the raid for your whole party')<0) return 'the hosting line reads: '+el.textContent;
     var keep={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed}, kG=G, a, b, c, ev={returnValue:null,prevented:0,preventDefault:function(){ this.prevented=1; }};
     try{
       G={sim:false,over:false}; NET.on=true; NET.role='host'; NET.peers=[{state:'in',seat:1}]; NET.upSeed=77;
       a=netHostHolds();
       NET.peers=[]; b=netHostHolds();
       NET.peers=[{state:'in',seat:1}]; NET.role='join'; c=netHostHolds();
     } finally { G=kG; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.upSeed=keep.upSeed; }
     if(!a) return 'a host with its party in its raid does not read as holding the party';
     if(b||c) return 'a host with nobody linked, or a teammate, reads as holding the party';
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("window.addEventListener('beforeunload',function(e){ if(netHostHolds())")<0) return 'closing the host window does not ask first';
     if(src.indexOf("_hw.style.display=netHostHolds()?'':'none'")<0) return 'the pause box never shows the hosting line';
     return null; }},
""")
