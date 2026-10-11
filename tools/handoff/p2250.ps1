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

# THE PICKUP STACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(k==='log') return;
    if(msgAlertK(k)){ alertSay(m,k,o); return; }   // v22.13 (R08): crit, warn and ext take the alert lane, not a feed row
'@ @'
    if(k==='log') return;
    if(k==='pick'){ pickSay(m,o); return; }   // v22.50 (R16): an item picked up is a row in the pickup stack, never a feed row
    if(msgAlertK(k)){ alertSay(m,k,o); return; }   // v22.13 (R08): crit, warn and ext take the alert lane, not a feed row
'@

SubRx @'
function sayWhenFree(m,kind,o){
  if(G&&!G.sim&&G.msgT>0){
'@ @'
function sayWhenFree(m,kind,o){
  if(G&&!G.sim&&G.msgT>0&&msgKind(kind)!=='pick'){   // v22.50 (R16): a pickup row has its own stack and never waits behind the feed
'@

SubRx @'
  alertTick(dt);   // the alert lane and its queue (R08)
'@ @'
  alertTick(dt);   // the alert lane and its queue (R08)
  pickTick(dt);   // v22.50 (R16): the pickup stack
'@

SubRx @'
function msgPx(f){ var m=(/([\d.]+)px/).exec(f); return m?parseFloat(m[1]):LH(12); }
'@ @'
function msgPx(f){ var m=(/([\d.]+)px/).exec(f); return m?parseFloat(m[1]):LH(12); }
// v22.50, the raid text rewrite (R16): THE PICKUP STACK. HIS ORDER (2026-10-09): the raid text reads like Call of Duty, Fortnite
// or ARC Raiders, and in those what you pick up is a short row at the side of the screen (the item, its name in its rarity colour,
// how many), never a sentence in the middle of it. Until now every item pulled out of a box was said twice in the message rows,
// Found: X and then Took X., so a box of three items wrote six lines over each other in the middle of the screen and only the last
// two were left to read, pushing any line that mattered off. say(name,'pick',{item,n,tag}) now pushes a row into G.pick instead
// (read by __hudSaid('pick')): the item icon, the name in its rarity colour, a count and a dim caps tag, on a plate at the right
// edge, growing up from above the gun card and the hidden chip, never higher than 62 percent down the screen (under the co-op
// kill feed). The stack holds 4 rows for 4 s each, newest at the bottom; the same item picked up again while its row is up adds to
// its count and refreshes it. It is hidden while the backpack or the map is open. The world loot labels at the box (his 6 s) stay.
// Cosmetic only: nothing here runs while G.sim is set, draws a random number or changes game state.
var PICKN=4, PICKLIFE=4;
function pickSay(m,o){
  if(!G) return;
  var q=(G.pick=G.pick||[]), now=G.t||0, it=(o&&o.item)||'', n=(o&&o.n>0)?Math.round(o.n):1, i, r;
  for(i=0;i<q.length;i++){
    r=q[i];
    if(r.T>0&&(it?r.item===it:(!r.item&&r.m===String(m)))){   // the same item while its row is up: one row, counted
      r.n+=n; r.T=PICKLIFE; r.m=String(m); if(o&&o.tag) r.tag=String(o.tag); if(o&&o.c) r.c=o.c;
      if(i<q.length-1){ q.splice(i,1); q.push(r); }
      return;
    }
  }
  q.push({m:String(m),item:it,n:n,tag:(o&&o.tag)?String(o.tag):'',c:(o&&o.c)||'',T:(o&&o.life>0)?o.life:PICKLIFE,at:now});
  while(q.length>PICKN) q.shift();
}
function pickTick(dt){
  var q=G&&G.pick, i;
  if(!q) return;
  for(i=q.length-1;i>=0;i--){ q[i].T-=dt; if(!(q[i].T>0)) q.splice(i,1); }
}
function pickCol(r){
  if(r.c) return HUDC[r.c]||r.c;
  var it=r.item&&ITEMS[r.item], rk=it?(dispR(r.item)||it.r):'';
  return (rk&&RCOL[rk])||HUDC.text;
}
function drawPickups(){
  var q=G&&G.pick, now, rs, zg, og, base, top, fL, fp, rh, gap, pad, isz, i, r, y, yb, al, col, nm, cnt, tag, wN, wC, wT, w, x, xR, oa, n=0;
  if(!q||!q.length||!G.player||G.over||G.bagOpen||G.mapOpen) return 0;
  now=G.t||0; rs=Math.max(1,hudRes());
  zg=(HUDZ.gear||1)*rs*hudUserZ('gear'); og=hudOff('gear');
  base=H+((H-34-LH(90))-H)*zg+(og.dy||0)-LH(6)-LH(20)*rs-LH(10)*rs;   // above the gun card and the place of the hidden chip over it
  top=H*0.62;   // never higher: the co-op kill feed and CONDITIONS live above
  fL=hudFS(TYPE.label); fp=msgPx(fL); rh=Math.round(fp*1.75); gap=Math.round(LH(4)*rs); pad=Math.round(LH(8)*rs); isz=Math.round(fp*1.3);
  xR=W-8*rs;   // where the gun card and the hidden chip end
  oa=ctx.globalAlpha;
  ctx.save();
  try{
    y=base;
    for(i=q.length-1;i>=0;i--){
      r=q[i];
      if(y-rh<top) break;
      al=Math.max(0,Math.min(1,(now-r.at)/0.15,r.T/0.5));
      if(!(al>0)) continue;
      ctx.font=fL; ctx.textAlign='right'; ctx.textBaseline='alphabetic';
      col=pickCol(r); nm=String(r.m); cnt=(r.n>1)?('x'+r.n):''; tag=r.tag?String(r.tag).toUpperCase():'';
      wN=ctx.measureText(nm).width; wC=cnt?ctx.measureText(cnt).width:0; wT=tag?ctx.measureText(tag).width:0;
      w=pad+((r.item&&ITEMS[r.item])?isz+pad*0.75:0)+wN+(cnt?pad*0.75+wC:0)+(tag?pad+wT:0)+pad;
      ctx.globalAlpha=oa*al;
      hudPlate(xR-w,y-rh,w,rh,col,HUDC.plate);
      yb=Math.round(y-rh/2+fp*0.36); x=xR-pad;
      if(tag){ ctx.fillStyle=HUDC.dim; ctx.fillText(tag,x,yb); x-=wT+pad; }
      if(cnt){ ctx.fillStyle=HUDC.text; ctx.fillText(cnt,x,yb); x-=wC+pad*0.75; }
      ctx.fillStyle=col; ctx.fillText(nm,x,yb); x-=wN+pad*0.75;
      if(r.item&&ITEMS[r.item]){ try{ drawIconSprite(ctx,r.item,x-isz/2,y-rh/2,isz); }catch(_ic){} }
      y-=rh+gap; n++;
    }
  } finally { ctx.restore(); ctx.globalAlpha=oa; }
  return n;
}
'@

SubRx @'
  drawCrierMarkers();
  if(!G.mapOpen&&!G.bagOpen){
'@ @'
  drawCrierMarkers();
  try{ drawPickups(); }catch(_dpk){}   // v22.50 (R16): the pickup stack on the right edge
  if(!G.mapOpen&&!G.bagOpen){
'@

SubRx @'
      var _sum='Found: '+keys.map(function(k){return ITEMS[k].name;}).join(', ');
      if(_gunLine&&_lootSub){ say(_gunLine,'info',{sub:_lootSub}); if(keys.length>1) say(_sum); }   // v22.43: the stowed gun and its swap key
      else say(_gunLine?((keys.length>1)?(_gunLine+' '+_sum):_gunLine):_sum);
'@ @'
      // v22.50 (R16): each item is a row in the pickup stack, so the Found line is gone from the message rows; the gun line stays.
      for(var _pk=0;_pk<keys.length;_pk++) if(ITEMS[keys[_pk]]) say(ITEMS[keys[_pk]].name,'pick',{item:keys[_pk]});
      if(_gunLine) say(_gunLine,'info',_lootSub?{sub:_lootSub}:null);   // v22.43: the stowed gun and its swap key
'@

SubRx @'
            say('Took '+ITEMS[_k].name+'.');
'@ @'
            // v22.50 (R16): no Took line. The pull above has put the item in the pickup stack, so a second line about it in the
            // middle of the screen only pushed the lines that matter off.
'@

SubRx @'
      say('Took '+items.map(function(q){ return ITEMS[q].name; }).join(', ')+'.');
'@ @'
      // v22.50 (R16): no Took line; openContainer above has put each item in the pickup stack.
'@

SubRx @'
var VER='22.49';
'@ @'
var VER='22.50';
'@

$pat = "(?m)^  now:'v22\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.50: What you pick up shows as rows on the right edge, above the gun card, with its icon and count. Check 22.50 fails on v22.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
