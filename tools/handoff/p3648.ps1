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

# RAID BACKPACK IN GROUPS: GUNS, USABLES, CRAFTING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  st.sort(function(a,b){
    var ia=ITEMS[a.key]||{},ib=ITEMS[b.key]||{};
    var ua=(ia.use||a.key.indexOf('gun_')===0)?0:1;
    var ub=(ib.use||b.key.indexOf('gun_')===0)?0:1;
    if(ua!==ub) return ua-ub;
    return String(ia.name||a.key)<String(ib.name||b.key)?-1:1;
  });
  return st;
}

'@ @'
  // v28.xx (cw-bagsort), HIS ORDER (2026-10-29): "Show guns, then usables, then crafting items". The stacks come in three groups in that order (bagGroup):
  // guns dearest first, usables by kind (heals, stims, plates, throwables, ammo, keycards), then crafting parts and salvage dearest first, so the junk is last.
  st.sort(function(a,b){
    var ga=bagGroup(a.key), gb=bagGroup(b.key), va, vb, na, nb;
    if(ga!==gb) return ga-gb;
    if(ga===1){ va=bagUseRank(a.key); vb=bagUseRank(b.key); if(va!==vb) return va-vb; }
    else { va=ival(a.key); vb=ival(b.key); if(va!==vb) return vb-va; }
    na=String((ITEMS[a.key]||{}).name||a.key); nb=String((ITEMS[b.key]||{}).name||b.key);
    return na<nb?-1:(na>nb?1:0);
  });
  return st;
}
// v28.xx (cw-bagsort): the backpack group of an item: 0 a gun, 1 anything else he can use (heals, stims, plates, throwables, ammo, keycards), 2 crafting parts and salvage.
function bagGroup(k){ var it=ITEMS[k]; if(!it) return 2; if(it.use==='gun'||String(k).indexOf('gun_')===0) return 0; return it.use?1:2; }
var BAG_USE_ORDER=['heal','stim','armor','throw','ammo','key'];
function bagUseRank(k){ var it=ITEMS[k], i=it?BAG_USE_ORDER.indexOf(it.use):-1; return i<0?BAG_USE_ORDER.length:i; }
// v28.xx (cw-bagsort): the rows of the raid backpack as drawn: each group starts a row of its own, guns and usables G.bagCols a row, crafting G.bagCols2 (smaller
// tiles). The Undercroft card keeps its one plain grid of G.bagCols. drawBag lays these out and the arrows and the pad walk them (bagStep).
function bagRowsOf(st){
  var R=[], hub=!!G.hubFloor, bc=Math.max(1,G.bagCols||5), sc=Math.max(1,G.bagCols2||bc), i=0, n, g, c, a;
  while(i<st.length){
    g=hub?0:bagGroup(st[i].key);
    for(n=i;n<st.length&&(hub?0:bagGroup(st[n].key))===g;n++){}
    c=(g===2&&!hub)?sc:bc;
    for(a=i;a<n;a+=c) R.push({g:g,a:a,n:Math.min(c,n-a),cols:c,first:a===i});
    i=n;
  }
  return R;
}
// v28.xx (cw-bagsort): one step up or down from stack sel over those rows; the stack it lands on, or -1 where the walk wraps right round (down past the end
// of the first row's columns, up before its first), which bagArrow turns into the step onto the tactical belt and round (no belt) turns back to the start.
// On one plain grid this is the v14.59 walk (down a column, then the top of the next; up a column, then the foot of the one before). Across groups it lands
// on the tile under the same place, or the nearest one in a short row, and remembers the place across (G.bagNavU), so a walk down never loops. keep stores it.
function bagStep(code,sel,round,keep){
  var st=bagStacks(), R=bagRowsOf(st), M=G.bagNavU, r, row, u, t, k, i, c, out=-1;
  if(!R.length) return -1;
  sel=clamp(sel|0,0,st.length-1);
  for(r=R.length-1;r>0;r--) if(sel>=R[r].a) break;
  row=R[r]; u=(M&&M.sel===sel&&M.u>=0&&M.u<1)?M.u:(sel-row.a+.5)/row.cols;
  if(code==='ArrowDown'){
    for(i=r+1;i<R.length&&out<0;i++){ t=R[i]; c=Math.floor(u*t.cols); if(c<t.n) out=t.a+c; else if(t.g!==row.g) out=t.a+t.n-1; }
    if(out<0){ k=Math.floor(u*R[0].cols)+1; if(k<R[0].n){ out=R[0].a+k; u=(k+.5)/R[0].cols; } else if(round){ out=R[0].a; u=.5/R[0].cols; } }
  } else if(code==='ArrowUp'){
    if(r>0){ t=R[r-1]; out=t.a+Math.min(Math.floor(u*t.cols),t.n-1); }
    else {
      k=Math.floor(u*R[0].cols)-1;
      if(k<0&&round) k=R[0].n-1;
      if(k>=0){ u=(k+.5)/R[0].cols; for(i=R.length-1;i>=0&&out<0;i--){ c=Math.floor(u*R[i].cols); if(c<R[i].n) out=R[i].a+c; } }
    }
  }
  if(keep&&out>=0) G.bagNavU={sel:out,u:u};
  return out;
}

'@

SubRx @'
    if(code==='ArrowUp'){
      if(G.bagSel-_bc>=0) G.bagSel-=_bc;
      else { var _ucol=(G.bagSel%_bc)-1; if(_ucol<0) _ucol=Math.min(_bc,_stN)-1; while(_ucol+_bc<_stN) _ucol+=_bc; G.bagSel=_ucol; }
      if(ev) ev.preventDefault(); }
    if(code==='ArrowDown'){ G.bagSel=(G.bagSel+_bc<_stN)?G.bagSel+_bc:((G.bagSel%_bc)+1)%Math.min(_bc,_stN); if(ev) ev.preventDefault(); }

'@ @'
    // v28.xx (cw-bagsort): the same walk over the rows as drawn (bagStep), so with the groups a step down from the last gun lands in the usables under it.
    if(code==='ArrowUp'||code==='ArrowDown'){ var _nx=bagStep(code,G.bagSel,true,true); if(_nx>=0&&_nx<_stN) G.bagSel=_nx; if(ev) ev.preventDefault(); }

'@

SubRx @'
  var wrap=!sn||(code==='ArrowDown'?(sel+bc>=sn&&(sel%bc)+1>=Math.min(bc,sn)):(sel===0));

'@ @'
  var wrap=!sn||bagStep(code,sel,false,false)<0;   // v28.xx (cw-bagsort): over the rows as drawn; bc stays for the old callers' sake

'@

SubRx @'
  var rowsAll=Math.max(2,Math.ceil(stacks.length/COLS));   // v28.xx (cw-bagtiles), the critic (2026-10-20: a tiny 3-item grid, a small under-filled box): the grid is 88 px tiles (style guide Tile) and always shows at least two rows of cells, empty ones drawn quiet, so the card is filled by its grid; no change to what is carried
  // v9.13: the vertical paddings scale with the tile, or a grid of double-sized
  // tiles would sit in a header and footer built for the small ones.
  var rowsMax=Math.max(2,Math.floor((H-LH(560)*BZ)/(TILE+GAP)));
  var rows=Math.min(rowsAll,rowsMax);
  var _dn=stacks.length?Math.min(6,itemRows(stacks[clamp(G.bagSel||0,0,stacks.length-1)].key).length):0;   // v28.xx (cw-bagpolish): the footer is as tall as the selected item's rows
  var hh=LH(242)*BZ+rows*(TILE+GAP)+_dn*LH(18)*BZ;

'@ @'
  // v28.xx (cw-bagsort), HIS ORDER (2026-10-29): "when I open the backpack in the raid, it needs to be better organized. Not really helpful to the player to see
  // all the junk and craftable components that he's found in detail. Show guns, then usables, then crafting items". The grid is three groups in that order,
  // each under a heading line (its name and count) and starting a row of its own; crafting parts and salvage pack a strip of small tiles, twice as many a row
  // on half the gap, so they read as what he found, not one big tile apiece.
  // BL is the list of lines (headings and tile rows) top to bottom; the window opens at the top and scrolls only as far as the selected row needs.
  var SCOLS=COLS*2, SGAP=Math.max(2,Math.round(GAP/2)), STILE=(gridW-(SCOLS-1)*SGAP)/SCOLS; G.bagCols2=SCOLS;
  var SECH=LH(22)*BZ, BROWS=bagRowsOf(stacks), BL=[], _by=0, _bi, _bt, _bg;
  for(_bi=0;_bi<BROWS.length;_bi++){
    if(BROWS[_bi].first){ BL.push({hd:BROWS[_bi].g,y:_by,h:SECH}); _by+=SECH; }
    _bt=(BROWS[_bi].g===2)?STILE:TILE; _bg=(BROWS[_bi].g===2)?SGAP:GAP;
    BL.push({row:BROWS[_bi],ri:_bi,tile:_bt,gap:_bg,y:_by,h:_bt+_bg}); _by+=_bt+_bg;
  }
  if(!BL.length){ BL.push({row:null,ri:0,tile:TILE,gap:GAP,y:0,h:TILE+GAP},{row:null,ri:1,tile:TILE,gap:GAP,y:TILE+GAP,h:TILE+GAP}); _by=2*(TILE+GAP); }   // an empty backpack keeps its two quiet rows
  // The footer is as tall as the tallest item's rows (it was the selected item's, so the panel grew and shrank as the highlight moved: his 10-27 rule for
  // the stash, nothing resizes on hover), and the grid takes the room the panel has above the belt (the old budget allowed two rows at his text size,
  // which the headings would have eaten); never under two rows. The panel is still sized to what is in the backpack.
  var _dn=0; for(_bi=0;_bi<stacks.length;_bi++) _dn=Math.max(_dn,Math.min(6,itemRows(stacks[_bi].key).length));
  var _bt0=(G.hotCells&&G.hotCells.length)?G.hotCells[0].y:(H-LH(70)*BZ);
  var maxGH=Math.max(2*(TILE+GAP),_bt0-LH(22)*BZ-LH(10)*BZ-LH(10)*BZ-LH(242)*BZ-_dn*LH(18)*BZ);
  var _bsel=clamp(G.bagSel||0,0,Math.max(0,stacks.length-1)), _bsl=0, _bw0=0, _bw1;
  for(_bi=0;_bi<BL.length;_bi++) if(BL[_bi].row&&_bsel>=BL[_bi].row.a&&_bsel<BL[_bi].row.a+BL[_bi].row.n){ _bsl=_bi; break; }
  while(_bw0<_bsl&&BL[_bsl].y+BL[_bsl].h-BL[_bw0].y>maxGH) _bw0++;
  for(_bw1=_bw0+1;_bw1<BL.length&&BL[_bw1].y+BL[_bw1].h-BL[_bw0].y<=maxGH;_bw1++){}
  if(_bw1-1>_bw0&&BL[_bw1-1].hd!==undefined) _bw1--;   // never end the window on a heading with none of its tiles
  var gridH=BL[_bw1-1].y+BL[_bw1-1].h-BL[_bw0].y;
  var hh=LH(242)*BZ+gridH+_dn*LH(18)*BZ;

'@

SubRx @'
  // the grid, windowed around the selection
  var sel=clamp(G.bagSel||0,0,Math.max(0,stacks.length-1));
  G.bagSel=sel;
  var selRow=Math.floor(sel/COLS);
  var top0=clamp(selRow-Math.floor(rows/2),0,Math.max(0,rowsAll-rows));
  var prot=safeSet();
  G.bagCells=[];
  for(var r2=0;r2<rows;r2++){
    for(var c2=0;c2<COLS;c2++){
      var si=(top0+r2)*COLS+c2;
      if(si>=stacks.length){ var _ex=gx+c2*(TILE+GAP), _ey=cy+r2*(TILE+GAP); ctx.fillStyle='#1a1e21'; ctx.fillRect(_ex,_ey,TILE,TILE); ctx.strokeStyle='#3d444a'; ctx.lineWidth=1; ctx.strokeRect(_ex+.5,_ey+.5,TILE-1,TILE-1); continue; }
      var st=stacks[si], it=ITEMS[st.key];
      var tx=gx+c2*(TILE+GAP), ty=cy+r2*(TILE+GAP);
      G.bagCells.push({x:tx,y:ty,w:TILE,h:TILE,key:st.key,stackIx:si,bagIx:st.idxs[0]});
      var hov=(mouse.x>=tx&&mouse.x<=tx+TILE&&mouse.y>=ty&&mouse.y<=ty+TILE);
      ctx.fillStyle=(si===sel)?'#262b30':(hov?'#1e2225':'#16191b');
      ctx.fillRect(tx,ty,TILE,TILE);
      var _bf=rfill(it?dispR(stacks[si].key):null);
      if(it){ ctx.fillStyle=RCOL[dispR(stacks[si].key)]||'#4a5257'; ctx.fillRect(tx+1,ty+TILE-4,TILE-2,3); }   // v28.xx (cw-bagpolish3), the critic (2026-10-20): every tile gets the same 1px line and rarity is only a 3 px bar at the foot (style guide: rarity as a bar), not a tinted fill and a coloured border
      ctx.strokeStyle=(si===sel&&!G.bagBelt)?'#e6ff3d':'#4a5257';   // v16.79, his order: the gold ring is on the belt row while the highlight is there
      ctx.lineWidth=(si===sel)?3:1.2;
      ctx.strokeRect(tx+.5,ty+.5,TILE-1,TILE-1);
      if(G.need&&G.need[st.key]>0){ ctx.save(); ctx.strokeStyle='#ffd452'; ctx.lineWidth=Math.max(2,LH(2)*BZ); ctx.globalAlpha=.75+.25*Math.sin((+G.t||0)*4); ctx.strokeRect(tx+2,ty+2,TILE-4,TILE-4); ctx.restore(); }   // v26.xx (career3): an item a contract needs
      drawIconSprite(ctx,st.key,tx+TILE/2,ty+TILE/2-LH(2)*BZ,TILE*0.62,1);   // v18.33: the sprite icon
      if(st.idxs.length>1){
        ctx.font=bFS(TYPE.micro); ctx.textAlign='right'; ctx.fillStyle='#FFF6DC';
        ctx.fillText(String(st.idxs.length),tx+TILE-LH(4)*BZ,ty+TILE-LH(4)*BZ);
        ctx.textAlign='left';
      }
      var isProt=false;
      for(var pk=0;pk<st.idxs.length;pk++) if(prot[st.idxs[pk]]){ isProt=true; break; }
      if(isProt){ ctx.font=bFS(TYPE.micro); ctx.fillStyle='#7fc4a0';
        ctx.fillText('\u25c6',tx+LH(3)*BZ,ty+LH(12)*BZ); }
    }
  }
  var gridBot=cy+rows*(TILE+GAP);
  if(rowsAll>rows){
    ctx.font=bFS(TYPE.micro); ctx.fillStyle='#aaa498'; ctx.textAlign='center';
    ctx.fillText('row '+(top0+1)+'-'+(top0+rows)+' of '+rowsAll,x+PW/2,gridBot+LH(2)*BZ);
    ctx.textAlign='left';
  }

'@ @'
  // the grid, windowed around the selection (v28.xx (cw-bagsort): in his three groups, lines _bw0 to _bw1-1 of BL)
  var sel=_bsel;
  G.bagSel=sel;
  var prot=safeSet(), _gnm=['guns','usables','crafting + salvage'];
  G.bagCells=[];
  for(var _li=_bw0;_li<_bw1;_li++){
    var LN=BL[_li], _ly=cy+LN.y-BL[_bw0].y;
    if(LN.hd!==undefined){
      // the group heading: the name in tx-1 and how many pieces in tx-2, on one baseline over the group's first tile
      var _gc=0;
      for(var _gs=0;_gs<stacks.length;_gs++) if(bagGroup(stacks[_gs].key)===LN.hd) _gc+=stacks[_gs].idxs.length;
      var _hb=_ly+LH(16)*BZ;
      ctx.font=bFS(TYPE.label); ctx.textAlign='left'; ctx.fillStyle='#efe9dc';
      ctx.fillText(_gnm[LN.hd],gx,_hb);
      ctx.fillStyle='#aaa498'; ctx.fillText(String(_gc),gx+ctx.measureText(_gnm[LN.hd]).width+LH(10)*BZ,_hb);
      continue;
    }
    var T=LN.tile, R0=LN.row, _nc=R0?R0.cols:COLS;
    for(var c2=0;c2<_nc;c2++){
      var tx=gx+c2*(T+LN.gap), ty=_ly, si=R0?R0.a+c2:-1;
      if(!R0||c2>=R0.n){ ctx.fillStyle='#1a1e21'; ctx.fillRect(tx,ty,T,T); ctx.strokeStyle='#3d444a'; ctx.lineWidth=1; ctx.strokeRect(tx+.5,ty+.5,T-1,T-1); continue; }
      var st=stacks[si], it=ITEMS[st.key];
      G.bagCells.push({x:tx,y:ty,w:T,h:T,key:st.key,stackIx:si,bagIx:st.idxs[0]});
      var hov=(mouse.x>=tx&&mouse.x<=tx+T&&mouse.y>=ty&&mouse.y<=ty+T);
      ctx.fillStyle=(si===sel)?'#262b30':(hov?'#1e2225':'#16191b');
      ctx.fillRect(tx,ty,T,T);
      if(it){ ctx.fillStyle=RCOL[dispR(st.key)]||'#4a5257'; ctx.fillRect(tx+1,ty+T-4,T-2,3); }   // v28.xx (cw-bagpolish3), the critic (2026-10-20): every tile gets the same 1px line and rarity is only a 3 px bar at the foot (style guide: rarity as a bar), not a tinted fill and a coloured border
      ctx.strokeStyle=(si===sel&&!G.bagBelt)?'#e6ff3d':'#4a5257';   // v16.79, his order: the gold ring is on the belt row while the highlight is there
      ctx.lineWidth=(si===sel)?3:1.2;
      ctx.strokeRect(tx+.5,ty+.5,T-1,T-1);
      if(G.need&&G.need[st.key]>0){ ctx.save(); ctx.strokeStyle='#ffd452'; ctx.lineWidth=Math.max(2,LH(2)*BZ); ctx.globalAlpha=.75+.25*Math.sin((+G.t||0)*4); ctx.strokeRect(tx+2,ty+2,T-4,T-4); ctx.restore(); }   // v26.xx (career3): an item a contract needs
      drawIconSprite(ctx,st.key,tx+T/2,ty+T/2-LH(2)*BZ,T*0.62,1);   // v18.33: the sprite icon
      if(st.idxs.length>1){
        ctx.font=bFS(TYPE.micro); ctx.textAlign='right'; ctx.fillStyle='#FFF6DC';
        ctx.fillText(String(st.idxs.length),tx+T-LH(4)*BZ,ty+T-LH(4)*BZ);
        ctx.textAlign='left';
      }
      var isProt=false;
      for(var pk=0;pk<st.idxs.length;pk++) if(prot[st.idxs[pk]]){ isProt=true; break; }
      if(isProt){ ctx.font=bFS(TYPE.micro); ctx.fillStyle='#7fc4a0';
        ctx.fillText('\u25c6',tx+LH(3)*BZ,ty+LH(12)*BZ); }
    }
  }
  var gridBot=cy+gridH;
  if(_bw0>0||_bw1<BL.length){
    var _rA=-1,_rB=-1;
    for(_li=_bw0;_li<_bw1;_li++) if(BL[_li].row){ if(_rA<0) _rA=BL[_li].ri; _rB=BL[_li].ri; }
    if(_rA<0){ _rA=0; _rB=0; }
    ctx.font=bFS(TYPE.micro); ctx.fillStyle='#aaa498'; ctx.textAlign='center';
    ctx.fillText('row '+(_rA+1)+'-'+(_rB+1)+' of '+BROWS.length,x+PW/2,gridBot+LH(12)*BZ);   // under the last tile row, clear of the small tiles' narrow gap
    ctx.textAlign='left';
  }

'@

SubRx @'
    if(e.deltaY!==0) hudSizeStep(e.deltaY<0?1:-1); return; }

'@ @'
    if(e.deltaY!==0) hudSizeStep(e.deltaY<0?1:-1); return; }
  // v28.xx (cw-bagsort): over the open raid backpack the wheel walks its rows a notch at a time and the grid window follows, so a group below the fold
  // is in reach of the mouse; at the top or the foot it stops there. Everywhere else the wheel zooms as before.
  if(state==='raid'&&G.bagOpen&&G.bagPanel&&inRect(G.bagPanel,mouse.x,mouse.y)){
    var _wR=bagRowsOf(bagStacks()), _wS=G.bagSel|0, _wr, _wd=e.deltaY*(e.deltaMode===1?16:(e.deltaMode===2?100:1)), _wn;
    G.bagWheel=(G.bagWheel||0)+_wd;
    if(Math.abs(G.bagWheel)<50) return;
    for(_wr=_wR.length-1;_wr>0;_wr--) if(_wS>=_wR[_wr].a) break;
    if(_wR.length&&(G.bagWheel>0?_wr<_wR.length-1:_wr>0)){ _wn=bagStep(G.bagWheel>0?'ArrowDown':'ArrowUp',_wS,false,true); if(_wn>=0){ G.bagSel=_wn; G.bagBelt=false; } }
    G.bagWheel=0;
    return;
  }

'@

SubRx @'
var VER='36.47';
'@ @'
var VER='36.48';
'@

$pat = "(?m)^  now:'v36\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.48: the raid backpack groups guns, then usables, then crafting and salvage on smaller tiles Check 36.48 fails on v36.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
