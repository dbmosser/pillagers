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

# CLEAR FORGE CHOICES AND RECEIPT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudPromptDraw(s,x,y,o){
  var t=String(s), m, w, a, d, sub=(o&&o.sub)?String(o.sub):'', sw=0, h, bw, i0, i1;
  ctx.font=FS(TYPE.head); ctx.textAlign='center';
  m=ctx.measureText(t); w=m.width;
  a=(m.actualBoundingBoxAscent>0)?m.actualBoundingBoxAscent:LH(12); d=(m.actualBoundingBoxDescent>0)?m.actualBoundingBoxDescent:LH(3);
  if(sub){ ctx.font=FS(TYPE.label); sw=ctx.measureText(sub).width; ctx.font=FS(TYPE.head); }
  h=a+d+LH(8)+(sub?LH(15):0); bw=Math.max(w,sw)+LH(16);
  hudPlate(x-bw/2,y-a-LH(4),bw,h,(o&&o.accent)||null,(o&&o.plate)||null);
  // v22.xx, the raid text rewrite (R44): the prompt line carries the ink outline as well as its plate (2 x hudRes on the screen,
  // under whatever scale the caller has put it, so hudAtIn does not double it).
  var _pa=Math.abs((ctx.getTransform?ctx.getTransform().a:1)||1)/((typeof DPRH==='number'&&DPRH>0)?DPRH:1);   // v23.xx (gfx4): ctx runs at DPRH, not the world DPR
  // v24.27, UI REDESIGN ui7 (his #50): THE KEY IS A KEYCAP. The [E] of the line is cut out of it with a clip and an amber keycap with
  // the key in dark ink (the pad button in its own colour on a controller) is drawn in its place. The line is still drawn whole, one
  // fillText through the TX door, so his wording of the whole sentence, the word editor and the line as read are all unchanged.
  var _pc=(o&&o.col)||HUDC.text, _plw=2*Math.max(1,(typeof hudRes==='function')?hudRes():1)/Math.max(0.25,_pa), _T=TX(t), _x0, _k0, _kW;
  i0=_T.indexOf('['); i1=(i0>=0)?_T.indexOf(']',i0):-1;
  ctx.fillStyle=_pc;
  if(i1>i0+1){
    _x0=x-w/2; _k0=_x0+hudRawW(_T.slice(0,i0)); _kW=hudRawW(_T.slice(i0,i1+1));
    ctx.save(); ctx.beginPath(); ctx.rect(_x0-LH(12),y-a-LH(8),w+LH(24),a+d+LH(16)); ctx.rect(_k0,y-a-LH(8),_kW,a+d+LH(16)); ctx.clip('evenodd');
    try{ hudText(t,x,y,_plw); } finally { ctx.restore(); }
    hudKey(_T.slice(i0+1,i1),_k0,y,a,_kW);
    ctx.fillStyle=_pc; ctx.textAlign='center';
  }
  else hudText(t,x,y,_plw);
  if(sub){ ctx.font=FS(TYPE.label); ctx.fillStyle=(o&&o.subCol)||HUDC.text; ctx.fillText(sub,x,y+d+LH(14)); ctx.font=FS(TYPE.head); }
  return {w:w,by:y-a-LH(4)+h};
}

'@ @'
function hudPromptDraw(s,x,y,o){
  var t=String(s), m, w, a, d, sub=(o&&o.sub)?String(o.sub):'', sw=0, h, bw, i0, i1;
  ctx.font=FS(TYPE.head); ctx.textAlign='center';
  m=ctx.measureText(t); w=m.width;
  a=(m.actualBoundingBoxAscent>0)?m.actualBoundingBoxAscent:LH(12); d=(m.actualBoundingBoxDescent>0)?m.actualBoundingBoxDescent:LH(3);
  if(sub){ ctx.font=FS(TYPE.label); sw=ctx.measureText(sub).width; ctx.font=FS(TYPE.head); }
  // v28.xx (cw-cx-forgefinish): an optional station label shares the prompt plate; other prompts keep their geometry.
  var label=(o&&o.label)?String(o.label):'', labelH=label?LH(22):0;
  h=a+d+LH(8)+(sub?LH(15):0)+labelH; bw=Math.max(w,sw)+LH(label?24:16);
  hudPlate(x-bw/2,y-a-LH(4)-labelH,bw,h,(o&&o.accent)||null,(o&&o.plate)||null);
  if(label){ ctx.font=FS(TYPE.label); ctx.fillStyle=UIC.tx_2; ctx.fillText(label,x,y-a-LH(10)); ctx.font=FS(TYPE.head); }
  // v22.xx, the raid text rewrite (R44): the prompt line carries the ink outline as well as its plate (2 x hudRes on the screen,
  // under whatever scale the caller has put it, so hudAtIn does not double it).
  var _pa=Math.abs((ctx.getTransform?ctx.getTransform().a:1)||1)/((typeof DPRH==='number'&&DPRH>0)?DPRH:1);   // v23.xx (gfx4): ctx runs at DPRH, not the world DPR
  // v24.27, UI REDESIGN ui7 (his #50): THE KEY IS A KEYCAP. The [E] of the line is cut out of it with a clip and an amber keycap with
  // the key in dark ink (the pad button in its own colour on a controller) is drawn in its place. The line is still drawn whole, one
  // fillText through the TX door, so his wording of the whole sentence, the word editor and the line as read are all unchanged.
  var _pc=(o&&o.col)||HUDC.text, _plw=2*Math.max(1,(typeof hudRes==='function')?hudRes():1)/Math.max(0.25,_pa), _T=TX(t), _x0, _k0, _kW;
  i0=_T.indexOf('['); i1=(i0>=0)?_T.indexOf(']',i0):-1;
  ctx.fillStyle=_pc;
  if(i1>i0+1){
    _x0=x-w/2; _k0=_x0+hudRawW(_T.slice(0,i0)); _kW=hudRawW(_T.slice(i0,i1+1));
    ctx.save(); ctx.beginPath(); ctx.rect(_x0-LH(12),y-a-LH(8),w+LH(24),a+d+LH(16)); ctx.rect(_k0,y-a-LH(8),_kW,a+d+LH(16)); ctx.clip('evenodd');
    try{ hudText(t,x,y,_plw); } finally { ctx.restore(); }
    hudKey(_T.slice(i0+1,i1),_k0,y,a,_kW);
    ctx.fillStyle=_pc; ctx.textAlign='center';
  }
  else hudText(t,x,y,_plw);
  if(sub){ ctx.font=FS(TYPE.label); ctx.fillStyle=(o&&o.subCol)||HUDC.text; ctx.fillText(sub,x,y+d+LH(14)); ctx.font=FS(TYPE.head); }
  return {w:w,by:y-a-LH(4)-labelH+h};
}

'@

SubRx @'
function drawForgePrompt(x,y){
  var info=forgePromptInfo();
  return hudPromptDraw(info.line,x,y,{sub:info.sub,subCol:info.short?UIC.danger:UIC.tx_1,accent:info.short?UIC.danger:UIC.acc});
}
'@ @'
function drawForgePrompt(x,y){
  var info=forgePromptInfo();
  return hudPromptDraw(info.line,x,y-16,{label:'the forge',sub:info.sub,subCol:info.short?UIC.danger:UIC.tx_1,accent:info.short?UIC.danger:UIC.acc});
}
'@

SubRx @'
    if(!wlUnder(fx-_ftw/2,fy-84-_fpx,_ftw,_fpx*1.3)){   // v31.xx (cw-trcol2): not over the corner column or the score plate
'@ @'
    if(!G.nearForge&&!wlUnder(fx-_ftw/2,fy-84-_fpx,_ftw,_fpx*1.3)){   // v28.xx (cw-cx-forgefinish): the nearby prompt owns the station name.
'@

SubRx @'
function drawForgeUI(){
  var U=G&&G.forgeUI, p=G&&G.player, R, w, rs, u, fT, fH, fL, fM, fG, pT, pH, pL, pM, n, PW, PH, HH, GB, CH, FH, pad, x, y, i, o, nw, os, ns, sel, c, cx, cy, cw, chh, a, yy, rows, k, vr, tx, tw, ckL, xr, ok, lab, kw, hy, E, wd;
  if(!U||!p||G.over) return;
  R=forgeOpts(); w=forgeGun();
  if(!w||!R.opts.length){ G.forgeUI=null; return; }
  rs=Math.max(1,hudRes()); u=function(px){ return Math.round(LH(px)*rs); };
  fT=hudFS(TYPE.title); fH=hudFS(TYPE.head); fL=hudFS(TYPE.label); fM=hudFS(TYPE.micro); fG=hudFS(TYPE.huge);
  pT=msgPx(fT); pH=msgPx(fH); pL=msgPx(fL); pM=msgPx(fM);
  n=R.opts.length; pad=u(24); HH=u(54); GB=u(92); CH=u(144); FH=u(46);
  PW=u(660); PH=HH+GB+u(8)+CH+u(10)+FH;
  x=Math.round((W-PW)/2); y=Math.round(H*0.47-PH/2);
  if(y<u(8)) y=u(8);
  ctx.save();
  try{
    ctx.textBaseline='alphabetic'; ctx.textAlign='left';
    ctx.fillStyle='rgba(0,0,0,.40)'; ctx.fillRect(x+u(6),y+u(8),PW,PH);
    hudPanel(x,y,PW,PH,0.97);
    // the header: the name, the score, the way out
    ctx.font=fT; ctx.fillStyle=UIC.acc; ctx.fillText('THE FORGE',x+pad,y+Math.round(HH*0.66));
    ok=forgeScore(); xr=x+PW-pad; hy=y+Math.round(HH*0.5);
    ctx.font=fL; lab=padOn()?padB('B'):'ESC';
    a=ctx.measureText('M').actualBoundingBoxAscent||LH(12); kw=Math.max(hudRawW(lab)+LH(14),a+LH(9)); tw=hudRawW('CLOSE');
    ckL=u(8)+kw+u(8)+tw+u(12);
    forgeChamfer(xr-ckL,hy-u(15),ckL,u(30),u(6));
    ctx.fillStyle=(mouse.x>=xr-ckL&&mouse.x<=xr&&mouse.y>=hy-u(15)&&mouse.y<=hy+u(15))?UIC.ui_hover:UIC.ui_raised; ctx.fill();
    ctx.strokeStyle=UIC.ui_line_hi; ctx.lineWidth=1; ctx.stroke();
    U.closeBox={x:xr-ckL,y:hy-u(15),w:ckL,h:u(30)};
    forgeKeycap(lab,xr-ckL+u(8),hy+Math.round(pL*0.35),fL);
    ctx.textAlign='left'; ctx.font=fL; ctx.fillStyle=UIC.tx_2; ctx.fillText('CLOSE',xr-ckL+u(8)+kw+u(8),hy+Math.round(pL*0.35));
    ctx.textAlign='right'; ctx.font=fH; ctx.fillStyle=UIC.tx_1; ctx.fillText(forgeMoney(ok),xr-ckL-u(24),hy+Math.round(pH*0.4));
    ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.fillText('stash',xr-ckL-u(24),hy-Math.round(pH*0.5));
    ctx.textAlign='left';
    ctx.fillStyle=UIC.ui_line; ctx.fillRect(x+pad,y+HH,PW-pad*2,1);
    // the gun on the bench and the ladder it climbs
    yy=y+HH+Math.round(GB/2);
    try{ gunIcon(ctx,w.id,x+pad+u(52),yy,u(80),w.tint); }catch(_gi){}
    ctx.font=fH; ctx.fillStyle=RCOL[gunRarity(w.id)]||UIC.tx_1; ctx.fillText(String(w.name).toUpperCase(),x+pad+u(116),yy-u(2));
    ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.fillText('IN YOUR HANDS',x+pad+u(116),yy-u(2)-pH-u(2));
    rows=['MK I','MK II','MK III']; xr=x+PW-pad;
    for(i=2;i>=0;i--){
      cw=u(62); cx=xr-(2-i)*(cw+u(8))-cw; k=(w.fk||0);
      forgeChamfer(cx,yy-u(15),cw,u(30),u(6));
      if(i===k){ ctx.fillStyle=UIC.acc; ctx.fill(); }
      else { ctx.fillStyle=(i===k+1)?UIC.acc_dim:UIC.ui_raised; ctx.fill(); ctx.strokeStyle=(i===k+1)?UIC.acc:UIC.ui_line; ctx.lineWidth=(i===k+1)?2:1; ctx.stroke(); }
      ctx.font=fL; ctx.textAlign='center'; ctx.fillStyle=(i===k)?UIC.acc_ink:((i===k+1)?UIC.acc:UIC.tx_3);
      ctx.fillText(rows[i],cx+cw/2,yy+Math.round(pL*0.35)); ctx.textAlign='left';
    }
    // the choices
    U.cells=[];
    cy=y+HH+GB+u(8); cx=x+pad; cw=(n>1)?Math.floor((PW-pad*2-u(12)*(n-1))/n):(PW-pad*2); chh=CH;
    for(i=0;i<n;i++){
      o=R.opts[i]; sel=((U.sel|0)===i);
      c={x:cx,y:cy,w:cw,h:chh,i:i}; U.cells.push(c);
      if(isFinite(mouse.x)&&(mouse.x!==U.mx||mouse.y!==U.my)){ if(mouse.x>=c.x&&mouse.x<=c.x+c.w&&mouse.y>=c.y&&mouse.y<=c.y+c.h) U.sel=i; }
      sel=((U.sel|0)===i);
      forgeChamfer(c.x,c.y,c.w,c.h,u(10));
      ctx.fillStyle=sel?UIC.ui_hover:UIC.ui_raised; ctx.fill();
      ctx.strokeStyle=sel?UIC.acc:UIC.ui_line; ctx.lineWidth=sel?2:1; ctx.stroke();
      ctx.fillStyle=(o.k==='el')?ELEM[o.el].c:FORGE_GOLD; ctx.fillRect(c.x+u(10),c.y,u(48),u(3));
      if(o.k==='mk2'){
        nw=forgeApply(w,1); os=gunStats(w); ns=gunStats(nw);
        ctx.font=fG; ctx.fillStyle=FORGE_GOLD; ctx.fillText('MK II',c.x+u(22),c.y+u(58));
        ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.fillText('GUN UPGRADE',c.x+u(24),c.y+u(78));
        vr=[['DAMAGE',os.dmg,ns.dmg],['MAGAZINE',w.mag,nw.mag],['RELOAD',(w.reload/1000).toFixed(2)+'S',(nw.reload/1000).toFixed(2)+'S']];
        tx=c.x+u(176);
        for(k=0;k<3;k++){
          yy=c.y+u(38)+k*u(30);
          ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.textAlign='left'; ctx.fillText(vr[k][0],tx,yy);
          ctx.font=fL; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(String(vr[k][1]),tx+u(122),yy);
          ctx.strokeStyle=UIC.acc; ctx.lineWidth=Math.max(1.5,u(2)); ctx.beginPath(); ctx.moveTo(tx+u(134),yy-u(9)); ctx.lineTo(tx+u(141),yy-u(4)); ctx.lineTo(tx+u(134),yy+u(1)); ctx.stroke();
          ctx.fillStyle=UIC.tx_1; ctx.textAlign='left'; ctx.fillText(String(vr[k][2]),tx+u(152),yy);
        }
        ctx.textAlign='right'; ctx.font=fG; ctx.fillStyle=(forgeScore()<o.cost)?UIC.danger:UIC.acc;
        ctx.fillText(forgeMoney(o.cost),c.x+c.w-u(22),c.y+u(58));
        ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.fillText('COST',c.x+c.w-u(22),c.y+u(28));
        ctx.textAlign='left';
        forgeKeycap(padOn()?padB('A'):'1',c.x+c.w-u(22)-u(30),c.y+chh-u(14),fL);
        ctx.font=fL; ctx.fillStyle=UIC.tx_1; ctx.textAlign='right'; ctx.fillText('UPGRADE',c.x+c.w-u(22)-u(40),c.y+chh-u(14)); ctx.textAlign='left';
      }
      if(o.k==='el'){
        E=ELEM[o.el]; wd=String(E.w2||'').split(' \u00b7 ');
        forgeElemGlyph(ctx,o.el,c.x+c.w/2,c.y+u(42),u(16),E.c);
        ctx.textAlign='center';
        ctx.font=fH; ctx.fillStyle=E.c; ctx.fillText(E.name,c.x+c.w/2,c.y+u(84));
        ctx.font=fM; ctx.fillStyle=UIC.tx_2; ctx.fillText(wd[0]||'',c.x+c.w/2,c.y+u(101)); ctx.fillText(wd[1]||'',c.x+c.w/2,c.y+u(115));
        ctx.textAlign='left'; ctx.font=fL; ctx.fillStyle=(forgeScore()<o.cost)?UIC.danger:UIC.acc; ctx.fillText(forgeMoney(o.cost),c.x+u(14),c.y+chh-u(12));
        if(!padOn()) forgeKeycap(String(i+1),c.x+c.w-u(14)-u(24),c.y+chh-u(12),fM);
      }
      cx+=cw+u(12);
    }
    U.mx=mouse.x; U.my=mouse.y;
    // the keys it names
    yy=y+PH-Math.round(FH/2)+Math.round(pL*0.35); xr=x+pad;
    ctx.font=fL;
    function hint(key,txt){ var kw=forgeKeycap(key,xr,yy,fL); ctx.font=fL; ctx.fillStyle=UIC.tx_2; ctx.textAlign='left'; ctx.fillText(txt,xr+kw+u(8),yy); xr+=kw+u(8)+hudRawW(txt)+u(26); }
    if(padOn()){ if(n>1) hint('D-PAD','CHOOSE'); hint(padB('A'),'UPGRADE'); hint(padB('B'),'CLOSE'); }
    else { hint(n>1?('1-'+n):'1',n>1?'CHOOSE':'UPGRADE'); hint(keyLabel('KeyE','E'),'CONFIRM'); hint('ESC','CLOSE'); }
  } finally { ctx.restore(); }
}

'@ @'
// v28.xx (cw-cx-forgefinish): the existing four-choice station dialog separates current tier, focus, price and effects.
function drawForgeUI(){
  var U=G&&G.forgeUI, p=G&&G.player, R=forgeOpts(), w=forgeGun();
  if(!U||!p||G.over) return;
  if(!w||!R.opts.length){G.forgeUI=null;return;}
  var z=Math.max(0.75,Math.min(2.2,H/1080)), u=function(n){return Math.round(n*z);},
      PW=Math.min(Math.round(W*0.9),u(1200)), PH=Math.min(Math.round(H*0.9),u(640)),
      x=Math.round((W-PW)/2), y=Math.round((H-PH)/2), pad=u(24), HH=u(72), GB=u(112), FH=u(64),
      fT='700 '+u(32)+'px '+HUDF, fH='600 '+u(20)+'px '+HUDF, fL='600 '+u(16)+'px '+HUDF,
      i, o, c, cx, cy=y+HH+GB+pad, cw, ch=PH-HH-GB-FH-pad*2, yy, E, words, sel;
  ctx.save();
  try{
    ctx.textAlign='left';ctx.textBaseline='alphabetic';
    ctx.fillStyle='rgba(6,7,8,.80)';ctx.fillRect(0,0,W,H);
    hudPlate(x,y,PW,PH,null,UIC.ui_panel);
    ctx.strokeStyle=UIC.ui_line_hi;ctx.lineWidth=1;ctx.strokeRect(x+0.5,y+0.5,PW-1,PH-1);
    ctx.font=fT;ctx.fillStyle=UIC.tx_1;ctx.fillText('the forge',x+pad,y+u(46));
    U.closeBox={x:x+PW-pad-u(48),y:y+u(12),w:u(48),h:u(48)};
    c=U.closeBox;ctx.strokeStyle=UIC.ui_line_hi;ctx.strokeRect(c.x,c.y,c.w,c.h);
    ctx.strokeStyle=UIC.tx_1;ctx.lineWidth=Math.max(1,u(2));ctx.beginPath();
    ctx.moveTo(c.x+u(16),c.y+u(16));ctx.lineTo(c.x+u(32),c.y+u(32));
    ctx.moveTo(c.x+u(32),c.y+u(16));ctx.lineTo(c.x+u(16),c.y+u(32));ctx.stroke();
    ctx.font=fL;ctx.textAlign='right';ctx.fillStyle=UIC.tx_2;ctx.fillText(padOn()?padB('B'):'esc',c.x-u(16),y+u(44));
    ctx.fillText('stash',c.x-u(112),y+u(27));ctx.font=fH;ctx.fillStyle=UIC.tx_1;ctx.fillText(forgeMoney(forgeScore()),c.x-u(112),y+u(51));
    ctx.fillStyle=UIC.ui_line;ctx.fillRect(x+pad,y+HH,PW-pad*2,1);
    try{gunIcon(ctx,w.id,x+pad+u(52),y+HH+u(62),u(80),w.tint);}catch(_gi){}
    ctx.textAlign='left';ctx.font=fL;ctx.fillStyle=UIC.tx_2;ctx.fillText('in your hands',x+pad+u(116),y+HH+u(34));
    ctx.font=fH;ctx.fillStyle=UIC.tx_1;ctx.fillText(String(w.name),x+pad+u(116),y+HH+u(62),PW-u(500));
    ctx.textAlign='right';ctx.font=fL;ctx.fillStyle=UIC.tx_2;ctx.fillText('current',x+PW-pad,y+HH+u(34));
    ctx.font=fH;ctx.fillStyle=UIC.tx_1;ctx.fillText(w.fk===1?'mk ii':'mk i',x+PW-pad,y+HH+u(62));
    U.cells=[];cw=Math.floor((PW-pad*2-u(16)*(R.opts.length-1))/R.opts.length);cx=x+pad;
    for(i=0;i<R.opts.length;i++){
      o=R.opts[i];c={x:cx,y:cy,w:cw,h:ch,i:i};U.cells.push(c);
      if(isFinite(mouse.x)&&(mouse.x!==U.mx||mouse.y!==U.my)&&mouse.x>=c.x&&mouse.x<=c.x+c.w&&mouse.y>=c.y&&mouse.y<=c.y+c.h)U.sel=i;
      sel=(U.sel|0)===i;
      hudPlate(c.x,c.y,c.w,c.h,null,sel?UIC.ui_hover:UIC.ui_raised);
      ctx.strokeStyle=sel?UIC.acc:UIC.ui_line_hi;ctx.lineWidth=sel?2:1;ctx.strokeRect(c.x,c.y,c.w,c.h);
      E=o.k==='el'?ELEM[o.el]:null;
      ctx.fillStyle=E?E.c:FORGE_GOLD;ctx.fillRect(c.x+u(16),c.y,u(48),u(3));
      if(E)forgeElemGlyph(ctx,o.el,c.x+c.w/2,c.y+u(64),u(28),E.c);
      ctx.textAlign='center';ctx.font=fT;ctx.fillStyle=UIC.tx_1;ctx.fillText(E?E.name:'mk ii',c.x+c.w/2,c.y+u(126));
      words=E?String(E.w2||'').split(' \u00b7 '):['gun upgrade'];
      ctx.font=fL;ctx.fillStyle=UIC.tx_2;
      for(var j=0;j<words.length;j++)ctx.fillText(words[j],c.x+c.w/2,c.y+u(162+j*24),c.w-u(32));
      ctx.textAlign='left';ctx.font=fH;ctx.fillStyle=forgeScore()<o.cost?UIC.danger:UIC.tx_1;
      ctx.fillText(forgeMoney(o.cost),c.x+u(16),c.y+c.h-u(24));
      if(!padOn())forgeKeycap(String(i+1),c.x+c.w-u(48),c.y+c.h-u(24),fL);
      cx+=cw+u(16);
    }
    U.mx=mouse.x;U.my=mouse.y;
    yy=y+PH-u(26);ctx.textAlign='left';ctx.font=fL;ctx.fillStyle=UIC.tx_2;
    ctx.fillText(padOn()?('d-pad  choose     '+padB('A')+'  upgrade'):('1-'+R.opts.length+'  choose     '+keyLabel('KeyE','E')+'  confirm'),x+pad,yy);
  }finally{ctx.restore();}
}

'@

SubRx @'
  try{ if(G.forgeUI) drawForgeUI(); }catch(_dfu){}   // v26.xx (forgest2): THE FORGE panel

'@ @'

'@

SubRx @'
  try{ if(!G.mapOpen) trColDraw(); }catch(_tc){}   // v31.xx (cw-mapstyle): the corner column is not drawn over the map card (its header has its own X and weather line); it comes back when the map shuts. The old note:    // v30.xx (cw-trcol): the wallet and notes rows of the corner column, over everything else the way the page text was
'@ @'
  try{ if(!G.mapOpen) trColDraw(); }catch(_tc){}   // v31.xx (cw-mapstyle): the corner column is not drawn over the map card (its header has its own X and weather line); it comes back when the map shuts. The old note:    // v30.xx (cw-trcol): the wallet and notes rows of the corner column, over everything else the way the page text was
  try{ if(G.forgeUI) drawForgeUI(); }catch(_dfu){}   // v28.xx (cw-cx-forgefinish): the station scrim covers every raid HUD panel.
'@

SubRx @'
function gunCardSize(cmp,tag){
  var rs=Math.max(1,hudRes()), fp=msgPx(hudFS(TYPE.label)), hp=msgPx(hudFS(TYPE.head)), pad=Math.round(LH(8)*rs), rh=Math.round(fp*1.5);
  var el=!!(cmp&&cmp.f&&cmp.f.el&&typeof ELEM!=='undefined'&&ELEM[cmp.f.el]);
  return {w:Math.round(fp*18), h:pad*2+Math.round(hp*1.1)+rh*(1+GUNSTAT_ROWS.length)+(tag?rh:0)+(el?rh:0)+((cmp&&cmp.f&&gunKillsOf(cmp.f.id)>0)?rh:0)};   // v26.xx (career1): a row for the kill tally
}function gunCardDraw(cmp,xR,yB,al,tag){
  var rs=Math.max(1,hudRes()), fL=hudFS(TYPE.label), fp=msgPx(fL), fH=hudFS(TYPE.head), hp=msgPx(fH), pad=Math.round(LH(8)*rs), rh=Math.round(fp*1.5);
  var R=GUNSTAT_ROWS, _gz=gunCardSize(cmp,tag), w=_gz.w, h=_gz.h, x=xR-w, y=yB-h, i, k, v, dv, yy, vc, oa=ctx.globalAlpha, xv, xd;
  vc=(cmp.verdict==='UPGRADE')?'#7fe08a':((cmp.verdict==='DOWNGRADE')?'#ff6b5a':'#ffc04a');
  ctx.save();
  try{
    ctx.globalAlpha=oa*(al===undefined?1:al);
    hudPlate(x,y,w,h,vc,HUDC.plate);
    GUNCARD_LAST={x:x,y:y,w:w,h:h};   // v24.9x (ringbadge): where the card is, for a ring badge at the edge
    ctx.textBaseline='alphabetic';
    yy=y+pad+Math.round(hp*0.85);
    var _rwd=ITEMRAR[gunRarity(cmp.f.id)]||'', _rww=0;   // v26.30 (rarvar2): the rarity word sits at the right of the name, in its colour
    if(_rwd){ ctx.font=fL; _rww=Math.round(ctx.measureText(_rwd).width+pad); }
    ctx.font=fH; ctx.textAlign='left'; ctx.fillStyle=RCOL[gunRarity(cmp.f.id)]||HUDC.text;
    ctx.fillText(String(cmp.f.name).toUpperCase(),x+pad,yy,w-pad*2-_rww);
    if(_rwd){ ctx.font=fL; ctx.textAlign='right'; ctx.fillText(_rwd,x+w-pad,yy); ctx.textAlign='left'; }
    yy+=rh; ctx.font=fL; ctx.fillStyle=vc; ctx.fillText(cmp.verdict,x+pad,yy);
    ctx.textAlign='right'; ctx.fillStyle=HUDC.dim;
    if(!cmp.noVs) ctx.fillText('VS '+(cmp.h?String(cmp.h.name).toUpperCase()+((cmp.h.id!==cmp.f.id&&gunBase(cmp.h.id)===gunBase(cmp.f.id))?(' '+(ITEMRAR[gunRarity(cmp.h.id)]||'')):''):'BARE HANDS'),x+w-pad,yy,w*0.56);   // v26.30 (rarvar2): the same model at another rarity says which   // v24.xx (belthover1): not on the card of the gun in hand
    xd=x+w-pad; xv=xd-Math.round(fp*3.6);
    for(i=0;i<R.length;i++){
      k=R[i][0]; v=cmp.f[k]; dv=cmp.h?cmp.d[k]:null; yy+=rh;
      ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText(R[i][1],x+pad,yy);
      ctx.textAlign='right'; ctx.fillStyle=HUDC.text; ctx.fillText(String(v)+(k==='rng'?'M':''),xv,yy);
      if(dv!==null){ ctx.fillStyle=dv>0?'#7fe08a':(dv<0?'#ff6b5a':HUDC.dim); ctx.fillText(dv>0?('+'+dv):(dv<0?String(dv):'='),xd,yy); }
    }
    if(cmp.f.el&&typeof ELEM!=='undefined'&&ELEM[cmp.f.el]){   // v24.xx (belthover1): a MK III names its element in its colour, and what it does
      yy+=rh; ctx.textAlign='left'; ctx.fillStyle=ELEM[cmp.f.el].c; ctx.fillText(ELEM[cmp.f.el].name,x+pad,yy);
      ctx.textAlign='right'; ctx.fillStyle=HUDC.dim; ctx.fillText(String(ELEM[cmp.f.el].w2||''),x+w-pad,yy,w*0.62);
    }    if(gunKillsOf(cmp.f.id)>0){ yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText('KILLS',x+pad,yy); ctx.textAlign='right'; ctx.fillStyle=HUDC.text; ctx.fillText(gunKillsOf(cmp.f.id).toLocaleString(),x+w-pad,yy); }   // v26.xx (career1): the tally
    if(tag){ yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText(String(tag).toUpperCase(),x+pad,yy,w-pad*2); }
  } finally { ctx.restore(); ctx.globalAlpha=oa; }
  return h;
}

'@ @'
// v28.xx (cw-cx-forgefinish): one shared card keeps rarity in its bar, readable stat values and a clear purchase cost.
function gunCardMetrics(){
  var s=Math.max(0.75,Math.min(2.2,H/1080));
  return {s:s,pad:24*s,rh:32*s,title:32*s,label:16*s,value:20*s,w:440*s};
}
function gunCardSize(cmp,tag){
  var m=gunCardMetrics(),el=!!(cmp&&cmp.f&&cmp.f.el&&typeof ELEM!=='undefined'&&ELEM[cmp.f.el]);
  return {w:Math.round(m.w),h:Math.round(m.pad*2+m.title*1.1+m.rh*(1+GUNSTAT_ROWS.length+(tag?1:0)+(el?1:0)+((cmp&&cmp.f&&gunKillsOf(cmp.f.id)>0)?1:0)))};
}
function gunCardDraw(cmp,xR,yB,al,tag){
  var m=gunCardMetrics(),sz=gunCardSize(cmp,tag),x=xR-sz.w,y=yB-sz.h,pad=m.pad,rh=m.rh,yy,
      fL='600 '+m.label+'px '+HUDF,fV='600 '+m.value+'px '+HUDF,fT='700 '+m.title+'px '+HUDF,
      rc=RCOL[gunRarity(cmp.f.id)]||HUDC.text,vc=cmp.verdict==='UPGRADE'?UIC.ok:cmp.verdict==='DOWNGRADE'?UIC.danger:UIC.tx_2,
      R=GUNSTAT_ROWS,i,k,v,dv,xd=xR-pad,xv=xd-64*m.s;
  ctx.save();
  try{
    ctx.globalAlpha*=al===undefined?1:al;
    hudPlate(x,y,sz.w,sz.h,null,'rgba(22,25,27,.95)');
    ctx.strokeStyle=UIC.ui_line_hi;ctx.lineWidth=1;ctx.strokeRect(x+0.5,y+0.5,sz.w-1,sz.h-1);
    ctx.fillStyle=rc;ctx.fillRect(x,y+4*m.s,3*m.s,sz.h-8*m.s);
    GUNCARD_LAST={x:x,y:y,w:sz.w,h:sz.h};
    ctx.textBaseline='alphabetic';ctx.textAlign='left';yy=y+pad+m.title*0.85;
    ctx.font=fT;ctx.fillStyle=UIC.tx_1;ctx.fillText(String(cmp.f.name).toUpperCase(),x+pad,yy,sz.w-pad*2-72*m.s);
    ctx.font=fL;ctx.fillStyle=UIC.tx_2;ctx.textAlign='right';ctx.fillText(ITEMRAR[gunRarity(cmp.f.id)]||'',xd,yy);
    yy+=rh;ctx.textAlign='left';ctx.fillStyle=vc;ctx.fillText(cmp.verdict,x+pad,yy);
    ctx.textAlign='right';ctx.fillStyle=UIC.tx_2;
    if(!cmp.noVs)ctx.fillText('VS '+(cmp.h?String(cmp.h.name).toUpperCase()+((cmp.h.id!==cmp.f.id&&gunBase(cmp.h.id)===gunBase(cmp.f.id))?(' '+(ITEMRAR[gunRarity(cmp.h.id)]||'')):''):'BARE HANDS'),xd,yy,sz.w*0.56);
    for(i=0;i<R.length;i++){
      k=R[i][0];v=cmp.f[k];dv=cmp.h?cmp.d[k]:null;yy+=rh;
      ctx.strokeStyle=UIC.ui_line;ctx.beginPath();ctx.moveTo(x+pad,yy-rh+8*m.s);ctx.lineTo(xd,yy-rh+8*m.s);ctx.stroke();
      ctx.textAlign='left';ctx.font=fL;ctx.fillStyle=UIC.tx_2;ctx.fillText(R[i][1],x+pad,yy);
      ctx.textAlign='right';ctx.font=fV;ctx.fillStyle=UIC.tx_1;ctx.fillText(String(v)+(k==='rng'?'M':''),xv,yy);
      if(dv){ctx.font=fL;ctx.fillStyle=dv>0?UIC.ok:UIC.danger;ctx.fillText(dv>0?'+'+dv:String(dv),xd,yy);}
    }
    if(cmp.f.el&&typeof ELEM!=='undefined'&&ELEM[cmp.f.el]){
      yy+=rh;ctx.font=fL;ctx.textAlign='left';ctx.fillStyle=ELEM[cmp.f.el].c;ctx.fillText(ELEM[cmp.f.el].name,x+pad,yy);
      ctx.textAlign='right';ctx.fillStyle=UIC.tx_2;ctx.fillText(String(ELEM[cmp.f.el].w2||''),xd,yy,sz.w*0.60);
    }
    if(gunKillsOf(cmp.f.id)>0){yy+=rh;ctx.font=fL;ctx.textAlign='left';ctx.fillStyle=UIC.tx_2;ctx.fillText('KILLS',x+pad,yy);ctx.textAlign='right';ctx.fillStyle=UIC.tx_1;ctx.fillText(gunKillsOf(cmp.f.id).toLocaleString(),xd,yy);}
    if(tag){yy+=rh;ctx.textAlign='left';ctx.font=/^cost /i.test(tag)?fV:fL;ctx.fillStyle=UIC.tx_1;ctx.fillText(String(tag).toUpperCase(),x+pad,yy,sz.w-pad*2);}
  }finally{ctx.restore();}
  return sz.h;
}

'@

SubRx @'
  B=HUDBOX.gear; if(B&&B.h>0&&B.y>H*0.4) yB=Math.round(B.y-m);
'@ @'
  // v28.xx (cw-cx-forgefinish): purchase receipts dock above the first hotbar slot, with room for its caption.
  if(/^cost /i.test(String(tag))&&G&&G.hotCells&&G.hotCells.length){
    var cell=G.hotCells[0],gap=Math.round(16*gunCardMetrics().s);
    xR=Math.max(sz.w+gap,Math.min(W-gap,cell.x+sz.w));
    yB=Math.max(sz.h+gap,Math.min(H-gap,cell.y-msgPx(beltCapFS(cell.w))*1.1-gap));
    return {xR:Math.round(xR),yB:Math.round(yB)};
  }
  B=HUDBOX.gear; if(B&&B.h>0&&B.y>H*0.4) yB=Math.round(B.y-m);
'@

SubRx @'
var VER='32.42';
'@ @'
var VER='32.43';
'@

$pat = "(?m)^  now:'v32\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.43: The element picker has a scrim, one close control and readable choices. Upgrade receipts dock above the hotbar. Check 32.43 fails on v32.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
