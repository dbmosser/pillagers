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

# RAID PURCHASES USE THE STASH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v26.xx (forgest2), HIS ORDERS 2026-10-12 ("a pack-a-punch mechanism to upgrade guns", "in-raid only", "if you extract with an upgraded gun you
// get to keep it") AND HIS QUESTION 2026-10-14: THE BENCH. At the Forge E opens THE FORGE panel; picking MK II turns the gun in your hands into
// its MK II (forgeApply, the model of v24.03) and takes FORGE_COST[0] from the RAID SCORE, the same in the DEMO (ARCADE.mine) and in CAREER
// (G.cs.s), so no caller ever asks which mode it is in. The panel is not a pause (the raid runs on, like the stall); the mouse, the number
// keys and the pad all work; ESC, TAB, B and CLOSE leave it with no charge. Too little score says NEED $2,500 and opens nothing. Done, it
// says GUN UPGRADED, shows the new gun against the old on the pickup card, rings the anvil, throws gold sparks and is HEARD: the upgrade
// pings 700 out, so machines and pillagers in earshot come to look. In two players each window has its own score and its own bench; the
// station stands in the same place in both. Nothing here draws from any stream.
function forgeScore(){ return (G&&G.arcade)?Math.max(0,ARCADE.mine|0):((G&&G.cs)?Math.max(0,G.cs.s|0):0); }
function forgeSpend(n){
  if(!(n>0)||forgeScore()<n) return false;
  if(G.arcade){ ARCADE.mine=(ARCADE.mine|0)-n; try{ arcadeScSend(); }catch(_fs){} } else{ G.cs.s=(G.cs.s|0)-n; csTally('forge',-n); }
  return true;
}
function forgeGun(){ var p=G&&G.player, w=p&&p.wep; return (w&&w.id&&w.id!=='fists'&&w.mag>0&&WEAPONS[w.id])?w:null; }
function forgeOpts(){
  var w=forgeGun();
  if(!w) return {err:'NO GUN IN HAND',opts:[]};
  if(w.fk===2) return {err:'MAX TIER',opts:[]};
  if(w.fk===1) return {err:'',opts:ELEM_ORDER.map(function(e){ return {k:'el',el:e,cost:FORGE_COST[1]}; })};   // v26.xx (forgest3): MK III, and which element
  return {err:'',opts:[{k:'mk2',cost:FORGE_COST[0]}]};
}
function forgePromptInfo(){
  var R=forgeOpts(), w=forgeGun(), need, short;
  if(R.err) return {line:R.err,sub:'',short:false};
  need=R.opts[0].cost; short=forgeScore()<need;
  return {line:'['+keyLabel('KeyE','E')+'] UPGRADE \u00b7 '+(w.fk===1?'MK III':'MK II'),sub:short?('NEED '+arcadeCr(need)):(arcadeCr(need)+(w.fk===1?' \u00b7 CHOOSE ELEMENT':'')),short:short};
}
function forgeOpen(){
  var R=forgeOpts(), need;
  if(!G||G.over||G.forgeUI) return false;
  if(R.err){ say(R.err,'info'); try{ sndUi('deny'); }catch(_f0){} return false; }
  need=R.opts[0].cost;
  if(forgeScore()<need){ say('NEED '+arcadeCr(need),'warn'); try{ sndUi('deny'); }catch(_f1){} return false; }
  G.forgeUI={t0:G.t||0,sel:0,n:R.opts.length,cells:[],closeBox:null,mx:NaN,my:NaN};
  G.mapOpen=false; mouse.down=false;
  try{ sndUi('open'); }catch(_f2){}
  return true;
}
function forgeClose(spent){
  if(!G) return false;
  G.forgeUI=null; G.forgeLock=keys['KeyE']?1:0;   // v26.xx (forgest3): the lock holds only while E is still down, so a quick second visit opens at once
  if(typeof PAD!=='undefined'&&PAD&&PAD.on) PAD.xAfterTrade=1;
  if(!spent){ try{ sndUi('back'); }catch(_fc){} }
  return true;
}
function forgeBuy(ix){
  var U=G&&G.forgeUI, p=G&&G.player, w=forgeGun(), R=forgeOpts(), o=R.opts[ix], nw, col, tag, F=G&&G.forge;
  if(!U||!p||!w||!o||G.over) return false;
  if(!forgeSpend(o.cost)){ say('NEED '+arcadeCr(o.cost),'warn'); try{ sndUi('deny'); }catch(_b0){} return false; }
  nw=forgeApply(w,1);
  if(o.k==='el') nw=forgeApply(w,2,o.el);   // v26.xx (forgest3): MK III with the element picked
  p.wep=nw; p.wepIssued=false;
  col=(o.k==='el')?ELEM[o.el].c:FORGE_GOLD; tag=(o.k==='el')?ELEM[o.el].name:'MK II';
  say('GUN UPGRADED','obj',{sub:String(nw.name).toUpperCase()+((o.k==='el')?('  \u00b7  '+ELEM[o.el].name):'')});
  G.gunCard={gk:nw.id,w:nw,vs:w,route:tag+'  -'+arcadeCr(o.cost),t0:G.t||0};
  blip('forge'); if(o.k==='el'&&ELEM[o.el]&&ELEM[o.el].snd) blip(ELEM[o.el].snd);   // v26.xx (forgest3): and the element's own sound
  if(F&&isFinite(F.x)){
    spark(F.x,F.y-26,col,40,420); flash(F.x,F.y-30,130,col,0.5);
    ping(F.x,F.y,700,false,false,'player','fire');
  }
  forgeClose(true);
  return true;
}
function forgeClick(){
'@ @'
// v28.xx (cw-cx-stashraid), HIS ORDER 2026-10-19: "any money spent in a raid comes from credits stash".
// v28.xx (cw-cx-stashraid): each window pays from its own save P.credits in DEMO and CAREER, and saves the purchase.
// v28.xx (cw-cx-stashraid): E buys MK II instantly; MK III opens the element picker. Too little stash money opens nothing.
// v28.xx (cw-cx-stashraid): the existing gun card, sparks, upgrade sound and 700 ping stay; raid score and its ledger are untouched.
function forgeScore(){ return Math.max(0,+P.credits||0); }
function forgeMoney(n){ return '$'+Math.max(0,n).toLocaleString('en-US'); }
function forgeSpend(n){
  if(!(n>0)||forgeScore()<n) return false;
  P.credits-=n; saveProfile();
  return true;
}
function forgeGun(){ var p=G&&G.player, w=p&&p.wep; return (w&&w.id&&w.id!=='fists'&&w.mag>0&&WEAPONS[w.id])?w:null; }
function forgeOpts(){
  var w=forgeGun();
  if(!w) return {err:'NO GUN IN HAND',opts:[]};
  if(w.fk===2) return {err:'MAX TIER',opts:[]};
  if(w.fk===1) return {err:'',opts:ELEM_ORDER.map(function(e){ return {k:'el',el:e,cost:FORGE_COST[1]}; })};   // v26.xx (forgest3): MK III, and which element
  return {err:'',opts:[{k:'mk2',cost:FORGE_COST[0]}]};
}
function forgePromptInfo(){
  var R=forgeOpts(), w=forgeGun(), need, short;
  if(R.err) return {line:R.err,sub:'',short:false};
  need=R.opts[0].cost; short=forgeScore()<need;
  return {line:'['+keyLabel('KeyE','E')+'] UPGRADE \u00b7 '+(w.fk===1?'MK III':'MK II'),sub:short?('NEED '+forgeMoney(need)):(forgeMoney(need)+(w.fk===1?' \u00b7 CHOOSE ELEMENT':'')),short:short};
}
function forgeOpen(){
  var R=forgeOpts(), need;
  if(!G||G.over||G.forgeUI) return false;
  if(R.err){ say(R.err,'info'); try{ sndUi('deny'); }catch(_f0){} return false; }
  need=R.opts[0].cost;
  if(forgeScore()<need){ say('need '+forgeMoney(need),'warn'); try{ sndUi('deny'); }catch(_f1){} return false; }
  if(R.opts[0].k==='mk2') return forgeBuy(0);   // v28.xx (cw-cx-stashraid): one interaction buys MK II; MK III needs an element.
  G.forgeUI={t0:G.t||0,sel:0,n:R.opts.length,cells:[],closeBox:null,mx:NaN,my:NaN};
  G.mapOpen=false; mouse.down=false;
  try{ sndUi('open'); }catch(_f2){}
  return true;
}
function forgeClose(spent){
  if(!G) return false;
  G.forgeUI=null; G.forgeLock=keys['KeyE']?1:0;   // v26.xx (forgest3): the lock holds only while E is still down, so a quick second visit opens at once
  if(typeof PAD!=='undefined'&&PAD&&PAD.on) PAD.xAfterTrade=1;
  if(!spent){ try{ sndUi('back'); }catch(_fc){} }
  return true;
}
function forgeBuy(ix){
  var U=G&&G.forgeUI, p=G&&G.player, w=forgeGun(), R=forgeOpts(), o=R.opts[ix], nw, col, tag, F=G&&G.forge;
  if(!p||!w||!o||G.over||(!U&&o.k!=='mk2')) return false;
  if(!forgeSpend(o.cost)){ say('need '+forgeMoney(o.cost),'warn'); try{ sndUi('deny'); }catch(_b0){} return false; }
  nw=forgeApply(w,1);
  if(o.k==='el') nw=forgeApply(w,2,o.el);   // v26.xx (forgest3): MK III with the element picked
  p.wep=nw; p.wepIssued=false;
  col=(o.k==='el')?ELEM[o.el].c:FORGE_GOLD; tag=(o.k==='el')?ELEM[o.el].name:'MK II';
  say('gun upgraded','obj',{sub:String(nw.name).toLowerCase()+((o.k==='el')?('  \u00b7  '+ELEM[o.el].name):'')});
  G.gunCard={gk:nw.id,w:nw,vs:w,route:tag+'  -'+forgeMoney(o.cost),t0:G.t||0};
  blip('forge'); if(o.k==='el'&&ELEM[o.el]&&ELEM[o.el].snd) blip(ELEM[o.el].snd);   // v26.xx (forgest3): and the element's own sound
  if(F&&isFinite(F.x)){
    spark(F.x,F.y-26,col,40,420); flash(F.x,F.y-30,130,col,0.5);
    ping(F.x,F.y,700,false,false,'player','fire');
  }
  forgeClose(true);
  return true;
}
function forgeClick(){
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
    ctx.textAlign='right'; ctx.font=fH; ctx.fillStyle=UIC.tx_1; ctx.fillText(arcadeCr(ok),xr-ckL-u(24),hy+Math.round(pH*0.4));
    ctx.font=fM; ctx.fillStyle=UIC.tx_3; ctx.fillText('RAID SCORE',xr-ckL-u(24),hy-Math.round(pH*0.5));
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
        ctx.fillText(arcadeCr(o.cost),c.x+c.w-u(22),c.y+u(58));
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
        ctx.textAlign='left'; ctx.font=fL; ctx.fillStyle=(forgeScore()<o.cost)?UIC.danger:UIC.acc; ctx.fillText(arcadeCr(o.cost),c.x+u(14),c.y+chh-u(12));
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

'@

SubRx @'
  if(G.cash!=null&&G.cash<st.price){ say('NOT ENOUGH CASH ON YOU','info',{sub:'Costs '+'$'+st.price.toLocaleString()+'. Carrying '+'$'+G.cash.toLocaleString()+'.'}); return; }   // v28.xx (cw-precash), HIS ORDER (2026-10-15): "quickly pick how much cash ... to take": a raid that took a set amount of cash can spend no more than that at the stall

'@ @'

'@

SubRx @'
  if(G.cash!=null) G.cash=Math.max(0,G.cash-st.price);   // v28.xx (cw-precash)

'@ @'

'@

SubRx @'
  if((P.credits||0)<st.price){ say('NOT ENOUGH BANKED CREDITS','info',{sub:'Costs '+'$'+st.price.toLocaleString()+'.'+((G.pedCarry||0)>0?(' Carrying '+'$'+(G.pedCarry||0).toLocaleString()+'.'):'')}); return; }   // v22.xx (tr4fixc): the shooter voice, the headline says banked
'@ @'
  if((P.credits||0)<st.price){ say('need '+'$'+st.price.toLocaleString(),'info'); return; }   // v28.xx (cw-cx-stashraid): the stall draws from the stash, as the forge does.
'@

SubRx @'
  // v28.xx (cw-precash), HIS ORDER (2026-10-15): "On the pre-raid screen ... quickly pick how much cash ... to take". The amount set on the PRE-RAID page (P.takeCashRaid, written when he deploys with MY LOADOUT) is the cash on him: the stall sells him no more than that, and banked Credits stay banked (nothing is lost with it). No pick means no cap.
  G.cash=null;
  if(!G.sim&&P.takeCashRaid!=null) G.cash=Math.max(0,Math.min(P.takeCashRaid|0,P.credits|0));
  P.takeCashRaid=null;

'@ @'

'@

SubRx @'
// v28.xx (cw-precash), HIS ORDER (2026-10-15): "quickly pick how much cash ... to take". P.takeCash is null for ALL (no cap) or a number of credits; the step is a tenth of the bank, in hundreds.
function cashStep(d){
  var c=P.credits|0, st=Math.max(100,Math.round(c/10/100)*100), cur=(P.takeCash==null)?c:Math.min(P.takeCash|0,c);
  if(d==='all'){ P.takeCash=null; return; }
  cur+=(d>0?st:-st);
  P.takeCash=(cur>=c)?null:Math.max(0,cur);
}

'@ @'

'@

SubRx @'
  var host=document.getElementById('sectorpack'), keys, i, k, h, held, got, nc, tc;
'@ @'
  var host=document.getElementById('sectorpack'), keys, i, k, h, held, got, nc;
'@

SubRx @'
  tc=(P.takeCash==null)?null:Math.min(P.takeCash|0,P.credits|0);
  h+='<span class="pkc'+(tc!==null?' on':'')+'" data-cashchip="1"><span class="pkn">CASH</span><button data-cash="-1">-</button><b style="min-width:4.2em">'+(tc===null?'ALL':tc.toLocaleString())+'</b><span style="color:var(--ash)">/'+(P.credits|0).toLocaleString()+'</span><button data-cash="1">+</button><button data-cash="all">MAX</button></span>';
  // v28.xx (cw-packbulk), quality pass: the two whole-pack buttons stood after the CASH chip and read as cash buttons beside its own MAX. They sit right after the PACK label now and say what they do, PACK ALL and CLEAR.

'@ @'
  // v28.xx (cw-cx-stashraid): pack only items and the data core; stash money stays available in the raid.

'@

SubRx @'
    if(b.getAttribute('data-cash')){ cashStep(b.getAttribute('data-cash')==='all'?'all':(+b.getAttribute('data-cash'))); }   // v28.xx (cw-precash)
    else if(b.getAttribute('data-core')){ if(!packCore()) return; }
'@ @'
    if(b.getAttribute('data-core')){ if(!packCore()) return; }
'@

SubRx @'
    else if(pa){ P.takeCash=(pa==='all')?null:0; ks=packList(); for(j=0;j<ks.length;j++) packSet(ks[j],pa==='all'?heldCount(ks[j]):0); }
'@ @'
    else if(pa){ ks=packList(); for(j=0;j<ks.length;j++) packSet(ks[j],pa==='all'?heldCount(ks[j]):0); }
'@

SubRx @'
  P.takeCashRaid=(kitPickOf()==='mine')?P.takeCash:null;   // v28.xx (cw-precash): the cash he picked goes up with MY LOADOUT only

'@ @'

'@

SubRx @'
if(P.safeUp!==undefined) delete P.safeUp;
'@ @'
if(P.safeUp!==undefined) delete P.safeUp;
// v28.xx (cw-cx-stashraid): old saves load without the retired carried cash fields.
delete P.takeCash; delete P.takeCashRaid;
'@

SubRx @'
var VER='31.82';
'@ @'
var VER='31.83';
'@

$pat = "(?m)^  now:'v31\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.83: The forge and stall spend stash credits. One interaction buys MK II. MK III keeps its element choice. Raid score stays whole. Check 31.83 fails on v31.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
