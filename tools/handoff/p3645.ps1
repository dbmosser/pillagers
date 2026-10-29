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

# COMBAT STATUS ROWS SHARE ONE WIDTH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawStatusIcons(){
  var p=G&&G.player, L=STATUSL, E, i, j, n=0, s=0, hr, S, g, r, ox, oy, yBot, rows, B, wC, nf, vf, x, y, cx, cy, tx, tw, lw, rr, u, hx, ph;
  if(!p||G.over||G.sim||G.mapOpen) return 0;
  statusLive(p);
  for(i=0;i<L.length;i++) if(L[i].on) n++;
  if(!n) return 0;
  // v28.xx (cw-cx-statuswrap): crowding changes the rows and columns, never the shared 20px title and 16px detail floors.
  nf=FS(TYPE.head).replace(/([\d.]+)px/,function(m,n){ return Math.max(parseFloat(n),20*uiScale())+'px'; });
  vf=FS(TYPE.label).replace(/([\d.]+)px/,function(m,n){ return Math.max(parseFloat(n),16*uiScale())+'px'; });
  hr=hudRes(); S=LH(26); g=LH(8); r=S/2;
  ph=Math.max(S*1.12,parseFloat((/([\d.]+)px/).exec(nf)[1])+parseFloat((/([\d.]+)px/).exec(vf)[1])+LH(8));
  tw=0;
  ctx.save();
  try{
    for(i=0;i<L.length;i++){
      E=L[i]; if(!E.on) continue;
      if(E.nf!==nf){ ctx.font=nf; E.nf=nf; E.nw=ctx.measureText(E.nm).width; }
      if(E.ws!==E.v||E.wf!==vf){ ctx.font=vf; E.ws=E.v; E.wf=vf; E.vw=ctx.measureText(E.v||'').width; }
      tw=Math.max(tw,E.nw||0,E.vw||0);
    }
  } finally { ctx.restore(); }
  wC=Math.ceil(ph+LH(6)+tw+LH(10)+g)*hr;   // v28.xx (cw-cx-statuswrap): each column clears the longest live title or detail and an eight-pixel gap.
  ox=Math.round(9*hr);                       // the left edge the legend and the board already share
  oy=Math.round(H*0.40);                     // under the board, whose height is capped at 38 percent of the screen
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);   // v19.07: and below the teammate rows
  yBot=H-LH(8)*hr;                           // and it stops above the controls and the vitals, wherever they sit
  // v19.19, from the review (2026-10-07): the board was avoided only when its top was above the column, and the controls list and the
  // vitals only when their top was below it, so a board dragged down, or a list grown or dragged up, had the icons drawn over it. Every
  // panel at the left is now treated the same, top to bottom: one that starts by the column's first row pushes the column below it, one
  // that starts lower ends the column above it. When that leaves no room for a row, the column moves to the right of those panels.
  var _bx=[legOverBoard()?null:HUDBOX.raiders,HUDBOX.legend,(G&&G.legendOn===2)?LEGSIDE:null,HUDBOX.body,FEEDBOX.on?FEEDBOX:null,(typeof MEDALBOX==='object'&&MEDALBOX&&MEDALBOX.on)?MEDALBOX:null].filter(function(b){ return b&&b.x<ox+wC&&b.x+b.w>ox; }).sort(function(a,b){ return a.y-b.y; }), _bi, _br;
  for(_bi=0;_bi<_bx.length;_bi++){ B=_bx[_bi];
    if(B.y+B.h+g*hr<=oy||B.y>=yBot) continue;
    if(B===FEEDBOX||B===MEDALBOX){ yBot=Math.min(yBot,B.y-g*hr); continue; }   // cw-hudfix, his note 10-27: the feed and the medal strip only cap the column
    if(B.y<=oy+S*hr/2) oy=Math.round(B.y+B.h+g*hr);
    else yBot=Math.min(yBot,B.y-((B===HUDBOX.body)?LH(20):g)*hr);
  }
  rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((ph+g)*hr)));
  // v28.xx (cw-cx-statuswrap): wrap at full type size; if two columns cannot fit vertically, stack beside the left HUD panels.
  if(n>rows*2||yBot-oy<ph*hr){
    _br=0; for(_bi=0;_bi<_bx.length;_bi++) _br=Math.max(_br,_bx[_bi].x+_bx[_bi].w);
    ox=Math.round(Math.max(ox,_br+g*hr)); oy=Math.round(H*0.40); yBot=H-LH(8)*hr;
    if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.x<ox+wC&&NETTEAMBOX.x+NETTEAMBOX.w>ox&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);
    rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((ph+g)*hr)));
  }
  lw=Math.max(2,S*0.085); rr=r*0.8; u=S*0.24; hx=r*1.04;
  ctx.save();
  try{
    ctx.translate(ox,oy); ctx.scale(hr,hr);
    ctx.textAlign='left'; ctx.lineCap='butt'; ctx.lineJoin='miter';
    for(i=0;i<L.length;i++){
      E=L[i]; if(!E.on) continue;
      // v28.xx (cw-cx-statuswrap): every live status is drawn, with measured column spacing and a panel-height row step.
      x=Math.floor(s/rows)*wC/hr; y=(s%rows)*(ph+g); s++;
      cx=x+ph/2; cy=y+ph/2; tx=x+ph+LH(6);
      ctx.globalAlpha=(E.id==='stim'&&p.stimT<=3)?(0.6+0.4*Math.cos((G.t||0)*12)):1;   // the last three seconds of a stim blink
      // the words' widths, measured again only when the words or the text size change
      if(E.nf!==nf){ ctx.font=nf; E.nf=nf; E.nw=ctx.measureText(E.nm).width; }
      if(E.ws!==E.v||E.wf!==vf){ ctx.font=vf; E.ws=E.v; E.wf=vf; E.vw=ctx.measureText(E.v||'').width; }
      tw=Math.max(E.nw||0,E.vw||0);
      ctx.fillStyle='rgba(22,25,27,.90)'; statusPill(cx-ph/2,cy,tx+tw+LH(10),ph);   // v28.xx (cw-cx-statusread): style-guide panel fill for every status.
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
        ctx.fillStyle=E.col; ctx.beginPath(); ctx.arc(cx+r*0.72,cy+r*0.72,S*0.23,0,6.2832); ctx.fill();
        if(E.nk!==E.n){ E.nk=E.n; E.ns=String(E.n); }
        ctx.font=vf; ctx.textAlign='center'; ctx.fillStyle='#0b0f14'; ctx.fillText(E.ns,cx+r*0.72,cy+r*0.72+LH(4)); ctx.textAlign='left';
      }
      // v28.xx (cw-cx-statusread): neutral readable type; the existing ring and glyph carry each status colour.
      ctx.font=nf; ctx.fillStyle='#efe9dc'; ctx.fillText(E.nm,tx,cy-LH(2));
      ctx.font=vf; ctx.fillStyle='#aaa498'; ctx.fillText(E.v||'',tx,cy+LH(11));   // v28.xx (cw-cx-statusdetail): style-guide tx-2 keeps the bonus below the status name in the hierarchy.
    }
  } finally { ctx.restore(); }
  return s;
}
'@ @'
function drawStatusIcons(){
  var p=G&&G.player, L=STATUSL, E, i, j, n=0, s=0, hr, S, g, r, ox, oy, yBot, rows, B, wC, nf, vf, x, y, cx, cy, tx, tw, lw, rr, u, hx, ph;
  if(!p||G.over||G.sim||G.mapOpen) return 0;
  statusLive(p);
  for(i=0;i<L.length;i++) if(L[i].on) n++;
  if(!n) return 0;
  // v28.xx (cw-cx-statuswrap): crowding changes the rows and columns, never the shared 20px title and 16px detail floors.
  nf=FS(TYPE.head).replace(/([\d.]+)px/,function(m,n){ return Math.max(parseFloat(n),20*uiScale())+'px'; });
  vf=FS(TYPE.label).replace(/([\d.]+)px/,function(m,n){ return Math.max(parseFloat(n),16*uiScale())+'px'; });
  hr=hudRes(); S=LH(26); g=Math.round(8*uiScale()); r=S/2;
  ph=Math.max(48*uiScale(),parseFloat((/([\d.]+)px/).exec(nf)[1])+parseFloat((/([\d.]+)px/).exec(vf)[1])+LH(8));
  tw=0;
  ctx.save();
  try{
    for(i=0;i<L.length;i++){
      E=L[i]; if(!E.on) continue;
      if(E.nf!==nf){ ctx.font=nf; E.nf=nf; E.nw=ctx.measureText(E.nm).width; }
      if(E.ws!==E.v||E.wf!==vf){ ctx.font=vf; E.ws=E.v; E.wf=vf; E.vw=ctx.measureText(E.v||'').width; }
      tw=Math.max(tw,E.nw||0,E.vw||0);
    }
  } finally { ctx.restore(); }
  wC=(Math.ceil(Math.max(220*uiScale(),ph+LH(6)+tw+LH(10)))+g)*hr;   // v28.xx (cw-cx-statuspanels): one measured panel width, at least 220px, with an eight-pixel column gap.
  ox=Math.round(9*hr);                       // the left edge the legend and the board already share
  oy=Math.round(H*0.40);                     // under the board, whose height is capped at 38 percent of the screen
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);   // v19.07: and below the teammate rows
  yBot=H-LH(8)*hr;                           // and it stops above the controls and the vitals, wherever they sit
  // v19.19, from the review (2026-10-07): the board was avoided only when its top was above the column, and the controls list and the
  // vitals only when their top was below it, so a board dragged down, or a list grown or dragged up, had the icons drawn over it. Every
  // panel at the left is now treated the same, top to bottom: one that starts by the column's first row pushes the column below it, one
  // that starts lower ends the column above it. When that leaves no room for a row, the column moves to the right of those panels.
  var _bx=[legOverBoard()?null:HUDBOX.raiders,HUDBOX.legend,(G&&G.legendOn===2)?LEGSIDE:null,HUDBOX.body,FEEDBOX.on?FEEDBOX:null,(typeof MEDALBOX==='object'&&MEDALBOX&&MEDALBOX.on)?MEDALBOX:null].filter(function(b){ return b&&b.x<ox+wC&&b.x+b.w>ox; }).sort(function(a,b){ return a.y-b.y; }), _bi, _br;
  for(_bi=0;_bi<_bx.length;_bi++){ B=_bx[_bi];
    if(B.y+B.h+g*hr<=oy||B.y>=yBot) continue;
    if(B===FEEDBOX||B===MEDALBOX){ yBot=Math.min(yBot,B.y-g*hr); continue; }   // cw-hudfix, his note 10-27: the feed and the medal strip only cap the column
    if(B.y<=oy+S*hr/2) oy=Math.round(B.y+B.h+g*hr);
    else yBot=Math.min(yBot,B.y-((B===HUDBOX.body)?LH(20):g)*hr);
  }
  rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((ph+g)*hr)));
  // v28.xx (cw-cx-statuswrap): wrap at full type size; if two columns cannot fit vertically, stack beside the left HUD panels.
  if(n>rows*2||yBot-oy<ph*hr){
    _br=0; for(_bi=0;_bi<_bx.length;_bi++) _br=Math.max(_br,_bx[_bi].x+_bx[_bi].w);
    ox=Math.round(Math.max(ox,_br+g*hr)); oy=Math.round(H*0.40); yBot=H-LH(8)*hr;
    if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.x<ox+wC&&NETTEAMBOX.x+NETTEAMBOX.w>ox&&NETTEAMBOX.y+NETTEAMBOX.h+g*hr>oy) oy=Math.round(NETTEAMBOX.y+NETTEAMBOX.h+g*hr);
    rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((ph+g)*hr)));
  }
  lw=Math.max(2,S*0.085); rr=r*0.8; u=S*0.24; hx=r*1.04;
  ctx.save();
  try{
    ctx.translate(ox,oy); ctx.scale(hr,hr);
    ctx.textAlign='left'; ctx.lineCap='butt'; ctx.lineJoin='miter';
    for(i=0;i<L.length;i++){
      E=L[i]; if(!E.on) continue;
      // v28.xx (cw-cx-statuswrap): every live status is drawn, with measured column spacing and a panel-height row step.
      x=Math.floor(s/rows)*wC/hr; y=(s%rows)*(ph+g); s++;
      cx=x+ph/2; cy=y+ph/2; tx=x+ph+LH(6);
      ctx.globalAlpha=(E.id==='stim'&&p.stimT<=3)?(0.6+0.4*Math.cos((G.t||0)*12)):1;   // the last three seconds of a stim blink
      // the words' widths, measured again only when the words or the text size change
      if(E.nf!==nf){ ctx.font=nf; E.nf=nf; E.nw=ctx.measureText(E.nm).width; }
      if(E.ws!==E.v||E.wf!==vf){ ctx.font=vf; E.ws=E.v; E.wf=vf; E.vw=ctx.measureText(E.v||'').width; }
      tw=Math.max(E.nw||0,E.vw||0);
      ctx.fillStyle='rgba(22,25,27,.90)'; statusPill(cx-ph/2,cy,x+wC/hr-g,ph);   // v28.xx (cw-cx-statuspanels): all status rows share the measured right edge and enough padding for 20px/16px type.
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
        ctx.fillStyle=E.col; ctx.beginPath(); ctx.arc(cx+r*0.72,cy+r*0.72,S*0.23,0,6.2832); ctx.fill();
        if(E.nk!==E.n){ E.nk=E.n; E.ns=String(E.n); }
        ctx.font=vf; ctx.textAlign='center'; ctx.fillStyle='#0b0f14'; ctx.fillText(E.ns,cx+r*0.72,cy+r*0.72+LH(4)); ctx.textAlign='left';
      }
      // v28.xx (cw-cx-statusread): neutral readable type; the existing ring and glyph carry each status colour.
      ctx.font=nf; ctx.fillStyle='#efe9dc'; ctx.fillText(E.nm,tx,cy-LH(2));
      ctx.font=vf; ctx.fillStyle='#aaa498'; ctx.fillText(E.v||'',tx,cy+LH(11));   // v28.xx (cw-cx-statusdetail): style-guide tx-2 keeps the bonus below the status name in the hierarchy.
    }
  } finally { ctx.restore(); }
  return s;
}
'@

SubRx @'
var VER='36.44';
'@ @'
var VER='36.45';
'@

$pat = "(?m)^  now:'v36\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.45: The status stack has one aligned right edge, enough padding for both text lines and consistent eight-pixel gaps. Font floors remain 20px and 16px. HUD rendering only. LOCAL: no linked review. Check 36.45 fails on v36.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
