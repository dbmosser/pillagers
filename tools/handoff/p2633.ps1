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

# THE WHEEL HAS EIGHT FIXED SLOTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHEEL_ORDER=['frag','smoke','decoy','trip','bandage','medkit','stim','plate'];
'@ @'
// v26.xx (wheelfixed), HIS ORDER 2026-10-14 ("yes fixed 8 slot ring"): THE WHEEL IS ALWAYS THE SAME EIGHT SLOTS IN THE SAME PLACES, so a hand
// learns where each thing is. Clockwise from the top: TOP the medkit, TOP-RIGHT the frag, RIGHT the smoke, BOTTOM-RIGHT the decoy, BOTTOM the
// armour plate, BOTTOM-LEFT the tripwire, LEFT the stim, TOP-LEFT the bandage (throwables on the right, medical on the left, the plate
// underneath). Whatever he carries, in the backpack or the pouch, fills its slot by itself: nothing is set up or assigned. A type he has none
// of still has its slot, dimmed with a 0, and letting go on it takes nothing out. DEMO and CAREER lay it out the same; nothing is saved.
var WHEEL_ORDER=['medkit','frag','smoke','decoy','plate','trip','stim','bandage'];
'@

SubRx @'
function wheelList(){
  var out=[], i, n;
  for(i=0;i<WHEEL_ORDER.length;i++){ n=wheelHave(WHEEL_ORDER[i]); if(n>0) out.push({k:WHEEL_ORDER[i],n:n}); }
  return out;
}
'@ @'
function wheelList(){
  var out=[], i;
  for(i=0;i<WHEEL_ORDER.length;i++) out.push({k:WHEEL_ORDER[i],n:wheelHave(WHEEL_ORDER[i])});
  return out;
}
function wheelAny(list){
  var i;
  for(i=0;list&&i<list.length;i++) if(list[i].n>0) return true;
  return false;
}
'@

SubRx @'
  if(!list.length){ say('NOTHING TO USE'); return false; }
'@ @'
  if(!wheelAny(list)){ say('NOTHING TO USE'); return false; }
'@

SubRx @'
  if(w.sel<0||!w.list||!w.list[w.sel]) return false;
  return wheelPick(w.list[w.sel].k);
'@ @'
  if(w.sel<0||!w.list||!w.list[w.sel]) return false;
  if(!(wheelHave(w.list[w.sel].k)>0)){ say(('NO '+ITEMS[w.list[w.sel].k].name).toUpperCase()); return false; }   // v26.xx (wheelfixed): the slot is there, and empty
  return wheelPick(w.list[w.sel].k);
'@

SubRx @'
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
'@ @'
function drawWheel(){
  var w=G&&G.wheel, p=G&&G.player, m, gm, R, ri, sc, sk, j, seg, ac, a0, a1, gap, ro, k, it, cx, cy, fade, rm, ix, iy, sz, rim, on, hv, ok, gr, i, sel, nm, tw, bx, by, hk, lift, ph, ca, ck, chord, kk;
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
    k=w.list[j].k; it=ITEMS[k]; hv=(j===sel); ok=w.list[j].n>0; on=hv&&ok;
    ac=-Math.PI/2+j*seg; a0=ac-seg/2+gap/2; a1=ac+seg/2-gap/2;
    if(m===1){ a0=ac-Math.PI+0.001; a1=ac+Math.PI-0.001; }
    ro=on?R+lift:R;
    ctx.beginPath(); ctx.arc(cx,cy,ro,a0,a1); ctx.arc(cx,cy,ri,a1,a0,true); ctx.closePath();
    gr=ctx.createRadialGradient(cx,cy,ri,cx,cy,ro);
    if(on){ gr.addColorStop(0,'rgba(86,66,26,.96)'); gr.addColorStop(1,'rgba(52,40,16,.96)'); }
    else if(hv){ gr.addColorStop(0,'rgba(44,48,52,.92)'); gr.addColorStop(1,'rgba(28,31,34,.92)'); }
    else { gr.addColorStop(0,'rgba(34,38,41,.92)'); gr.addColorStop(1,'rgba(20,23,25,.92)'); }
    ctx.fillStyle=gr; ctx.fill();
    ctx.lineWidth=(on?LH(2.5):LH(1.5))*Math.min(sk,2); ctx.strokeStyle=on?UIC.acc:UIC.ui_line_hi; ctx.stroke();
    rim=null; try{ rim=RCOL[dispR(k)]; }catch(_rc){}
    if(rim){ ctx.globalAlpha=fade*(ok?1:0.35); ctx.beginPath(); ctx.arc(cx,cy,ro-LH(3)*sc,a0+0.03,a1-0.03); ctx.lineWidth=LH(3)*Math.min(sk,2); ctx.strokeStyle=rim; ctx.stroke(); ctx.globalAlpha=fade; }
    if(on){ ctx.beginPath(); ctx.arc(cx,cy,ri+LH(2)*sc,a0+0.02,a1-0.02); ctx.lineWidth=LH(3)*Math.min(sk,2); ctx.strokeStyle=UIC.acc; ctx.stroke(); }
    rm=(ri+ro)/2; sz=on?R*0.36:R*0.31; ix=cx+Math.cos(ac)*rm; iy=cy+Math.sin(ac)*rm-R*0.05;
    ctx.globalAlpha=fade*(ok?1:0.3);
    drawIconSprite(ctx,k,ix,iy,sz);
    ctx.globalAlpha=fade;
    ctx.textAlign='center';
    nm=String(it.name).toUpperCase();
    chord=(m>2)?2*rm*Math.sin(seg/2)*0.9:R;
    wheelFit(nm,TYPE.head,sk,chord);
    ctx.fillStyle=on?UIC.tx_1:(ok?UIC.tx_2:UIC.tx_3); hudText(nm,ix,iy+sz*0.5+LH(15)*sc);
    ctx.font=FSz(TYPE.head,sk*0.95); tw=ctx.measureText('x'+w.list[j].n).width+LH(14)*sk; ph=LH(24)*sk;
    bx=ix+sz*0.5-tw*0.35; by=iy-sz*0.5-ph*0.45;
    ctx.globalAlpha=fade*(ok?1:0.55);
    hudPlate(bx,by,tw,ph,null,'rgba(11,12,13,.9)');
    ctx.fillStyle=ok?UIC.acc:UIC.tx_3; ctx.fillText('x'+w.list[j].n,bx+tw/2,by+ph*0.74);
    ctx.globalAlpha=fade;
  }
  ctx.beginPath(); ctx.arc(cx,cy,ri-LH(8)*sc,0,Math.PI*2); ctx.fillStyle='rgba(11,12,13,.8)'; ctx.fill();
  ctx.lineWidth=LH(1.5)*Math.min(sk,2); ctx.strokeStyle=UIC.ui_line_hi; ctx.stroke();
  if(sel>=0&&w.list[sel]){
    ac=-Math.PI/2+sel*seg;
    ctx.beginPath(); ctx.moveTo(cx+Math.cos(ac)*(ri-LH(8)*sc),cy+Math.sin(ac)*(ri-LH(8)*sc));
    ctx.lineTo(cx+Math.cos(ac-0.16)*(ri-LH(20)*sc),cy+Math.sin(ac-0.16)*(ri-LH(20)*sc));
    ctx.lineTo(cx+Math.cos(ac+0.16)*(ri-LH(20)*sc),cy+Math.sin(ac+0.16)*(ri-LH(20)*sc));
    ctx.closePath(); ctx.fillStyle=(w.list[sel].n>0)?UIC.acc:UIC.tx_3; ctx.fill();
  }
  ctx.textAlign='center';
  chord=2*(ri-LH(16)*sc)*0.92;
  if(sel>=0&&w.list[sel]){
    k=w.list[sel].k; nm=String(ITEMS[k].name).toUpperCase(); ok=w.list[sel].n>0;
    wheelFit(nm,TYPE.head,sk*1.15,chord); ctx.fillStyle=ok?UIC.tx_1:UIC.tx_2; hudText(nm,cx,cy-LH(2)*sc);
    nm=ok?wheelBlurb(k):'NONE CARRIED'; wheelFit(nm,TYPE.label,sk,chord); ctx.fillStyle=ok?UIC.acc:UIC.tx_3; hudText(nm,cx,cy+LH(20)*sc);
  } else {
    ctx.font=FSz(TYPE.head,sk*1.15); ctx.fillStyle=UIC.tx_2; hudText('ITEMS',cx,cy-LH(2)*sc);
    ctx.font=FSz(TYPE.label,sk); ctx.fillStyle=UIC.tx_3; hudText('AIM TO CHOOSE',cx,cy+LH(20)*sc);
  }
  hk=padOn()?'D-DOWN':String(keyLabel('KeyQ','Q'));
  kk=Math.min(sk,2.4); by=cy-R-LH(38)*sc;
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
var VER='26.32';
'@ @'
var VER='26.33';
'@

$pat = "(?m)^  now:'v26\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.33: The item wheel now has eight fixed slots, and an empty one shows dim with a 0. Check 26.33 fails on v26.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
