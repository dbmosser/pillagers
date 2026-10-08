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

# STATUS ICONS ON THE LEFT, LIKE WOW OR DIABLO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawBossBar(){
'@ @'
// v19.00, his notes (2026-10-07): "there should be status effect icons over on the side, like in WoW or diablo -- healing,
// stamina, etc" and "like maybe the green circle heal happens open on the left instead of above the player's head".
// THE STATUS COLUMN. Round icons down the left edge, in the band that is empty in every HUD state: under the CURRENT PILLAGERS
// board (capped at 38 percent of the height) and above the controls legend, or above the vitals when the legend is folded or off.
// A buff sits on a dark disc; a status working against you sits on a hexagon with a red edge, so the two read apart without
// reading. A ring in the status colour is lit for the share of its time still to run, clockwise from twelve, and empties as it
// wears off. The name and what is left are written beside it on a dark tab, so it reads from a sofa with no mouse (player 2 is on
// a pad). HEALING is the green ring that sat over her head since v5.44, moved here with the same reading: the health still to come
// up to healReach, over what this fill delivers, and the same seconds. STIM, RECOVERING (the out of fight creep back to the
// Bandage ceiling), WINDED (and the let-go-of-sprint latch nothing showed), WADING in deep water, LIQUOR and BLOTTER had no icon.
// A drink with two or more doses carries the count on a badge. Drawn in screen space at the top level of drawHUD and scaled once
// by hudRes (41 pixels at 1080p, 82 at 4K), never inside another panel's zoom. It registers no HUDBOX, so it never takes a click
// and a shot goes straight through it. Each window draws its own player from its own profile. Plain paths: no images, no
// gradients, and a word is rebuilt and measured only when its number changes.
var STATUSL=[
  {id:'heal',  nm:'HEALING',    col:'#6fe0a0', bad:0},
  {id:'stim',  nm:'STIM',       col:'#ffd25a', bad:0},
  {id:'rest',  nm:'RECOVERING', col:'#ff9db0', bad:0},
  {id:'wind',  nm:'WINDED',     col:'#ff5a4a', bad:1},
  {id:'wade',  nm:'WADING',     col:'#6fb6d8', bad:1},
  {id:'drunk', nm:'LIQUOR',     col:'#d98aff', bad:1},
  {id:'lsd',   nm:'BLOTTER',    col:'#ff9ae6', bad:1}
];
var STATUS_HEX=(function(){ var o=[], k; for(k=0;k<6;k++) o.push(Math.cos(-1.5708+k*1.0472),Math.sin(-1.5708+k*1.0472)); return o; })();
// What is true about this window's player now, written into the fixed list in place: on, the lit share of the ring (what is
// still to run), the dose count, and the words under the name. Reads only; changes nothing.
function statusLive(p){
  var L=STATUSL, B=(typeof P!=='undefined'&&P&&P.buzz)?P.buzz:null, E, i, j, t, k, n, mx, du, top;
  for(i=0;i<L.length;i++){
    E=L[i]; E.on=false; E.n=0; E.f=1;
    if(E.id==='heal'){
      // the reading the ring over her head used (v15.40): health still to come up to healReach, of what this fill delivers
      t=((p.healQ||0)>0)?Math.max(0,healReach(p)-p.hp):0;
      if(t>0&&(p.healAmt0||0)>0&&(p.healRate||0)>0){ E.on=true; E.f=clamp(t/p.healAmt0,0,1); k=Math.ceil(t/p.healRate); if(E.vk!==k){ E.vk=k; E.v=k+'s'; } }
    } else if(E.id==='stim'){
      if((p.stimT||0)>0){ E.on=true; E.f=clamp(p.stimT/STIM_SEC,0,1); k=Math.ceil(p.stimT); if(E.vk!==k){ E.vk=k; E.v=k+'s'; } }
    } else if(E.id==='rest'){
      // tickRegen's own test: standing, under the Bandage ceiling, and regenDelay seconds since a shot fired or taken
      top=healCeil(ITEMS.bandage);
      if(!p.downed&&p.hp>0&&p.hp<top&&(p.combatT||0)>=CFG.regenDelay){ E.on=true; if(E.vk!==top){ E.vk=top; E.v='to '+top; } }
    } else if(E.id==='wind'){
      // the v4.24 lock (the ring runs down as the bar climbs back to 12) and the v8.73 latch, which the player update clears
      // every frame the sprint key is up, so while it is set the key is still held
      if(!p.downed&&!((p.stimT||0)>0)&&(p.stamLock||p.stamRelease)){
        E.on=true;
        if(p.stamLock){ E.f=clamp(1-(p.stam||0)/12,0,1); if(E.vk!==1){ E.vk=1; E.v='out of breath'; } }
        else if(E.vk!==2){ E.vk=2; E.v='let go of sprint'; }
      }
    } else if(E.id==='wade'){
      // the same deep water test and edge the speed line uses, so it shows exactly where the slow is
      if(!p.downed&&inWaterDeep(p.x,p.y,(CFG.wadeInset===undefined?11:CFG.wadeInset))){ E.on=true; if(E.vk!==1){ E.vk=1; E.v='slow and loud'; } }
    } else if(B){
      // a drink: every dose of this kind in the profile, the ring and the time on the one with the longest left
      n=0; mx=0; du=180;
      for(j=0;j<B.length;j++) if(B[j]&&B[j].tag===E.id){ n++; if(B[j].t>mx){ mx=B[j].t; du=B[j].dur||180; } }
      if(n>0&&mx>0){ E.on=true; E.n=n; E.f=clamp(mx/du,0,1); k=Math.ceil(mx); if(E.vk!==k){ E.vk=k; E.v=(k>=60)?(Math.floor(k/60)+':'+((k%60)<10?'0':'')+(k%60)):(k+'s'); } }
    }
  }
}
// A dark tab with round ends from x0 to x1, h tall, centred on cy.
function statusPill(x0,cy,x1,h){
  var r=h/2;
  if(x1<x0+h) x1=x0+h;
  ctx.beginPath();
  ctx.arc(x0+r,cy,r,Math.PI*0.5,Math.PI*1.5);
  ctx.arc(x1-r,cy,r,-Math.PI*0.5,Math.PI*0.5);
  ctx.closePath(); ctx.fill();
}
// The glyphs about the icon centre, u half their size, with fill and stroke already set to col: a cross for healing, a syringe
// for the stim, a heart for recovering, a struck double chevron for winded, two waves for wading, a bottle for liquor and a
// blotter tab for blotter.
function statusGlyph(id,cx,cy,u,col){
  ctx.beginPath();
  if(id==='heal'){
    ctx.rect(cx-u*0.34,cy-u,u*0.68,u*2); ctx.rect(cx-u,cy-u*0.34,u*2,u*0.68); ctx.fill();
  } else if(id==='stim'){
    ctx.save(); ctx.translate(cx,cy); ctx.rotate(-0.7854);
    ctx.rect(-u*0.62,-u*0.3,u*1.12,u*0.6); ctx.rect(-u*1.0,-u*0.09,u*0.4,u*0.18); ctx.rect(-u*1.12,-u*0.38,u*0.14,u*0.76); ctx.rect(u*0.5,-u*0.06,u*0.6,u*0.12);
    ctx.fill(); ctx.restore();
  } else if(id==='rest'){
    ctx.moveTo(cx,cy+u*0.92);
    ctx.bezierCurveTo(cx-u*1.35,cy-u*0.05,cx-u*0.62,cy-u*1.22,cx,cy-u*0.42);
    ctx.bezierCurveTo(cx+u*0.62,cy-u*1.22,cx+u*1.35,cy-u*0.05,cx,cy+u*0.92);
    ctx.fill();
  } else if(id==='wind'){
    ctx.lineWidth=u*0.34; ctx.lineCap='round'; ctx.lineJoin='round';
    ctx.moveTo(cx-u*0.78,cy-u*0.62); ctx.lineTo(cx-u*0.16,cy); ctx.lineTo(cx-u*0.78,cy+u*0.62);
    ctx.moveTo(cx+u*0.04,cy-u*0.62); ctx.lineTo(cx+u*0.66,cy); ctx.lineTo(cx+u*0.04,cy+u*0.62);
    ctx.stroke();
    ctx.beginPath(); ctx.moveTo(cx-u*0.92,cy+u*0.92); ctx.lineTo(cx+u*0.92,cy-u*0.92);
    ctx.strokeStyle='#0b0f14'; ctx.lineWidth=u*0.56; ctx.stroke();
    ctx.strokeStyle=col; ctx.lineWidth=u*0.22; ctx.stroke();
    ctx.lineCap='butt'; ctx.lineJoin='miter';
  } else if(id==='wade'){
    ctx.lineWidth=u*0.28; ctx.lineCap='round';
    ctx.moveTo(cx-u,cy-u*0.36); ctx.quadraticCurveTo(cx-u*0.5,cy-u*0.82,cx,cy-u*0.36); ctx.quadraticCurveTo(cx+u*0.5,cy+u*0.1,cx+u,cy-u*0.36);
    ctx.moveTo(cx-u,cy+u*0.44); ctx.quadraticCurveTo(cx-u*0.5,cy-u*0.02,cx,cy+u*0.44); ctx.quadraticCurveTo(cx+u*0.5,cy+u*0.9,cx+u,cy+u*0.44);
    ctx.stroke(); ctx.lineCap='butt';
  } else if(id==='drunk'){
    ctx.moveTo(cx-u*0.5,cy+u); ctx.lineTo(cx-u*0.5,cy-u*0.1); ctx.lineTo(cx-u*0.2,cy-u*0.45); ctx.lineTo(cx-u*0.2,cy-u); ctx.lineTo(cx+u*0.2,cy-u);
    ctx.lineTo(cx+u*0.2,cy-u*0.45); ctx.lineTo(cx+u*0.5,cy-u*0.1); ctx.lineTo(cx+u*0.5,cy+u); ctx.closePath(); ctx.fill();
    ctx.fillStyle='#0b0f14'; ctx.fillRect(cx-u*0.5,cy+u*0.18,u,u*0.34); ctx.fillStyle=col;
  } else {
    ctx.moveTo(cx,cy-u); ctx.lineTo(cx+u,cy); ctx.lineTo(cx,cy+u); ctx.lineTo(cx-u,cy); ctx.closePath(); ctx.fill();
    ctx.fillStyle='#0b0f14'; ctx.beginPath(); ctx.arc(cx,cy,u*0.44,0,6.2832); ctx.fill();
    ctx.fillStyle=col; ctx.beginPath(); ctx.arc(cx,cy,u*0.18,0,6.2832); ctx.fill();
  }
}
// Called once a frame from drawHUD. Returns how many icons it drew.
function drawStatusIcons(){
  var p=G&&G.player, L=STATUSL, E, i, j, n=0, s=0, hr, S, g, r, ox, oy, yBot, rows, B, wC, nf, vf, x, y, cx, cy, tx, tw, lw, rr, u, hx, ph;
  if(!p||G.over||G.sim||G.mapOpen) return 0;
  statusLive(p);
  for(i=0;i<L.length;i++) if(L[i].on) n++;
  if(!n) return 0;
  hr=hudRes(); S=LH(26); g=LH(5); r=S/2;
  wC=(S+LH(110))*hr;                         // one column, icon and words, on screen
  ox=Math.round(9*hr);                       // the left edge the legend and the board already share
  oy=Math.round(H*0.40);                     // under the board, whose height is capped at 38 percent of the screen
  B=HUDBOX.raiders;                          // a board dragged or grown down into the band pushes the column below it
  if(B&&B.x<ox+wC&&B.x+B.w>ox&&B.y<=oy&&B.y+B.h+g*hr>oy) oy=Math.round(B.y+B.h+g*hr);
  yBot=H-LH(8)*hr;                           // and it stops above the controls and the vitals, wherever they sit
  B=HUDBOX.legend; if(B&&B.x<ox+wC&&B.x+B.w>ox&&B.y>oy) yBot=Math.min(yBot,B.y-g*hr);
  B=HUDBOX.body;   if(B&&B.x<ox+wC&&B.x+B.w>ox&&B.y>oy) yBot=Math.min(yBot,B.y-LH(20)*hr);
  rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((S+g)*hr)));   // more than fit start a second column to the right
  nf=FS(TYPE.label); vf=FS(TYPE.micro);
  lw=Math.max(2,S*0.085); rr=r*0.8; u=S*0.24; hx=r*1.04; ph=S*0.86;
  ctx.save();
  try{
    ctx.translate(ox,oy); ctx.scale(hr,hr);
    ctx.textAlign='left'; ctx.lineCap='butt'; ctx.lineJoin='miter';
    for(i=0;i<L.length;i++){
      E=L[i]; if(!E.on) continue;
      x=Math.floor(s/rows)*(S+LH(110)); y=(s%rows)*(S+g); s++;
      cx=x+r; cy=y+r; tx=x+S+LH(6);
      ctx.globalAlpha=(E.id==='stim'&&p.stimT<=3)?(0.6+0.4*Math.cos((G.t||0)*12)):1;   // the last three seconds of a stim blink
      // the words' widths, measured again only when the words or the text size change
      if(E.nf!==nf){ ctx.font=nf; E.nf=nf; E.nw=ctx.measureText(E.nm).width; }
      if(E.ws!==E.v||E.wf!==vf){ ctx.font=vf; E.ws=E.v; E.wf=vf; E.vw=ctx.measureText(E.v||'').width; }
      tw=Math.max(E.nw||0,E.vw||0);
      ctx.fillStyle='rgba(6,9,13,.62)'; statusPill(cx-ph/2,cy,tx+tw+LH(10),ph);
      // the disc, or a hexagon with a red edge for a status working against you
      ctx.beginPath();
      if(E.bad){ ctx.moveTo(cx+STATUS_HEX[0]*hx,cy+STATUS_HEX[1]*hx); for(j=2;j<12;j+=2) ctx.lineTo(cx+STATUS_HEX[j]*hx,cy+STATUS_HEX[j+1]*hx); ctx.closePath(); }
      else ctx.arc(cx,cy,r,0,6.2832);
      ctx.fillStyle='rgba(8,12,18,.92)'; ctx.fill();
      ctx.lineWidth=Math.max(1.2,S*0.045); ctx.strokeStyle=E.bad?'rgba(255,90,74,.85)':'rgba(127,146,216,.55)'; ctx.stroke();
      // the ring: a faint track, and the share still to run lit in the status colour, clockwise from twelve
      ctx.lineWidth=lw;
      ctx.strokeStyle='rgba(255,255,255,.13)'; ctx.beginPath(); ctx.arc(cx,cy,rr,0,6.2832); ctx.stroke();
      if(E.f>0.002){ ctx.strokeStyle=E.col; ctx.beginPath(); ctx.arc(cx,cy,rr,-1.5708,-1.5708+6.2832*E.f); ctx.stroke(); }
      ctx.fillStyle=E.col; ctx.strokeStyle=E.col;
      statusGlyph(E.id,cx,cy,u,E.col);
      // a drink's dose count, on a badge at the bottom right of its icon
      if(E.n>1){
        ctx.fillStyle=E.col; ctx.beginPath(); ctx.arc(x+S*0.86,cy+r*0.72,S*0.23,0,6.2832); ctx.fill();
        if(E.nk!==E.n){ E.nk=E.n; E.ns=String(E.n); }
        ctx.font=vf; ctx.textAlign='center'; ctx.fillStyle='#0b0f14'; ctx.fillText(E.ns,x+S*0.86,cy+r*0.72+LH(4)); ctx.textAlign='left';
      }
      ctx.font=nf; ctx.fillStyle=E.col;     ctx.fillText(E.nm,tx,cy-LH(2));
      ctx.font=vf; ctx.fillStyle='#cdd6dd'; ctx.fillText(E.v||'',tx,cy+LH(9));
    }
  } finally { ctx.restore(); }
  return s;
}
function drawBossBar(){
'@

SubRx @'
  if(G.bagOpen) drawBag();
'@ @'
  try{ drawStatusIcons(); }catch(_sti){}   // v19.00, his note (2026-10-07): the status icons down the left, under the backpack, a trade and the map
  if(G.bagOpen) drawBag();
'@

SubRx @'
  if(HERO&&st.healLeft>0&&st.healTot>0){
'@ @'
  // v19.00, his note (2026-10-07): "like maybe the green circle heal happens open on the left instead of above the player's head".
  // The heal over time is the HEALING icon in the status column on the left of the HUD now (drawStatusIcons), from the same
  // numbers, so this ring is off. CFG.healRingHead 1 (in no default, so never set in play) brings it back exactly as it was, for
  // a side by side look and for the v15.40 check, which reads this ring.
  if(HERO&&CFG.healRingHead===1&&st.healLeft>0&&st.healTot>0){
'@

SubRx @'
    var _bzTags=[['drunk','LIQUOR'],['lsd','ACID']];
'@ @'
    var _bzTags=[['drunk','LIQUOR'],['lsd','BLOTTER']];   // v19.00: the drink is Blotter (BOOZE), the word its status icon uses
'@

SubRx @'
var VER='18.99';
'@ @'
var VER='19.00';
'@

$pat = "(?m)^  now:'v18\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.00: Status effects show as icons with names and timers down the left of the screen. Check 19.00 fails on v18.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
