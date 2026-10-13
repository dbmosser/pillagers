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

# EVERY BELT ITEM SHOWS AN INFO CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function beltHoverHud(){
'@ @'
// v24.xx (belthover2), HIS ORDER (2026-10-12): "-- other items should show info card too". THE INFO CARD of every other belt item, in
// the frame and the type of the gun card: the name and a bar down the left in its rarity colour (white, green, blue, purple, gold),
// the rarity word and how many he holds, what it does in numbers read from the numbers the game uses (heals, over, up to, takes;
// armour; rounds; the stim; a charge: damage at the centre, blast, fuse; a smoke and a decoy: how long; the Tripwire Mine: what
// sets it off, damage, blast, arms, lasts), its value in credits, and the keys that use it as keycaps (the belt key, then FIRE).
// Short caps labels, no sentences. Drawing only, as the gun card.
var ITEMRAR={common:'COMMON',uncommon:'UNCOMMON',rare:'RARE',elite:'ELITE',gold:'GOLD'};
function beltInfoKey(S){
  var k;
  if(!S||S.kind==='empty'||S.kind==='gun'||S.vacant) return null;
  k=(S.itemKey&&ITEMS[S.itemKey])?S.itemKey:((S.icon&&ITEMS[S.icon])?S.icon:null);
  return (k&&ITEMS[k].use!=='gun')?k:null;
}
function beltInfoRows(k){
  var it=ITEMS[k], R=[], tk=it&&it.tk;
  function s1(v){ return (Math.round(v*10)/10)+'S'; }
  if(!it) return R;
  if(it.use==='heal'){ R.push(['HEALS',(it.amt||0)+' HP']); if(it.hot) R.push(['OVER',s1(it.hot)]); R.push(['UP TO',(it.capHp||100)+' HP']); R.push(['TAKES',s1(CFG.healPrep===undefined?1.5:CFG.healPrep)]); }
  else if(it.use==='armor'){ R.push(['ARMOUR','+'+(it.amt||0)]); R.push(['TAKES',s1(CFG.armorPrep===undefined?2:CFG.armorPrep)]); }
  else if(it.use==='ammo') R.push(['ROUNDS','+'+(it.amt||0)]);
  else if(it.use==='stim'){ R.push(['LASTS',s1(STIM_SEC)]); R.push(['SPEED','+'+Math.round((STIM_SPD-1)*100)+'%']); R.push(['STAMINA','UNLIMITED']); }
  else if(tk==='frag'){ R.push(['DAMAGE','140']); R.push(['BLAST',Math.round((CFG.fragR===undefined?190:CFG.fragR)/10)+'M']); R.push(['FUSE',s1(FRAG_FUSE)]); }   // 140: explodeFrag, 115+25 at the centre
  else if(tk==='trip'){ R.push(['TRIGGER','WIRE CROSSED']); R.push(['DAMAGE','140']); R.push(['BLAST',Math.round(TRIP_R/10)+'M']); R.push(['ARMS',s1(TRIP_ARM)]); R.push(['LASTS',s1(TRIP_LIFE)]); }   // 140: tripBlast, 110+30
  else if(tk==='smoke'){ R.push(['RADIUS',Math.round((CFG.smokeR===undefined?165:CFG.smokeR)/10)+'M']); R.push(['LASTS','12S']); }   // activateThrow: life 12
  else if(tk==='decoy'){ R.push(['LASTS','6S']); }   // activateThrow: life 6
  else if(it.use==='key') R.push(['OPENS','1 LOCKED ROOM']);
  return R;
}
function itemCardSize(o){
  var rs=Math.max(1,hudRes()), fp=msgPx(hudFS(TYPE.label)), hp=msgPx(hudFS(TYPE.head)), pad=Math.round(LH(8)*rs), rh=Math.round(fp*1.5);
  return {w:Math.round(fp*18), h:pad*2+Math.round(hp*1.1)+rh*(1+o.rows.length+(o.val?1:0))+Math.round(rh*1.35)};
}
function itemCardDraw(o,xR,yB,al){
  var rs=Math.max(1,hudRes()), fL=hudFS(TYPE.label), fp=msgPx(fL), fH=hudFS(TYPE.head), hp=msgPx(fH), pad=Math.round(LH(8)*rs), rh=Math.round(fp*1.5);
  var sz=itemCardSize(o), w=sz.w, h=sz.h, x=xR-w, y=yB-h, yy, i, oa=ctx.globalAlpha, cx, a, gp=Math.round(LH(5)*rs);
  ctx.save();
  try{
    ctx.globalAlpha=oa*(al===undefined?1:al);
    hudPlate(x,y,w,h,null,'rgba(11,12,13,.9)'); hudPlate(x,y,w,h,o.col,HUDC.plate);   // solid, as the gun card over the belt
    ctx.textBaseline='alphabetic';
    yy=y+pad+Math.round(hp*0.85);
    ctx.font=fH; ctx.textAlign='left'; ctx.fillStyle=o.col; ctx.fillText(o.name,x+pad,yy,w-pad*2);
    yy+=rh; ctx.font=fL; ctx.fillStyle=o.col; ctx.fillText(o.rar,x+pad,yy);
    ctx.textAlign='right'; ctx.fillStyle=HUDC.text; ctx.fillText(o.held,x+w-pad,yy);
    for(i=0;i<o.rows.length;i++){
      yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText(o.rows[i][0],x+pad,yy);
      ctx.textAlign='right'; ctx.fillStyle=HUDC.text; ctx.fillText(String(o.rows[i][1]),x+w-pad,yy,w*0.6);
    }
    if(o.val){ yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText('VALUE',x+pad,yy); ctx.textAlign='right'; ctx.fillStyle=UIC.acc; ctx.fillText(o.val,x+w-pad,yy); }
    yy+=Math.round(rh*1.35); ctx.textAlign='left'; a=Math.round(fp*0.72); cx=x+pad;
    for(i=0;i<o.keys.length;i++){
      cx+=hudKey(o.keys[i][0],cx,yy,a,0)+LH(2)+gp; ctx.font=fL; ctx.textAlign='left'; ctx.fillStyle=HUDC.text;
      ctx.fillText(o.keys[i][1],cx,yy); cx+=hudRawW(o.keys[i][1])+gp*2.4;
    }
  } finally { ctx.restore(); ctx.globalAlpha=oa; }
  return h;
}
function beltInfoCard(S,c){
  var k=beltInfoKey(S), it, rk, o, rs, m, sz, xR, yB, v, n;
  if(!k||!c) return null;
  it=ITEMS[k]; rk=dispR(k)||it.r||'common'; v=ival(k); n=(S.count|0);
  o={name:String(it.name).toUpperCase(), col:RCOL[rk]||HUDC.text, rar:ITEMRAR[rk]||'', held:'HELD '+n, rows:beltInfoRows(k),
     val:(v>0)?('$'+v.toLocaleString()):'', keys:[[String(keyLabel('Digit'+(c.i+1),String(c.i+1))),'SELECT'],['FIRE','USE']]};
  rs=Math.max(1,hudRes()); m=Math.round(LH(8)*rs); sz=itemCardSize(o);
  xR=Math.round(Math.max(m+sz.w,Math.min(W-m,c.x+c.w/2+sz.w/2)));
  yB=Math.round(c.y-LH(6)*rs-((state!=='hub')?msgPx(beltCapFS(c.w))*1.1:0));
  yB=Math.max(m+sz.h,Math.min(H-m,yB));
  itemCardDraw(o,xR,yB,1);
  BELTHOV.box={x:xR-sz.w,y:yB-sz.h,w:sz.w,h:sz.h,i:c.i,kind:'item',name:o.name,key:k};
  return BELTHOV.box;
}
function beltHoverHud(){
'@

SubRx @'
  S=hotbarSlots()[c.i]; g=beltHovGun(S);
  if(!g) return null;
'@ @'
  S=hotbarSlots()[c.i]; g=beltHovGun(S);
  if(!g) return beltInfoCard(S,c);   // v24.xx (belthover2): every other item shows its info card
'@

SubRx @'
var VER='25.58';
'@ @'
var VER='25.59';
'@

$pat = "(?m)^  now:'v25\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.59: Rest the mouse on any item on the tactical belt and its info card shows above it. Check 25.59 fails on v25.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
