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

# HUB BACKPACK READABILITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

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
    G.hubBagBeltBottom=G.bagFoot.y-24*s;
    drawBelt();
    var beltTop=G.hotCells.length?G.hotCells[0].y:G.hubBagBeltBottom-100*s;
    text('tactical belt',left,beltTop-20*s,16,'#aaa498');
    ctx.fillStyle='#1e2225';mapRR(left,top,lw,168*s,4*s);ctx.fill();
    text('equipped',left+24*s,top+30*s,16,'#aaa498');
    drawIconSprite(ctx,G.player.wep.id,left+72*s,top+96*s,96*s);
    text(G.player.wep.name,left+144*s,top+70*s,20);
    var w=G.player.wep;
    text('dmg '+(w.dmg*(w.pellets||1))+'  range '+Math.round(w.rng/10)+'m  '+(w.auto?'auto':'semi')+(w.mag?'  mag '+w.mag:''),left+144*s,top+102*s,16,'#aaa498');
    text('integrity '+Math.round(G.player.hp)+'/'+G.player.maxhp+'    armour '+Math.round(G.player.armor),left+144*s,top+134*s,16,'#aaa498');
    ctx.textAlign='right';text(w.mag===0?'melee':G.player.ammo+' / '+rsvShow(G.player),left+lw-24*s,top+78*s,w.mag===0?20:56,'#efe9dc',800);ctx.textAlign='left';
    var cols=Math.max(1,Math.floor((lw+gap)/(96*s+gap))),tile=(lw-(cols-1)*gap)/cols;
    var gy=top+216*s,rows=Math.max(1,Math.floor((beltTop-64*s-gy+gap)/(tile+gap)));
    var all=Math.max(1,Math.ceil(stacks.length/cols)),first=clamp(Math.floor(sel/cols)-Math.floor(rows/2),0,Math.max(0,all-rows));
    G.bagCols=cols;G.bagCells=[];
    var n=0;for(i=0;i<stacks.length;i++)n+=stacks[i].idxs.length;
    text('backpack '+n,left,gy-16*s,16,'#aaa498');
    var prot=safeSet();
    for(i=0;i<rows;i++)for(j=0;j<cols;j++){
      var ix=(first+i)*cols+j,st=stacks[ix],tx=left+j*(tile+gap),ty=gy+i*(tile+gap),focused=!!st&&ix===sel&&!G.bagBelt;
      ctx.fillStyle='#1e2225';mapRR(tx,ty,tile,tile,4*s);ctx.fill();
      ctx.lineWidth=focused?2:1;ctx.strokeStyle=focused?'#e6ff3d':'#2e3337';ctx.stroke();
      if(!st)continue;
      G.bagCells.push({x:tx,y:ty,w:tile,h:tile,key:st.key,stackIx:ix,bagIx:st.idxs[0]});
      ctx.fillStyle=RCOL[dispR(st.key)]||'#4a5257';ctx.fillRect(tx+2,ty+tile-4*s,tile-4,3*s);
      drawIconSprite(ctx,st.key,tx+tile/2,ty+tile*.47,tile*.62);
      if(st.idxs.length>1){ctx.textAlign='right';text(String(st.idxs.length),tx+tile-8*s,ty+tile-10*s,16);ctx.textAlign='left';}
      if(st.idxs.some(function(k){return !!prot[k];}))text('\u25c6',tx+8*s,ty+22*s,16,'#76b97c');
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
    ctx.fillStyle='#1e2225';mapRR(dx,top,dw,beltTop-48*s-top,4*s);ctx.fill();
    var it=key&&ITEMS[key],detailY=top+32*s;
    if(it&&it.gk&&WEAPONS[it.gk]){
      var weapon=(typeof gunQPeek==='function'&&gunQPeek(it.gk))||WEAPONS[it.gk],cmp=gunCompare(weapon,G.player.wep);
      cmp.f=Object.assign({},cmp.f,{name:it.name});
      var sz=gunCardSize(cmp,'IN BACKPACK');
      gunCardDraw(cmp,right,top+sz.h,1,'IN BACKPACK');
      G.bagCardBox={x:dx,y:top,w:sz.w,h:sz.h};detailY=top+sz.h+32*s;
    }else if(it){
      text(it.name,dx+24*s,detailY,20);detailY+=40*s;
      var rr=itemRows(key);for(i=0;i<rr.length&&i<6;i++){
        text(rr[i][0],dx+24*s,detailY,16,'#aaa498');ctx.textAlign='right';text(String(rr[i][1]),right-24*s,detailY,20);ctx.textAlign='left';detailY+=36*s;
      }
    }
    if(it)text('$'+ival(key).toLocaleString()+' each',dx+24*s,detailY,16,'#aaa498');
    var hints=padOn()?[['DPAD','move'],['A','pick up or place'],['Y','drop']]:[['','drag to tactical belt']];
    var hx=left,fy=G.bagFoot.y+40*s;
    for(i=0;i<hints.length;i++){
      var label=hints[i][0]?padB(hints[i][0]):'',ww=0;font(16);
      if(label){ww=ctx.measureText(label).width+16*s;ctx.strokeStyle='#4a5257';ctx.lineWidth=1;mapRR(hx,fy-22*s,ww,30*s,4*s);ctx.stroke();text(label,hx+8*s,fy,16);hx+=ww+8*s;}
      text(hints[i][1],hx,fy,16,'#aaa498');hx+=ctx.measureText(hints[i][1]).width+24*s;
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
'@

SubRx @'
    if(G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number') hy=G.hubBagBeltBottom-bw; // v28.xx (cw-cx-hubbagcard): same belt and hit boxes, inside the card.
'@ @'
    if(G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number') hy=G.hubBagBeltBottom-bw; // v28.xx (cw-cx-hubbagcard): same belt and hit boxes, inside the card.
    if(G&&G.hubFloor&&typeof G.hubBagBeltLeft==='number') hx=G.hubBagBeltLeft; // v28.xx (cw-cx-hubbagreadability): left edge follows the open grid.
'@

SubRx @'
  var DI=ITEMS[G.drag.key], ds=LH(26);
'@ @'
  // v28.xx (cw-cx-hubbagreadability): a pad-held icon is visibly lifted above its lime target; the mouse and raid ghost stay unchanged.
  if(G.hubFloor&&padOn()){
    var c=bagPadCell(),s=Math.max(.75,Math.min(2.2,H/1080));if(!c)return;
    var size=c.w*.8,cx=c.x+c.w/2+12*s,cy=c.y+c.h/2-12*s;
    ctx.save();ctx.globalAlpha=1;ctx.strokeStyle='#e6ff3d';ctx.lineWidth=3*s;ctx.strokeRect(c.x-2*s,c.y-2*s,c.w+4*s,c.h+4*s);
    ctx.fillStyle='#0b0c0d';mapRR(cx-size/2+4*s,cy-size/2+4*s,size,size,4*s);ctx.fill();
    ctx.fillStyle='#1e2225';mapRR(cx-size/2,cy-size/2,size,size,4*s);ctx.fill();
    drawIconSprite(ctx,G.drag.key,cx,cy,size*.85);ctx.restore();return;
  }
  var DI=ITEMS[G.drag.key], ds=LH(26);
'@

SubRx @'
      _bpath(); ctx.stroke();   // v18.34: the rounded ring
'@ @'
      _bpath(); ctx.stroke();   // v18.34: the rounded ring
      if(G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number'&&G.bagBelt&&q===clamp(G.bagBeltSel||0,0,sl.length-1)){ctx.strokeStyle='#e6ff3d';ctx.lineWidth=3;_bpath();ctx.stroke();} // v28.xx (cw-cx-hubbagreadability): focus is lime; the owner-required equipped gold ring stays.
'@

SubRx @'
  return {s:s,pad:24*s,rh:32*s,title:32*s,label:16*s,value:20*s,w:440*s};
'@ @'
  var hub=G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number'; // v28.xx (cw-cx-hubbagreadability): larger hub labels and a subordinate item title.
  return {s:s,pad:24*s,rh:32*s,title:(hub?28:32)*s,label:(hub?20:16)*s,value:20*s,w:440*s};
'@

SubRx @'
    if(tag){yy+=rh;ctx.textAlign='left';ctx.font=/^cost /i.test(tag)?fV:fL;ctx.fillStyle=UIC.tx_1;ctx.fillText(String(tag).toUpperCase(),x+pad,yy,sz.w-pad*2);}
'@ @'
    if(tag){yy+=rh;ctx.textAlign='left';ctx.font=/^cost /i.test(tag)?fV:fL;ctx.fillStyle=(G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number')?UIC.tx_2:UIC.tx_1;ctx.fillText(String(tag).toUpperCase(),x+pad,yy,sz.w-pad*2);} // v28.xx (cw-cx-hubbagreadability): the location tag is secondary.
'@

SubRx @'
function beltFS(bw,k){ var f=FS(TYPE.micro), m=(/([\d.]+)px/).exec(f), n=m?parseFloat(m[1]):11, want=Math.round(bw*k); return (want>n)?f.replace((/([\d.]+)px/),want+'px'):f; }
'@ @'
function beltFS(bw,k){ var f=FS(TYPE.micro), m=(/([\d.]+)px/).exec(f), n=m?parseFloat(m[1]):11, want=Math.round(bw*k); if(G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number')want=Math.max(want,20*Math.max(.75,Math.min(2.2,H/1080))); return (want>n)?f.replace((/([\d.]+)px/),want+'px'):f; } // v28.xx (cw-cx-hubbagreadability): key numbers stay readable in the hub card.
'@

SubRx @'
        ctx.textAlign='right'; ctx.fillText(String(S.count),bx+bw-LH(4),hy+bw-LH(5)); ctx.textAlign='left';
      }
    }
    // v26.xx (wheel4): no group labels under the belt; it holds nine guns and nothing else.
'@ @'
        ctx.textAlign='right'; ctx.fillText(String(S.count),bx+bw-LH(4),hy+bw-LH(5)); ctx.textAlign='left';
      }
      if(G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number'&&G.drag&&G.drag.pad&&G.drag.fromHot===q){ctx.fillStyle='rgba(22,25,27,.6)';ctx.fillRect(bx+2,hy+2,bw-4,bw-4);} // v28.xx (cw-cx-hubbagreadability): dim the held item's origin after its icon is drawn.
    }
    // v26.xx (wheel4): no group labels under the belt; it holds nine guns and nothing else.
'@

SubRx @'
var VER='34.06';
'@ @'
var VER='34.07';
'@

$pat = "(?m)^  now:'v34\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.07: Larger labels, an aligned belt, compact item details and a lifted held item make the hub backpack easier to read. Check 34.07 fails on v34.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
