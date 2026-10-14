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

# THE WHEEL LOOKS THE PART (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawWheel(){
  var w=G&&G.wheel, p=G&&G.player, m, R, ri, j, seg, ac, a0, a1, gap, ro, k, it, s, cx, cy, fade, rm, ix, iy, sz, rim, nm, on, tx;
  if(!w||!w.list||!w.list.length||!p) return;
  m=w.list.length; R=Math.round(Math.min(LH(176),H*0.31)); ri=Math.round(R*0.42);
  fade=Math.min(1,w.t/0.10);
  cx=W/2; cy=H*0.5;
  try{ s=w2s(p.x,0,p.y); if(isFinite(s.x)&&isFinite(s.y)){ cx=clamp(s.x,R+LH(24),W-R-LH(24)); cy=clamp(s.y-LH(14),R+LH(24),H-R-LH(24)); } }catch(_ws){}
  seg=Math.PI*2/m; gap=(m>1)?0.05:0;
  ctx.save();
  ctx.globalAlpha=fade;
  ctx.fillStyle='rgba(5,7,9,.42)'; ctx.fillRect(0,0,W,H);
  for(j=0;j<m;j++){
    k=w.list[j].k; it=ITEMS[k]; on=(j===w.sel);
    ac=-Math.PI/2+j*seg; a0=ac-seg/2+gap/2; a1=ac+seg/2-gap/2;
    if(m===1){ a0=ac-Math.PI+0.001; a1=ac+Math.PI-0.001; }
    ro=on?R+LH(10):R;
    ctx.beginPath(); ctx.arc(cx,cy,ro,a0,a1); ctx.arc(cx,cy,ri,a1,a0,true); ctx.closePath();
    ctx.fillStyle=on?'rgba(58,46,22,.96)':'rgba(22,25,27,.92)'; ctx.fill();
    ctx.lineWidth=on?LH(2.5):LH(1.5); ctx.strokeStyle=on?UIC.acc:UIC.ui_line_hi; ctx.stroke();
    rim=null; try{ rim=RCOL[dispR(k)]; }catch(_rc){}
    if(rim){ ctx.beginPath(); ctx.arc(cx,cy,ro-LH(3),a0+0.03,a1-0.03); ctx.lineWidth=LH(3); ctx.strokeStyle=rim; ctx.stroke(); }
    rm=(ri+ro)/2; ix=cx+Math.cos(ac)*rm; iy=cy+Math.sin(ac)*rm-LH(7);
    sz=on?LH(58):LH(50);
    ctx.globalAlpha=fade*(w.list[j].n>0?1:0.3);
    drawIconSprite(ctx,k,ix,iy,sz);
    ctx.globalAlpha=fade;
    ctx.textAlign='center';
    ctx.font=FS(TYPE.micro); nm=String(it.name).toUpperCase();
    ctx.fillStyle=on?UIC.tx_1:UIC.tx_2; hudText(nm,ix,iy+sz*0.5+LH(13));
    ctx.font=FS(TYPE.label); tx='x'+w.list[j].n;
    ctx.fillStyle=UIC.acc; hudText(tx,ix+sz*0.5,iy-sz*0.32);
  }
  ctx.beginPath(); ctx.arc(cx,cy,ri-LH(8),0,Math.PI*2); ctx.fillStyle='rgba(11,12,13,.9)'; ctx.fill();
  ctx.lineWidth=LH(1.5); ctx.strokeStyle=UIC.ui_line_hi; ctx.stroke();
  ctx.textAlign='center';
  if(w.sel>=0&&w.list[w.sel]){
    ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_1; hudText(String(ITEMS[w.list[w.sel].k].name).toUpperCase(),cx,cy-LH(1));
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.acc; hudText('RELEASE TO PICK',cx,cy+LH(16));
  } else {
    ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_2; hudText('ITEMS',cx,cy-LH(1));
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_3; hudText('AIM TO CHOOSE',cx,cy+LH(16));
  }
  ctx.textAlign='left';
  ctx.restore();
}
'@ @'
// v26.xx (wheel6), HIS BAR #50 (looks like a AAA game): the wheel draws on a soft vignette, not a flat dim; each segment is a graphite plate with a
// rarity rim on its outer edge, the picture, the NAME in caps and a count pill; the segment under the aim lifts out, goes amber and gets a pointer
// on the hub; the hub says the name, what the item does (wheelBlurb) and how many; under the ring one line names the key to let go of. Cosmetic
// only (no seeded draw, no shadowBlur); it draws when the wheel is open and nothing else.
function wheelBlurb(k){
  var it=ITEMS[k];
  if(!it) return '';
  if(it.use==='throw') return (k==='trip')?'PLACE A MINE':((k==='smoke')?'THROW A SMOKE SCREEN':((k==='decoy')?'THROW A DECOY':'COOK AND THROW'));
  if(it.use==='heal') return 'HEALS TO '+Math.round(healCeil(it));
  if(it.use==='stim') return 'UNLIMITED STAMINA '+STIM_SEC+'S';
  if(it.use==='armor') return 'ARMOUR +'+(it.amt|0);
  return '';
}
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
'@

SubRx @'
    if(rState==='reload'&&p.wep.reload){
'@ @'
    if(p.drawT>0&&p.drawLen>0&&!rState){   // v26.xx (wheel6): the gun is being drawn: the ring fills clockwise from twelve, and is gone when it is ready
      var _drf=clamp(1-p.drawT/p.drawLen,0,1), _drr=gap+len+4*_wz;
      ctx.strokeStyle='rgba(230,240,246,.22)'; ctx.lineWidth=3.2*_wz;
      ctx.beginPath(); ctx.arc(rx0,ry0,_drr,0,6.2832); ctx.stroke();
      ctx.strokeStyle='rgba(230,240,246,.95)';
      ctx.beginPath(); ctx.arc(rx0,ry0,_drr,-1.5708,-1.5708+6.2832*_drf); ctx.stroke();
    }
    if(rState==='reload'&&p.wep.reload){
'@

SubRx @'
if(_gunUp&&!rState&&p.wep&&p.wep.mag>0){
'@ @'
if(_gunUp&&!p.hand&&!(p.drawT>0)&&!rState&&p.wep&&p.wep.mag>0){   // v26.xx (wheel6): no magazine ring while the gun is away or being drawn
'@

SubRx @'
0,p.muzzle,((G.deathBeat>0||p.hp<=0)?'down':(G.punchT>0?'fist':((pmode===''&&(G.handsT>0||(p.wep&&p.wep.id==='fists')))?'none':pmode))),p.iv,
'@ @'
0,p.muzzle,((G.deathBeat>0||p.hp<=0)?'down':(G.punchT>0?'fist':((pmode===''&&(G.handsT>0||p.hand||(p.wep&&p.wep.id==='fists')))?'none':pmode))),p.iv,
'@

SubRx @'
var _gmode=((G.deathBeat>0||p.hp<=0)?'down':(G.punchT>0?'fist':((pmode===''&&(G.handsT>0||(p.wep&&p.wep.id==='fists')))?'none':pmode)));
'@ @'
var _gmode=((G.deathBeat>0||p.hp<=0)?'down':(G.punchT>0?'fist':((pmode===''&&(G.handsT>0||p.hand||(p.wep&&p.wep.id==='fists')))?'none':pmode)));
'@

SubRx @'
var VER='26.28';
'@ @'
var VER='26.29';
'@

$pat = "(?m)^  now:'v26\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.29: The item wheel has a proper look, a ring on the crosshair shows a gun being drawn, and your gun is put away while an item is out. Check 26.29 fails on v26.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
