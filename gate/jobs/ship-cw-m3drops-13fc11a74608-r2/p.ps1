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

# SEASON ZERO M3: WORN GEAR IN LOOT BOXES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wornName(pc){ return pc&&WORN_KINDS[pc.k]?(WORN_RARS[pc.r].id+' '+WORN_KINDS[pc.k].n):''; }
'@ @'
// v37.xx (cw-m3drops), his answer 73: "today's armor rigs become armor pieces". Rigs left the game at v5.83 and every operator wears the same armour (myRig), so nothing is converted and no speed or noise cost comes back: armor pieces carry the old names.
var WORN_ARMOR_N=['scav vest','plated vest','breacher plate','breacher plate'];
function wornName(pc){ return pc&&WORN_KINDS[pc.k]?(WORN_RARS[pc.r].id+' '+(pc.k==='armor'?WORN_ARMOR_N[pc.r]:WORN_KINDS[pc.k].n)):''; }
// v37.xx (cw-m3drops), HIS RULINGS OF 11-01 (season zero m3): gear is in loot boxes like everything else, nothing on the ground, no ground glow (answer 58); a raid averages
// 4 or 5 pieces (answer 57); see a piece's traits before you take it, with a better or worse tip (answers 59, 71); strength follows existing gear "kinda like how Destiny 2
// does (did) it" (answer 62). A PIECE IN A RAID IS A KEY THAT SPELLS ITSELF OUT: wg_kind_rarity_power_seed. wornItemEnsure makes the piece from those four values and registers
// it NOT ENUMERABLE, so a key means the same piece on any PC and no loop over ITEMS (the shop, the market, the wanted list, a check over every item) ever sees one. At home a
// piece is a record in P.gear or P.worn (bankItem turns the key into one on an extract).
var WORN_DROPS_ON=true;
// The chance a map box holds a piece, from his real raids: v35.38 to v36.66 (19 raids, abandons left out) opened 13.6 containers a raid (7 extracts 20.6, 12 deaths 9.6). That count
// includes wrecks and piles; about 3 in 4 are map boxes, so 10.2 boxes a raid, and the 3 to 4 of the 4 or 5 pieces boxes owe him gives 3.5 / 10.2. 00p-m3d adds the rest and may retune this.
var WORN_BOX_CH=0.34;
var WORN_RAR_ODDS=[60,28,10,2];   // scrap, sound, rare, relic, percent
var WORN_ITEM_R=['common','uncommon','rare','elite'];
function wornKeyOf(k,r,pw,seed){ return 'wg_'+k+'_'+r+'_'+pw+'_'+(seed>>>0); }
function wornKeyIs(key){ return typeof key==='string'&&key.indexOf('wg_')===0; }
// The one door for a key: any other key is just its ITEMS row; a piece's key registers itself the first time. A bad wg_ key gives nothing.
function wornItemEnsure(key){
  var q, pc;
  if(!wornKeyIs(key)) return ITEMS[key];
  if(Object.prototype.hasOwnProperty.call(ITEMS,key)) return ITEMS[key];
  q=key.split('_');
  if(q.length!==5||!Object.prototype.hasOwnProperty.call(WORN_KINDS,q[1])||wornKeyOf(q[1],+q[2],+q[3],+q[4])!==key||!(+q[2]>=0&&+q[2]<=3&&+q[3]>=1&&+q[3]<=WORN_PW_MAX)||+q[2]%1||+q[3]%1) return null;
  pc=wornMake(q[1],+q[2],+q[3],+q[4]);
  if(!pc) return null;
  Object.defineProperty(ITEMS,key,{value:{name:wornName(pc),val:wornPrice(pc),wt:0,r:WORN_ITEM_R[pc.r],c:WORN_RARS[pc.r].c,use:'wornpiece',pc:pc},enumerable:false,configurable:true});
  return ITEMS[key];
}
// The best power owned of a kind (of any kind with none given), worn or in the stash; 0 with none.
function wornBestPw(kind){
  var b=0, i, pc, L=(P&&Array.isArray(P.gear))?P.gear:[], W=(P&&P.worn)||{};
  for(i=0;i<WORN_SLOTS.length;i++){ pc=W[WORN_SLOTS[i]]; if(pc&&(!kind||pc.k===kind)&&(pc.pw|0)>b) b=pc.pw|0; }
  for(i=0;i<L.length;i++){ pc=L[i]; if(pc&&(!kind||pc.k===kind)&&(pc.pw|0)>b) b=pc.pw|0; }
  return b;
}
// A roll lands from 2 under your best of that kind to 1 over; about one in ten is the step above, 3 to 5 over. With none of the kind, the same from your best of any kind minus 5;
// with nothing at all, 15 to 20. After a death the stash keeps you from starting at zero. R is the caller's dice (wornRand), never RNGS or FXS.
function wornDropPw(kind,R){
  var b=wornBestPw(kind), a, n;
  R=R||wornRand((((G&&G.seed)>>>0)^0x5EED)>>>0);
  if(b<=0){ a=wornBestPw(); if(a<=0) return 15+Math.floor(R()*6); b=Math.max(1,a-5); }
  n=(R()<0.1)?(b+3+Math.floor(R()*3)):(b-2+Math.floor(R()*4));
  return Math.max(1,Math.min(WORN_PW_MAX,n));
}
function wornBoxSeed(ct){
  var h=(((G&&G.seed)>>>0)^Math.imul(0x574D,0x9E3779B1))>>>0;
  h=(h^Math.imul(Math.round(ct.x)|0,374761393))>>>0;
  h=(h^Math.imul(Math.round(ct.y)|0,668265263))>>>0;
  h=Math.imul(h^(h>>>15),2246822519)>>>0;
  h=Math.imul(h^(h>>>13),3266489917)>>>0;
  return (h^(h>>>16))>>>0;
}
// THE SIDE ROLL, once per box, the moment it is first searched: a map box only (a wreck and a pillager's pile are 00p-m3d's; a pile he dropped, a man's bag and a restocked crate roll
// nothing), on its own dice from the raid seed and the box's fixed place, so it never reads or moves RNGS or FXS and seed 4242 builds the same raid. It slots into the box in value
// order and leaves the normal items, their order, the search time and the box's look exactly as they were. The host rolls for the whole party, a linked window never.
function wornBoxRoll(ct){
  var R, kinds, i, n, r, k, key;
  if(!WORN_DROPS_ON||!ct||ct.gearDone||!G||G.sim||G.arcade||G.hubFloor||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) return null;
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join') return null;
  if(ct.opened||ct.dropped||ct.mercSrc||ct.net||!(ct.d>=0)||ct.type==='botwreck'||!Array.isArray(ct.loot)) return null;
  ct.gearDone=1;
  R=wornRand(wornBoxSeed(ct));
  if(R()>=WORN_BOX_CH) return null;
  kinds=Object.keys(WORN_KINDS); k=kinds[Math.floor(R()*kinds.length)];
  n=R()*100; for(r=0;r<3&&n>=WORN_RAR_ODDS[r];r++) n-=WORN_RAR_ODDS[r];
  i=(R()*4294967296)>>>0;   // the piece's own seed
  key=wornKeyOf(k,r,wornDropPw(k,R),i);
  if(!wornItemEnsure(key)) return null;
  for(i=0;i<ct.loot.length&&ival(ct.loot[i])<=ival(key);i++);
  ct.loot.splice(i,0,key);
  return key;
}
function wornNextKey(ct){ var i, L=ct&&ct.loot; for(i=0;L&&i<L.length;i++) if(wornKeyIs(L[i])) return L[i]; return null; }
function wornTraitTxt(pc,t){ return WORN_STATS[t.s].n+' +'+Math.round(wornTraitV(pc,t)*100)+'%'; }
// The one trait line on its pickup row: the row says no more than the others do.
function wornRowLine(pc){ return (pc&&pc.tr&&pc.tr.length)?wornTraitTxt(pc,pc.tr[0]):''; }
// THE TIP (his answers 59, 71): name in rarity colour, each trait, then better, worse or even against what he wears. One small plate, the same beside the search bar and in the backpack.
function wornTipLines(pc){
  var o=[{t:wornName(pc),c:WORN_RARS[pc.r].c}], i, v=wornTip(pc,P);
  for(i=0;i<pc.tr.length;i++) o.push({t:wornTraitTxt(pc,pc.tr[i]),c:HUDC.text});
  o.push({t:v,c:v==='better'?UIC.ok:(v==='worse'?UIC.danger:HUDC.dim)});
  return o;
}
function wornTipSize(pc){
  var L=wornTipLines(pc), rs=Math.max(1,hudRes()), fL=hudFS(TYPE.label), fp=msgPx(fL), pad=Math.round(LH(8)*rs), w=0, i;
  ctx.save(); ctx.font=fL; for(i=0;i<L.length;i++) w=Math.max(w,ctx.measureText(L[i].t).width); ctx.restore();
  return {w:Math.round(w+pad*2),h:pad*2+Math.round(fp*1.5)*L.length};
}
function wornTipDraw(pc,x,y){
  var L=wornTipLines(pc), sz=wornTipSize(pc), rs=Math.max(1,hudRes()), fL=hudFS(TYPE.label), fp=msgPx(fL), pad=Math.round(LH(8)*rs), rh=Math.round(fp*1.5), i, yy=y+pad+Math.round(fp*1.05);
  ctx.save();
  try{
    hudPlate(x,y,sz.w,sz.h,WORN_RARS[pc.r].c,HUDC.plate);
    ctx.font=fL; ctx.textAlign='left'; ctx.textBaseline='alphabetic';
    for(i=0;i<L.length;i++){ ctx.fillStyle=L[i].c; ctx.fillText(L[i].t,x+pad,yy); yy+=rh; }
  } finally { ctx.restore(); }
  return sz;
}
// Beside the search bar, while he holds search on a box that still holds a piece. Letting go leaves it in the box, the choice the staged pull already gives.
function wornTipAtBar(ct,s){
  var k=wornNextKey(ct), it=k?wornItemEnsure(k):null, rs, sz, m, x, y;
  if(!it) return false;
  rs=Math.max(1,hudRes()); sz=wornTipSize(it.pc); m=Math.round(LH(8)*rs);
  x=s.x+30*rs+m; if(x+sz.w>W-m) x=s.x-30*rs-m-sz.w;
  y=Math.max(m,Math.min(H-m-sz.h,s.y-5*rs-sz.h/2));
  wornTipDraw(it.pc,Math.round(x),Math.round(y));
  return true;
}
// A simple icon per kind in the piece's rarity colour, painted in the existing icon route.
function wornPoly(c,S,a){ c.beginPath(); c.moveTo(a[0]*S,a[1]*S); for(var i=2;i<a.length;i+=2) c.lineTo(a[i]*S,a[i+1]*S); c.closePath(); c.fill(); }
function wornIconDraw(c,key,cx,cy,S){
  var q=String(key).split('_'), k=q[1], rar=WORN_RARS[Math.max(0,Math.min(3,(+q[2])|0))], col=rar.c, dk=darkHex(col,0.55), i;
  c.save(); c.translate(cx,cy); c.fillStyle=col; c.strokeStyle=dk; c.lineCap='round';
  if(k==='head'){ c.beginPath(); c.arc(0,S*.06,S*.3,Math.PI,0); c.closePath(); c.fill(); c.fillRect(-S*.38,S*.06,S*.76,S*.1); c.fillStyle=dk; c.fillRect(-S*.2,S*.16,S*.4,S*.09); }
  else if(k==='amulet'){ c.lineWidth=Math.max(1,S*.05); c.beginPath(); c.moveTo(-S*.24,-S*.36); c.lineTo(0,S*.04); c.lineTo(S*.24,-S*.36); c.stroke(); wornPoly(c,S,[0,-.04,.18,.18,0,.4,-.18,.18]); }
  else if(k==='armor'){ wornPoly(c,S,[-.3,-.34,-.12,-.34,0,-.22,.12,-.34,.3,-.34,.36,0,.27,.36,-.27,.36,-.36,0]); c.fillStyle=dk; c.fillRect(-S*.15,-S*.06,S*.3,S*.27); }
  else if(k==='pants'){ c.fillRect(-S*.27,-S*.36,S*.54,S*.14); c.fillRect(-S*.27,-S*.22,S*.23,S*.58); c.fillRect(S*.04,-S*.22,S*.23,S*.58); }
  else if(k==='ring'){ c.strokeStyle=col; c.lineWidth=Math.max(1,S*.1); c.beginPath(); c.arc(0,S*.08,S*.24,0,Math.PI*2); c.stroke(); c.fillStyle=dk; wornPoly(c,S,[0,-.38,.14,-.22,0,-.08,-.14,-.22]); }
  else if(k==='boots'){ wornPoly(c,S,[-.24,-.36,.06,-.36,.06,.06,.36,.17,.36,.36,-.24,.36]); c.fillStyle=dk; c.fillRect(-S*.24,S*.27,S*.6,S*.09); }
  else if(k==='gloves'){ c.fillRect(-S*.22,-S*.06,S*.42,S*.4); for(i=0;i<4;i++) c.fillRect(-S*.22+i*S*.11,-S*.34,S*.09,S*.3); c.fillRect(S*.2,S*.0,S*.13,S*.17); c.fillStyle=dk; c.fillRect(-S*.22,S*.25,S*.42,S*.09); }
  else { c.lineWidth=Math.max(1,S*.05); c.beginPath(); c.arc(0,-S*.25,S*.12,Math.PI,0); c.stroke(); c.fillRect(-S*.27,-S*.25,S*.54,S*.61); c.fillStyle=dk; c.fillRect(-S*.27,-S*.25,S*.54,S*.17); c.fillRect(-S*.16,S*.06,S*.32,S*.19); }
  c.restore();
}
'@

SubRx @'
    var it=ITEMS[loot[j]]; if(!it) continue;
    var r=dispR(loot[j])||it.r;
'@ @'
    var it=ITEMS[loot[j]]; if(!it) continue;
    if(it.use==='wornpiece') continue;   // v37.xx (cw-m3drops): a worn piece never changes how a box looks (his answer 58, no glow)
    var r=dispR(loot[j])||it.r;
'@

SubRx @'
        ammoNeed(near,ammoDry(G.player,G.bag));   // v35.xx (cw-ammoneed): a pillager with no ammo is more likely to find an ammo box
'@ @'
        ammoNeed(near,ammoDry(G.player,G.bag));   // v35.xx (cw-ammoneed): a pillager with no ammo is more likely to find an ammo box
        wornBoxRoll(near);   // v37.xx (cw-m3drops): the side roll, once per box
'@

SubRx @'
  if(onlyKeys) return grantLoot(ct,onlyKeys);   // v13.35: hands back where the item went, for the staged pull to show after Took
'@ @'
  if(onlyKeys) return grantLoot(ct,onlyKeys);   // v13.35: hands back where the item went, for the staged pull to show after Took
  wornBoxRoll(ct);   // v37.xx (cw-m3drops): a box opened with no hold first rolls here
'@

SubRx @'
  if(m.dry) ammoNeed(ct,1);   // v35.xx (cw-ammoneed): player 2 has no ammo, so the host rolls the help for his box
'@ @'
  if(m.dry) ammoNeed(ct,1);   // v35.xx (cw-ammoneed): player 2 has no ammo, so the host rolls the help for his box
  wornBoxRoll(ct);   // v37.xx (cw-m3drops): the host rolls with its own seed and its own best gear; the same key means the same piece on both PCs
'@

SubRx @'
    var key=keys[l],itm=ITEMS[key],_rvF=null;
'@ @'
    var key=keys[l],itm=wornItemEnsure(key),_rvF=null;   // v37.xx (cw-m3drops): a piece's key registers itself on any PC
    if(!itm&&wornKeyIs(key)) continue;   // a bad wg_ key from a damaged word gives nothing
'@

SubRx @'
    else { G.bag.push(key); _beltGot=autoBelt(key,1); if(_beltGot) _beltKeep.push(_beltGot); if(beltTag()) _ptags[l]=beltTag(); }
    spark(ct.x,ct.y,itm.c,7,120);
'@ @'
    else { G.bag.push(key); _beltGot=autoBelt(key,1); if(_beltGot) _beltKeep.push(_beltGot); if(beltTag()) _ptags[l]=beltTag(); }
    // v37.xx (cw-m3drops): THE ONE NEW ROW KIND: the pickup row as every other, its rarity colour, its icon, and its one trait line in the row's own tag. The spark puts the cosmetic stream back, so a piece moves neither stream.
    if(itm.use==='wornpiece'){ _ptags[l]=wornRowLine(itm.pc); var _wfx=FXS; spark(ct.x,ct.y,itm.c,7,120); FXS=_wfx; }
    else spark(ct.x,ct.y,itm.c,7,120);
'@

SubRx @'
function bankItem(k){
  var it=ITEMS[k];
'@ @'
function bankItem(k){
  var it=wornItemEnsure(k);
  if(it&&it.use==='wornpiece'){ wornAdd(P,JSON.parse(JSON.stringify(it.pc))); return null; }   // v37.xx (cw-m3drops): an extract turns the key into a record of his own (a copy, so the key still means the piece it spells)
'@

SubRx @'
  } else if(it.use){
    R.push(['USE',String(it.use).toUpperCase()]);
'@ @'
  } else if(it.use==='wornpiece'){
    // v37.xx (cw-m3drops): the tip beside the panel says it
  } else if(it.use){
    R.push(['USE',String(it.use).toUpperCase()]);
'@

SubRx @'
        G.bagCardBox={x:_gcX-_gcSz.w,y:_gcT,w:_gcSz.w,h:_gcSz.h};
      }
    }catch(_gcE){}
'@ @'
        G.bagCardBox={x:_gcX-_gcSz.w,y:_gcT,w:_gcSz.w,h:_gcSz.h};
      }
      // v37.xx (cw-m3drops), his answers 59 and 71: THE SAME TIP IN THE BACKPACK, for a piece under the mouse or else the selected one: beside the panel, under the gun card when one is up; with no room beside, inside the panel's right edge.
      var _wpK=null, _wpSz, _wpM=Math.round(LH(8)*_gcRs), _wpX, _wpY, _wpB=G.bagPanel;
      if(!padOn()&&G.bagCells) for(_gcI=0;_gcI<G.bagCells.length;_gcI++){ _gcC=G.bagCells[_gcI];
        if(mouse.x>=_gcC.x&&mouse.x<=_gcC.x+_gcC.w&&mouse.y>=_gcC.y&&mouse.y<=_gcC.y+_gcC.h){ if(ITEMS[_gcC.key]&&ITEMS[_gcC.key].use==='wornpiece') _wpK=_gcC.key; break; } }
      if(!_wpK&&!_gcIt&&sit&&sit.use==='wornpiece') _wpK=sst.key;
      if(_wpK&&_wpB){
        _wpSz=wornTipSize(ITEMS[_wpK].pc);
        _wpX=_wpB.x+_wpB.w+_wpM; if(_wpX+_wpSz.w>W-_wpM) _wpX=_wpB.x+_wpB.w-_wpM-_wpSz.w;
        _wpY=(_gcIt&&G.bagCardBox)?(G.bagCardBox.y+G.bagCardBox.h+_wpM):((_wpX>_wpB.x+_wpB.w)?_wpB.y:Math.round(_hdrB+_wpM));
        wornTipDraw(ITEMS[_wpK].pc,Math.round(_wpX),Math.round(Math.max(_wpM,Math.min(H-_wpM-_wpSz.h,_wpY))));
      }
    }catch(_gcE){}
'@

SubRx @'
      if(_hsS) ctx.restore();
    }
  }
  // The world pass already draws the name and a health pip on every visible
'@ @'
      if(_hsS) ctx.restore();
      try{ wornTipAtBar(_sc,s2); }catch(_wtb){}   // v37.xx (cw-m3drops): the piece still in this box; the bar and its feel are unchanged
    }
  }
  // The world pass already draws the name and a health pip on every visible
'@

SubRx @'
function drawItemIconArt(c,key,cx,cy,S){
'@ @'
function drawItemIconArt(c,key,cx,cy,S){
  if(wornKeyIs(key)){ wornIconDraw(c,key,cx,cy,S); return; }   // v37.xx (cw-m3drops): a worn piece, one simple icon per kind
'@

SubRx @'
k=netClean(m.items[i],32); if(k&&Object.prototype.hasOwnProperty.call(ITEMS,k)&&ITEMS[k]) items.push(k); }
'@ @'
k=netClean(m.items[i],32); if(k) wornItemEnsure(k); if(k&&Object.prototype.hasOwnProperty.call(ITEMS,k)&&ITEMS[k]) items.push(k); }
'@

SubRx @'
  k=netClean(m.k,32); if(!k||!Object.prototype.hasOwnProperty.call(ITEMS,k)||!ITEMS[k]) return 'bad';
  g=NET.up[peer.seat];
'@ @'
  k=netClean(m.k,32); if(k) wornItemEnsure(k); if(!k||!Object.prototype.hasOwnProperty.call(ITEMS,k)||!ITEMS[k]) return 'bad';
  g=NET.up[peer.seat];
'@

SubRx @'
var VER='37.43';
'@ @'
var VER='37.44';
'@

$pat = "(?m)^  now:'v37\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.44: a map box may hold a worn piece, rolled once on its own dice at the first search so seed 4242 and the raid streams never move; a tip beside the search bar and in the backpack shows its name, traits and better, worse or even; it comes out as a pickup row in its rarity colour with one trait line; on an extract it joins the gear stash, on a death it is gone; looting a box with no piece is exactly what it was Check 37.44 fails on v37.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
