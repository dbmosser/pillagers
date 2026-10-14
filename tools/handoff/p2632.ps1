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

# THE WHEEL IN THE MIDDLE, BIGGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.wheel={t:0,list:list,sel:-1,mx:mouse.x,my:mouse.y,d:0};
  return true;
}
'@ @'
  G.wheel={t:0,list:list,sel:-1,mx:W/2,my:H/2,ox:mouse.x,oy:mouse.y,armed:0,d:0};   // v26.xx (wheelcenter): mx,my is the wheel centre (the screen centre); ox,oy is where the mouse was when Q went down
  return true;
}
// v26.xx (wheelcenter), HIS NOTE 2026-10-14 after playing the wheel: "the wheel is pretty awesome but it needs to show in the middle of the screen
// and larger insetad of on top of the player". It was drawn over the player, wherever he stood, at a fixed HUD step that did not grow with a big
// screen (275 px at 1080p and the same 275 at 4K). The ring is now centred on the screen and its radius is a share of the shorter side of it
// (32 percent), so it grows with the screen; the pictures, names and counts grow with it (sc is the growth over the old size). The mouse picks
// by its direction from the screen centre, a dead zone in the hub (dz) cancels, and nothing is picked until the mouse has moved a little from
// where it was when Q went down (armed), so a tap of Q with the cursor off to one side picks nothing. The wheel is read from W and H each
// frame, so a resized window keeps it centred.
function wheelGeom(){
  var R=Math.round(Math.min(W,H)*0.32), ri=Math.round(R*0.42);
  return {cx:W/2,cy:H/2,R:R,ri:ri,dz:Math.max(LH(28),Math.round(ri*0.4)),sc:R/Math.max(1,LH(176))};
}
// A line of text at the wheel's size (z times the HUD step), shrunk to fit maxw when it is wider. Sets ctx.font and returns it.
function wheelFit(s,spec,z,maxw){
  var f=FSz(spec,z), tw;
  ctx.font=f; tw=ctx.measureText(s).width;
  if(maxw>0&&tw>maxw){ f=FSz(spec,z*maxw/tw); ctx.font=f; }
  return f;
}
'@

SubRx @'
  var w=G&&G.wheel, p=G&&G.player, dx, dy, d, m;
'@ @'
  var w=G&&G.wheel, p=G&&G.player, dx, dy, d, m, gm;
'@

SubRx @'
  else { dx=mouse.x-w.mx; dy=mouse.y-w.my; d=Math.sqrt(dx*dx+dy*dy); w.sel=(d<LH(28))?-1:wheelAt(m,dx,dy); }
'@ @'
  else {   // v26.xx (wheelcenter): the direction is measured from the screen centre, and not before the mouse has moved from where it was at Q down
    gm=wheelGeom(); w.mx=gm.cx; w.my=gm.cy;
    dx=mouse.x-w.mx; dy=mouse.y-w.my; d=Math.sqrt(dx*dx+dy*dy);
    if(!w.armed&&Math.abs(mouse.x-w.ox)+Math.abs(mouse.y-w.oy)>=LH(10)) w.armed=1;
    w.sel=(!w.armed||d<gm.dz)?-1:wheelAt(m,dx,dy);
  }
'@

SubRx @'
function drawWheel(){
  var w=G&&G.wheel, p=G&&G.player, m, R, ri, j, seg, ac, a0, a1, gap, ro, k, it, s, cx, cy, fade, rm, ix, iy, sz, rim, on, gr, i, sel, nm, tw, bx, by, hk;
  if(!w||!w.list||!w.list.length||!p) return;
  m=w.list.length; R=Math.round(Math.min(LH(176),H*0.31)); ri=Math.round(R*0.42);
  fade=Math.min(1,w.t/0.10);
  cx=W/2; cy=H*0.5;
  try{ s=w2s(p.x,0,p.y); if(isFinite(s.x)&&isFinite(s.y)){ cx=clamp(s.x,R+LH(24),W-R-LH(40)); cy=clamp(s.y-LH(14),R+LH(24),H-R-LH(60)); } }catch(_ws){}
  seg=Math.PI*2/m; gap=(m>1)?0.05:0; sel=w.sel;
  ctx.save();
  ctx.globalAlpha=fade;
  gr=ctx.createRadialGradient(cx,cy,ri,cx,cy,Math.max(W,H)*0.62);
  gr.addColorStop(0,'rgba(5,7,9,.28)'); gr.addColorStop(1,'rgba(5,7,9,.62)');
  ctx.fillStyle=gr; ctx.fillRect(0,0,W,H);
  ctx.strokeStyle='rgba(74,82,87,.7)'; ctx.lineWidth=LH(1.5);
  for(i=0;i<48;i++){
    a0=i*Math.PI/24;
    ctx.beginPath(); ctx.moveTo(cx+Math.cos(a0)*(R+LH(18)),cy+Math.sin(a0)*(R+LH(18))); ctx.lineTo(cx+Math.cos(a0)*(R+LH(18)+((i%6===0)?LH(7):LH(3.5))),cy+Math.sin(a0)*(R+LH(18)+((i%6===0)?LH(7):LH(3.5)))); ctx.stroke();
  }
  for(j=0;j<m;j++){
    k=w.list[j].k; it=ITEMS[k]; on=(j===sel);
    ac=-Math.PI/2+j*seg; a0=ac-seg/2+gap/2; a1=ac+seg/2-gap/2;
    if(m===1){ a0=ac-Math.PI+0.001; a1=ac+Math.PI-0.001; }
    ro=on?R+LH(12):R;
    ctx.beginPath(); ctx.arc(cx,cy,ro,a0,a1); ctx.arc(cx,cy,ri,a1,a0,true); ctx.closePath();
    gr=ctx.createRadialGradient(cx,cy,ri,cx,cy,ro);
    if(on){ gr.addColorStop(0,'rgba(86,66,26,.97)'); gr.addColorStop(1,'rgba(52,40,16,.97)'); }
    else { gr.addColorStop(0,'rgba(34,38,41,.94)'); gr.addColorStop(1,'rgba(20,23,25,.94)'); }
    ctx.fillStyle=gr; ctx.fill();
    ctx.lineWidth=on?LH(2.5):LH(1.5); ctx.strokeStyle=on?UIC.acc:UIC.ui_line_hi; ctx.stroke();
    rim=null; try{ rim=RCOL[dispR(k)]; }catch(_rc){}
    if(rim){ ctx.beginPath(); ctx.arc(cx,cy,ro-LH(3),a0+0.03,a1-0.03); ctx.lineWidth=LH(3); ctx.strokeStyle=rim; ctx.stroke(); }
    if(on){ ctx.beginPath(); ctx.arc(cx,cy,ri+LH(2),a0+0.02,a1-0.02); ctx.lineWidth=LH(3); ctx.strokeStyle=UIC.acc; ctx.stroke(); }
    rm=(ri+ro)/2; ix=cx+Math.cos(ac)*rm; iy=cy+Math.sin(ac)*rm-LH(9);
    sz=on?LH(60):LH(50);
    ctx.globalAlpha=fade*(w.list[j].n>0?1:0.3);
    drawIconSprite(ctx,k,ix,iy,sz);
    ctx.globalAlpha=fade;
    ctx.textAlign='center';
    ctx.font=FS(TYPE.micro); nm=String(it.name).toUpperCase();
    ctx.fillStyle=on?UIC.tx_1:UIC.tx_2; hudText(nm,ix,iy+sz*0.5+LH(13));
    ctx.font=FS(TYPE.label); tw=ctx.measureText('x'+w.list[j].n).width+LH(10);
    bx=ix+sz*0.5-tw*0.35; by=iy-sz*0.5;
    hudPlate(bx,by-LH(8),tw,LH(18),null,'rgba(11,12,13,.88)');
    ctx.fillStyle=UIC.acc; ctx.fillText('x'+w.list[j].n,bx+tw/2,by+LH(5));
  }
  ctx.beginPath(); ctx.arc(cx,cy,ri-LH(8),0,Math.PI*2); ctx.fillStyle='rgba(11,12,13,.92)'; ctx.fill();
  ctx.lineWidth=LH(1.5); ctx.strokeStyle=UIC.ui_line_hi; ctx.stroke();
  if(sel>=0&&w.list[sel]){
    ac=-Math.PI/2+sel*seg;
    ctx.beginPath(); ctx.moveTo(cx+Math.cos(ac)*(ri-LH(8)),cy+Math.sin(ac)*(ri-LH(8)));
    ctx.lineTo(cx+Math.cos(ac-0.16)*(ri-LH(18)),cy+Math.sin(ac-0.16)*(ri-LH(18)));
    ctx.lineTo(cx+Math.cos(ac+0.16)*(ri-LH(18)),cy+Math.sin(ac+0.16)*(ri-LH(18)));
    ctx.closePath(); ctx.fillStyle=UIC.acc; ctx.fill();
  }
  ctx.textAlign='center';
  if(sel>=0&&w.list[sel]){
    k=w.list[sel].k;
    ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_1; hudText(String(ITEMS[k].name).toUpperCase(),cx,cy-LH(4));
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.acc; hudText(wheelBlurb(k),cx,cy+LH(13));
  } else {
    ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_2; hudText('ITEMS',cx,cy-LH(4));
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_3; hudText('AIM TO CHOOSE',cx,cy+LH(13));
  }
  hk=padOn()?'D-DOWN':String(keyLabel('KeyQ','Q'));
  ctx.font=FS(TYPE.label); tw=ctx.measureText('RELEASE TO TAKE OUT').width+LH(52);
  by=cy+R+LH(40);
  hudPlate(cx-tw/2,by-LH(16),tw,LH(26),null,HUDC.plate);
  hudKey(hk,cx-tw/2+LH(8),by+LH(2),LH(9),LH(34));
  ctx.textAlign='left'; ctx.fillStyle=UIC.tx_1; hudText('RELEASE TO TAKE OUT',cx-tw/2+LH(46),by+LH(2));
  ctx.textAlign='left';
  ctx.restore();
}
'@ @'
// v26.xx (wheelcenter): the same wheel, drawn on the middle of the screen at wheelGeom's size. The backdrop is a light vignette round the ring
// (it fades to nothing by twice the radius), so the world and what is coming stay in view; the hint line sits above the ring, clear of the belt.
function drawWheel(){
  var w=G&&G.wheel, p=G&&G.player, m, gm, R, ri, sc, sk, j, seg, ac, a0, a1, gap, ro, k, it, cx, cy, fade, rm, ix, iy, sz, rim, on, gr, i, sel, nm, tw, bx, by, hk, lift, ph, ca, ck, chord, kk;
  if(!w||!w.list||!w.list.length||!p) return;
  m=w.list.length; gm=wheelGeom(); R=gm.R; ri=gm.ri; cx=gm.cx; cy=gm.cy; sc=gm.sc; sk=Math.max(1,sc);
  fade=Math.min(1,w.t/0.10); seg=Math.PI*2/m; gap=(m>1)?0.045:0; sel=w.sel; lift=LH(14)*sc; ck=R+LH(18)*sc;
  ctx.save();
  ctx.globalAlpha=fade;
  gr=ctx.createRadialGradient(cx,cy,R*0.9,cx,cy,R*2.3);
  gr.addColorStop(0,'rgba(5,7,9,.34)'); gr.addColorStop(1,'rgba(5,7,9,0)');
  ctx.fillStyle=gr; ctx.fillRect(0,0,W,H);
  ctx.strokeStyle='rgba(74,82,87,.7)'; ctx.lineWidth=LH(1.5)*Math.min(sk,2);
  for(i=0;i<48;i++){
    a0=i*Math.PI/24; ca=(i%6===0)?LH(7)*sc:LH(3.5)*sc;
    ctx.beginPath(); ctx.moveTo(cx+Math.cos(a0)*ck,cy+Math.sin(a0)*ck); ctx.lineTo(cx+Math.cos(a0)*(ck+ca),cy+Math.sin(a0)*(ck+ca)); ctx.stroke();
  }
  for(j=0;j<m;j++){
    k=w.list[j].k; it=ITEMS[k]; on=(j===sel);
    ac=-Math.PI/2+j*seg; a0=ac-seg/2+gap/2; a1=ac+seg/2-gap/2;
    if(m===1){ a0=ac-Math.PI+0.001; a1=ac+Math.PI-0.001; }
    ro=on?R+lift:R;
    ctx.beginPath(); ctx.arc(cx,cy,ro,a0,a1); ctx.arc(cx,cy,ri,a1,a0,true); ctx.closePath();
    gr=ctx.createRadialGradient(cx,cy,ri,cx,cy,ro);
    if(on){ gr.addColorStop(0,'rgba(86,66,26,.96)'); gr.addColorStop(1,'rgba(52,40,16,.96)'); }
    else { gr.addColorStop(0,'rgba(34,38,41,.92)'); gr.addColorStop(1,'rgba(20,23,25,.92)'); }
    ctx.fillStyle=gr; ctx.fill();
    ctx.lineWidth=(on?LH(2.5):LH(1.5))*Math.min(sk,2); ctx.strokeStyle=on?UIC.acc:UIC.ui_line_hi; ctx.stroke();
    rim=null; try{ rim=RCOL[dispR(k)]; }catch(_rc){}
    if(rim){ ctx.beginPath(); ctx.arc(cx,cy,ro-LH(3)*sc,a0+0.03,a1-0.03); ctx.lineWidth=LH(3)*Math.min(sk,2); ctx.strokeStyle=rim; ctx.stroke(); }
    if(on){ ctx.beginPath(); ctx.arc(cx,cy,ri+LH(2)*sc,a0+0.02,a1-0.02); ctx.lineWidth=LH(3)*Math.min(sk,2); ctx.strokeStyle=UIC.acc; ctx.stroke(); }
    rm=(ri+ro)/2; sz=on?R*0.36:R*0.31; ix=cx+Math.cos(ac)*rm; iy=cy+Math.sin(ac)*rm-R*0.05;
    ctx.globalAlpha=fade*(w.list[j].n>0?1:0.3);
    drawIconSprite(ctx,k,ix,iy,sz);
    ctx.globalAlpha=fade;
    ctx.textAlign='center';
    nm=String(it.name).toUpperCase();
    chord=(m>2)?2*rm*Math.sin(seg/2)*0.9:R;
    wheelFit(nm,TYPE.head,sk,chord);
    ctx.fillStyle=on?UIC.tx_1:UIC.tx_2; hudText(nm,ix,iy+sz*0.5+LH(15)*sc);
    ctx.font=FSz(TYPE.head,sk*0.95); tw=ctx.measureText('x'+w.list[j].n).width+LH(14)*sk; ph=LH(24)*sk;
    bx=ix+sz*0.5-tw*0.35; by=iy-sz*0.5-ph*0.45;
    hudPlate(bx,by,tw,ph,null,'rgba(11,12,13,.9)');
    ctx.fillStyle=UIC.acc; ctx.fillText('x'+w.list[j].n,bx+tw/2,by+ph*0.74);
  }
  ctx.beginPath(); ctx.arc(cx,cy,ri-LH(8)*sc,0,Math.PI*2); ctx.fillStyle='rgba(11,12,13,.8)'; ctx.fill();
  ctx.lineWidth=LH(1.5)*Math.min(sk,2); ctx.strokeStyle=UIC.ui_line_hi; ctx.stroke();
  if(sel>=0&&w.list[sel]){
    ac=-Math.PI/2+sel*seg;
    ctx.beginPath(); ctx.moveTo(cx+Math.cos(ac)*(ri-LH(8)*sc),cy+Math.sin(ac)*(ri-LH(8)*sc));
    ctx.lineTo(cx+Math.cos(ac-0.16)*(ri-LH(20)*sc),cy+Math.sin(ac-0.16)*(ri-LH(20)*sc));
    ctx.lineTo(cx+Math.cos(ac+0.16)*(ri-LH(20)*sc),cy+Math.sin(ac+0.16)*(ri-LH(20)*sc));
    ctx.closePath(); ctx.fillStyle=UIC.acc; ctx.fill();
  }
  ctx.textAlign='center';
  chord=2*(ri-LH(16)*sc)*0.92;
  if(sel>=0&&w.list[sel]){
    k=w.list[sel].k; nm=String(ITEMS[k].name).toUpperCase();
    wheelFit(nm,TYPE.head,sk*1.15,chord); ctx.fillStyle=UIC.tx_1; hudText(nm,cx,cy-LH(2)*sc);
    nm=wheelBlurb(k); wheelFit(nm,TYPE.label,sk,chord); ctx.fillStyle=UIC.acc; hudText(nm,cx,cy+LH(20)*sc);
  } else {
    ctx.font=FSz(TYPE.head,sk*1.15); ctx.fillStyle=UIC.tx_2; hudText('ITEMS',cx,cy-LH(2)*sc);
    ctx.font=FSz(TYPE.label,sk); ctx.fillStyle=UIC.tx_3; hudText('AIM TO CHOOSE',cx,cy+LH(20)*sc);
  }
  hk=padOn()?'D-DOWN':String(keyLabel('KeyQ','Q'));
  kk=Math.min(sk,2.4); by=cy-R-LH(54)*sc;
  ctx.save(); ctx.translate(cx,by); ctx.scale(kk,kk);
  ctx.font=FS(TYPE.label); tw=ctx.measureText('RELEASE TO TAKE OUT').width+LH(52);
  hudPlate(-tw/2,-LH(16),tw,LH(26),null,HUDC.plate);
  hudKey(hk,-tw/2+LH(8),LH(2),LH(9),LH(34));
  ctx.textAlign='left'; ctx.fillStyle=UIC.tx_1; hudText('RELEASE TO TAKE OUT',-tw/2+LH(46),LH(2));
  ctx.restore();
  ctx.textAlign='left';
  ctx.restore();
}
'@

SubRx @'
var VER='26.31';
'@ @'
var VER='26.32';
'@

$pat = "(?m)^  now:'v26\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.32: The item wheel now opens in the middle of the screen and is much bigger. Check 26.32 fails on v26.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
