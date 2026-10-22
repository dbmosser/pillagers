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

# HUB BACKPACK DETAIL AND BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawHubBagCard(){
  var s=Math.max(.75,Math.min(2.2,H/1080)),p=24*s,gap=8*s,head=72*s,foot=64*s;
  var b={x:Math.round(W*.05),y:Math.round(H*.05),w:W-2*Math.round(W*.05),h:H-2*Math.round(H*.05)};
  var left=b.x+p,right=b.x+b.w-p,top=b.y+head+p,dw=gunCardMetrics().w,dx=right-dw,lw=dx-32*s-left;
  var stacks=bagStacks(),sel=clamp(G.bagSel||0,0,Math.max(0,stacks.length-1)),i,j;
  G.bagSel=sel;G.bagPanel=b;G.bagHead={x:b.x,y:b.y,w:b.w,h:head};
  G.bagFoot={x:b.x,y:b.y+b.h-foot,w:b.w,h:foot};G.bagCardBox=null;
  ctx.save();
  try{
    ctx.globalAlpha=1;ctx.textBaseline='alphabetic';ctx.textAlign='left';
    ctx.fillStyle='rgba(6,7,8,.80)';ctx.fillRect(0,0,W,H);
    ctx.save();mapRR(b.x,b.y,b.w,b.h,4*s);ctx.clip();ctx.fillStyle='#16191b';ctx.fillRect(b.x,b.y,b.w,b.h);ctx.restore();
    ctx.strokeStyle='#4a5257';ctx.lineWidth=1;mapRR(b.x+.5,b.y+.5,b.w-1,b.h-1,4*s);ctx.stroke();
    function font(n,weight){ctx.font=(weight||600)+' '+(n*s)+'px '+HUDF;}
    function text(t,x,y,n,col,weight){font(n,weight);ctx.fillStyle=col||'#efe9dc';ctx.fillText(t,x,y);}
    function rule(y){ctx.strokeStyle='#2e3337';ctx.lineWidth=1;ctx.beginPath();ctx.moveTo(left,y);ctx.lineTo(right,y);ctx.stroke();}
    text('backpack',left,b.y+46*s,32,'#efe9dc',700);rule(b.y+head);rule(G.bagFoot.y);
    hubBagChrome(true,{x:right-48*s,y:b.y+12*s,w:48*s,h:48*s});
    G.hubBagBeltBottom=G.bagFoot.y-24*s;G.hubBagBeltLeft=left; // v28.xx (cw-cx-hubbagreadability): the belt and its label share the grid edge.
    drawBelt();
    var beltTop=G.hotCells.length?G.hotCells[0].y:G.hubBagBeltBottom-100*s;
    text('tactical belt',left,beltTop-16*s,20,'#aaa498');
    ctx.fillStyle='#1e2225';mapRR(left,top,lw,144*s,4*s);ctx.fill();
    text('equipped',left+24*s,top+28*s,20,'#aaa498');
    drawIconSprite(ctx,G.player.wep.id,left+72*s,top+96*s,96*s);
    text(G.player.wep.name,left+144*s,top+64*s,32);
    var w=G.player.wep;
    text('dmg '+(w.dmg*(w.pellets||1))+'  range '+Math.round(w.rng/10)+'m  '+(w.auto?'auto':'semi')+(w.mag?'  mag '+w.mag:''),left+144*s,top+100*s,20,'#aaa498');
    text('integrity '+Math.round(G.player.hp)+'/'+G.player.maxhp+'    armour '+Math.round(G.player.armor),left+144*s,top+132*s,20,'#aaa498');
    if(w.mag===0){font(32);var nameW=ctx.measureText(w.name).width;text('melee',left+144*s+nameW+16*s,top+64*s,16,'#aaa498');}
    else{ctx.textAlign='right';text('ammo',left+lw-24*s,top+28*s,20,'#aaa498');text(G.player.ammo+' / '+rsvShow(G.player),left+lw-24*s,top+86*s,56,'#efe9dc',800);ctx.textAlign='left';}
    var cols=Math.max(1,Math.floor((lw+gap)/(88*s+gap))),tile=(lw-(cols-1)*gap)/cols;
    var gy=top+192*s,rows=Math.max(1,Math.floor((beltTop-48*s-gy+gap)/(tile+gap)));
    var all=Math.max(1,Math.ceil(stacks.length/cols)),first=clamp(Math.floor(sel/cols)-Math.floor(rows/2),0,Math.max(0,all-rows));
    G.bagCols=cols;G.bagCells=[];
    var n=0;for(i=0;i<stacks.length;i++)n+=stacks[i].idxs.length;
    text('backpack '+n,left,gy-16*s,20,'#aaa498');
    var prot=safeSet();
    for(i=0;i<rows;i++)for(j=0;j<cols;j++){
      var ix=(first+i)*cols+j,st=stacks[ix],tx=left+j*(tile+gap),ty=gy+i*(tile+gap),focused=!!st&&ix===sel&&!G.bagBelt;
      ctx.fillStyle=st?'#1e2225':'#111315';mapRR(tx,ty,tile,tile,4*s);ctx.fill();
      ctx.lineWidth=focused?3:1;ctx.strokeStyle=focused?'#e6ff3d':(st?'#2e3337':'rgba(46,51,55,.4)');ctx.stroke();
      if(!st)continue;
      G.bagCells.push({x:tx,y:ty,w:tile,h:tile,key:st.key,stackIx:ix,bagIx:st.idxs[0]});
      ctx.fillStyle=RCOL[dispR(st.key)]||'#4a5257';ctx.fillRect(tx+2,ty+tile-4*s,tile-4,3*s);
      drawIconSprite(ctx,st.key,tx+tile/2,ty+tile*.47,tile*.62);
      if(st.idxs.length>1){ctx.textAlign='right';text(String(st.idxs.length),tx+tile-8*s,ty+tile-10*s,16);ctx.textAlign='left';}
      if(st.idxs.some(function(k){return !!prot[k];}))text('\u25c6',tx+8*s,ty+22*s,16,'#76b97c');
      if(G.drag&&G.drag.pad&&st.idxs.indexOf(G.drag.bagIx)>=0){ctx.fillStyle='rgba(22,25,27,.6)';ctx.fillRect(tx+2,ty+2,tile-4,tile-4);}
    }
    if(all>rows)text('row '+(first+1)+'-'+Math.min(first+rows,all)+' of '+all,left,gy+rows*(tile+gap)+20*s,16,'#aaa498');
    var key=G.drag&&G.drag.key||stacks[sel]&&stacks[sel].key;
    if(!padOn()){
      var cells=G.bagCells.concat(G.hotCells||[]);
      for(i=0;i<cells.length;i++)if(inRect(cells[i],mouse.x,mouse.y)){
        var c=cells[i],sl=c.i!==undefined?hotbarSlots()[c.i]:null;
        key=c.key||(sl&&(sl.itemKey||(sl.icon&&ITEMS['gun_'+sl.icon]?'gun_'+sl.icon:sl.icon)))||key;break;
      }
    }
    // v28.xx (cw-cx-hubbagreadability): the portrait, price and shared gun card form one detail pane sized to its content.
    var it=key&&ITEMS[key],detailY=top+184*s,sz=null,cmp=null,rr=it?itemRows(key):[];
    if(it&&it.gk&&WEAPONS[it.gk]){
      var weapon=(typeof gunQPeek==='function'&&gunQPeek(it.gk))||WEAPONS[it.gk];cmp=gunCompare(weapon,G.player.wep);
      cmp.f=Object.assign({},cmp.f,{name:it.name});sz=gunCardSize(cmp,'IN BACKPACK');
    }
    if(it){
      var dh=sz?112*s+sz.h:(176+Math.min(6,rr.length)*36)*s;
      ctx.fillStyle='#1e2225';mapRR(dx,top,dw,dh,4*s);ctx.fill();
      drawIconSprite(ctx,key,dx+72*s,top+56*s,96*s);
      ctx.textAlign='right';text('$'+ival(key).toLocaleString()+' each',right-24*s,top+42*s,20);ctx.textAlign='left';
      if(sz){gunCardDraw(cmp,right,top+112*s+sz.h,1,'IN BACKPACK');G.bagCardBox={x:dx,y:top+112*s,w:sz.w,h:sz.h};}
      else{
        text(it.name,dx+24*s,top+144*s,32);ctx.fillStyle=RCOL[dispR(key)]||'#4a5257';ctx.fillRect(dx+24*s,top+160*s,dw-48*s,3*s);
        for(i=0;i<rr.length&&i<6;i++){
          text(rr[i][0],dx+24*s,detailY,20,'#aaa498');text(String(rr[i][1]),dx+160*s,detailY,20);detailY+=36*s;
        }
      }
    }
    var hints=padOn()?[['DPAD','move'],['A','pick up or place'],['Y','drop']]:[['','drag to tactical belt']];
    var hx=left,fy=G.bagFoot.y+40*s;
    for(i=0;i<hints.length;i++){
      var label=hints[i][0]?padB(hints[i][0]):'',ww=0;font(20);
      if(label){ww=ctx.measureText(label).width+16*s;ctx.strokeStyle='#4a5257';ctx.lineWidth=1;mapRR(hx,fy-22*s,ww,30*s,4*s);ctx.stroke();text(label,hx+8*s,fy,20);hx+=ww+8*s;}
      text(hints[i][1],hx,fy,20,'#efe9dc');hx+=ctx.measureText(hints[i][1]).width+24*s;
    }
    ctx.textAlign='right';text((padOn()?padB('B'):'esc')+'  close',right,fy,20,'#e6ff3d',700);
  }finally{ctx.restore();}
}
'@ @'
function drawHubBagCard(){
  var s=Math.max(.75,Math.min(2.2,H/1080)),p=24*s,gap=8*s,head=72*s,foot=64*s;
  var b={x:Math.round(W*.05),y:Math.round(H*.05),w:W-2*Math.round(W*.05),h:H-2*Math.round(H*.05)};
  var left=b.x+p,right=b.x+b.w-p,top=b.y+head+p,dw=gunCardMetrics().w,dx=right-dw,lw=dx-32*s-left;
  var stacks=bagStacks(),sel=clamp(G.bagSel||0,0,Math.max(0,stacks.length-1)),i,j;
  G.bagSel=sel;G.bagPanel=b;G.bagHead={x:b.x,y:b.y,w:b.w,h:head};
  G.bagFoot={x:b.x,y:b.y+b.h-foot,w:b.w,h:foot};G.bagCardBox=null;G.hubBagDetail=null;
  ctx.save();
  try{
    ctx.globalAlpha=1;ctx.textBaseline='alphabetic';ctx.textAlign='left';
    ctx.fillStyle='rgba(6,7,8,.80)';ctx.fillRect(0,0,W,H);
    ctx.save();mapRR(b.x,b.y,b.w,b.h,4*s);ctx.clip();ctx.fillStyle='#16191b';ctx.fillRect(b.x,b.y,b.w,b.h);ctx.restore();
    ctx.strokeStyle='#4a5257';ctx.lineWidth=1;mapRR(b.x+.5,b.y+.5,b.w-1,b.h-1,4*s);ctx.stroke();
    function font(n,weight){ctx.font=(weight||600)+' '+(n*s)+'px '+HUDF;}
    function text(t,x,y,n,col,weight){font(n,weight);ctx.fillStyle=col||'#efe9dc';ctx.fillText(t,x,y);}
    function rule(y){ctx.strokeStyle='#2e3337';ctx.lineWidth=1;ctx.beginPath();ctx.moveTo(left,y);ctx.lineTo(right,y);ctx.stroke();}
    text('backpack',left,b.y+46*s,32,'#efe9dc',700);rule(b.y+head);rule(G.bagFoot.y);
    hubBagChrome(true,{x:right-48*s,y:b.y+12*s,w:48*s,h:48*s});
    G.hubBagBeltBottom=G.bagFoot.y-24*s;G.hubBagBeltLeft=left;G.hubBagBeltWidth=lw; // v28.xx (cw-cx-hubbagreadability): the belt and its label share the grid edge.
    drawBelt();
    var beltTop=G.hotCells.length?G.hotCells[0].y:G.hubBagBeltBottom-100*s;
    text('tactical belt',left,beltTop-16*s,20,'#aaa498');
    ctx.fillStyle='#1e2225';mapRR(left,top,lw,128*s,4*s);ctx.fill();
    text('equipped',left+24*s,top+28*s,20,'#aaa498');
    drawIconSprite(ctx,G.player.wep.id,left+72*s,top+80*s,72*s);
    text(G.player.wep.name,left+144*s,top+56*s,20);
    var w=G.player.wep;
    text('dmg '+(w.dmg*(w.pellets||1))+'  range '+Math.round(w.rng/10)+'m  '+(w.auto?'auto':'semi')+(w.mag?'  mag '+w.mag:''),left+144*s,top+88*s,20,'#aaa498');
    text('integrity '+Math.round(G.player.hp)+'/'+G.player.maxhp+'    armour '+Math.round(G.player.armor),left+144*s,top+116*s,20,'#aaa498');
    if(w.mag===0){font(20);var nameW=ctx.measureText(w.name).width;text('melee',left+144*s+nameW+16*s,top+56*s,16,'#aaa498');}
    else{ctx.textAlign='right';text('ammo',left+lw-24*s,top+28*s,20,'#aaa498');text(G.player.ammo+' / '+rsvShow(G.player),left+lw-24*s,top+86*s,56,'#efe9dc',800);ctx.textAlign='left';}
    var cols=Math.max(1,Math.min(8,Math.floor((lw+gap)/(88*s+gap)))),tile=(lw-(cols-1)*gap)/cols;
    var gy=top+166*s,rows=Math.max(1,Math.floor((beltTop-40*s-gy+gap)/(tile+gap)));
    var all=Math.max(1,Math.ceil(stacks.length/cols)),first=clamp(Math.floor(sel/cols)-Math.floor(rows/2),0,Math.max(0,all-rows));
    G.bagCols=cols;G.bagCells=[];
    var n=0;for(i=0;i<stacks.length;i++)n+=stacks[i].idxs.length;
    text('backpack '+n,left,gy-16*s,20,'#aaa498');
    var prot=safeSet();
    for(i=0;i<rows;i++)for(j=0;j<cols;j++){
      var ix=(first+i)*cols+j,st=stacks[ix],tx=left+j*(tile+gap),ty=gy+i*(tile+gap),focused=!!st&&ix===sel&&!G.bagBelt;
      ctx.fillStyle=st?'#1e2225':'#16191b';mapRR(tx,ty,tile,tile,4*s);ctx.fill();
      ctx.lineWidth=focused?3:1;ctx.strokeStyle=focused?'#e6ff3d':'#2e3337';ctx.stroke();
      if(!st)continue;
      G.bagCells.push({x:tx,y:ty,w:tile,h:tile,key:st.key,stackIx:ix,bagIx:st.idxs[0]});
      ctx.fillStyle=RCOL[dispR(st.key)]||'#4a5257';ctx.fillRect(tx+2,ty+tile-4*s,tile-4,3*s);
      drawIconSprite(ctx,st.key,tx+tile/2,ty+tile*.47,tile*.62);
      if(st.idxs.length>1){ctx.textAlign='right';text(String(st.idxs.length),tx+tile-8*s,ty+tile-10*s,16);ctx.textAlign='left';}
      if(st.idxs.some(function(k){return !!prot[k];}))text('\u25c6',tx+8*s,ty+22*s,16,'#76b97c');
      if(G.drag&&G.drag.pad&&st.idxs.indexOf(G.drag.bagIx)>=0){ctx.fillStyle='rgba(22,25,27,.6)';ctx.fillRect(tx+2,ty+2,tile-4,tile-4);}
    }
    if(all>rows)text('row '+(first+1)+'-'+Math.min(first+rows,all)+' of '+all,left,gy+rows*(tile+gap)+20*s,16,'#aaa498');
    var key=G.drag&&G.drag.key||stacks[sel]&&stacks[sel].key;
    if(!padOn()){
      var cells=G.bagCells.concat(G.hotCells||[]);
      for(i=0;i<cells.length;i++)if(inRect(cells[i],mouse.x,mouse.y)){
        var c=cells[i],sl=c.i!==undefined?hotbarSlots()[c.i]:null;
        key=c.key||(sl&&(sl.itemKey||(sl.icon&&ITEMS['gun_'+sl.icon]?'gun_'+sl.icon:sl.icon)))||key;break;
      }
    }
    // v28.xx (cw-cx-hubbagreadability): the portrait, price and shared gun card form one detail pane sized to its content.
    // v28.xx (cw-cx-hubbagfinish): one raised detail panel, with the shared comparison rows drawn directly on it.
    var it=key&&ITEMS[key],detailY=top+224*s,sz=null,cmp=null,rr=it?itemRows(key):[],tag=G.drag?null:'IN BACKPACK';
    if(it)G.hubBagDetail={price:'$'+ival(key).toLocaleString()+' each'};
    if(it&&it.gk&&WEAPONS[it.gk]){
      var weapon=(typeof gunQPeek==='function'&&gunQPeek(it.gk))||WEAPONS[it.gk];cmp=gunCompare(weapon,G.player.wep);
      cmp.f=Object.assign({},cmp.f,{name:it.name});sz=gunCardSize(cmp,tag);
    }
    if(it){
      var dh=Math.max(gy+rows*(tile+gap)-gap-top,sz?112*s+sz.h:(216+Math.min(6,rr.length)*36)*s);
      ctx.fillStyle='#1e2225';mapRR(dx,top,dw,dh,4*s);ctx.fill();ctx.strokeStyle='#4a5257';ctx.lineWidth=1;ctx.stroke();
      ctx.fillStyle=RCOL[dispR(key)]||'#4a5257';ctx.fillRect(dx+1,top+dh-4*s,dw-2,3*s);
      drawIconSprite(ctx,key,dx+72*s,top+56*s,96*s);
      if(G.drag){ctx.strokeStyle='#4a5257';ctx.lineWidth=1;mapRR(dx+144*s,top+40*s,64*s,32*s,4*s);ctx.stroke();text('held',dx+152*s,top+62*s,20);}
      if(sz){gunCardDraw(cmp,right,top+112*s+sz.h,1,tag);G.bagCardBox={x:dx,y:top+112*s,w:sz.w,h:sz.h};}
      else{
        text(it.name,dx+24*s,top+144*s,32);text(G.hubBagDetail.price,dx+24*s,top+180*s,20);
        for(i=0;i<rr.length&&i<6;i++){
          text(rr[i][0],dx+24*s,detailY,20,'#aaa498');text(String(rr[i][1])==='armor'?'armour':String(rr[i][1]),dx+160*s,detailY,20);detailY+=36*s;
        }
      }
    }
    var hints=padOn()?[['DPAD','move'],['A','pick up or place'],['Y','drop']]:[['','drag to tactical belt']];
    var hx=left,fy=G.bagFoot.y+40*s;
    for(i=0;i<hints.length;i++){
      var label=hints[i][0]?padB(hints[i][0]):'',ww=0;font(20);
      if(label){ww=ctx.measureText(label).width+16*s;ctx.strokeStyle='#4a5257';ctx.lineWidth=1;mapRR(hx,fy-22*s,ww,30*s,4*s);ctx.stroke();text(label,hx+8*s,fy,20);hx+=ww+8*s;}
      text(hints[i][1],hx,fy,20,'#efe9dc');hx+=ctx.measureText(hints[i][1]).width+24*s;
    }
    ctx.textAlign='right';text((padOn()?padB('B'):'esc')+'  close',right,fy,20,'#e6ff3d',700);
  }finally{ctx.restore();}
}
'@

SubRx @'
    var gap=LH(6), gapG=LH(18);   // v25.xx (belt6a): LH(6) inside a group, LH(18) between groups
'@ @'
    var gap=LH(6), gapG=LH(18);   // v25.xx (belt6a): LH(6) inside a group, LH(18) between groups
    if(G&&G.hubFloor&&typeof G.hubBagBeltWidth==='number')gap=gapG=8*Math.max(.75,Math.min(2.2,H/1080)); // v28.xx (cw-cx-hubbagfinish): one 8px rhythm across the window belt.
'@

SubRx @'
    if(G&&G.hubFloor&&typeof G.hubBagBeltLeft==='number') hx=G.hubBagBeltLeft; // v28.xx (cw-cx-hubbagreadability): left edge follows the open grid.
'@ @'
    if(G&&G.hubFloor&&typeof G.hubBagBeltLeft==='number') hx=G.hubBagBeltLeft; // v28.xx (cw-cx-hubbagreadability): left edge follows the open grid.
    if(G&&G.hubFloor&&typeof G.hubBagBeltWidth==='number'){bw=(G.hubBagBeltWidth-_gt)/sl.length;tw2=G.hubBagBeltWidth;hy=G.hubBagBeltBottom-bw;} // v28.xx (cw-cx-hubbagfinish): nine existing slots span the grid; no extra controls.
'@

SubRx @'
    hudPlate(x,y,sz.w,sz.h,null,'rgba(22,25,27,.95)');
    ctx.strokeStyle=UIC.ui_line_hi;ctx.lineWidth=1;ctx.strokeRect(x+0.5,y+0.5,sz.w-1,sz.h-1);
    ctx.fillStyle=rc;ctx.fillRect(x,y+4*m.s,3*m.s,sz.h-8*m.s);
'@ @'
    if(!(G&&G.hubFloor&&G.hubBagDetail)){ // v28.xx (cw-cx-hubbagfinish): the hub owns one surrounding detail panel and its rarity bar.
    hudPlate(x,y,sz.w,sz.h,null,'rgba(22,25,27,.95)');
    ctx.strokeStyle=UIC.ui_line_hi;ctx.lineWidth=1;ctx.strokeRect(x+0.5,y+0.5,sz.w-1,sz.h-1);
    ctx.fillStyle=rc;ctx.fillRect(x,y+4*m.s,3*m.s,sz.h-8*m.s);
    }
'@

SubRx @'
    ctx.font=fL;ctx.fillStyle=UIC.tx_2;ctx.textAlign='right';ctx.fillText(ITEMRAR[gunRarity(cmp.f.id)]||'',xd,yy);
'@ @'
    ctx.font=fL;ctx.fillStyle=UIC.tx_2;ctx.textAlign='right';ctx.fillText(ITEMRAR[gunRarity(cmp.f.id)]||'',xd,yy);
    if(G&&G.hubFloor&&G.hubBagDetail){yy+=rh;ctx.textAlign='left';ctx.font=fV;ctx.fillStyle=UIC.tx_1;ctx.fillText(G.hubBagDetail.price,x+pad,yy);} // v28.xx (cw-cx-hubbagfinish): price belongs directly under the item name.
'@

SubRx @'
  return {w:Math.round(m.w),h:Math.round(m.pad*2+m.title*1.1+m.rh*(1+GUNSTAT_ROWS.length+(tag?1:0)+(el?1:0)+((cmp&&cmp.f&&gunKillsOf(cmp.f.id)>0)?1:0)))};
'@ @'
  return {w:Math.round(m.w),h:Math.round(m.pad*2+(G&&G.hubFloor&&G.hubBagDetail?m.rh:0)+m.title*1.1+m.rh*(1+GUNSTAT_ROWS.length+(tag?1:0)+(el?1:0)+((cmp&&cmp.f&&gunKillsOf(cmp.f.id)>0)?1:0)))}; // v28.xx (cw-cx-hubbagfinish): include the hub price row in the measured card.
'@

SubRx @'
  return {s:s,pad:24*s,rh:32*s,title:(hub?28:32)*s,label:(hub?20:16)*s,value:20*s,w:440*s};
'@ @'
  return {s:s,pad:24*s,rh:32*s,title:32*s,label:(hub?20:16)*s,value:20*s,w:440*s}; // v28.xx (cw-cx-hubbagfinish): one title size for the focused item.
'@

SubRx @'
var VER='34.07';
'@ @'
var VER='34.08';
'@

$pat = "(?m)^  now:'v34\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.08: One detail panel shows the price under the item name and labels held items. The nine belt slots span the grid. Check 34.08 fails on v34.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
