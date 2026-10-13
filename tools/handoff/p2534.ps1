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

# A GUN ON THE BELT SHOWS ITS CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          rng:Math.round((w.rng||0)/10),hand:hand,dps:Math.round(sus)};
'@ @'
          rng:Math.round((w.rng||0)/10),hand:hand,dps:Math.round(sus),
          fk:(w.fk===1||w.fk===2)?w.fk:0, el:(w.fk===2&&w.el&&typeof ELEM!=='undefined'&&ELEM[w.el])?w.el:''};   // v24.xx (belthover1): the forge MK and the element, for the card
'@

SubRx @'
function gunCardDraw(cmp,xR,yB,al,tag){
  var rs=Math.max(1,hudRes()), fL=hudFS(TYPE.label), fp=msgPx(fL), fH=hudFS(TYPE.head), hp=msgPx(fH), pad=Math.round(LH(8)*rs), rh=Math.round(fp*1.5);
  var R=GUNSTAT_ROWS, w=Math.round(fp*18), h=pad*2+Math.round(hp*1.1)+rh*(1+R.length)+(tag?rh:0), x=xR-w, y=yB-h,
'@ @'
// v24.xx (belthover1): the size of the card, read by gunCardDraw and by the belt hover card (which places it above a key before it is
// drawn). A MK III adds one row: its element in its own colour and what it does.
function gunCardSize(cmp,tag){
  var rs=Math.max(1,hudRes()), fp=msgPx(hudFS(TYPE.label)), hp=msgPx(hudFS(TYPE.head)), pad=Math.round(LH(8)*rs), rh=Math.round(fp*1.5);
  var el=!!(cmp&&cmp.f&&cmp.f.el&&typeof ELEM!=='undefined'&&ELEM[cmp.f.el]);
  return {w:Math.round(fp*18), h:pad*2+Math.round(hp*1.1)+rh*(1+GUNSTAT_ROWS.length)+(tag?rh:0)+(el?rh:0)};
}function gunCardDraw(cmp,xR,yB,al,tag){
  var rs=Math.max(1,hudRes()), fL=hudFS(TYPE.label), fp=msgPx(fL), fH=hudFS(TYPE.head), hp=msgPx(fH), pad=Math.round(LH(8)*rs), rh=Math.round(fp*1.5);
  var R=GUNSTAT_ROWS, _gz=gunCardSize(cmp,tag), w=_gz.w, h=_gz.h, x=xR-w, y=yB-h,
'@

SubRx @'
    ctx.fillText('VS '+(cmp.h?String(cmp.h.name).toUpperCase():'BARE HANDS'),x+w-pad,yy,w*0.56);
'@ @'
    if(!cmp.noVs) ctx.fillText('VS '+(cmp.h?String(cmp.h.name).toUpperCase():'BARE HANDS'),x+w-pad,yy,w*0.56);   // v24.xx (belthover1): not on the card of the gun in hand
'@

SubRx @'
    if(tag){ yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText(String(tag).toUpperCase(),x+pad,yy,w-pad*2); }
'@ @'
    if(cmp.f.el&&typeof ELEM!=='undefined'&&ELEM[cmp.f.el]){   // v24.xx (belthover1): a MK III names its element in its colour, and what it does
      yy+=rh; ctx.textAlign='left'; ctx.fillStyle=ELEM[cmp.f.el].c; ctx.fillText(ELEM[cmp.f.el].name,x+pad,yy);
      ctx.textAlign='right'; ctx.fillStyle=HUDC.dim; ctx.fillText(String(ELEM[cmp.f.el].w2||''),x+w-pad,yy,w*0.62);
    }    if(tag){ yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText(String(tag).toUpperCase(),x+pad,yy,w-pad*2); }
'@

SubRx @'
  return gunCardDraw(gunCompare(C.w,C.vs),W-8*rs,Math.round(H*0.6),Math.max(0,Math.min(1,(GUNCARD_T-age)/0.5)),C.route);
}
'@ @'
  return gunCardDraw(gunCompare(C.w,C.vs),W-8*rs,Math.round(H*0.6),Math.max(0,Math.min(1,(GUNCARD_T-age)/0.5)),C.route);
}
// v24.xx (belthover1), HIS ORDER (2026-10-12): "guns on the toolbar should automatically show their gun card when theyy are moused
// over -- other items should show info card too". THE BELT HOVER CARD, GUNS FIRST. The mouse resting on a gun key of the tactical
// belt shows that gun's stat card (gunCardDraw, the one card of the pickup and the backpack: the name with its MK, the element of a
// MK III, the five numbers) just above the key and its caption, kept inside the screen at any size. The gun in his hands reads IN
// HANDS with no comparison; the other gun he carries (OTHER GUN) and a packed gun (IN BACKPACK) are compared with it. It waits a
// short dwell on one key (BELTHOV_DWELL), so sweeping the crosshair across the belt never flashes cards, and it is gone the frame
// the mouse leaves. Drawing only: it takes no click and no key, so firing, aiming and dragging are untouched; it hides while the
// trigger is held, during a drag or a HUD panel drag, with the map, the pause box or a trade up, while down, and while a controller
// owns the crosshair. The Undercroft belt (the floor and the backpack) draws the same card. BELTHOV is the key under the mouse, when
// the mouse got there, and the card drawn this frame (box, in screen pixels), for the fixture.
var BELTHOV={i:-1,at:0,st:'',box:null}, BELTHOV_DWELL=0.15;
function beltHovNow(){ return ((typeof performance!=='undefined'&&performance.now)?performance.now():Date.now())/1000; }
function beltHovGun(S){
  var p=G&&G.player, it, gk;
  if(!S||S.kind!=='gun'||S.vacant) return null;
  it=S.itemKey?ITEMS[S.itemKey]:null;
  gk=(it&&it.use==='gun')?it.gk:((S.icon&&WEAPONS[S.icon])?S.icon:null);
  if(!gk||gk==='fists'||!WEAPONS[gk]||!(WEAPONS[gk].mag>0)) return null;
  if(p&&S.inHand&&p.wep&&p.wep.id===gk) return {w:p.wep,hand:1};
  if(p&&(!it||S.equipped)){
    if(p.sec&&p.sec.id===gk) return {w:p.sec,tag:'OTHER GUN'};
    if(p.wep&&p.wep.id===gk) return {w:p.wep,hand:1};
  }
  return {w:((typeof gunQPeek==='function')&&gunQPeek(gk))||WEAPONS[gk],tag:'IN BACKPACK'};
}
function beltHovCell(){
  var C=G&&G.hotCells, i, c;
  if(!C||!C.length||typeof mouse==='undefined'||!mouse) return null;
  for(i=0;i<C.length;i++){ c=C[i]; if(c&&mouse.x>=c.x&&mouse.x<=c.x+c.w&&mouse.y>=c.y&&mouse.y<=c.y+c.h) return c; }
  return null;
}
function beltHovOff(){
  var p=G&&G.player;
  return !G||!!G.over||!!G.mapOpen||!!G.paused||!!pauseOpen||!!G.trade||!!G.drag||!!mouse.down||!!HUDDRAG||!!HUDRESIZE
    ||!!(padOn()&&PAD.curOwn)||!!(p&&(p.downed||p.dying));
}
function beltHoverHud(){
  var now=beltHovNow(), c, S, g, cmp, rs, m, sz, xR, yB, p=G&&G.player;
  BELTHOV.box=null;
  c=beltHovOff()?null:beltHovCell();
  if(!c){ BELTHOV.i=-1; return null; }
  if(c.i!==BELTHOV.i||BELTHOV.st!==state){ BELTHOV.i=c.i; BELTHOV.at=now; BELTHOV.st=state; return null; }
  if(now-BELTHOV.at<BELTHOV_DWELL) return null;
  S=hotbarSlots()[c.i]; g=beltHovGun(S);
  if(!g) return null;
  cmp=g.hand?{verdict:'IN HANDS',f:gunStats(g.w),h:null,d:{},noVs:1}:gunCompare(g.w,p&&p.wep);
  rs=Math.max(1,hudRes()); m=Math.round(LH(8)*rs); sz=gunCardSize(cmp,g.tag||'');
  xR=Math.round(Math.max(m+sz.w,Math.min(W-m,c.x+c.w/2+sz.w/2)));
  yB=Math.round(c.y-LH(6)*rs-((state!=='hub')?msgPx(beltCapFS(c.w))*1.1:0));   // above the key, and above its caption line in a raid
  yB=Math.max(m+sz.h,Math.min(H-m,yB));
  ctx.save(); try{ hudPlate(xR-sz.w,yB-sz.h,sz.w,sz.h,null,'rgba(11,12,13,.9)'); } finally { ctx.restore(); }   // a solid backing: over the belt the card sits on busy ground and HUD panels
  gunCardDraw(cmp,xR,yB,1,g.tag||'');
  BELTHOV.box={x:xR-sz.w,y:yB-sz.h,w:sz.w,h:sz.h,i:c.i,kind:'gun',name:String(cmp.f.name)};
  return BELTHOV.box;
}
'@

SubRx @'
  try{ gunCardHud(); }catch(_gch){}   // v23.xx (feat2b): the gun stat card on pickup
'@ @'
  try{ gunCardHud(); }catch(_gch){}   // v23.xx (feat2b): the gun stat card on pickup
  try{ beltHoverHud(); }catch(_bhv){}   // v24.xx (belthover1): the card of the gun the mouse rests on, on the tactical belt
'@

SubRx @'
  try{ G=st; drawBelt(); HUBBELT.cells=(st.hotCells||[]).slice(); }
'@ @'
  try{ G=st; drawBelt(); HUBBELT.cells=(st.hotCells||[]).slice(); try{ beltHoverHud(); }catch(_bhv){} }   // v24.xx (belthover1): the belt hover card on the floor
'@

SubRx @'
  try{ G=hubBagG; drawBag(); drawBelt(); drawDragGhost(); }
'@ @'
  try{ G=hubBagG; drawBag(); drawBelt(); try{ beltHoverHud(); }catch(_bhv){} drawDragGhost(); }   // v24.xx (belthover1): and over the Undercroft backpack
'@

SubRx @'
var VER='25.33';
'@ @'
var VER='25.34';
'@

$pat = "(?m)^  now:'v25\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.34: Rest the mouse on a gun on the tactical belt and its stat card shows above it. Check 25.34 fails on v25.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
