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

# GUN STAT CARD ON PICKUP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var found=ct.dropped?(function(){var g2={};for(var k2 in WEAPONS[itm.gk])g2[k2]=WEAPONS[itm.gk][k2];g2.q='field';g2.qRank=1;return g2;})():rollFieldGun(itm.gk);
'@ @'
      var found=ct.dropped?(function(){var g2={};for(var k2 in WEAPONS[itm.gk])g2[k2]=WEAPONS[itm.gk][k2];g2.q='field';g2.qRank=1;return g2;})():rollFieldGun(itm.gk);
      var _gcVs=p.wep;   // v23.xx (feat2b): the gun in hand before this find is routed, for the stat card
'@

SubRx @'
      }
    }
    else if(G.arcade&&!G.sim&&itm&&!itm.use) _ptags[l]=
'@ @'
      }
      // v23.xx (feat2b), HIS #17 and his answer 34 (2026-10-12): THE STAT CARD ON PICKUP. Every gun he takes raises the card against
      // the gun that was in his hands, with where it went. In the arcade a gun scrapped for points raises none (it is not his).
      if(!G.sim&&!(G.arcade&&(/^SCRAPPED/).test(String(_ptags[l]||'')))) G.gunCard={gk:itm.gk,w:found,vs:_gcVs,route:String(_ptags[l]||'BACKPACK'),t0:G.t||0};
    }
    else if(G.arcade&&!G.sim&&itm&&!itm.use) _ptags[l]=
'@

SubRx @'
function alertLayout(){
'@ @'
// v23.xx (feat2b), HIS #17 (2026-10-12): "better gun stat cards - yes", and his answer 34: on pickup and in the backpack. ONE CARD,
// drawn from gunCompare (feat2a) so the UI redesign can restyle it in one place: the gun name in its rarity colour, the verdict
// (UPGRADE green, DOWNGRADE red, SIDEGRADE amber) against the gun in his hands, then DMG, RATE, MAG, RANGE and HANDLING with the
// difference (green better, red worse, = the same), and where it went. Sized by hudRes, so at 4K it is twice the 1080p size and reads
// on a TV. gunCardDraw draws it with its bottom right corner at xR,yB and returns its height.
function gunCardDraw(cmp,xR,yB,al,tag){
  var rs=Math.max(1,hudRes()), fL=hudFS(TYPE.label), fp=msgPx(fL), fH=hudFS(TYPE.head), hp=msgPx(fH), pad=Math.round(LH(8)*rs), rh=Math.round(fp*1.5);
  var R=GUNSTAT_ROWS, w=Math.round(fp*18), h=pad*2+Math.round(hp*1.1)+rh*(1+R.length)+(tag?rh:0), x=xR-w, y=yB-h, i, k, v, dv, yy, vc, oa=ctx.globalAlpha, xv, xd;
  vc=(cmp.verdict==='UPGRADE')?'#7fe08a':((cmp.verdict==='DOWNGRADE')?'#ff6b5a':'#ffc04a');
  ctx.save();
  try{
    ctx.globalAlpha=oa*(al===undefined?1:al);
    hudPlate(x,y,w,h,vc,HUDC.plate);
    ctx.textBaseline='alphabetic';
    yy=y+pad+Math.round(hp*0.85);
    ctx.font=fH; ctx.textAlign='left'; ctx.fillStyle=RCOL[gunRarity(cmp.f.id)]||HUDC.text;
    ctx.fillText(String(cmp.f.name).toUpperCase(),x+pad,yy,w-pad*2);
    yy+=rh; ctx.font=fL; ctx.fillStyle=vc; ctx.fillText(cmp.verdict,x+pad,yy);
    ctx.textAlign='right'; ctx.fillStyle=HUDC.dim;
    ctx.fillText('VS '+(cmp.h?String(cmp.h.name).toUpperCase():'BARE HANDS'),x+w-pad,yy,w*0.56);
    xd=x+w-pad; xv=xd-Math.round(fp*3.6);
    for(i=0;i<R.length;i++){
      k=R[i][0]; v=cmp.f[k]; dv=cmp.h?cmp.d[k]:null; yy+=rh;
      ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText(R[i][1],x+pad,yy);
      ctx.textAlign='right'; ctx.fillStyle=HUDC.text; ctx.fillText(String(v)+(k==='rng'?'M':''),xv,yy);
      if(dv!==null){ ctx.fillStyle=dv>0?'#7fe08a':(dv<0?'#ff6b5a':HUDC.dim); ctx.fillText(dv>0?('+'+dv):(dv<0?String(dv):'='),xd,yy); }
    }
    if(tag){ yy+=rh; ctx.textAlign='left'; ctx.fillStyle=HUDC.dim; ctx.fillText(String(tag).toUpperCase(),x+pad,yy,w-pad*2); }
  } finally { ctx.restore(); ctx.globalAlpha=oa; }
  return h;
}
// v23.xx (feat2b): the pickup card, 4 s from the pickup (fading for the last half second), at the right edge above the pickup stack.
// Hidden while the backpack or the map is open (the backpack has its own card).
var GUNCARD_T=4;
function gunCardHud(){
  var C=G&&G.gunCard, age, rs;
  if(!C||!G.player||G.over||G.bagOpen||G.mapOpen) return 0;
  age=(G.t||0)-(C.t0||0);
  if(age>GUNCARD_T||age<-1){ G.gunCard=null; return 0; }
  rs=Math.max(1,hudRes());
  return gunCardDraw(gunCompare(C.w,C.vs),W-8*rs,Math.round(H*0.6),Math.max(0,Math.min(1,(GUNCARD_T-age)/0.5)),C.route);
}
function alertLayout(){
'@

SubRx @'
  try{ drawPickups(); }catch(_dpk){}   // v22.50 (R16): the pickup stack on the right edge
'@ @'
  try{ drawPickups(); }catch(_dpk){}   // v22.50 (R16): the pickup stack on the right edge
  try{ gunCardHud(); }catch(_gch){}   // v23.xx (feat2b): the gun stat card on pickup
'@

SubRx @'
var VER='23.78';
'@ @'
var VER='23.79';
'@

$pat = "(?m)^  now:'v23\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.79: Picking up a gun now shows a stat card that says if it is an upgrade, with damage, rate, magazine, range and handling. Check 23.79 fails on v23.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
