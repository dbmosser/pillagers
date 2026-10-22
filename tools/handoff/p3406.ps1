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

# HUB BACKPACK CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawHubBag(){
'@ @'
// v28.xx (cw-cx-hubbagcard), his Q43: "centred card with an X, taking up nearly the entire screen". Hub presentation only; stacks and belt actions stay shared.
function hubBagChrome(on,box){
  var b=document.getElementById('hubbagclose');
  document.body.classList.toggle('hubbagcard',!!on);
  if(!on){ if(b)b.style.display='none'; return; }
  if(!b){
    b=document.createElement('button'); b.id='hubbagclose'; b.type='button';
    b.textContent='\u00d7'; b.setAttribute('aria-label','close backpack');
    b.addEventListener('click',function(e){e.preventDefault();e.stopPropagation();hubBagOpenSet(false);});
    document.body.appendChild(b);
  }
  if(box){
    var r=cv.getBoundingClientRect(),sx=r.width/W,sy=r.height/H;
    b.style.cssText='position:fixed;z-index:11;display:block;box-sizing:border-box;padding:0;margin:0;border:1px solid #4a5257;border-radius:4px;background:#1e2225;color:#efe9dc;line-height:1;min-width:0;'+
      'font:600 '+(32*box.h/48*sy)+'px '+HUDF+';left:'+(r.left+box.x*sx)+'px;top:'+(r.top+box.y*sy)+'px;width:'+(box.w*sx)+'px;height:'+(box.h*sy)+'px;';
  }
}
// v28.xx (cw-cx-hubbagcard): empty cells are a scrollable viewport, never a bag limit. One right detail pane replaces the duplicate gun stats.
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
function drawHubBag(){
'@

SubRx @'
  try{ G=hubBagG; drawBag(); drawBelt(); try{ if(padOn()) BELTHOV.box=null; else beltHoverHud(); }catch(_bhv){} drawDragGhost(); }   // v32.xx (cw-bagpadcards): on a pad the floor backpack shows the focused cell's card only, never a belt card as well   // v24.xx (belthover1): and over the Undercroft backpack
'@ @'
  try{ G=hubBagG; drawHubBagCard(); BELTHOV.box=null; drawDragGhost(); } // v28.xx (cw-cx-hubbagcard): one in-card detail view for the focused or hovered item.
'@

SubRx @'
    if(G&&G.hubFloor) hx=Math.round((W-tw2)/2);
'@ @'
    if(G&&G.hubFloor) hx=Math.round((W-tw2)/2);
    if(G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number') hy=G.hubBagBeltBottom-bw; // v28.xx (cw-cx-hubbagcard): same belt and hit boxes, inside the card.
'@

SubRx @'
  ctx.fillText(DI.name,mouse.x,mouse.y+ds);
'@ @'
  if(!(G.hubFloor&&padOn())) ctx.fillText(DI.name,mouse.x,mouse.y+ds); // v28.xx (cw-cx-hubbagcard): the held item is named in the detail pane, clear of the belt.
'@

SubRx @'
    hubBagG=null; hubBagOpen=false;
'@ @'
    hubBagG=null; hubBagOpen=false;
    hubBagChrome(false); // v28.xx (cw-cx-hubbagcard): close the native X through every existing back route.
'@

SubRx @'
  try{ if(pauseOpen) togglePauseBox(false); }catch(_pz){}
  hubBagOpen=false; hubBagG=null;
'@ @'
  try{ if(pauseOpen) togglePauseBox(false); }catch(_pz){}
  hubBagOpen=false; hubBagG=null;
  hubBagChrome(false); // v28.xx (cw-cx-hubbagcard): ascending discards the old window chrome.
'@

SubRx @'
  #hcv { position:absolute; inset:0; width:100%; height:100%; pointer-events:none; z-index:5; }
'@ @'
  #hcv { position:absolute; inset:0; width:100%; height:100%; pointer-events:none; z-index:5; }
  /* v28.xx (cw-cx-hubbagcard): world HUD text stays behind this career window. */
  body.hubbagcard #topright,body.hubbagcard #kbmark{visibility:hidden!important}
  #hubbagclose:focus-visible{outline:2px solid var(--acc);outline-offset:3px}
'@

SubRx @'
    hubBagOpen=false; hubBagG=null;   // v8.95: never arrive on the floor with it up
'@ @'
    hubBagOpen=false; hubBagG=null;   // v8.95: never arrive on the floor with it up
    hubBagChrome(false); // v28.xx (cw-cx-hubbagcard): returning to the floor discards the old window chrome.
'@

SubRx @'
var VER='34.05';
'@ @'
var VER='34.06';
'@

$pat = "(?m)^  now:'v34\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.06: The hub backpack fills one centred card, with a scrim, an X and one item detail pane. Check 34.06 fails on v34.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
