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

# BIG GUNS IN YOUR HANDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  var fl=Math.cos(face)<0?-1:1;
'@ @'
// v25.xx (bigguns1), HIS ORDER (2026-10-12): "guns in player's characters hands need to be bigger/look more impressive, everything is
// wayy too small". BIG GUNS. A rifle in your hands was 19 by 5 units with only 12 of them clear of the chest; pistol and SMG were a
// stub at the fist, and rifle, Scattergun and Support MG were one dark stick. Every gun class now has its own baked sprite at about
// one and a half times the length, drawn from the stock butt tucked into the chest out to the muzzle: Tacker and Scav Pistol about
// 19, Magnum, Sputter and Compact SMG 21, rifles 27 to 30, Scattergun 29, Support MG 33, Marksman 36, Longshot and Lance 40. Each is
// inked like the body, in a gun-metal ramp with one lit top edge and a cool rim light on its lower edge so it reads on a dark floor,
// with its own parts: magazines, the drum, the pump, scopes with a lit lens, rails, the suppressor, the coil rings. Held in two
// hands: the trigger hand on the grip, the far arm under the gun to the foregrip (both hands on the grip for a pistol); at a sprint
// it is carried low. Facing left the gun is mirrored so the magazine stays under the barrel and the scope on top; aiming up, the
// gun and both arms go behind the body instead of across the face. THE FORGE SHOWS: MK II wears a gold finish with a slow shine
// across the receiver; MK III adds its element, a lit strip along the barrel and a glow at the muzzle with its own motif (embers
// for FIRE, a flickering arc for SHOCK, a frost rim for CRYO, a swelling drip for ACID). The reload sends the far hand to this
// gun magazine well, and the spent magazine falls from there. Baked once per class, finish, tier and screen scale, so a body
// costs one image and a few hand rectangles a frame, fewer calls than before. Cosmetic only: no seeded draw (G.t only), and
// nothing a fight reads moves: bullets keep their spawn point, range and spread, and collision radii are unchanged.
var GUNSPR=null;
var GUNMAT={d:'#23282e',m:'#353c45',l:'#4a535d',w:'#5c4a34',W:'#7a6246',k:'#0e1013',y:'#d8a020',r:'#b83a2a',g:'#9fd8ff',c:'#5a3e86',v:'#d8b4ff',e:'#eef2f4'};
var GUNGOLD={d:'#8a6a1e',m:'#c9962c',l:'#e0ac3a'};
var GUNDEF=(function(){
  function R(x,y,w,h,m,f){ return ['r',x,y,w,h,m,f||'']; }
  function C(x,y,r,m,f){ return ['c',x,y,r,m,f||'']; }
  function P(a,m,f){ return ['p',a,m,f||'']; }
  function grip(x,m){ return P([x,2.2, x+2.6,2.2, x+2.0,6.2, x-0.6,6.2],m||'d'); }
  function cmag(x,y){ return P([x,y, x+2.8,y, x+4.0,y+6.3, x+1.2,y+6.7],'l','H'); }
  var D={};
  D.tacker={pist:1,tip:16.8,by:0,grip:4.4,fg:4.4,well:[8.5,2.8],port:[8,-2.75],rv:[3,-2.75,11,5.5],br:[14,16.8],p:[
    P([4,1.5, 7,1.5, 6.2,6, 3.4,6],'d'), R(5.5,2.75,6.5,1.4,'l'), R(3,-2.75,11,5.5,'m','FHR'), R(9,-2.75,2,5.5,'y','O'),
    R(14,-1.5,2.8,3,'d','H')]};
  D.pistol={pist:1,tip:17.2,by:-1.3,grip:4.2,fg:4.2,well:[5,6],port:[10,-2.6],rv:[3,-2.9,13.4,4.9],br:[12,17.2],p:[
    P([3.6,1.6, 6.8,1.6, 6.0,6.2, 2.8,6.2],'d'), R(6.8,1.6,2.6,1.5,'d'), R(3,-0.6,12.4,2.6,'m','R'), R(3,-2.9,13.4,2.4,'l','FH'),
    R(9,-2.6,2.2,0.9,'k','O'), R(16.4,-2.2,0.8,1.8,'d')]};
  D.magnum={pist:1,tip:20,by:0,grip:4.2,fg:4.2,well:[10,2.5],port:[10,-2.5],rv:[3,-2.4,7,4.6],br:[12,20],p:[
    P([3.4,1.4, 6.6,1.4, 5.6,6.6, 2.4,6.6],'w'), R(3,-2.4,7,4.6,'m','FHR'), R(12,-1.7,8,3.4,'m','HR'), R(12,-2.6,8,0.9,'d'),
    C(10,0,2.5,'l','F'), R(9,-0.3,2,0.6,'k','O'), R(18.6,-3.6,0.9,1.1,'d')]};
  D.sputter={tip:20,by:0,grip:5,fg:15.2,well:[11.2,2.8],port:[9,-2.8],rv:[3,-2.8,10,5.6],br:[13,20],p:[
    R(-3,-1.6,6,0.9,'d'), R(-3,-1.6,1,3.8,'d'), R(-3,1.3,6,0.9,'d'), grip(5), P([10,2.8, 12.4,2.8, 14.2,7, 11.8,7.4],'l','H'),
    R(3,-2.8,10,5.6,'m','FHR'), R(13,-1.9,4.6,3.8,'d','H'), R(14,-0.5,0.8,1,'k','OV'), R(15.6,-0.5,0.8,1,'k','OV'),
    R(17.6,-1.2,2.4,2.4,'m')]};
  D.smg={tip:21,by:0,grip:4.6,fg:16.5,well:[10.3,3],port:[8,-3],rv:[2.5,-3,11.5,6],br:[14,21],p:[
    R(-2.5,-2.2,5.5,1.8,'d'), R(-3,-2.6,1.3,4.6,'d'), grip(4.6), R(9,3,2.6,6,'l','H'), R(2.5,-3,11.5,6,'m','FHR'),
    R(14,-2,5,4,'d','H'), R(15,-0.6,0.9,1.2,'k','OV'), R(16.8,-0.6,0.9,1.2,'k','OV'), R(19,-1.2,2,2.4,'m')]};
  D.chatter={tip:26.5,by:0,grip:5,fg:16.5,well:[10.4,2.6],port:[9,-2.6],rv:[3,-2.6,10,5.2],br:[13,26.5],p:[
    grip(5), cmag(9,2.6), P([-3,-2.2, 3,-1.6, 3,2, -3,3],'d','F'), R(3,-2.6,10,5.2,'m','FHR'), R(13,-2,8,3.8,'d','HR'),
    R(20,-3.6,0.9,1.6,'d'), R(21,-1,5.5,2,'m','H')]};
  D.carbine={tip:26.4,by:0,grip:5,fg:17.5,well:[10.8,2.6],port:[9,-2.6],rv:[3,-2.6,11,5.2],br:[14,26.4],p:[
    grip(5), cmag(9.4,2.6), R(-3,-2.4,1.8,5,'d','F'), R(-1.2,-1.2,4.4,1.6,'d'), R(3,-2.6,11,5.2,'m','FHR'), R(14,-2,7,3.8,'l','FHR'),
    R(15.4,-2,0.8,0.8,'k','O'), R(17.2,-2,0.8,0.8,'k','O'), R(19,-2,0.8,0.8,'k','O'), R(21,-1,5.4,2,'m','H'),
    R(7,-4.8,3.6,2.2,'d','H'), R(10,-4.4,0.7,1.4,'r','O')]};
  D.rifle={tip:30,by:0,grip:5.2,fg:18.5,well:[11.4,2.7],port:[10,-2.7],rv:[3,-2.7,12,5.4],br:[15,30],p:[
    grip(5.2), cmag(10,2.7), P([-3,-2.4, 3,-2, 3,2.2, -3,3.4],'d','F'), R(3,-2.7,12,5.4,'m','FHR'), R(15,-2.2,9,4,'l','FHR'),
    R(16,-2.2,0.9,0.9,'k','O'), R(18,-2.2,0.9,0.9,'k','O'), R(20,-2.2,0.9,0.9,'k','O'), R(22,-2.2,0.9,0.9,'k','O'),
    R(22.8,-3.9,0.9,1.7,'d'), R(24,-1,4.8,2,'m','H'), R(28.6,-1.4,1.4,2.8,'d'),
    R(7,-2.9,4,0.5,'d','O'), R(6,-5,6,2.3,'d','H'), R(11.3,-4.7,0.7,1.7,'g','O')]};
  D.whisper={tip:29.4,by:0,grip:5,fg:16,well:[10.7,2.4],port:[9,-2.4],rv:[2.8,-2.4,11,4.8],br:[18.4,29.4],p:[
    grip(5), R(9.5,2.4,2.4,5.4,'l','H'), P([-3,-2, 2.8,-1.6, 2.8,1.8, -3,2.8],'d','F'), P([-1.8,-0.6, 1.4,-0.5, 1.4,0.7, -1.8,1.4],'k','O'),
    R(2.8,-2.4,11,4.8,'m','FHR'), R(13.8,-1.6,4.6,3.2,'d'), R(18.4,-2.2,11,4.4,'d','HR'), R(21.5,-2.2,0.6,4.4,'k','OV'),
    R(25,-2.2,0.6,4.4,'k','OV')]};
  D.scuttle={tip:21.2,by:0,grip:4.8,fg:13,well:[7,2.9],port:[7,-2.9],rv:[4,-2.9,6,5.8],br:[10,21.2],p:[
    P([-3,-1.8, 4.2,-1.8, 4.6,2.6, 1.6,2.6, -3,3.8],'w'), R(-2,0.2,5,0.5,'W','O'), R(4,-2.9,6,5.8,'m','FHR'),
    R(10,-2.4,10,2.3,'m','H'), R(10,-0.1,10,2.3,'l','R'), R(10.5,1.6,5.4,1.8,'W'), R(19.6,-2.9,1.6,5.6,'d')]};
  D.shotgun={tip:28.4,by:-1.3,grip:5,fg:17.5,well:[10,3],port:[8,-3],rv:[3,-3,9,6],br:[12,28.4],p:[
    grip(5), P([-3,-2.2, 3,-2, 3,2.4, -3,3.6],'w'), R(3,-3,9,6,'m','FHR'), R(5,-1.6,5,1.9,'d'), R(5.4,-1.4,1,1.5,'r','O'),
    R(7,-1.4,1,1.5,'r','O'), R(8.6,-1.4,1,1.5,'r','O'), R(12,0.1,13,2.2,'d','R'), R(12,-2.6,15.5,2.6,'m','H'), R(14,-0.4,7,4,'W','H'),
    R(15.2,0.1,0.6,3,'w','O'), R(17,0.1,0.6,3,'w','O'), R(18.8,0.1,0.6,3,'w','O'), R(26.8,-3,1.6,3.6,'d'), R(26,-3.7,0.8,0.8,'e','O')]};
  D.lmg={tip:32.6,by:0,grip:5.4,fg:19,well:[11,2],port:[10,-3.2],rv:[3,-3.2,13,6.4],br:[16,32.6],p:[
    grip(5.4), C(11,5.6,3.75,'l','F'), C(11,5.6,1.2,'d','O'), P([-3,-2.6, 3,-2.4, 3,2.6, -3,3.6],'d','F'), R(3,-3.2,13,6.4,'m','FHR'),
    R(7,-5.6,6,1.1,'d'), R(7,-5.6,1.1,2.5,'d'), R(11.9,-5.6,1.1,2.5,'d'), R(21,2.6,9.5,0.9,'d'), R(21.5,3.8,8.5,0.9,'d'),
    R(16,-2.4,11,4.8,'l','FHR'), R(18,-1.2,1.6,1.5,'k','OV'), R(21,-1.2,1.6,1.5,'k','OV'), R(24,-1.2,1.6,1.5,'k','OV'),
    R(27,-1.1,4,2.2,'m','H'), R(31,-1.7,1.6,3.4,'d')]};
  D.dmr={tip:35.6,by:0,grip:5.2,fg:20,well:[12.1,2.7],port:[10,-2.7],rv:[3,-2.7,13,5.4],br:[16,35.6],p:[
    grip(5.2), R(10.5,2.7,3.2,4.6,'l','H'), P([-3,-2.6, 3,-2.2, 3,2.4, -3,3.6],'d','F'), R(-2.4,-3.6,4,1.2,'l'), R(3,-2.7,13,5.4,'m','FHR'),
    R(16,-2.1,10,3.8,'l','FHR'), R(26,-0.9,7,1.8,'m','H'), R(33,-1.7,2.6,3.4,'d'), R(34,-1.7,0.6,3.4,'k','O'),
    R(7,-3.4,1,0.8,'d','O'), R(12.5,-3.4,1,0.8,'d','O'), R(4.5,-6.4,11,3,'d','H'), R(3.8,-6.8,1.4,3.8,'d'), R(14.6,-6.9,1.8,4,'d'),
    R(16,-6.6,0.7,3.4,'g','O')]};
  D.sniper={tip:39.3,by:0,grip:5.2,fg:20,well:[12.3,2.8],port:[10,-2.8],rv:[3,-2.8,12,5.6],br:[25,39.3],p:[
    grip(5.2), R(11,2.8,2.6,3,'l'), P([-3.4,-2.6, 3,-2.4, 3,2.4, -3.4,3.8],'d','F'), R(-2.6,-4,4.4,1.5,'l','F'), R(3,-2.8,12,5.6,'m','FHR'),
    R(9.2,2.6,0.8,2.2,'d'), C(9.6,5.2,1.2,'l','H'), R(15,-2,10,3.6,'l','FHR'), R(25,-0.8,11,1.6,'m','H'), R(26,-0.25,9,0.5,'k','OV'),
    R(36,-1.9,3.3,3.8,'d'), R(37.2,-1.9,0.6,3.8,'k','O'), R(6.5,-3.6,1.2,0.9,'d','O'), R(12.5,-3.6,1.2,0.9,'d','O'),
    R(3.5,-7,13,3.5,'d','H'), R(2.6,-7.4,1.8,4.3,'d'), R(14.8,-7.7,2.4,4.9,'d'), R(16.8,-7.3,0.8,4.1,'g','O'), R(16.9,-7.1,0.6,0.9,'e','O')]};
  D.lance={tip:39.6,by:0,grip:5.2,fg:21,well:[12,3],port:[10,-3],rv:[3,-3,13,6],br:[16,39.6],p:[
    grip(5.2), R(10.5,3,3,3.6,'c'), R(11,3.6,2,0.6,'v','O'), P([-3,-2.6, 3,-2.4, 3,2.6, -3,3.6],'d','F'), R(3,-3,13,6,'l','FHR'),
    R(16,-1.75,22,3.5,'m','HR'), R(16,-0.3,22,0.6,'v','O'), R(19,-2.6,1.4,5.2,'d'), R(23.6,-2.6,1.4,5.2,'d'), R(28.2,-2.6,1.4,5.2,'d'),
    R(32.8,-2.6,1.4,5.2,'d'), R(38,-2.1,1.6,4.2,'d'), R(6,-5.6,8,2.4,'d','H'), R(13.4,-5.3,0.7,1.8,'v','O')]};
  return D;
})();
function gunDef(w){ return GUNDEF[(w&&w.id)||'rifle']||GUNDEF.rifle; }
function gunPath(c,q){
  var a, i;
  c.beginPath();
  if(q[0]==='r') c.rect(q[1],q[2],q[3],q[4]);
  else if(q[0]==='c') c.arc(q[1],q[2],q[3],0,6.2832);
  else { a=q[1]; c.moveTo(a[0],a[1]); for(i=2;i<a.length;i+=2) c.lineTo(a[i],a[i+1]); c.closePath(); }
}
function gunBake(id,fk,el,rc,S){
  var st=GUNSPR||(GUNSPR=gfxStore('gun')), key=id+'|'+fk+'|'+el+'|'+rc+'|'+S, b=st.m[key], D, cv, c, i, q, mi, m, f, col, ec, rv;
  if(b) return b;
  D=GUNDEF[id]||GUNDEF.rifle; ec=(fk===2&&ELEM[el])?ELEM[el].c:null;
  b={x0:-5,y0:-10,w:D.tip+9,h:22};
  cv=document.createElement('canvas'); cv.width=Math.ceil(b.w*S); cv.height=Math.ceil(b.h*S);
  c=cv.getContext('2d'); c.scale(S,S); c.translate(-b.x0,-b.y0); c.lineJoin='round';
  for(i=0;i<D.p.length;i++){
    q=D.p[i]; mi=(q[0]==='r')?5:((q[0]==='c')?4:2); m=q[mi]; f=q[mi+1]||'';
    col=(fk&&f.indexOf('F')>=0&&GUNGOLD[m])?GUNGOLD[m]:(GUNMAT[m]||GUNMAT.m);
    if(ec&&f.indexOf('V')>=0) col=ec;
    gunPath(c,q);
    if(f.indexOf('O')<0){ c.strokeStyle=INK; c.lineWidth=1.4; c.stroke(); }
    c.fillStyle=col; c.fill();
    if(q[0]==='r'){
      if(f.indexOf('H')>=0){ c.fillStyle=(fk&&f.indexOf('F')>=0)?'#fff0b0':'#8d99a6'; c.fillRect(q[1],q[2],q[3],Math.min(0.8,q[4]/2)); }
      if(f.indexOf('R')>=0){ c.fillStyle=(el==='cryo'&&ec)?'rgba(238,250,255,.85)':'rgba(169,194,216,.55)'; c.fillRect(q[1],q[2]+q[4]-0.6,q[3],0.6); }
    } else if(q[0]==='c'&&f.indexOf('H')>=0){ c.strokeStyle='#8d99a6'; c.lineWidth=0.7; c.beginPath(); c.arc(q[1],q[2],q[3]-0.4,3.7,5.7); c.stroke(); }
  }
  rv=D.rv;
  if(rc){ c.fillStyle=rc; c.fillRect(rv[0]+0.8,rv[1]+rv[3]-1.7,Math.max(2,rv[2]-1.6),1); }
  if(fk){   // two small chevrons on the stock, the Forge mark
    c.fillStyle=fk===2?(ec||'#ffc94a'):'#fff0b0';
    for(i=0;i<fk;i++){ c.beginPath(); c.moveTo(-1.6+i*1.6,-0.9); c.lineTo(-0.6+i*1.6,0); c.lineTo(-1.6+i*1.6,0.9); c.lineTo(-2.2+i*1.6,0.9); c.lineTo(-1.2+i*1.6,0); c.lineTo(-2.2+i*1.6,-0.9); c.closePath(); c.fill(); }
  }
  if(ec){ c.fillStyle=ec; c.fillRect(D.br[0],D.by-0.3,D.br[1]-D.br[0]-0.6,0.6); }
  b.c=cv; st.m[key]=b; st.n++;
  return b;
}
function gunHeldOn(st,mode){ return !!(st&&st.hero)&&mode!=='none'&&mode!=='crouchnone'&&mode!=='fist'; }
function gunHeld(px,ty,face,fl,st,coat,bld,pc,ads,sprint,rl,muzzle){
  var w=(st&&st.own&&st.own.wep&&st.own.wep.id)?st.own.wep:null, id=(w&&GUNDEF[w.id])?w.id:'rifle', D=GUNDEF[id];
  var fk=(w&&(w.fk===1||w.fk===2))?w.fk:0, el=(fk===2&&w.el&&ELEM[w.el])?w.el:'';
  var wt=(w&&WTIER[w.id]!==undefined)?WTIER[w.id]:1;
  var rc=!w?'':((w.q==='gold')?'#ffc72e':(wt>=5?RCOL.gold:(wt>=4?RCOL.elite:(wt===3?RCOL.rare:(wt===2?RCOL.uncommon:RCOL.common)))));   // the tier colour, from the one rarity table
  var S=1, B, drop=0, reach=0, gy, ext, hc, aw, low, ang, sx, gx, t, k, f, tx, ty2, ec, i;
  try{ S=Math.min(5,wallSpriteScale()+1); }catch(_s){ S=2; }
  B=gunBake(id,fk,el,rc,S);
  if(rl>0){
    if(rl<.35) drop=(rl/.35)*.55;
    else if(rl<.78){ drop=.55; reach=(rl-.35)/.43; }
    else drop=.55*(1-(rl-.78)/.22);
  }
  low=!!(sprint&&!(rl>0));
  gy=ty-20+(ads?-1:0); ext=(D.pist?2:0)+(ads?2:(low?-2:0)); hc=handColour(st);
  aw=(bld==='broad')?3.3:(bld==='curved'?2.0:(pc?2.1:2.4));
  ang=face+fl*(drop+(low?0.45:0));
  wc.save(); wc.translate(px,gy); wc.rotate(ang); if(fl<0) wc.scale(1,-1);
  // the far arm, under the gun to the foregrip (to the magazine well while reloading; to the grip on a pistol)
  sx=(reach>0)?(D.well[0]+ext):(D.pist?(D.grip+ext+0.4):(D.fg+ext));
  if(!low){ wc.fillStyle=INK; wc.fillRect(-0.5,0.4,sx+0.6,3.8); wc.fillStyle=coat; wc.fillRect(0,0.9,sx-0.4,2.8); }
  wc.drawImage(B.c,B.x0+ext,B.y0,B.w,B.h);
  // the near arm along the gun to the grip, and the trigger hand on it
  gx=D.grip+ext-1.2;
  wc.fillStyle=INK; wc.fillRect(-1.2,-aw-0.5,gx+1.4,2*aw+1); wc.fillStyle=coat; wc.fillRect(-0.8,-aw,gx+0.8,2*aw);
  if(pc&&/^#[0-9a-fA-F]{6}$/.test(coat)){ wc.fillStyle=litHex(coat,.22,true); wc.fillRect(-0.8,-aw,gx+0.8,0.9); }
  if(st.merc||(st.own&&st.own.merc)){ wc.fillStyle=INK; wc.fillRect(1.3,-aw,2.4,2*aw); wc.fillStyle='#f0a020'; wc.fillRect(1.7,-aw,1.6,2*aw); wc.fillStyle='#ffd27a'; wc.fillRect(1.7,-aw,1.6,0.6); }
  wc.fillStyle=INK; wc.fillRect(gx-0.5,-0.1,4.4,4.4); wc.fillStyle=hc; wc.fillRect(gx,0.4,3.4,3.4);
  if(rl>0&&reach>0){
    tx=D.well[0]+ext-1.7; ty2=D.well[1]+(1-reach)*7;
    wc.fillStyle=INK; wc.fillRect(tx-0.1,ty2+1.4,3.6,5.2); wc.fillStyle=GUNMAT.l; wc.fillRect(tx+0.3,ty2+1.8,2.8,4.4);
    wc.fillStyle=INK; wc.fillRect(tx-0.5,ty2-0.5,4.4,4.4); wc.fillStyle=hc; wc.fillRect(tx,ty2,3.4,3.4);
  } else if(!low){
    tx=D.pist?(D.grip+ext+0.2):(D.fg+ext-1.7);
    wc.fillStyle=INK; wc.fillRect(tx-0.5,D.pist?0.9:-0.3,4.4,4.4); wc.fillStyle=hc; wc.fillRect(tx,D.pist?1.4:0.2,3.4,3.4);
  }
  // THE FORGE, live: a slow shine across a gold receiver, and on MK III the element at the muzzle (G.t only, never the raid stream)
  if(fk){
    t=(typeof G!=='undefined'&&G&&isFinite(G.t))?G.t:0; f=(t%2.5)/2.5;
    wc.globalCompositeOperation='lighter';
    if(f<0.5){ wc.fillStyle='rgba(255,240,176,.55)'; wc.fillRect(D.rv[0]+ext+(f/0.5)*(D.rv[2]-1.4),D.rv[1],1.4,D.rv[3]); }
    if(el){
      ec=ELEM[el].c; k=0.5+0.5*Math.sin(t*4.2); tx=D.tip+ext; ty2=D.by;
      wc.globalAlpha=0.28+0.22*k; wc.fillStyle=ec; wc.beginPath(); wc.arc(tx,ty2,2.2+k*1.1,0,6.2832); wc.fill(); wc.globalAlpha=1;
      if(el==='fire'){ for(i=0;i<2;i++){ f=((t*0.9+i*0.5)%1); wc.fillStyle='rgba(255,150,60,'+(0.9*(1-f)).toFixed(3)+')'; wc.fillRect(D.br[0]+ext+4+i*5+f*2,D.by-1.6-f*5,0.9,0.9); } }
      else if(el==='shock'){ i=Math.floor(t/0.2); if(i%3!==2){ f=(i*7)%5; wc.strokeStyle=ec; wc.lineWidth=0.6; wc.beginPath(); wc.moveTo(D.br[0]+ext+2+f,D.by-0.6); wc.lineTo(D.br[0]+ext+4.5+f,D.by-2.6+(i%2)*0.8); wc.lineTo(D.br[0]+ext+7+f,D.by-0.8); wc.stroke(); } }
      else if(el==='cryo'){ wc.fillStyle='rgba(220,245,255,.22)'; wc.fillRect(D.rv[0]+ext,D.rv[1]-0.8,D.br[1]-D.rv[0],0.8); }
      else if(el==='acid'){ f=(t%1.2)/1.2; wc.globalAlpha=f<0.6?0.9:Math.max(0,0.9-(f-0.6)*2.2); wc.fillStyle=ec; wc.beginPath(); wc.arc(tx-1,ty2+1.6+(f>0.6?(f-0.6)*14:0),0.5+Math.min(f,0.6)*1.4,0,6.2832); wc.fill(); wc.globalAlpha=1; }
    }
    wc.globalCompositeOperation='source-over';
  }
  if(muzzle>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,212,138,.95)';
    wc.beginPath(); wc.arc(D.tip+ext,D.by,4.5,0,6.2832); wc.fill();
    wc.fillRect(D.tip+ext-4,D.by-1,10,2);
    wc.globalCompositeOperation='source-over';
  }
  wc.restore();
  // the spent magazine falls from this gun magazine well
  if(rl>0&&rl<.4){
    var mg=rl/.4, wx=D.well[0]+ext, wy=(D.well[1]+2)*(fl<0?-1:1), mx=px+Math.cos(ang)*wx-Math.sin(ang)*wy, my=gy+Math.sin(ang)*wx+Math.cos(ang)*wy;
    wc.globalAlpha=clamp(1-mg,0,1); wc.fillStyle=GUNMAT.l;
    wc.save(); wc.translate(mx,my+mg*14); wc.rotate(mg*4.2); wc.fillRect(-1.4,-3,2.8,6); wc.restore();
    wc.globalAlpha=1;
  }
}
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  var fl=Math.cos(face)<0?-1:1;
'@

SubRx @'
  var pw=6+pk*5;
  if(!(OUTF&&OUTF.nopack)){
'@ @'
  // v25.xx (bigguns1): the held gun. Aiming up, the gun and both arms are drawn here, behind the pack, the body and the head.
  var _GH=gunHeldOn(st,mode), _GB=_GH&&Math.sin(face)<-0.3;
  if(_GB) gunHeld(x+leanX,ty,face,fl,st,coat,_BLD,_PC,ads,sprint,rl,muzzle);  var pw=6+pk*5;
  if(!(OUTF&&OUTF.nopack)){
'@

SubRx @'
  } else {
  // v7.77, his order: every family its own silhouette, the tier on the top
'@ @'
  } else if(_GH){
    wc.restore();   // v25.xx (bigguns1): the big held gun draws itself (gunHeld), in front of the body unless aiming up
    if(!_GB) gunHeld(x+leanX,ty,face,fl,st,coat,_BLD,_PC,ads,sprint,rl,muzzle);  } else {
  // v7.77, his order: every family its own silhouette, the tier on the top
'@

SubRx @'
  // spent magazine tumbling away at the start of the reload
  if(rl>0&&rl<.4){
'@ @'
  // spent magazine tumbling away at the start of the reload
  if(rl>0&&rl<.4&&!_GH){   // v25.xx (bigguns1): a big held gun drops its own from its well
'@

SubRx @'
var VER='25.25';
'@ @'
var VER='25.26';
'@

$pat = "(?m)^  now:'v25\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.26: The guns in your hands are bigger, every class has its own look, and a Forge gun shows its gold and its element. Check 25.26 fails on v25.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
