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

# THE BACKPACK TEXT GROWS WITH THE BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var BZ=hudRes();
  var TILE=LH(58)*BZ,GAP=LH(7)*BZ,MARG=LH(30)*BZ;
  var COLS=clamp(Math.floor((W*0.66-MARG*2+GAP)/(TILE+GAP)),5,12); G.bagCols=COLS;
  var gridW=COLS*TILE+(COLS-1)*GAP;
  // The panel is sized to the grid rather than the grid squeezed into a fixed
  // panel, so the two can never disagree the way they did.
  var PW=Math.min(W-LH(24)*BZ,gridW+MARG*2);
  var x=Math.round((W-PW)/2);
  var gx=x+Math.round((PW-gridW)/2);
  var rowsAll=Math.max(1,Math.ceil(stacks.length/COLS));
  // v9.13: the vertical paddings scale with the tile, or a grid of double-sized
  // tiles would sit in a header and footer built for the small ones.
  var rowsMax=Math.max(2,Math.floor((H-LH(300)*BZ)/(TILE+GAP)));
  var rows=Math.min(rowsAll,rowsMax);
  var hh=LH(150)*BZ+rows*(TILE+GAP)+LH(64)*BZ;
  hh=Math.min(hh,H-70*BZ);
  // v8.51, audit: reserve the belt's REAL footprint. v8.94: and MEASURE it
  // rather than assert it. LH(70)+LH(14) is 131px at every resolution, because
  // LH follows the text size and not the screen, but the belt has sized itself
  // to the room between the corner blocks since v8.81: 101 tall at 1080p, 175 at
  // 4K. Measured overlap of the old number against the real belt: clear by 10 at
  // 1080p, 28 into it at 1440p, 64 into it at 4K, which is his screenshot.
  // G.hotCells is written by the belt draw earlier in this same frame, so this is
  // the same rectangle the mouse hit-tests against and they cannot drift.
  var _beltTop=(G.hotCells&&G.hotCells.length)?G.hotCells[0].y:(H-LH(70));
  // LH(22) rather than LH(14): the weapon and prompt line sits above the cells,
  // and it was the other half of what the panel was covering.
  // v9.13: the belt reserve scales too. The belt has followed the screen since
  // v8.81, so a fixed gap above it drifts by exactly the amount the belt grew.
  var _bagRoom=_beltTop-LH(22)*BZ-LH(10)*BZ;
  if(hh>_bagRoom) hh=Math.max(LH(120)*BZ,_bagRoom);
  y=Math.max(LH(10)*BZ,_beltTop-LH(22)*BZ-hh);
  // v8.94: recorded as it is drawn, like G.hotCells. Without this the only way
  // to ask where the panel is was to repeat its placement maths somewhere else,
  // which is exactly how its belt reserve drifted out of date for three builds.
  G.bagPanel={x:x,y:y,w:PW,h:hh};
  hudPanel(x,y,PW,hh,0.96);   // v18.13: the one HUD panel

  var cy=y+LH(19);
  ctx.font=FS(TYPE.head); ctx.fillStyle='#ffc04a';
  // v8.94, his note: BACKPACK, not INVENTORY. His vocabulary: I opens the
  // BACKPACK, and inventory means the backpack plus the belt together.
  ctx.fillText('BACKPACK',x+11,cy);
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#6b7783'; ctx.textAlign='right';
  // v17.55, polish after his pick 4: IN A PARTY RAID THE BACKPACK SAYS HOW TO OFFER AN ITEM. Y on a controller (T on keys) offers
  // the selected item to the nearest teammate, and nothing on screen said so. The line keeps its own keys and gains the offer
  // first; on a narrow panel the offer is said shorter. Solo and in the Undercroft the line is as it was.
  var _bh=(PAD&&PAD.on)?((state==='hub')?padB('VIEW to close'):padB('A pick up or place   B close')):'B or I to close', _bo;
  if(state!=='hub'&&typeof NET==='object'&&NET&&NET.on){ _bo=((PAD&&PAD.on)?padB('Y'):'Z')+' drop for teammate   '; _bh=_bo+_bh; if(ctx.measureText(_bh).width>PW-LH(130)) _bh=((PAD&&PAD.on)?padB('Y'):'Z')+' drop   '+_bh.slice(_bo.length); }
  ctx.fillText(_bh,x+PW-11,cy); ctx.textAlign='left';   // v16.79, his order: in a raid a pad packs with A and backs out on B; on the floor A does nothing to the backpack and VIEW still closes it
  cy+=LH(8);
  ctx.strokeStyle='#232b35'; ctx.beginPath(); ctx.moveTo(x+11,cy); ctx.lineTo(x+PW-11,cy); ctx.stroke();

  // equipped, with its portrait
  cy+=LH(16);
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#6b7783';
  ctx.fillText('EQUIPPED',x+11,cy);
  cy+=LH(15);
  drawIconSprite(ctx,p.wep.id,x+11+LH(16),cy-LH(2),LH(30));   // v18.33: the sprite icon
  ctx.font=FS(TYPE.head); ctx.fillStyle='#cdd6dd';
  ctx.fillText(p.wep.name,x+11+LH(38),cy);
  ctx.font=FS(TYPE.label); ctx.textAlign='right';
  ctx.fillStyle=p.wep.mag===0?'#8a96a1':(p.ammo===0?'#ff5a4a':'#ffc04a');
  ctx.fillText(p.wep.mag===0?'MELEE':(p.ammo+' / '+p.reserve),x+PW-11,cy);
  ctx.textAlign='left';
  cy+=LH(14);
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#6b7783';
  ctx.fillText('DMG '+(p.wep.dmg*(p.wep.pellets||1))+'  RANGE '+Math.round(p.wep.rng/10)+'m  '+(p.wep.auto?'AUTO':'SEMI')+
    (p.wep.mag?('  MAG '+p.wep.mag):''),x+11,cy);
  cy+=LH(16);
  // v8.78: this counted the whole store, so the instant an item went to the belt
  // it printed "BAG 5 items" over a grid of four. Splitting it is the honest
  // form: BACKPACK plus BELT is the inventory, and neither number claims the
  // other's items. Counted the same way the grid claims them, per key, so it
  // cannot drift from what is drawn below it.
  var _bpN=0,_bltN=0,_clm={};
  if(G.hotAssign) for(var _ck in G.hotAssign){ var _cv=G.hotAssign[_ck]; if(_cv&&beltClaimsBag(_cv)) _clm[_cv]=(_clm[_cv]||0)+1; }   // v14.63
  for(var _ci=0;_ci<G.bag.length;_ci++){ var _ck2=G.bag[_ci];
    if(_clm[_ck2]>0){ _clm[_ck2]--; _bltN++; } else _bpN++; }
  ctx.fillText('Integrity '+Math.round(p.hp)+'/'+p.maxhp+'    Armour '+Math.round(p.armor)+
    '    BACKPACK '+_bpN+'    BELT '+_bltN,x+11,cy);   // v8.34, split at v8.78
  cy+=LH(8);
  ctx.strokeStyle='#232b35'; ctx.beginPath(); ctx.moveTo(x+11,cy); ctx.lineTo(x+PW-11,cy); ctx.stroke();
  cy+=LH(10);

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
      if(si>=stacks.length) break;
      var st=stacks[si], it=ITEMS[st.key];
      var tx=gx+c2*(TILE+GAP), ty=cy+r2*(TILE+GAP);
      G.bagCells.push({x:tx,y:ty,w:TILE,h:TILE,key:st.key,stackIx:si,bagIx:st.idxs[0]});
      var hov=(mouse.x>=tx&&mouse.x<=tx+TILE&&mouse.y>=ty&&mouse.y<=ty+TILE);
      ctx.fillStyle=(si===sel)?'rgba(52,60,84,.9)':(hov?'rgba(34,42,58,.9)':'rgba(18,24,34,.9)');
      ctx.fillRect(tx,ty,TILE,TILE);
      var _bf=rfill(it?dispR(stacks[si].key):null);
      if(_bf){ ctx.fillStyle=_bf; ctx.fillRect(tx,ty,TILE,TILE); }
      ctx.strokeStyle=(si===sel&&!G.bagBelt)?'#ffc04a':(RCOL[it?dispR(stacks[si].key):null]||'rgba(90,102,116,.6)');   // v16.79, his order: the gold ring is on the belt row while the highlight is there
      ctx.lineWidth=(si===sel)?2:1.2;
      ctx.strokeRect(tx+.5,ty+.5,TILE-1,TILE-1);
      drawIconSprite(ctx,st.key,tx+TILE/2,ty+TILE/2-LH(2),TILE*0.62);   // v18.33: the sprite icon
      if(st.idxs.length>1){
        ctx.font=FS(TYPE.micro); ctx.textAlign='right'; ctx.fillStyle='#FFF6DC';
        ctx.fillText(String(st.idxs.length),tx+TILE-LH(4),ty+TILE-LH(4));
        ctx.textAlign='left';
      }
      var isProt=false;
      for(var pk=0;pk<st.idxs.length;pk++) if(prot[st.idxs[pk]]){ isProt=true; break; }
      if(isProt){ ctx.font=FS(TYPE.micro); ctx.fillStyle='#7fc4a0';
        ctx.fillText('\u25c6',tx+LH(3),ty+LH(12)); }
    }
  }
  var gridBot=cy+rows*(TILE+GAP);
  if(rowsAll>rows){
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#9aa8d0'; ctx.textAlign='center';
    ctx.fillText('row '+(top0+1)+'-'+(top0+rows)+' of '+rowsAll,x+PW/2,gridBot+LH(2));
    ctx.textAlign='left';
  }

  // the selected stack, spelled out
  var hintY=Math.min(gridBot+LH(20),y+hh-LH(24));
  ctx.strokeStyle='#232b35'; ctx.beginPath();
  ctx.moveTo(x+11,hintY-LH(12)); ctx.lineTo(x+PW-11,hintY-LH(12)); ctx.stroke();
  if(stacks.length){
    var sst=stacks[sel], sit=ITEMS[sst.key];
    ctx.font=FS(TYPE.label);
    ctx.fillStyle=RCOL[sit?dispR(sst.key):null]||'#cdd6dd';
    ctx.fillText((sit?sit.name:sst.key)+(sst.idxs.length>1?('  x'+sst.idxs.length):''),x+11,hintY);
    ctx.textAlign='right'; ctx.fillStyle='#ffc04a';
    // v15.95, credits audit finding: THE BACKPACK PANEL PRINTS THE PRICE WITH THE THOUSANDS SEPARATOR. This line printed ival()
    // bare, so a selected Meridian Reactor Core read $2600 each while the stash hover and the tag-junk hint print the very same
    // words as $2,600 each, and the Peddler panel one keypress away prints +$1,430 and Carried home: $2,600. Every other price
    // surface goes through toLocaleString (the v15.05 gamble button was the same class). drawHubBag draws this panel on the
    // floor with G swapped, so the Undercroft backpack reads the same. Display only: the price, the dials, the loot tables and
    // every seeded draw are unchanged.
    ctx.fillText('$'+ival(sst.key).toLocaleString()+' each',x+PW-11,hintY);
    ctx.textAlign='left';
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#9aa8d0';
    var isGun=!!(sit&&sit.use==='gun');
    // WHAT IT ACTUALLY IS, v5.33. Same rows as the stash panel, same function,
    // so the two windows can never describe one object differently. Drawn above
    // the key hints because the stats are why you opened the bag.
    var _rw=itemRows(sst.key), _ry=hintY+LH(13);
    for(var _rr=0;_rr<_rw.length&&_rr<6;_rr++){
      ctx.fillStyle='rgba(154,168,208,.55)';
      ctx.fillText(_rw[_rr][0],x+11,_ry);
      ctx.fillStyle='#cdd6dd';
      ctx.fillText(String(_rw[_rr][1]),x+11+LH(74),_ry);
      _ry+=LH(11);
    }
    ctx.fillStyle='#9aa8d0';
    // v15.59, first run audit finding: THE UNDERCROFT BACKPACK NAMES ONLY KEYS THAT WORK ON THE FLOOR. drawHubBag draws this
    // same panel on the floor with G swapped to the Undercroft backpack, and this line printed the raid hint there too: the
    // arrows to move, Z to drop one, and on a gun ENTER to equip and SHIFT+ENTER to put it on the back. The floor branch of the
    // keydown listener returns before raidKey, where all of those live, and nothing else on the floor reads them for the
    // backpack, so down here the arrows moved nothing, Z dropped nothing and ENTER equipped nothing, right after the stash told
    // a new player to equip his gun. With a controller the line named the D-pad, and the floor branch of the pad poll reads no
    // D-pad. Only the mouse drag onto the tactical belt works on the floor, so on the floor the line names only that, and with a
    // controller it names nothing. state is 'raid' in a raid, so the raid hint is untouched. No number and no seeded draw moved.
    ctx.fillText((state==='hub')?((PAD&&PAD.on)?'':'drag to tactical belt')
      :(PAD&&PAD.on)?'DPAD move, past the ends to the tactical belt   A pick up or place   B close'   // v16.79, his order: D-LEFT no longer drops on a pad
      :('ARROWS move   Z drop one   drag to tactical belt'
        +(isGun?'   ENTER equip   SHIFT+ENTER to back':'')
        ),x+11,_ry+LH(3));
  } else {
    ctx.font=FS(TYPE.label); ctx.fillStyle='#6b7783';
    ctx.fillText('Backpack is empty.',x+11,hintY);
  }
}
// HIS NOTE, 2026-08-26: "player should be able to mark a waypoint on their map
// using the mouse (add cursor when map is up)". The map draw computed its own
// scale and origin as locals, so a click had no way to ask where it landed in the
// world. That projection is a function now and BOTH the draw and the click use
// it, for the same reason mouseWorld() exists after the throwable bug: two copies
// of a coordinate transform is how the cursor and the thing it points at end up
// disagreeing.
'@ @'
  // v18.85, SEEN ON THE 4K RAID SCREENSHOT (2026-10-07): THE BACKPACK TEXT GROWS WITH THE BACKPACK. Since v9.13 the panel, the tiles
  // and the gaps scale with the screen (BZ, hudRes, 1 at 1080p and about 2 at 4K), but every line of text and every text offset
  // stayed at its 1080p size, so at 4K the title, the equipped gun, its numbers and the item line were half size in a panel twice
  // as big, hard to read from the couch. Every font in this panel goes through bFS (the HUD type times BZ) and every offset that was
  // not yet scaled is now LH(n)*BZ. At 1080p BZ is exactly 1 and nothing moves.
  var BZ=hudRes(), bFS=function(s){ var f=FS(s); return (BZ>1.01)?f.replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*BZ).toFixed(1)+'px'; }):f; };
  var TILE=LH(58)*BZ,GAP=LH(7)*BZ,MARG=LH(30)*BZ;
  var COLS=clamp(Math.floor((W*0.66-MARG*2+GAP)/(TILE+GAP)),5,12); G.bagCols=COLS;
  var gridW=COLS*TILE+(COLS-1)*GAP;
  // The panel is sized to the grid rather than the grid squeezed into a fixed
  // panel, so the two can never disagree the way they did.
  var PW=Math.min(W-LH(24)*BZ,gridW+MARG*2);
  var x=Math.round((W-PW)/2);
  var gx=x+Math.round((PW-gridW)/2);
  var rowsAll=Math.max(1,Math.ceil(stacks.length/COLS));
  // v9.13: the vertical paddings scale with the tile, or a grid of double-sized
  // tiles would sit in a header and footer built for the small ones.
  var rowsMax=Math.max(2,Math.floor((H-LH(300)*BZ)/(TILE+GAP)));
  var rows=Math.min(rowsAll,rowsMax);
  var hh=LH(150)*BZ+rows*(TILE+GAP)+LH(64)*BZ;
  hh=Math.min(hh,H-70*BZ);
  // v8.51, audit: reserve the belt's REAL footprint. v8.94: and MEASURE it
  // rather than assert it. LH(70)+LH(14) is 131px at every resolution, because
  // LH follows the text size and not the screen, but the belt has sized itself
  // to the room between the corner blocks since v8.81: 101 tall at 1080p, 175 at
  // 4K. Measured overlap of the old number against the real belt: clear by 10 at
  // 1080p, 28 into it at 1440p, 64 into it at 4K, which is his screenshot.
  // G.hotCells is written by the belt draw earlier in this same frame, so this is
  // the same rectangle the mouse hit-tests against and they cannot drift.
  var _beltTop=(G.hotCells&&G.hotCells.length)?G.hotCells[0].y:(H-LH(70)*BZ);
  // LH(22) rather than LH(14): the weapon and prompt line sits above the cells,
  // and it was the other half of what the panel was covering.
  // v9.13: the belt reserve scales too. The belt has followed the screen since
  // v8.81, so a fixed gap above it drifts by exactly the amount the belt grew.
  var _bagRoom=_beltTop-LH(22)*BZ-LH(10)*BZ;
  if(hh>_bagRoom) hh=Math.max(LH(120)*BZ,_bagRoom);
  y=Math.max(LH(10)*BZ,_beltTop-LH(22)*BZ-hh);
  // v8.94: recorded as it is drawn, like G.hotCells. Without this the only way
  // to ask where the panel is was to repeat its placement maths somewhere else,
  // which is exactly how its belt reserve drifted out of date for three builds.
  G.bagPanel={x:x,y:y,w:PW,h:hh};
  hudPanel(x,y,PW,hh,0.96);   // v18.13: the one HUD panel

  var cy=y+LH(19)*BZ;
  ctx.font=bFS(TYPE.head); ctx.fillStyle='#ffc04a';
  // v8.94, his note: BACKPACK, not INVENTORY. His vocabulary: I opens the
  // BACKPACK, and inventory means the backpack plus the belt together.
  ctx.fillText('BACKPACK',x+11,cy);
  ctx.font=bFS(TYPE.micro); ctx.fillStyle='#6b7783'; ctx.textAlign='right';
  // v17.55, polish after his pick 4: IN A PARTY RAID THE BACKPACK SAYS HOW TO OFFER AN ITEM. Y on a controller (T on keys) offers
  // the selected item to the nearest teammate, and nothing on screen said so. The line keeps its own keys and gains the offer
  // first; on a narrow panel the offer is said shorter. Solo and in the Undercroft the line is as it was.
  var _bh=(PAD&&PAD.on)?((state==='hub')?padB('VIEW to close'):padB('A pick up or place   B close')):'B or I to close', _bo;
  if(state!=='hub'&&typeof NET==='object'&&NET&&NET.on){ _bo=((PAD&&PAD.on)?padB('Y'):'Z')+' drop for teammate   '; _bh=_bo+_bh; if(ctx.measureText(_bh).width>PW-LH(130)*BZ) _bh=((PAD&&PAD.on)?padB('Y'):'Z')+' drop   '+_bh.slice(_bo.length); }
  ctx.fillText(_bh,x+PW-11,cy); ctx.textAlign='left';   // v16.79, his order: in a raid a pad packs with A and backs out on B; on the floor A does nothing to the backpack and VIEW still closes it
  cy+=LH(8)*BZ;
  ctx.strokeStyle='#232b35'; ctx.beginPath(); ctx.moveTo(x+11,cy); ctx.lineTo(x+PW-11,cy); ctx.stroke();

  // equipped, with its portrait
  cy+=LH(16)*BZ;
  ctx.font=bFS(TYPE.micro); ctx.fillStyle='#6b7783';
  ctx.fillText('EQUIPPED',x+11,cy);
  cy+=LH(15)*BZ;
  drawIconSprite(ctx,p.wep.id,x+11+LH(16)*BZ,cy-LH(2)*BZ,LH(30)*BZ);   // v18.33: the sprite icon
  ctx.font=bFS(TYPE.head); ctx.fillStyle='#cdd6dd';
  ctx.fillText(p.wep.name,x+11+LH(38)*BZ,cy);
  ctx.font=bFS(TYPE.label); ctx.textAlign='right';
  ctx.fillStyle=p.wep.mag===0?'#8a96a1':(p.ammo===0?'#ff5a4a':'#ffc04a');
  ctx.fillText(p.wep.mag===0?'MELEE':(p.ammo+' / '+p.reserve),x+PW-11,cy);
  ctx.textAlign='left';
  cy+=LH(14)*BZ;
  ctx.font=bFS(TYPE.micro); ctx.fillStyle='#6b7783';
  ctx.fillText('DMG '+(p.wep.dmg*(p.wep.pellets||1))+'  RANGE '+Math.round(p.wep.rng/10)+'m  '+(p.wep.auto?'AUTO':'SEMI')+
    (p.wep.mag?('  MAG '+p.wep.mag):''),x+11,cy);
  cy+=LH(16)*BZ;
  // v8.78: this counted the whole store, so the instant an item went to the belt
  // it printed "BAG 5 items" over a grid of four. Splitting it is the honest
  // form: BACKPACK plus BELT is the inventory, and neither number claims the
  // other's items. Counted the same way the grid claims them, per key, so it
  // cannot drift from what is drawn below it.
  var _bpN=0,_bltN=0,_clm={};
  if(G.hotAssign) for(var _ck in G.hotAssign){ var _cv=G.hotAssign[_ck]; if(_cv&&beltClaimsBag(_cv)) _clm[_cv]=(_clm[_cv]||0)+1; }   // v14.63
  for(var _ci=0;_ci<G.bag.length;_ci++){ var _ck2=G.bag[_ci];
    if(_clm[_ck2]>0){ _clm[_ck2]--; _bltN++; } else _bpN++; }
  ctx.fillText('Integrity '+Math.round(p.hp)+'/'+p.maxhp+'    Armour '+Math.round(p.armor)+
    '    BACKPACK '+_bpN+'    BELT '+_bltN,x+11,cy);   // v8.34, split at v8.78
  cy+=LH(8)*BZ;
  ctx.strokeStyle='#232b35'; ctx.beginPath(); ctx.moveTo(x+11,cy); ctx.lineTo(x+PW-11,cy); ctx.stroke();
  cy+=LH(10)*BZ;

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
      if(si>=stacks.length) break;
      var st=stacks[si], it=ITEMS[st.key];
      var tx=gx+c2*(TILE+GAP), ty=cy+r2*(TILE+GAP);
      G.bagCells.push({x:tx,y:ty,w:TILE,h:TILE,key:st.key,stackIx:si,bagIx:st.idxs[0]});
      var hov=(mouse.x>=tx&&mouse.x<=tx+TILE&&mouse.y>=ty&&mouse.y<=ty+TILE);
      ctx.fillStyle=(si===sel)?'rgba(52,60,84,.9)':(hov?'rgba(34,42,58,.9)':'rgba(18,24,34,.9)');
      ctx.fillRect(tx,ty,TILE,TILE);
      var _bf=rfill(it?dispR(stacks[si].key):null);
      if(_bf){ ctx.fillStyle=_bf; ctx.fillRect(tx,ty,TILE,TILE); }
      ctx.strokeStyle=(si===sel&&!G.bagBelt)?'#ffc04a':(RCOL[it?dispR(stacks[si].key):null]||'rgba(90,102,116,.6)');   // v16.79, his order: the gold ring is on the belt row while the highlight is there
      ctx.lineWidth=(si===sel)?2:1.2;
      ctx.strokeRect(tx+.5,ty+.5,TILE-1,TILE-1);
      drawIconSprite(ctx,st.key,tx+TILE/2,ty+TILE/2-LH(2)*BZ,TILE*0.62);   // v18.33: the sprite icon
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
    ctx.font=bFS(TYPE.micro); ctx.fillStyle='#9aa8d0'; ctx.textAlign='center';
    ctx.fillText('row '+(top0+1)+'-'+(top0+rows)+' of '+rowsAll,x+PW/2,gridBot+LH(2)*BZ);
    ctx.textAlign='left';
  }

  // the selected stack, spelled out
  var hintY=Math.min(gridBot+LH(20)*BZ,y+hh-LH(24)*BZ);
  ctx.strokeStyle='#232b35'; ctx.beginPath();
  ctx.moveTo(x+11,hintY-LH(12)*BZ); ctx.lineTo(x+PW-11,hintY-LH(12)*BZ); ctx.stroke();
  if(stacks.length){
    var sst=stacks[sel], sit=ITEMS[sst.key];
    ctx.font=bFS(TYPE.label);
    ctx.fillStyle=RCOL[sit?dispR(sst.key):null]||'#cdd6dd';
    ctx.fillText((sit?sit.name:sst.key)+(sst.idxs.length>1?('  x'+sst.idxs.length):''),x+11,hintY);
    ctx.textAlign='right'; ctx.fillStyle='#ffc04a';
    // v15.95, credits audit finding: THE BACKPACK PANEL PRINTS THE PRICE WITH THE THOUSANDS SEPARATOR. This line printed ival()
    // bare, so a selected Meridian Reactor Core read $2600 each while the stash hover and the tag-junk hint print the very same
    // words as $2,600 each, and the Peddler panel one keypress away prints +$1,430 and Carried home: $2,600. Every other price
    // surface goes through toLocaleString (the v15.05 gamble button was the same class). drawHubBag draws this panel on the
    // floor with G swapped, so the Undercroft backpack reads the same. Display only: the price, the dials, the loot tables and
    // every seeded draw are unchanged.
    ctx.fillText('$'+ival(sst.key).toLocaleString()+' each',x+PW-11,hintY);
    ctx.textAlign='left';
    ctx.font=bFS(TYPE.micro); ctx.fillStyle='#9aa8d0';
    var isGun=!!(sit&&sit.use==='gun');
    // WHAT IT ACTUALLY IS, v5.33. Same rows as the stash panel, same function,
    // so the two windows can never describe one object differently. Drawn above
    // the key hints because the stats are why you opened the bag.
    var _rw=itemRows(sst.key), _ry=hintY+LH(13)*BZ;
    for(var _rr=0;_rr<_rw.length&&_rr<6;_rr++){
      ctx.fillStyle='rgba(154,168,208,.55)';
      ctx.fillText(_rw[_rr][0],x+11,_ry);
      ctx.fillStyle='#cdd6dd';
      ctx.fillText(String(_rw[_rr][1]),x+11+LH(74)*BZ,_ry);
      _ry+=LH(11)*BZ;
    }
    ctx.fillStyle='#9aa8d0';
    // v15.59, first run audit finding: THE UNDERCROFT BACKPACK NAMES ONLY KEYS THAT WORK ON THE FLOOR. drawHubBag draws this
    // same panel on the floor with G swapped to the Undercroft backpack, and this line printed the raid hint there too: the
    // arrows to move, Z to drop one, and on a gun ENTER to equip and SHIFT+ENTER to put it on the back. The floor branch of the
    // keydown listener returns before raidKey, where all of those live, and nothing else on the floor reads them for the
    // backpack, so down here the arrows moved nothing, Z dropped nothing and ENTER equipped nothing, right after the stash told
    // a new player to equip his gun. With a controller the line named the D-pad, and the floor branch of the pad poll reads no
    // D-pad. Only the mouse drag onto the tactical belt works on the floor, so on the floor the line names only that, and with a
    // controller it names nothing. state is 'raid' in a raid, so the raid hint is untouched. No number and no seeded draw moved.
    ctx.fillText((state==='hub')?((PAD&&PAD.on)?'':'drag to tactical belt')
      :(PAD&&PAD.on)?'DPAD move, past the ends to the tactical belt   A pick up or place   B close'   // v16.79, his order: D-LEFT no longer drops on a pad
      :('ARROWS move   Z drop one   drag to tactical belt'
        +(isGun?'   ENTER equip   SHIFT+ENTER to back':'')
        ),x+11,_ry+LH(3)*BZ);
  } else {
    ctx.font=bFS(TYPE.label); ctx.fillStyle='#6b7783';
    ctx.fillText('Backpack is empty.',x+11,hintY);
  }
}
// HIS NOTE, 2026-08-26: "player should be able to mark a waypoint on their map
// using the mouse (add cursor when map is up)". The map draw computed its own
// scale and origin as locals, so a click had no way to ask where it landed in the
// world. That projection is a function now and BOTH the draw and the click use
// it, for the same reason mouseWorld() exists after the throwable bug: two copies
// of a coordinate transform is how the cursor and the thing it points at end up
// disagreeing.
'@

SubRx @'
var VER='18.84';
'@ @'
var VER='18.85';
'@

$pat = "(?m)^  now:'v18\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.85: At 4K the backpack text is as big, relative to the panel, as at 1080p. Check 18.85 fails on v18.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
