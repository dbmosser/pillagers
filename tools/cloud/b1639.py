import os, gen
from gen import patch, fixture
patch(1639, [
("""  if(typeof P==='undefined'||!P||!P.buzz||!P.buzz.length) return;""",
"""  if(typeof P==='undefined'||!P||!P.buzz||!P.buzz.length){ buzzMenuFx(0,0); return; }"""),
("""  var dr=8.5*(1-Math.exp(-buzzLevel('drunk')*1.8/7)), ac=8.5*(1-Math.exp(-buzzLevel('lsd')*1.8/7));""",
"""  var _lsd=buzzLevel('lsd');
  var dr=8.5*(1-Math.exp(-buzzLevel('drunk')*1.8/7)), ac=8.5*(1-Math.exp(-_lsd*1.8/7))*Math.min(1,0.5*_lsd+0.5*Math.max(0,_lsd-1));   // v16.39, his note: one hit of Blotter is half as strong; two or more hits are as before
  buzzMenuFx(dr,ac);   // v16.39, his note: Liquor and Blotter reach the menu screens too"""),
("""function drawBuzzFx(){""",
"""// v16.39, HIS NOTE: blotter and liquor should affect the menu screens too. The open panels (every .modal that is on, and the
// pause box) sway and blur with Liquor and shift colour with Blotter, at the strength the world has, gentler so text stays
// readable. Written only when it changes; cleared when the buzz is gone.
var BUZZMENU='';
function buzzMenuFx(dr,ac){
  var f='', tr='', t=BUZZT*0.4, els, i, key;
  if(dr>0.05){ f+='blur('+Math.min(dr*0.18,1.4).toFixed(2)+'px) '; tr='translate('+(Math.sin(t*0.7)*dr*1.6).toFixed(1)+'px,'+(Math.cos(t*0.5)*dr*1.0).toFixed(1)+'px) rotate('+(Math.sin(t*0.3)*dr*0.18).toFixed(2)+'deg)'; }
  if(ac>0.05){ f+='hue-rotate('+Math.round(Math.sin(t*0.6)*ac*14)+'deg) saturate('+(1+ac*0.10).toFixed(2)+')'; if(!tr) tr='skewX('+(Math.sin(t*0.8)*ac*0.35).toFixed(2)+'deg)'; }
  key=f+'|'+tr;
  if(key===BUZZMENU&&!f) return;
  BUZZMENU=key;
  try{
    els=document.querySelectorAll('.modal.on > *, .pausebox');
    for(i=0;i<els.length;i++){ els[i].style.filter=f; els[i].style.transform=tr; }
    if(!f){ els=document.querySelectorAll('.modal > *'); for(i=0;i<els.length;i++) if(els[i].style.filter||els[i].style.transform){ els[i].style.filter=''; els[i].style.transform=''; } }
  }catch(_bm){}
}
function drawBuzzFx(){"""),
], "BLOTTER GENTLER, AND THE MENUS FEEL IT. His notes: one hit of Blotter should be less intense, and Blotter and Liquor should affect the menu screens too. One hit now draws at half strength; two or more hits are as before. The open panels (stash, sector page, stations, pause box) sway and blur with Liquor and shift colour with Blotter, gentler than the world so text stays readable. Check 16.39 fails on v16.38",
"# BLOTTER GENTLER, AND THE MENUS FEEL IT (his notes).\n")
fixture(1639, r"""  {v:'16.39',what:'one hit of Blotter draws at half strength, and Liquor and Blotter reach the open menu panels',
   run:function(){
     if(typeof buzzMenuFx!=='function') return 'the menu screens never feel Liquor or Blotter';
     var m=document.createElement('div'), c=document.createElement('div'), bad=[];
     m.className='modal on'; m.appendChild(c); document.body.appendChild(m);
     try{
       BUZZMENU=''; buzzMenuFx(2,0);
       if(c.style.filter.indexOf('blur')<0||!c.style.transform) bad.push('Liquor does not blur and sway an open panel ('+c.style.filter+' / '+c.style.transform+')');
       buzzMenuFx(0,2);
       if(c.style.filter.indexOf('hue-rotate')<0) bad.push('Blotter does not shift the colour of an open panel ('+c.style.filter+')');
       buzzMenuFx(0,0);
       if(c.style.filter||c.style.transform) bad.push('the panel keeps the effect after the buzz is gone');
     } finally { document.body.removeChild(m); BUZZMENU=''; }
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("*Math.min(1,0.5*_lsd+0.5*Math.max(0,_lsd-1))")<0) bad.push('one hit of Blotter is as strong as before');
     return bad.length?bad.join('; '):null; }},
""")
