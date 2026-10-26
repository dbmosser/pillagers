$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# PILLAGERS DRAWN A THIRD THE SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var FIG_SCALE=0.8, FIG_UP=4, /*
'@ @'
var FIG_SCALE=1.25/3, FIG_UP=Math.round(45*FIG_SCALE)-32, /* v28.xx (cw-thirdsize), HIS NOTE (2026-10-25, played on the old build 33.17, where the figure was drawn at 1.25): "player character is still wayyy too big, needs to be 1/3 of the size he is right now". So every human figure is drawn at a third of what he saw: 1.25/3 (about 0.42) of the size 1 art (34.83 drew 0.8, so this is about half of that), drawing only: hit areas, walking, doors and the nav grid keep their old radius. FIG_SCALE is the one number to change; FIG_UP follows it (the lean head top is about 45*FIG_SCALE over the feet, so every plate keeps the gap over the head it had on the size 1 figure: FIG_UP 12 there, -13 at 1.25/3). */ /*
'@

SubRx @'
function figOn(){ return !!(typeof wc!=='undefined'&&wc&&((typeof cv!=='undefined'&&wc.canvas===cv)||RIM.on===1)); }
'@ @'
function figOn(){ return !!(typeof wc!=='undefined'&&wc&&((typeof cv!=='undefined'&&wc.canvas===cv)||RIM.on===1||(typeof GOLDB!=='undefined'&&GOLDB.h&&wc===GOLDB.x))); }   // v28.xx (cw-thirdsize): the golden body pass (goldBodyBegin) draws a world figure on its own canvas, so the golden pillager is drawn at the size of the others, not at size 1
function figK1(){ return (figOn()&&!pixOn())?FIG_SCALE:1; }   // v28.xx (cw-thirdsize): the drawn figure scale on the world canvas (1 on a preview canvas and in the pixel look, which keeps its own size)
function figShK(sh){ var b=null; if(pixOn()) return [1,1]; try{ b=(typeof G!=='undefined'&&G&&sh===G.player)?cosWorn('build'):(sh&&sh.build); }catch(_b){ b=null; } return figKS(b); }   // v28.xx (cw-thirdsize): the drawn size of a shooter (FIG_SCALE times the build), for the flash point, the tracer start and the brass
function figHudLift(h){ return pixOn()?h:(FIG_UP+32)*(ZOOM()||1)+(h-44)*hudRes(); }   // v28.xx (cw-thirdsize): the w2s lift (screen px) of a HUD plate over your head, given as its lift at ZOOM 1 over the size 1 head (44 over the feet). The head part is world units times ZOOM (FIG_UP+32, the drawn lean head top), the gap is HUD px times hudRes (hudAtIn grows the plate by hudRes), so the plate sits just over the drawn head at 1080, at 4K, zoomed in and aimed. The pixel look keeps its own lift
function figUpL(){ return pixOn()?4:FIG_UP; }   // v28.xx (cw-thirdsize): the plate lift over a world figure; the pixel body keeps its own size (PIX_FIGK), so its plates keep the lift they had before (FIG_UP 4)
function shotLy(sh,wep){ return ((gunMuzD0(sh,wep)>0||(sh&&sh.kind==='stray'))&&!pixOn())?20*figShK(sh)[1]:12; }   // v28.xx (cw-thirdsize): the height a shot is drawn at (its tracer, and the flash of the survivor, who draws no gun): the gun line of the drawn body (20 times its drawn size) for a player, a pillager and the survivor; 12 for a machine and in the pixel look
'@

SubRx @'
  colourCueGlyph(wc,st.team,x-18,y-29,.85,TEAMCOL[st.team]);
}
'@ @'
  var _cf=figK1(), _sd=(_cf!==1&&Math.cos(+face||0)<0)?-1:1; colourCueGlyph(wc,st.team,x-_sd*(6+12*_cf),y-29*_cf,.85,TEAMCOL[st.team]);   // v28.xx (cw-thirdsize): beside the head of the smaller body (x-18, y-29 at size 1), on the side away from his aim (the body mirrors on the same rule), so it never covers his gun or his flash; the mark keeps its size so the shape still reads; the pixel look keeps its place
}
'@

SubRx @'
function gunMuzD(sh,wep){
  var D;
  if(!sh||!wep||!G||!(sh===G.player||sh.kind==='raider')) return 0;
  D=GUNDEF[wep.id]||GUNDEF.rifle;
  return (D.tip+(D.pist?2:0))*GUNK;
}
function gunMuzzleAt(sh,wep,a){
  var L=gunMuzD(sh,wep), D, sg, by;
  if(!(L>0)) return null;
  D=GUNDEF[wep.id]||GUNDEF.rifle; sg=(Math.cos(a)<0)?-1:1; by=D.by*GUNK*sg;
  return {x:sh.x+Math.cos(a)*L-Math.sin(a)*by, y:sh.y-20+Math.sin(a)*L+Math.cos(a)*by};
}
function gunPortOff(sh,wep,a){
  var D, d;
  if(!(gunMuzD(sh,wep)>0)) return {x:0,y:0};
  D=GUNDEF[wep.id]||GUNDEF.rifle; d=(D.port?D.port[0]:8)*GUNK;
  return {x:Math.cos(a)*d, y:Math.sin(a)*d};
}
'@ @'
function gunMuzD0(sh,wep){
  var D;
  if(!sh||!wep||!G||!(sh===G.player||sh.kind==='raider')) return 0;
  D=GUNDEF[wep.id]||GUNDEF.rifle;
  return (D.tip+(D.pist?2:0))*GUNK;
}
// v28.xx (cw-thirdsize), his note of 2026-10-25 ("needs to be 1/3 of the size he is right now"): the held gun is drawn with the figure, so the flash point, the start of
// the tracer and the brass port are placed by the drawn size of the shooter (figShK, FIG_SCALE times the build, 1 in the pixel look) about the feet, the way drawAimMark
// already placed its dots. Drawing only: the round still spawns 17 units out with the same speed, spread and range.
function gunMuzD(sh,wep){ var L=gunMuzD0(sh,wep); return (L>0)?L*figShK(sh)[0]:0; }
function gunMuzzleAt(sh,wep,a){
  var L=gunMuzD0(sh,wep), D, sg, by, k;
  if(!(L>0)) return null;
  D=GUNDEF[wep.id]||GUNDEF.rifle; sg=(Math.cos(a)<0)?-1:1; by=D.by*GUNK*sg; k=figShK(sh);
  return {x:sh.x+(Math.cos(a)*L-Math.sin(a)*by)*k[0], y:sh.y+(-20+Math.sin(a)*L+Math.cos(a)*by)*k[1]};
}
function gunPortOff(sh,wep,a){
  var D, d, k;
  if(!(gunMuzD0(sh,wep)>0)) return {x:0,y:0};
  D=GUNDEF[wep.id]||GUNDEF.rifle; d=(D.port?D.port[0]:8)*GUNK; k=figShK(sh);
  return {x:Math.cos(a)*d*k[0], y:Math.sin(a)*d*k[1]};
}
'@

SubRx @'
  hx=x+Math.cos(face)*12; hy=y-10+Math.sin(face)*4;
  a=0.6+0.25*s; r=11+2*s;
'@ @'
  var _gk=figK1(); hx=x+Math.cos(face)*12*_gk; hy=y+(Math.sin(face)*4-10)*_gk;   // v28.xx (cw-thirdsize): at the hands of the smaller body, sized to them
  a=0.6+0.25*s; r=(11+2*s)*_gk;
'@

SubRx @'
  var pu=0.5+0.5*Math.sin((G.t||0)*5), rx=21+pu*2.5, ry=rx*1.3, cy=y-18, tg, tw;
'@ @'
  var pu=0.5+0.5*Math.sin((G.t||0)*5), _sk=figK1(), rx=(21+pu*2.5)*_sk, ry=rx*1.3, cy=y-18*_sk, tg, tw;   // v28.xx (cw-thirdsize): the spawn shield hugs the smaller body
'@

SubRx @'
  var q, z, t, R=34, cy, gr, k, ang;
'@ @'
  var q, z, t, R=34*figK1(), cy, gr, k, ang;   // v28.xx (cw-thirdsize): the bubble round the smaller body
'@

SubRx @'
  q=ZOOM()||1; z=Math.max(1,hudRes()); t=+G.t||0; cy=g.y-14;
'@ @'
  q=ZOOM()||1; z=Math.max(1,hudRes()); t=+G.t||0; cy=g.y-14*figK1();
'@

SubRx @'
sc=w2s(p.x,0,p.y); R=34*q; cy=sc.y-14*q;
'@ @'
sc=w2s(p.x,0,p.y); R=34*q*(pixOn()?1:FIG_SCALE); cy=sc.y-14*q*(pixOn()?1:FIG_SCALE); /* v28.xx (cw-thirdsize): your bubble round the smaller body */
'@

SubRx @'
        wc.rect(p.x-40,p.y-90,80,90-WADE_DEPTH);
'@ @'
        wc.rect(p.x-40,p.y-90,80,90-WADE_DEPTH*figK1());   // v28.xx (cw-thirdsize): the waterline at the waist of the smaller body
'@

SubRx @'
        var wy=p.y-WADE_DEPTH, wob=Math.sin(G.t*3.1)*0.8;
        wc.fillStyle='rgba(18,38,54,.55)';
        wc.beginPath(); wc.ellipse(p.x,wy+wob,13,4.2,0,0,6.2832); wc.fill();
        wc.strokeStyle='rgba(150,205,225,.5)'; wc.lineWidth=1;
        wc.beginPath(); wc.ellipse(p.x,wy+wob,13,4.2,0,0,6.2832); wc.stroke();
        if(p.moving){
          wc.strokeStyle='rgba(180,222,240,'+(0.30+0.14*Math.sin(G.t*7)).toFixed(3)+')';
          wc.beginPath(); wc.ellipse(p.x,wy+2+wob,20+2.5*Math.sin(G.t*5),6.5,0,0,6.2832); wc.stroke();
'@ @'
        var _wk=figK1(), wy=p.y-WADE_DEPTH*_wk, wob=Math.sin(G.t*3.1)*0.8*_wk;   // v28.xx (cw-thirdsize): the waterline and its rings to the size of the smaller body
        wc.fillStyle='rgba(18,38,54,.55)';
        wc.beginPath(); wc.ellipse(p.x,wy+wob,13*_wk,4.2*_wk,0,0,6.2832); wc.fill();
        wc.strokeStyle='rgba(150,205,225,.5)'; wc.lineWidth=1;
        wc.beginPath(); wc.ellipse(p.x,wy+wob,13*_wk,4.2*_wk,0,0,6.2832); wc.stroke();
        if(p.moving){
          wc.strokeStyle='rgba(180,222,240,'+(0.30+0.14*Math.sin(G.t*7)).toFixed(3)+')';
          wc.beginPath(); wc.ellipse(p.x,wy+2*_wk+wob,(20+2.5*Math.sin(G.t*5))*_wk,6.5*_wk,0,0,6.2832); wc.stroke();
'@

SubRx @'
    var cs2=w2s(p.x,30,p.y);
'@ @'
    var cs2=w2s(p.x,figHudLift(30+((p.cookKind==='frag'||pixOn())?0:LH(11))),p.y);   // v28.xx (cw-thirdsize): just over the smaller head, at 1080 and at 4K, zoomed in and aimed; the smoke, decoy and trip plates have a second row (LH(11) taller), so they lift by it and end the same gap over the head as the frag plate
'@

SubRx @'
    var _rb=w2s(p.x,34,p.y);
'@ @'
    var _rb=w2s(p.x,figHudLift(34),p.y);   // v28.xx (cw-thirdsize): just over the smaller head, at 1080 and at 4K, zoomed in and aimed
'@

SubRx @'
var _slp=w2s(p.x,66,p.y), _hsL
'@ @'
var _slp=w2s(p.x,figHudLift(66),p.y) /* v28.xx (cw-thirdsize): over the smaller head at any screen and zoom */, _hsL
'@

SubRx @'
_fpp=w2s(p.x,66,p.y), _hsFG
'@ @'
_fpp=w2s(p.x,figHudLift(66),p.y) /* v28.xx (cw-thirdsize): over the smaller head at any screen and zoom */, _hsFG
'@

SubRx @'
  bx=e.x-w/2; by=e.y-37;
'@ @'
  bx=e.x-w/2; by=pixOn()?e.y-37:e.y-(FIG_UP+32)-4;   // v28.xx (cw-thirdsize): just over the head of the smaller body, kneeling or rising in a crouch (the bar is drawn before the body), under his nameplate; the pixel look keeps its own place
'@

SubRx @'
    var fx=e.x, fy=e.y-15;
'@ @'
    var fx=e.x, fy=e.y-15, _pk=(figOn()&&!pixOn())?figKS():null;   // v28.xx (cw-thirdsize): his pack frame and what hangs off it ride the smaller body
    if(_pk){ wc.save(); wc.translate(fx,fy); wc.scale(_pk[0],_pk[1]); wc.translate(-fx,-fy); }
    try{
'@

SubRx @'
  })();
  drawOp(e.x,e.y-15,e.face,(e.step||0)*3,e.coat,0.3,0,'none',0,
'@ @'
    } finally { if(_pk) wc.restore(); }
  })();
  drawOp(e.x,e.y-15,e.face,(e.step||0)*3,e.coat,0.3,0,'none',0,
'@

SubRx @'
  wc.save(); wc.globalAlpha=wc.globalAlpha*u;
  shadowE(x+1.5,y+2,12.5,5,0.5);
'@ @'
  wc.save(); wc.globalAlpha=wc.globalAlpha*u;
  var _fk=kb?[FIG_SCALE*kb[0],FIG_SCALE*kb[1]]:[1,1]; shadowE(x+1.5*_fk[0],y+2*_fk[1],12.5*_fk[0],5*_fk[1],0.5);   // v28.xx (cw-thirdsize): the shadow of the fall is the size of the body that falls
'@

SubRx @'
  if(_SE>=0) drawSeatRing(x,y,_SE);
}
'@ @'
  if(_SE>=0){ var _rk=figK1(); if(_rk!==1){ wc.save(); wc.translate(x,y); wc.scale(1/_rk,1/_rk); wc.translate(-x,-y); } try{ drawSeatRing(x,y,_SE); } finally{ if(_rk!==1) wc.restore(); } }   // v28.xx (cw-thirdsize): the P1 and P2 ring and its number keep their full size under the smaller body, so the seats still read at the party
}
'@

SubRx @'
  wc.beginPath(); wc.ellipse(x,y+1,18,7,0,0,6.2832); wc.stroke();
'@ @'
  var _rk=figK1(); wc.lineWidth=2/_rk; wc.beginPath(); wc.ellipse(x,y+1,18/_rk,7/_rk,0,0,6.2832); wc.stroke();   // v28.xx (cw-thirdsize): the red downed ring keeps its full size round the smaller body, so a mate still finds him
'@

SubRx @'
wc.clip(); wc.translate(0,s);
}
'@ @'
wc.clip(); wc.translate(0,s*figK1());   // v28.xx (cw-thirdsize): the smaller body sinks by its own size, so it rises over the whole ascent
}
'@

SubRx @'
      fs=(typeof FIG_SCALE==='number'&&bld!==null)?FIG_SCALE:1,
'@ @'
      fs=(typeof FIG_SCALE==='number'&&bld!==null&&!pixOn())?FIG_SCALE:1,   /* v28.xx (cw-thirdsize), his note 2026-10-25 ("needs to be 1/3 of the size he is right now"): the pixel body keeps its own size, so its aim dots take no FIG_SCALE */
'@

SubRx @'
  if(e.kind==='raider'||e.kind==='stray') return 40+FIG_UP;
'@ @'
  if(e.kind==='raider'||e.kind==='stray') return 40+figUpL();   // v28.xx (cw-thirdsize): just over the smaller head; the pixel look keeps its own lift
'@

SubRx @'
    var _py=p.y-68-FIG_UP-((_pbi&&p.prep)?13:0);
'@ @'
    var _py=p.y-68-figUpL()-((_pbi&&p.prep)?13:0);   // v28.xx (cw-thirdsize): the pixel look keeps its own lift
'@

SubRx @'
      wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62-FIG_UP,tw+8,13);   // v32.64 (cw-figlook): over the bigger head
      wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52-FIG_UP);
      n++;
'@ @'
      wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62-figUpL(),tw+8,13);   // v32.64 (cw-figlook): over the bigger head   // v28.xx (cw-thirdsize): the pixel look keeps its own lift
      wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52-figUpL());
      n++;
'@

SubRx @'
    wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62-FIG_UP,tw+8,13);   // v32.64 (cw-figlook): over the bigger head
    wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52-FIG_UP);
  }catch(e){}
'@ @'
    wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62-figUpL(),tw+8,13);   // v32.64 (cw-figlook): over the bigger head   // v28.xx (cw-thirdsize): the pixel look keeps its own lift
    wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52-figUpL());
  }catch(e){}
'@

SubRx @'
  var i, g, nm, tw, n=0, U=FIG_UP+3;
'@ @'
  var i, g, nm, tw, n=0, U=figUpL()+3; /* v28.xx (cw-thirdsize): the pixel look keeps its own lift */
'@

SubRx @'
function elemBodyH(e){ return (e.kind==='raider'||e.kind==='stray'||e.kind==='peddler')?34:Math.max(14,(e.r||14)*1.4+6); }
'@ @'
function elemBodyK(e){ return (e&&(e.kind==='raider'||e.kind==='stray'||e.kind==='peddler')&&!pixOn())?FIG_SCALE/0.8:1; }   // v28.xx (cw-thirdsize): the element effects were fitted to the 0.8 body; on a human body they follow its drawn size (a machine and the pixel look keep theirs)
function elemBodyH(e){ return (e.kind==='raider'||e.kind==='stray'||e.kind==='peddler')?Math.max(14,Math.round(34*elemBodyK(e))):Math.max(14,(e.r||14)*1.4+6); }
'@

SubRx @'
    r=e.r||14; H=elemBodyH(e);
'@ @'
    var _ek=elemBodyK(e); r=(e.r||14)*_ek; H=elemBodyH(e);   // v28.xx (cw-thirdsize): as wide and as tall as the drawn body
'@

SubRx @'
        wc.globalAlpha=0.5; wc.fillStyle=ELEM.fire.c; elemFlame(x0,e.y-2,5.5,h);
        wc.globalAlpha=0.65; wc.fillStyle='#ffc04a'; elemFlame(x0,e.y-2,2.6,h*0.6);
'@ @'
        wc.globalAlpha=0.5; wc.fillStyle=ELEM.fire.c; elemFlame(x0,e.y-2,5.5*_ek,h);   // v28.xx (cw-thirdsize): flames as wide as the drawn body
        wc.globalAlpha=0.65; wc.fillStyle='#ffc04a'; elemFlame(x0,e.y-2,2.6*_ek,h*0.6);
'@

SubRx @'
      var bw=r+5, top=e.y-H-7, bot=e.y+4;
'@ @'
      var bw=r+5*_ek, top=e.y-H-7*_ek, bot=e.y+4*_ek;   // v28.xx (cw-thirdsize): the ice block round the drawn body
'@

SubRx @'
    shadowE=function(x,y,rx,ry,a){ var w1=wc; wc=h1.w0; try{ h1.sh0(x,y,rx,ry,a); } finally{ wc=w1; } };   // the ground shadow stays on the world canvas, out of the outline
'@ @'
    shadowE=function(x,y,rx,ry,a){ var w1=wc, M=(w1===RIM.xa)?w1.getTransform():null; wc=h1.w0; wc.save(); try{ if(M) wc.setTransform(M.a,M.b,M.c,M.d,M.e+h1.sx,M.f+h1.sy); h1.sh0(x,y,rx,ry,a); } finally{ wc.restore(); wc=w1; } };   // the ground shadow stays on the world canvas, out of the outline   // v28.xx (cw-thirdsize): drawn with the transform the body is drawn with (the figure scale), so the smaller body stands on its own shadow
'@

SubRx @'
    shadowE=function(x,y,rx,ry,a){ var w1=wc; wc=h1.w0; try{ h1.sh0(x,y,rx,ry,a); } finally{ wc=w1; } };   // the ground shadow stays on the world canvas, off the gold
'@ @'
    shadowE=function(x,y,rx,ry,a){ var w1=wc, M=(w1===GOLDB.x)?w1.getTransform():null; wc=h1.w0; wc.save(); try{ if(M) wc.setTransform(M.a,M.b,M.c,M.d,M.e+h1.sx,M.f+h1.sy); h1.sh0(x,y,rx,ry,a); } finally{ wc.restore(); wc=w1; } };   // the ground shadow stays on the world canvas, off the gold   // v28.xx (cw-thirdsize): drawn with the transform the body is drawn with (the figure scale), so the smaller body stands on its own shadow
'@

SubRx @'
  GFXMUZ.push({g:G,x:_mz?_mz.x:sh.x+Math.cos(ang)*17,y:_mz?_mz.y:sh.y+Math.sin(ang)*17-12,a:ang,f:muzFam(wep),c:muzTint(wep&&wep.tint),sh:sh,me:!!fromPlayer,n:0,age:0});
'@ @'
  GFXMUZ.push({g:G,x:_mz?_mz.x:sh.x+Math.cos(ang)*17,y:_mz?_mz.y:sh.y+Math.sin(ang)*17-shotLy(sh,wep),a:ang,f:muzFam(wep),c:muzTint(wep&&wep.tint),sh:sh,me:!!fromPlayer,n:0,age:0,fz:((_mz||sh.kind==='stray')&&!pixOn())?FIG_SCALE/0.8:1});   // v28.xx (cw-thirdsize): the flash of a player, a pillager or the survivor is sized to the smaller body (it was fitted to the 0.8 body), and the survivor (no gun drawn) flashes at the height of his tracer; a machine and the pixel look keep theirs
'@

SubRx @'
function gfxShotFx(x,y,ang,tint){   // a teammate tracer: one flash per shot, not one per pellet
  var i, m;
  if(GFX.bypass||!G||G.sim||!isFinite(x)||!isFinite(y)||!isFinite(ang)) return false;
  for(i=0;i<GFXMUZ.length;i++){ m=GFXMUZ[i]; if(m.g===G&&m.n===0&&!m.sh&&Math.abs(m.x-x)<5&&Math.abs(m.y-(y-12))<5) return false; }
  if(GFXMUZ.length>=24) GFXMUZ.shift();
  GFXMUZ.push({g:G,x:x,y:y-12,a:ang,f:'short',c:muzTint(tint),sh:null,me:false,n:0,age:0});
'@ @'
function gfxShotFx(x,y,ang,tint,fz){   // a teammate tracer: one flash per shot, not one per pellet   // v28.xx (cw-thirdsize): fz, the size of the flash (1, or the smaller gun of a teammate drawn at the figure scale)
  var i, m;
  if(GFX.bypass||!G||G.sim||!isFinite(x)||!isFinite(y)||!isFinite(ang)) return false;
  for(i=0;i<GFXMUZ.length;i++){ m=GFXMUZ[i]; if(m.g===G&&m.n===0&&!m.sh&&Math.abs(m.x-x)<5&&Math.abs(m.y-(y-12))<5) return false; }
  if(GFXMUZ.length>=24) GFXMUZ.shift();
  GFXMUZ.push({g:G,x:x,y:y-12,a:ang,f:'short',c:muzTint(tint),sh:null,me:false,n:0,age:0,fz:(isFinite(fz)&&fz>0)?fz:1});
'@

SubRx @'
if(_mzw) gfxShotFx(+a[9],+a[10]+12,Math.atan2(+a[3]||0,+a[2]||0),a[5]);
'@ @'
if(_mzw) gfxShotFx(+a[9],+a[10]+12,Math.atan2(+a[3]||0,+a[2]||0),a[5],pixOn()?1:FIG_SCALE/0.8); /* v28.xx (cw-thirdsize): a teammate flash at the drawn muzzle is sized to his smaller gun */
'@

SubRx @'
      wc.save(); wc.translate(m.x,m.y); wc.rotate(m.a); wc.drawImage(s,-4*k,-8*k,32*k,16*k); wc.restore();
'@ @'
      var kz=k*(m.fz||1); wc.save(); wc.translate(m.x,m.y); wc.rotate(m.a); wc.drawImage(s,-4*kz,-8*kz,32*kz,16*kz); wc.restore();   // v28.xx (cw-thirdsize): at the size of the gun that fired it (fz)
'@

SubRx @'
    G.bullets.push({sx:sh.x,sy:sh.y,mzd:Math.max(0,gunMuzD(sh,wep)-17),x:sh.x+Math.cos(ang)*17,y:sh.y+Math.sin(ang)*17,
'@ @'
    G.bullets.push({sx:sh.x,sy:sh.y,mzd:Math.max(0,gunMuzD(sh,wep)-17),ly:shotLy(sh,wep),x:sh.x+Math.cos(ang)*17,y:sh.y+Math.sin(ang)*17,   // v28.xx (cw-thirdsize): ly, the height its tracer is drawn at, the gun line of the drawn body (drawing only)
'@

SubRx @'
_fb.sy=_fb.y-_fb.vy/_fv*17; }
'@ @'
_fb.sy=_fb.y-_fb.vy/_fv*17; } if(_mzw&&_fb&&_fb.fx&&_fb.x===(+a[0]||0)&&!pixOn()) _fb.ly=20*FIG_SCALE; /* v28.xx (cw-thirdsize): his tracer at the gun line of his drawn body, as in his own window */
'@

SubRx @'
    wc.beginPath(); wc.moveTo(b.x-b.vx/bm*_gtl,b.y-b.vy/bm*_gtl-12);
    wc.lineTo(b.x,b.y-12); wc.stroke();
    if(b.rkt){ wc.fillStyle='#fff3c8'; wc.beginPath(); wc.arc(b.x,b.y-12,4,0,6.2832); wc.fill(); }   // v28.xx (cw-rocket): the rocket has a hot head
    if(_trc>1){
      wc.strokeStyle='rgba(255,236,180,.9)'; wc.lineWidth=1;
      wc.beginPath(); wc.moveTo(b.x-b.vx/bm*14,b.y-b.vy/bm*14-12);
      wc.lineTo(b.x,b.y-12); wc.stroke();
'@ @'
    var _ly=(b.ly>0)?b.ly:12;   // v28.xx (cw-thirdsize): at the gun line of the drawn body that fired it (12 for a machine)
    wc.beginPath(); wc.moveTo(b.x-b.vx/bm*_gtl,b.y-b.vy/bm*_gtl-_ly);
    wc.lineTo(b.x,b.y-_ly); wc.stroke();
    if(b.rkt){ wc.fillStyle='#fff3c8'; wc.beginPath(); wc.arc(b.x,b.y-_ly,4,0,6.2832); wc.fill(); }   // v28.xx (cw-rocket): the rocket has a hot head
    if(_trc>1){
      wc.strokeStyle='rgba(255,236,180,.9)'; wc.lineWidth=1;
      wc.beginPath(); wc.moveTo(b.x-b.vx/bm*14,b.y-b.vy/bm*14-_ly);
      wc.lineTo(b.x,b.y-_ly); wc.stroke();
'@

SubRx @'
    wc.save(); wc.translate(ct.x,ct.y-2); wc.rotate(ba);
'@ @'
    wc.save(); wc.translate(ct.x,ct.y-2); wc.rotate(ba); var _ck=figK1(); if(_ck!==1) wc.scale(_ck,_ck);   // v28.xx (cw-thirdsize), his order of 2026-10-20 ("scaled properly compared to bodies on ground"): the body lies at the size of a standing pillager (the figure scale on the world canvas; the pixel bake keeps its own size)
'@

SubRx @'
  shadowE(ct.x,ct.y+1,w*.62,3.5,.35);
'@ @'
  var _cs=(ct.type==='body'&&ct.carcass!=='deer'&&!(ct.bot&&WRECKDRAW[ct.bot]))?figK1():1; shadowE(ct.x,ct.y+1,w*.62*_cs,3.5*_cs,.35);   // v28.xx (cw-thirdsize): a body on the ground lies on a shadow of its own size
'@

SubRx @'
if(sh&&wep&&isFinite(ang)){ try{ mz=gunMuzzleAt(sh,wep,ang); }catch(_mz){} }
'@ @'
if(sh&&wep&&isFinite(ang)){ try{ mz=gunMuzzleAt(sh,wep,ang); }catch(_mz){} } if(!mz&&sh&&sh.kind==='stray'&&!pixOn()) mz={x:b.x,y:b.y-shotLy(sh,wep)};   /* v28.xx (cw-thirdsize): the survivor (no gun drawn) sends his flash point too, so the partner window draws his flash and tracer at his smaller size, as his own window does */
'@

SubRx @'
function worldSideCue(x,y,st){
'@ @'
function worldSideCue(x,y,st,face){   // v28.xx (cw-thirdsize): face, the aim of the body it marks
'@

SubRx @'
  worldSideCue(x,y,st);
'@ @'
  worldSideCue(x,y,st,face);   // v28.xx (cw-thirdsize): the mark sits on the side away from his aim
'@

SubRx @'
          var sgr=wc.createRadialGradient(e2.x,e2.y-14,2,e2.x,e2.y-14,40);
          sgr.addColorStop(0,'#7fc4a0'); sgr.addColorStop(1,'rgba(0,0,0,0)');
          wc.fillStyle=sgr; wc.beginPath(); wc.arc(e2.x,e2.y-14,40,0,6.2832); wc.fill();
'@ @'
          var _hk=pixOn()?1:FIG_SCALE/0.8, sgr=wc.createRadialGradient(e2.x,e2.y-14*_hk,2,e2.x,e2.y-14*_hk,40*_hk);   // v28.xx (cw-thirdsize): the glow follows his drawn body (it was fitted to the 0.8 body, so its middle sat at the head of the smaller one); the pixel look keeps its own
          sgr.addColorStop(0,'#7fc4a0'); sgr.addColorStop(1,'rgba(0,0,0,0)');
          wc.fillStyle=sgr; wc.beginPath(); wc.arc(e2.x,e2.y-14*_hk,40*_hk,0,6.2832); wc.fill();
'@

SubRx @'
      var _sp=w2s(_se.x,40,_se.y), _hsG=hudAtIn(_sp.x,_sp.y);   // v22.66 (R24): grows with the screen, as every world prompt
'@ @'
      var _sp=w2s(_se.x,pixOn()?40:figHudLift(66),_se.y), _hsG=hudAtIn(_sp.x,_sp.y);   // v22.66 (R24): grows with the screen, as every world prompt   // v28.xx (cw-thirdsize): over the drawn head of the smaller survivor at 1080, at 4K and aimed in (a fixed 40 was on his head at 4K); the pixel look keeps 40
'@

SubRx @'
var VER='34.89';
'@ @'
var VER='34.90';
'@

$pat = "(?m)^  now:'v34\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.90: Every pillager, bot, hire and body is drawn at a third of the size you saw on the old copy (build 33.17), about half of the size on the newest build (drawing only: hit areas, walking and doors keep their old size). Name plates, party tags, the shields, the muzzle flash and the tracers, the golden pillager, the fire and ice of forged guns, the survivor glow and the bodies on the ground follow the smaller body; the side mark beside a bot sits on the side away from his gun; the reload bar, the grenade timer and the give prompt sit just over the head on the 4K screen and when aiming too (on the newest build the reload bar was drawn across his head at 4K); the P1 and P2 seat rings and the red downed ring keep their full size so they still read. Watch for: the small body being hard to spot in a fight or on the big screen, the smaller muzzle flash being easy to miss on the TV, shots that look like misses still hitting (the hit circle is now much bigger than the body), the crowbar reaching further than its swing looks, with superhot holding time a shot that has not moved yet drawing its tracer over the front half of the gun, the smaller survivor glow being easy to miss, the round hatch you ascend from looking big under you, the Undercroft crowd looking small next to the stations, and the deer and the trees looking big next to him. Check 34.90 fails on v34.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
