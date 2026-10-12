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

# LAMPS THROW COLOURED LIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gfxLightOn(){ gfxHook('light'); return false; }   // B: true hands the light to gfxLightPass; false is the CLASSIC sheet
function gfxLightPass(dt,BR){ return false; }   // B: the coloured light map
'@ @'
// v23.xx (gfx7), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff", item 1, real lighting, and his answer 20
// (a): gritty and grounded, like ARC Raiders. THE COLOURED LIGHT MAP. A lamp's colour only ever reached the screen as two faint
// flat discs: the darkness sheet was colourless and every lamp punched a grey hole in it. Under LIGHTING HIGH or STANDARD the light
// pass builds a light map instead (LMAP, the size of the soft sheets): an ambient grey of exactly the CLASSIC sheet's strength,
// every lamp added in its own colour, and the world multiplied by it. The tint is the lamp colour normalised to hold luminance (the
// rule written at the darkness sheet: hold luminance, move hue) with its saturation pushed, so a sodium post throws amber and a
// FOUNDRY lamp throws cold blue. His lamp, the teammate's, gunfire and blasts, hunting machines in sight and the beacon add white,
// as their holes did. The sheet's indigo and the blacks lift are added after, as before, so ground away from every lamp is what
// CLASSIC drew, and each lamp's two flat discs become one smooth pool of its colour with the same peak. CLASSIC keeps the old
// sheet verbatim (the else branch at the light wrap). Light never feeds the sim, so stealth and detection are untouched, and the
// map is drawn before the fog of war sheet, so nothing lights through the fog. A light pass that throws three times in one raid
// hands that raid back to CLASSIC instead of drawing a broken frame every frame.
var LMAP={c:null,x:null,tint:{},rgb:{},err:0,errG:null,last:'',n:0};
function gfxRgb(col){
  var k=String(col||''), v=LMAP.rgb[k], m, h;
  if(v) return v;
  m=/^#([0-9a-f]{3}|[0-9a-f]{6})$/i.exec(k); v=[255,255,255];
  if(m){
    h=m[1]; if(h.length===3) h=h.charAt(0)+h.charAt(0)+h.charAt(1)+h.charAt(1)+h.charAt(2)+h.charAt(2);
    v=[parseInt(h.slice(0,2),16),parseInt(h.slice(2,4),16),parseInt(h.slice(4,6),16)];
  }
  LMAP.rgb[k]=v; return v;
}
function gfxTint(col){
  var k=String(col||''), t=LMAP.tint[k], c, l, i;
  if(t) return t;
  c=gfxRgb(k); l=(.2126*c[0]+.7152*c[1]+.0722*c[2])/255; t=[1,1,1];
  if(l>.05) for(i=0;i<3;i++) t[i]=Math.max(.15,Math.min(2,1+(c[i]/255/l-1)*2.2));
  LMAP.tint[k]=t; return t;
}
// A soft round sprite, made once per colour and kept in the store registry: 'map' holds the tint at half strength (a light map
// stamp, drawn 'lighter' at twice the source's strength), 'glow' holds the lamp colour at the tint's saturation (its pool over the world).
function gfxLightSpr(col,kind){
  var st=gfxStore('lightspr'), key=kind+'|'+col, s=st.m[key], x, gr, c, t, l;
  if(s) return s;
  s=document.createElement('canvas'); s.width=s.height=128; x=s.getContext('2d');
  if(kind==='map'){ t=gfxTint(col); c=Math.round(t[0]*127.5)+','+Math.round(t[1]*127.5)+','+Math.round(t[2]*127.5); }
  else { t=gfxTint(col); l=gfxRgb(col); l=(.2126*l[0]+.7152*l[1]+.0722*l[2]); c=Math.min(255,Math.round(t[0]*l))+','+Math.min(255,Math.round(t[1]*l))+','+Math.min(255,Math.round(t[2]*l)); }   // the pool: the lamp colour pushed to the tint's saturation at its own luminance
  gr=x.createRadialGradient(64,64,0,64,64,64);
  gr.addColorStop(0,'rgba('+c+',1)'); gr.addColorStop(1,'rgba('+c+',0)');
  if(kind==='glow') gr.addColorStop(.45,'rgba('+c+',.4)');   // the pool: a bright core to under half its reach, as the CLASSIC discs held it
  x.fillStyle=gr; x.fillRect(0,0,128,128);
  st.m[key]=s; st.n++;
  return s;
}
function gfxLightFail(e){
  if(LMAP.errG!==G){ LMAP.errG=G; LMAP.err=0; }
  LMAP.err++; LMAP.last=String((e&&e.message)||e).slice(0,160);
}
function gfxLightOn(){
  if(!gfxHook('light')) return false;
  if(CFG.gfxLight===0) return false;   // CLASSIC
  if(LMAP.errG===G&&LMAP.err>=3) return false;
  return true;
}
function gfxLightPass(dt,BR,o){
  if(!o||!G||!wc) return false;
  var x, lw=litC.width, lh=litC.height, day=isDay(), a, S, sp, amb, lf, i, k, L, fk, fk2, wspr, M, F, fr, frr, E, er, plr, Zs, TD, prevOp,
      gx, gy, gr, F2, f2, gr2, EG, ox=o.ox, oy=o.oy, Z=o.Z, VW=o.VW, VH=o.VH, p=o.p, az=o.az, inb=o.inb, urg=o.urg||0;
  if(!LMAP.c){ LMAP.c=document.createElement('canvas'); LMAP.x=LMAP.c.getContext('2d'); }
  if(LMAP.c.width!==lw) LMAP.c.width=lw;
  if(LMAP.c.height!==lh) LMAP.c.height=lh;
  x=LMAP.x;
  a=day?clamp(DAY_SHEET/BR,.02,.2):clamp(NIGHT_SHEET/BR,.05,.82);   // the CLASSIC sheet's strength
  S=day?[22,28,54]:[7,7,26];                                       // and its colour
  function put(spr,X,Y,R,al){
    if(!(R>0)||!(al>0)) return;
    x.globalAlpha=Math.min(1,al); x.drawImage(spr,X-R,Y-R,R*2,R*2);
  }
  try{
    // 1. the light map: the sheet's ambient, then every source added in its colour, in world units on the small sheet
    x.setTransform(1,0,0,1,0,0); x.globalCompositeOperation='source-over'; x.globalAlpha=1;
    amb=Math.round(255*(1-a));
    x.fillStyle='rgb('+amb+','+amb+','+amb+')'; x.fillRect(0,0,lw,lh);
    Zs=Z*SOFTR; x.setTransform(Zs,0,0,Zs,-ox*Zs,-oy*Zs);
    x.globalCompositeOperation='lighter';
    lf=wx().lights*(day?tod().lights:1);
    for(i=0;i<G.lights.length;i++){
      L=G.lights[i];
      if(L.x<ox-L.r||L.x>ox+VW+L.r||L.y<oy-L.r||L.y>oy+VH+L.r) continue;
      fk=(L.fl?(.72+.28*Math.sin(G.t*11+L.f)*Math.sin(G.t*3.1+L.f*2)):1)*lf;
      if(fk<=0.02) continue;
      put(gfxLightSpr(L.c,'map'),L.x,L.y,L.r*fk,2*a*.85*L.i);
    }
    wspr=gfxLightSpr('#ffffff','map');
    plr=100*Math.min(1.5,BR);
    put(wspr,p.x,p.y,plr,2*a*clamp(.5*BR,.3,.9));
    if(CFG.sharedSight!==0&&NET.on){ try{ M=netMates(); for(k=0;k<M.length;k++) put(wspr,M[k].x,M[k].y,plr,2*a*.40); }catch(_ml){} }
    for(i=0;i<G.flashes.length;i++){
      F=G.flashes[i]; fr=1-F.t/F.life;
      if(fr<=0) continue;
      frr=F.r*(F.life>.3?(.35+.65*(1-fr)):1);
      if(F.x<ox-frr||F.x>ox+VW+frr||F.y<oy-frr||F.y>oy+VH+frr) continue;
      put(wspr,F.x,F.y,frr,2*a*.9*fr);
    }
    for(i=0;i<VIS.length;i++){   // VIS, never G.ents: an unseen machine is never lit through the fog
      E=VIS[i];
      if(E.state!=='chase'&&E.state!=='alarm') continue;
      if(E.x<ox-90||E.x>ox+VW+90||E.y<oy-90||E.y>oy+VH+90) continue;
      er=E.kind==='sentry'?76:(E.kind==='crawler'?54:44);
      put(wspr,E.x,E.y,er,2*a*.34);
    }
    if(az){
      k=inb?(90+120*urg):70;
      if(az.x>ox-k&&az.x<ox+VW+k&&az.y>oy-k&&az.y<oy+VH+k) put(wspr,az.x,az.y,k,2*a*(inb?.62:.30));
    }
    x.setTransform(1,0,0,1,0,0); x.globalAlpha=1; x.globalCompositeOperation='source-over';
    // 2. the world takes the light map, stretched back over the frame as the sheet was
    wc.globalAlpha=1; wc.globalCompositeOperation='multiply';
    wc.drawImage(LMAP.c,0,0,W,H);
    // 3. the sheet's own colour and the blacks lift, added (CLASSIC: the sheet over the world, then #05030b by night, #0d0904 by day),
    //    then the time of day cast and shade exactly as CLASSIC
    wc.globalCompositeOperation='lighter';
    sp=day?[13,9,4]:[5,3,11];
    wc.fillStyle='rgb('+Math.round(S[0]*a+sp[0])+','+Math.round(S[1]*a+sp[1])+','+Math.round(S[2]*a+sp[2])+')';
    wc.fillRect(0,0,W,H);
    TD=tod();
    if(day&&TD.add){ wc.globalAlpha=TD.addA; wc.fillStyle=TD.add; wc.fillRect(0,0,W,H); wc.globalAlpha=1; }
    if(day&&TD.dim){ prevOp=wc.globalCompositeOperation; wc.globalCompositeOperation='source-over'; wc.fillStyle=TD.dim; wc.fillRect(0,0,W,H); wc.globalCompositeOperation=prevOp; }
    // 4. the glows in the world: each lamp's smooth pool of its own colour (CLASSIC: two flat discs, the same peak), then the flash
    //    bloom, the eyes of hunting machines in sight and the beacon, as CLASSIC draws them
    wc.save(); wc.scale(Z,Z); wc.translate(-ox,-oy);
    try{
      for(i=0;i<G.lights.length;i++){
        L=G.lights[i]; gx=L.x; gy=L.y; gr=L.r*.42;
        if(gx<ox-gr||gx>ox+VW+gr||gy<oy-gr||gy>oy+VH+gr) continue;
        fk2=(L.fl?(.72+.28*Math.sin(G.t*11+L.f)):1)*lf;
        if(fk2<=0.02) continue;
        wc.globalAlpha=Math.min(1,(day?.075:.30)*fk2);
        wc.drawImage(gfxLightSpr(L.c,'glow'),gx-gr,gy-gr,gr*2,gr*2);
      }
      for(i=0;i<G.flashes.length;i++){
        F2=G.flashes[i]; f2=1-F2.t/F2.life;
        if(f2<=0) continue;
        gx=F2.x; gy=F2.y; gr2=F2.r*.42*(F2.life>.3?(.4+.6*(1-f2)):1);
        if(gx<ox-gr2||gx>ox+VW+gr2||gy<oy-gr2||gy>oy+VH+gr2) continue;
        wc.globalAlpha=.30*f2; wc.fillStyle=F2.c||'#ffc27a';
        wc.beginPath(); wc.arc(gx,gy,gr2,0,6.2832); wc.fill();
      }
      for(i=0;i<VIS.length;i++){
        EG=VIS[i];
        if(EG.state!=='chase'&&EG.state!=='alarm') continue;
        if(EG.x<ox-60||EG.x>ox+VW+60||EG.y<oy-60||EG.y>oy+VH+60) continue;
        wc.globalAlpha=.13+.05*Math.sin(G.t*9);
        wc.fillStyle=EG.kind==='raider'?'#ff8a6a':'#ff4a32';
        wc.beginPath(); wc.arc(EG.x,EG.y-18,EG.kind==='sentry'?30:22,0,6.2832); wc.fill();
      }
      if(inb&&az){
        wc.globalAlpha=.10+.16*urg; wc.fillStyle='#4de3d0';
        wc.beginPath(); wc.arc(az.x,az.y,60+70*urg,0,6.2832); wc.fill();
      }
    } finally { wc.restore(); }
    LMAP.n++;
  } finally {
    x.setTransform(1,0,0,1,0,0); x.globalAlpha=1; x.globalCompositeOperation='source-over';
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }
  return true;
}
'@

SubRx @'
  // v23.xx (gfx2): THE LIGHT WRAP. gfxLightOn() true hands the light to gfxLightPass; false (always, in this build) runs the
  // CLASSIC darkness sheet and warm glows below exactly as v23.58 drew them. BR stays above the wrap: the fog pass reads it.
  var _gfxL=false; try{ _gfxL=gfxLightOn(); }catch(_glo){ _gfxL=false; }
  if(_gfxL){ try{ gfxLightPass(dt,BR); }catch(_glp){} } else {
'@ @'
  // v23.xx (gfx2): THE LIGHT WRAP. gfxLightOn() true hands the light to gfxLightPass; false runs the
  // CLASSIC darkness sheet and warm glows below exactly as v23.58 drew them. BR stays above the wrap: the fog pass reads it.
  // v23.xx (gfx7): true under LIGHTING HIGH and STANDARD, the coloured light map; the pass is handed this frame's camera
  var _gfxL=false; try{ _gfxL=gfxLightOn(); }catch(_glo){ _gfxL=false; }
  if(_gfxL){ try{ gfxLightPass(dt,BR,{ox:ox,oy:oy,Z:Z,VW:VW,VH:VH,p:p,az:az,inb:inb,urg:urg}); }catch(_glp){ try{ gfxLightFail(_glp); }catch(_glf){} } } else {
'@

SubRx @'
var VER='24.06';
'@ @'
var VER='24.07';
'@

$pat = "(?m)^  now:'v24\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.07: Lamps now light the ground in their own colour, amber posts and cold blue foundry lamps, with night exactly as dark as before. Check 24.07 fails on v24.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
