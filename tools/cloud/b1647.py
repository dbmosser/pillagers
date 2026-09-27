import os, gen
from gen import patch, fixture
patch(1647, [
("""  fogC.width=W; fogC.height=H;
  litC.width=W; litC.height=H;""",
"""  // v16.47, HIS NOTE (frame rate at 4K, lose nothing): the darkness and fog sheets are soft gradients, drawn and composited every
  // frame at full size. They are capped at 1920 pixels wide and stretched on the way in, so 1080p is unchanged and 4K fills a
  // quarter of the pixels on both layers.
  LSC=Math.min(1,1920/Math.max(1,W));
  fogC.width=Math.round(W*LSC); fogC.height=Math.round(H*LSC);
  litC.width=Math.round(W*LSC); litC.height=Math.round(H*LSC);"""),
("""var fogC=document.createElement('canvas'),fx2=fogC.getContext('2d');""",
"""var fogC=document.createElement('canvas'),fx2=fogC.getContext('2d'), LSC=1;   // v16.47: the scale of the two light layers"""),
("""  // lighting overlay
  lx2.globalCompositeOperation='source-over';""",
"""  // lighting overlay
  lx2.setTransform(LSC,0,0,LSC,0,0);   // v16.47
  lx2.globalCompositeOperation='source-over';"""),
("""  // warm light overlay, no fog: this is home
  lx2.globalCompositeOperation='source-over';""",
"""  // warm light overlay, no fog: this is home
  lx2.setTransform(LSC,0,0,LSC,0,0);   // v16.47
  lx2.globalCompositeOperation='source-over';"""),
("""  lx2.setTransform(Z,0,0,Z,-ox*Z,-oy*Z);""", """  lx2.setTransform(Z*LSC,0,0,Z*LSC,-ox*Z*LSC,-oy*Z*LSC);   // v16.47"""),
("""  fx2.setTransform(Z,0,0,Z,-ox*Z,-oy*Z);""", """  fx2.setTransform(Z*LSC,0,0,Z*LSC,-ox*Z*LSC,-oy*Z*LSC);   // v16.47"""),
("""  lx2.setTransform(1,0,0,1,0,0);
  wc.drawImage(litC,0,0);""",
"""  lx2.setTransform(LSC,0,0,LSC,0,0);
  wc.drawImage(litC,0,0,W,H);   // v16.47: stretched back to the screen"""),
("""  fx2.setTransform(1,0,0,1,0,0);""", """  fx2.setTransform(LSC,0,0,LSC,0,0);   // v16.47"""),
("""wc.drawImage(fogC,0,0);""", """wc.drawImage(fogC,0,0,W,H);   // v16.47: stretched back to the screen"""),
("""  wc.drawImage(litC,0,0);""", """  wc.drawImage(litC,0,0,W,H);   // v16.47"""),
], "FRAME RATE AT 4K. His note: improve the frame rate without losing anything; he plays at 4K. The darkness and fog of war sheets are soft gradients filled and composited over the whole screen every frame. They are now capped at 1920 pixels wide and stretched as they are drawn, so 1080p is unchanged and at 4K both layers fill a quarter of the pixels. Check 16.47 fails on v16.46",
"# FRAME RATE AT 4K (his note: faster, lose nothing).\n")
fixture(1647, r"""  {v:'16.47',what:'frame rate at 4K: the darkness and fog sheets are capped at 1920 wide and drawn stretched to the screen',
   run:function(){
     if(typeof LSC!=='number') return 'the light layers are drawn at full size at any resolution';
     if(!(W>0)) return 'SKIP: no screen';
     var want=Math.min(1,1920/W);
     if(Math.abs(LSC-want)>1e-6) return 'the layer scale is '+LSC+' at '+W+' wide, not '+want;
     if(Math.abs(fogC.width-Math.round(W*LSC))>1||Math.abs(litC.width-Math.round(W*LSC))>1) return 'the layers are '+fogC.width+' and '+litC.width+' wide, not '+Math.round(W*LSC);
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf('wc.drawImage(fogC,0,0,W,H);')<0||src.indexOf('wc.drawImage(litC,0,0,W,H);')<0) return 'a layer is not stretched back to the screen';
     if((src.match(/drawImage\((fogC|litC),0,0\);/g)||[]).length) return 'a layer is still drawn at its own size';
     return null; }},
""")
