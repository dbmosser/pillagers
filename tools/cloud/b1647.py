import os, gen
from gen import patch, fixture
patch(1647, [
("""    mouse.x=psx+rx*_rr2*pz; mouse.y=psy+ry*_rr2*pz; mouse.init=true;
  }""",
"""    mouse.x=psx+rx*_rr2*pz; mouse.y=psy+ry*_rr2*pz; mouse.init=true;
  }
  // v16.47: A CONTROLLER PLACES A MAP MARKER. With the map open, the right stick moves a cursor across the map (from where you
  // stand, the whole map in about two seconds) and a tap of D-UP places your marker there. The cursor takes over only once the
  // stick moves, so a mouse on the same window keeps the map.
  if(G&&!G.over&&G.mapOpen&&G.player&&(rx||ry||G.mapCur)){
    var _mnow=netPadNow(), _mdt=Math.min(0.05,Math.max(0,_mnow-(PAD.mcT||_mnow))); PAD.mcT=_mnow;
    if(!G.mapCur) G.mapCur={x:G.player.x,y:G.player.y};
    G.mapCur.x=clamp(G.mapCur.x+rx*WORLD_W*0.5*_mdt,0,WORLD_W); G.mapCur.y=clamp(G.mapCur.y+ry*WORLD_W*0.5*_mdt,0,WORLD_H);
    var _MPc=mapProj(); mouse.x=_MPc.ox+G.mapCur.x*_MPc.sc; mouse.y=_MPc.oy+G.mapCur.y*_MPc.sc; mouse.init=true;
  } else if(G&&!G.mapOpen){ G.mapCur=null; PAD.mcT=0; }"""),
("""      if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;""",
"""      if(G.mapOpen&&G.mapCur) netWpFromMap(); else if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;   // v16.47: with the map cursor moved, a tap places the marker"""),
("""  blip('pick'); say('Marker placed. Your party can see it.');""",
"""  blip('pick'); say((typeof NET==='object'&&NET&&NET.on)?'Marker placed. Your party can see it.':'Waypoint marked');"""),
], "A CONTROLLER PLACES A MAP MARKER. The gap left at v16.46: a controller could not place a map marker. With the map open the right stick now moves a cursor across the map and a tap of D-UP places the marker there, shared with the party as a mouse click is; a hold still shuts the map. A mouse on the same window keeps the map until the stick moves. Check 16.47 fails on v16.46",
"# A CONTROLLER PLACES A MAP MARKER (the gap left at v16.46).\n")
fixture(1647, r"""  {v:'16.47',what:'a controller places a map marker: the right stick moves a map cursor and a D-UP tap places the marker there',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf('if(G&&!G.over&&G.mapOpen&&G.player&&(rx||ry||G.mapCur)){')<0) return 'the right stick does not move a map cursor';
     if(src.indexOf('if(G.mapOpen&&G.mapCur) netWpFromMap();')<0) return 'a D-UP tap does not place the marker at the map cursor';
     if(typeof netWpFromMap!=='function'||typeof mapProj!=='function') return 'no map marker path';
     var kG=G, oS=say, oB=blip, r;
     try{
       say=function(){}; blip=function(){};
       var MP=mapProj(); G={waypoint:null};
       mouse.x=MP.ox+100*MP.sc; mouse.y=MP.oy+200*MP.sc;
       r=netWpFromMap();
     } finally { G=kG; say=oS; blip=oB; }
     if(!r||Math.abs(r.x-100)>2||Math.abs(r.y-200)>2) return 'the marker did not land under the map cursor ('+JSON.stringify(r)+')';
     return null; }},
""")
