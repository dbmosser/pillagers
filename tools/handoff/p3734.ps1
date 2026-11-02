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

# season zero m2: the hall of the fallen, a Mainframe tab and a wall in the Undercroft (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body:has(#opmodal.on #opane_rew[style*="display: flex"]) #hubtoast,
'@ @'
body:has(#opmodal.on #opane_hall[style*="display: flex"]) #hubtoast,body:has(#opmodal.on #opane_rew[style*="display: flex"]) #hubtoast,
'@

SubRx @'
  <div style="display:flex;gap:8px;margin-top:4px;flex:none">
    <button id="closeop"
'@ @'
  <!-- v37.xx (cw-m2hall), his rulings of 11-01 (season zero m2): the hall of the fallen, a tab at the Mainframe with full stats (renderHall). Rows and cards are .crow and .scard, so the pad walks them and the pane scrolls with it; the wheel scrolls the pane. -->
  <div class="tpane" id="opane_hall" data-lint-scroll style="display:none;flex-direction:column;flex:1;min-height:0;overflow-y:auto">
    <style>
    #opane_hall{ text-transform:lowercase; }
    #opane_hall > *{ flex:none; }
    #opane_hall #hallrecs{ display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:16px; margin:0 0 16px; }
    #root #opane_hall .hallrec{ box-sizing:border-box; padding:16px; border:1px solid var(--ui-line-hi); background:var(--ui-panel); border-radius:4px; }
    #opane_hall .hk{ font:600 20px/1.25 var(--f-cond); letter-spacing:.04em; color:var(--tx-2); }
    #opane_hall .hv{ font:700 36px/1.15 var(--f-cond); color:var(--tx-1); margin-top:8px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    #opane_hall .hs{ font:400 20px/1.4 var(--f-body); color:var(--tx-2); }
    #opane_hall .hallgrid{ display:grid; grid-template-columns:minmax(0,1.4fr) 64px minmax(0,2.2fr) 72px 96px 128px 72px; gap:16px; align-items:start; padding:12px 16px; }
    #opane_hall .hallhead{ font:600 20px/1.25 var(--f-cond); letter-spacing:.04em; color:var(--tx-2); border-bottom:1px solid var(--ui-line-hi); }
    #root #opane_hall .hallrow{ border-bottom:1px solid var(--ui-line); font-size:20px; }
    #opane_hall .hname{ font:700 28px/1.2 var(--f-cond); color:var(--tx-1); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    #opane_hall .hep,#opane_hall .hby{ font:400 20px/1.4 var(--f-body); color:var(--tx-2); }
    #opane_hall .hend{ font:400 20px/1.4 var(--f-body); color:var(--tx-1); }
    #opane_hall .hend.hlive{ font-weight:600; color:var(--ok); }
    #opane_hall .hn{ font:600 28px/1.2 var(--f-cond); color:var(--tx-1); }
    #opane_hall .hr{ text-align:right; }
    #opane_hall #hallempty{ padding:32px 16px; font:600 28px/1.2 var(--f-cond); color:var(--tx-2); text-align:center; }
    </style>
    <div id="hallrecs"></div>
    <div id="halllist"></div>
  </div>
  <div style="display:flex;gap:8px;margin-top:4px;flex:none">
    <button id="closeop"
'@

SubRx @'
// The one-time hub line for an old save's payout. Never in the demo, which plays on a copy.

'@ @'
// v37.xx (cw-m2hall), HIS RULINGS OF 11-01 (season zero m2): "a pillager earns an epithet from how it plays (the quiet, the greedy, the lucky)". Worked out at
// draw time and never stored, so a rule here can be tuned. The first rule that fits wins:
//   the untried   living, one raid or none
//   the brief     ended on its first raid, or before it
//   the deserter  quit a raid
//   the old       retired
//   the butcher   8 or more kills a raid, 16 or more in all
//   the greedy    died carrying $5,000 or more
//   the lucky     a best haul of $8,000 or more inside 5 raids
//   the ghost     5 or more raids, one kill for every two raids at most
//   the quiet     3 or more raids, under 2 kills a raid
//   the stubborn  10 or more raids
//   the unsung    anyone else
function pilEpithet(r){
  var e=(r&&r.end&&typeof r.end==='object')?r.end:null, n, k, b;
  if(!r||typeof r!=='object') return '';
  n=Math.max(0,+r.raids||0); k=Math.max(0,+r.kills||0); b=Math.max(0,+r.best||0);
  if(n<=1) return e?'the brief':'the untried';
  if(e&&e.how==='quit') return 'the deserter';
  if(e&&e.how==='retire') return 'the old';
  if(k>=16&&k/n>=8) return 'the butcher';
  if(e&&e.how==='dead'&&(+e.lost||0)>=5000) return 'the greedy';
  if(b>=8000&&n<=5) return 'the lucky';
  if(n>=5&&k/n<=0.5) return 'the ghost';
  if(n>=3&&k/n<2) return 'the quiet';
  if(n>=10) return 'the stubborn';
  return 'the unsung';
}
// THE LIVING ONE, a copy for drawing marked live. Generation one from an old save is the character he has always played, so it shows that character's old
// totals (his job 00p-m2d item 4); nothing is written to the save.
function hallLiving(p){
  var q, a, K;
  if(!p||!pilNow()) return null;
  q=JSON.parse(JSON.stringify(p.pil)); q.live=1;
  if((q.gen|0)===1&&(!Array.isArray(p.hall)||!p.hall.length)){
    a=(p.achN&&typeof p.achN==='object')?p.achN:{}; K=(+a.raider||0)+(+a.mach||0);
    q.raids=Math.max(+q.raids||0,+p.runs||0); q.ext=Math.max(+q.ext||0,+p.ext||0); q.best=Math.max(+q.best||0,+p.best||0); q.kills=Math.max(+q.kills||0,K);
  }
  return q;
}
// Everyone, the living one first and then newest first (P.hall is oldest first). An entry that is not a record is left out, a record missing fields is kept.
function hallRows(p){
  var out=[], H=(p&&Array.isArray(p.hall))?p.hall:[], q=hallLiving(p), i;
  if(q) out.push(q);
  for(i=H.length-1;i>=0;i--) if(H[i]&&typeof H[i]==='object') out.push(H[i]);
  return out;
}
// Who holds each record: the highest number, and the first to reach it keeps it on a tie.
function hallBest(L,f){
  var w=null, v=0, i, n;
  for(i=L.length-1;i>=0;i--){ n=Math.max(0,+L[i][f]||0); if(n>v){ v=n; w=L[i]; } }
  return {r:w,v:v};
}
function hallNum(v,pre){ return (typeof v==='number'&&isFinite(v))?((pre||'')+Math.round(v).toLocaleString()):'--'; }
function hallEndLines(r){
  var e=(r&&r.end&&typeof r.end==='object')?r.end:null, w=[], i, m='';
  if(r&&r.live) return {a:'living',b:''};
  if(!e) return {a:'gone',b:''};
  if(e.zone) w.push(String(e.zone).toLowerCase());
  if(e.map){ for(i=0;i<FIXED_MAPS.length;i++) if(FIXED_MAPS[i].id===e.map) m=String(FIXED_MAPS[i].name||''); w.push(String(m||e.map).toLowerCase()); }
  return {a:(e.how==='dead'?'died':(e.how==='quit'?'quit':(e.how==='retire'?'retired':'gone')))+(w.length?' at '+w.join(', '):''), b:e.by?('killed by '+String(e.by).toLowerCase()):''};
}
// THE TAB: the records, then every pillager. Reads the save, writes nothing.
function renderHall(){
  var rb=document.getElementById('hallrecs'), lb=document.getElementById('halllist'), L, i, r, h, b, s, any;
  if(!rb||!lb) return;
  L=hallRows(P);
  var C=[['raids','longest life',function(v){ return v.toLocaleString()+' raid'+(v===1?'':'s'); }],['best','richest haul',function(v){ return '$'+v.toLocaleString(); }],
         ['kills','most kills',function(v){ return v.toLocaleString()+' kill'+(v===1?'':'s'); }],['lvl','highest level',function(v){ return 'level '+v.toLocaleString(); }]];
  any=L.some(function(q){ return !q.live||(+q.raids||0)>0||(+q.best||0)>0||(+q.kills||0)>0; });
  h='';
  for(i=0;i<C.length;i++){
    b=hallBest(L,C[i][0]);
    h+='<div class="scard hallrec" data-rec="'+C[i][0]+'"><div class="hk">'+C[i][1]+'</div><div class="hv">'+(b.r?escHtml(pilName(b.r)):'--')+'</div><div class="hs">'+(b.r?C[i][2](b.v):'&nbsp;')+'</div></div>';
  }
  rb.innerHTML=any?h:''; rb.style.display=any?'':'none';
  h='<div class="hallgrid hallhead"><div>pillager</div><div class="hr">gen</div><div>how it ended</div><div class="hr">level</div><div class="hr">raids lived</div><div class="hr">best haul</div><div class="hr">kills</div></div>';
  for(i=0;i<L.length;i++){
    r=L[i]; s=hallEndLines(r);
    h+='<div class="crow hallrow hallgrid"><div><div class="hname">'+escHtml(pilName(r))+'</div><div class="hep">'+escHtml(pilEpithet(r))+'</div></div>'+
       '<div class="hn hr">'+hallNum(r.gen)+'</div>'+
       '<div><div class="hend'+(r.live?' hlive':'')+'">'+escHtml(s.a)+'</div>'+(s.b?'<div class="hby">'+escHtml(s.b)+'</div>':'')+'</div>'+
       '<div class="hn hr">'+hallNum(r.lvl)+'</div><div class="hn hr">'+hallNum(r.raids)+'</div><div class="hn hr">'+hallNum(r.best,'$')+'</div><div class="hn hr">'+hallNum(r.kills)+'</div></div>';
  }
  if(!(Array.isArray(P.hall)&&P.hall.length)) h+='<div id="hallempty">the hall is empty</div>';
  lb.innerHTML=h;
}
// The one-time hub line for an old save's payout. Never in the demo, which plays on a copy.

'@

SubRx @'
var T=[['con','CONTRACTS'],['mf','RACKS'],['rec','YOUR STATS']];
'@ @'
var T=[['con','CONTRACTS'],['mf','RACKS'],['rec','YOUR STATS'],['hall','THE HALL']];
'@

SubRx @'
  try{ renderRank(); }catch(e){}   // v37.xx (cw-m1ranks)

'@ @'
  try{ renderRank(); }catch(e){}   // v37.xx (cw-m1ranks)
  try{ renderHall(); }catch(e){}   // v37.xx (cw-m2hall)

'@

SubRx @'
           KeyF:['racks',   function(){ openOps('mf');  }],

'@ @'
           KeyR:['the hall',function(){ openOps('hall'); }],   // v37.xx (cw-m2hall): R is free since the rewards key went
           KeyF:['racks',   function(){ openOps('mf');  }],

'@

SubRx @'
function hubWall(o,x,y,w,h,d){ o.push({x:x,y:y,w:w,h:h,d:d===undefined?0:d}); }

'@ @'
function hubWall(o,x,y,w,h,d){ o.push({x:x,y:y,w:w,h:h,d:d===undefined?0:d}); }
// v37.xx (cw-m2hall), HIS RULINGS OF 11-01 (season zero m2): "a wall in the Undercroft with a portrait of each pillager in what it last wore". A real wall in the
// back wall's bay between the left pier and the lift housing: nothing stood there and nobody walks through it, and every station stays in reach. The newest three
// ended pillagers hang on it, newest on the left, each drawn by today's body draw in its end.look (today's look when a record has none), its name under it.
// The board is one cached canvas, baked once per hall change, so the floor draws one image a frame however many pillagers there have been.
var HALLW={x:210,y:20,w:80,h:34,n:3,bx:212,by:4,bw:76,bh:48,ss:6,c:null,k:'',bakes:0};
function hallWallKey(){
  var H=(typeof P!=='undefined'&&P&&Array.isArray(P.hall))?P.hall:[], e=H.length?H[H.length-1]:null;
  return H.length+'|'+((e&&e.end&&e.end.at)||0)+'|'+((e&&e.name)||'')+'|'+(pixOn()?1:0)+'|'+((document.fonts&&document.fonts.status==='loaded')?1:0);   // the font: a board baked before the fonts arrive is baked again once
}
function hallPortrait(x2,r,cx,fy,k){
  var L=(r.end&&r.end.look&&typeof r.end.look==='object')?r.end.look:null, M={hat:'cosHat',cut:'cosCut',skin:'cosSkin',scheme:'cosScheme',fit:'cosFit',outfit:'cosOutfit'}, keep={}, s, w0=wc, own0=cosOwned, g0=opGround;
  for(s in M){ keep[M[s]]=P[M[s]]; if(L&&L[s]!==undefined&&L[s]!==null) P[M[s]]=L[s]; }
  x2.save();
  try{
    wc=x2; if(L) cosOwned=function(){ return true; };   // it wore it, whatever this account owns today
    opGround=function(){};
    x2.translate(cx,fy); x2.scale(k,k); pixFrame();
    drawOpBody(0,0,1.5708,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});
  }catch(_hp){}
  finally{ wc=w0; cosOwned=own0; opGround=g0; x2.restore(); for(s in keep){ if(keep[s]===undefined) delete P[s]; else P[s]=keep[s]; } }
}
function hallWallBake(){
  var W0=HALLW, H=(P&&Array.isArray(P.hall))?P.hall:[], c=W0.c, x, i, r, cw, fx, fy=2, fw, fh=34, S=W0.ss;
  if(!c){ c=W0.c=document.createElement('canvas'); c.id='hallcv'; }
  c.width=W0.bw*S; c.height=W0.bh*S; x=c.getContext('2d');
  x.setTransform(S,0,0,S,0,0);
  x.fillStyle=UIC.ui_panel; x.fillRect(0,0,W0.bw,W0.bh);
  x.lineWidth=0.5; x.strokeStyle=UIC.ui_line_hi; x.strokeRect(0.25,0.25,W0.bw-0.5,W0.bh-0.5);
  cw=(W0.bw-4)/W0.n; fw=cw-2;
  x.textAlign='center'; x.textBaseline='alphabetic';
  for(i=0;i<W0.n;i++){
    fx=2+i*cw+1;
    x.fillStyle='#0d0f11'; x.fillRect(fx,fy,fw,fh);
    x.strokeStyle=UIC.ui_line_hi; x.strokeRect(fx,fy,fw,fh);
    r=H[H.length-1-i];
    if(!r||typeof r!=='object') continue;
    x.save(); x.beginPath(); x.rect(fx,fy,fw,fh); x.clip();
    hallPortrait(x,r,fx+fw/2,fy+fh+9,0.9);
    x.restore();
    x.fillStyle=UIC.tx_1; x.font=uiFont('label',7.4/16);
    x.fillText(pilName(r),fx+fw/2,fy+fh+8.5,cw-1);
  }
  W0.bakes++;
}
function hallWallDraw(){
  var k=hallWallKey(), sm=wc.imageSmoothingEnabled;
  if(HALLW.k!==k||!HALLW.c){ HALLW.k=k; try{ hallWallBake(); }catch(_hb){} }
  if(!HALLW.c) return;
  wc.imageSmoothingEnabled=true;
  wc.drawImage(HALLW.c,HALLW.bx,HALLW.by,HALLW.bw,HALLW.bh);
  wc.imageSmoothingEnabled=sm;
}

'@

SubRx @'
  hubWall(w,300,385,100,T,1);

'@ @'
  hubWall(w,300,385,100,T,1);
  hubWall(w,HALLW.x,HALLW.y,HALLW.w,HALLW.h,0);   // v37.xx (cw-m2hall): the hall wall

'@

SubRx @'
stations=stations.filter(function(_st){ return !!_st; });   // v8.40: drop the gated-out entries

'@ @'
stations=stations.filter(function(_st){ return !!_st; });   // v8.40: drop the gated-out entries
stations.push({id:'hall',x:HALLW.x+HALLW.w/2,y:66,r:36,label:'THE HALL',sub:'',c:'#d8c49a',wallSt:1,labelBelow:1,acts:{KeyE:['the hall',function(){ openOps('hall'); }]}});   // v37.xx (cw-m2hall): walk up to the wall and press E; last in the list, so every other station keeps its place

'@

SubRx @'
for(i=0;i<HB.stations.length;i++) if(HB.stations[i].id!=='lift') pool.push(HB.stations[i]);
'@ @'
for(i=0;i<HB.stations.length;i++) if(HB.stations[i].id!=='lift'&&!HB.stations[i].wallSt) pool.push(HB.stations[i]);   // v37.xx (cw-m2hall): nobody runs errands to the hall wall
'@

SubRx @'
var st=stations[i], nx=nextIdent();
'@ @'
var st=stations[i]; if(st.wallSt) continue; var nx=nextIdent();   // v37.xx (cw-m2hall): the hall wall has nobody beside it, and the others keep their faces
'@

SubRx @'
  for(i=0;i<HB.stations.length;i++) DR.push({k:HB.stations[i].y,s:HB.stations[i]});

'@ @'
  for(i=0;i<HB.stations.length;i++) if(!HB.stations[i].wallSt) DR.push({k:HB.stations[i].y,s:HB.stations[i]});
  DR.push({k:HALLW.y+HALLW.h+0.01,hw:1});   // v37.xx (cw-m2hall): the hall board, just in front of its wall

'@

SubRx @'
    } else if(it.s){
      var s2=it.s,pulse
'@ @'
    } else if(it.hw){
      hallWallDraw();   // v37.xx (cw-m2hall)
    } else if(it.s){
      var s2=it.s,pulse
'@

SubRx @'
wc.canvas.id==='avcv')&&pixBodyTry
'@ @'
wc.canvas.id==='avcv'||wc.canvas.id==='hallcv')&&pixBodyTry
'@

SubRx @'
var VER='37.33';
'@ @'
var VER='37.34';
'@

$pat = "(?m)^  now:'v37\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.34: The Mainframe has a hall tab (R, or click it): records on top, then every pillager with an epithet, and the living one first. A new wall stands left of the lift: the newest three fallen, press E there for the same tab. Watch for: a body in the Undercroft stuck near the new wall, and how the portraits read at your screen size. Check 37.34 fails on v37.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
