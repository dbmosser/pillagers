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

# UNDERCROFT FLOOR TEXT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hubStationNames(S,ox,oy){
  var i;
  wc.save(); wc.scale(S,S); wc.translate(-ox,-oy);
  wc.textAlign='center';
  for(i=0;i<HB.stations.length;i++){
    var s3=HB.stations[i],on=HB.near===s3;
    if(titleOn()||tskOn()) continue;   // v17.84: no station names under the title; v28.xx (cw-title-see): nor behind the scoreboard and the how-to page, where they smeared into the fight
    wc.font=FS(TYPE.label);
    var tw=wc.measureText(s3.label).width;
    // v10.93: a firm plate. It was half transparent, so the floor showed through
    // the name as well as dimming it.
    wc.fillStyle='rgba(6,9,13,'+(on?.92:.86)+')';
    // v10.23, his note: a station can carry its name under it instead of over
    // it. The cheat box does, because its name ran into its neighbour.
    var _lyP=s3.labelBelow?(s3.y+s3.r+4):(s3.y-56), _lyT=_lyP+10;
    // v6.73: keep the name inside the room. Centred text on a station near a wall used
    // to have its first letters cut off by the edge of the floor.
    var _lw2=wc.measureText(s3.label).width, _lx2=s3.x;
    var _lm2=34;                         // the 20 unit shell wall, plus a little air
    if(_lw2<HUBW-_lm2*2){
      if(_lx2-_lw2/2<_lm2)       _lx2=_lm2+_lw2/2;
      if(_lx2+_lw2/2>HUBW-_lm2)  _lx2=HUBW-_lm2-_lw2/2;
    }
    // v18.63, SEEN ON THE UNDERCROFT SCREENSHOT (2026-10-07): THE PLATE SITS UNDER THE NAME. It was laid at the station's x before a
    // name near a wall was pushed inward (v6.73), so a bare strip of plate stuck out beside SHOP, CRAFT, AND HIRE and WIRT THE
    // GAMBLER, and it was 13 units tall, which at the label size covered only the lower half of the letters. It is now drawn where
    // the name is and as tall as its letters.
    var _lmx=wc.measureText(s3.label), _lAsc=Math.max(8,_lmx.actualBoundingBoxAscent||9), _lDsc=Math.max(2,_lmx.actualBoundingBoxDescent||3);
    wc.fillRect(_lx2-tw/2-5,_lyT-_lAsc-3,tw+10,_lAsc+_lDsc+6);
    // v10.93: opaque. This was rgba(160,172,184,.75).
    wc.fillStyle=on?s3.c:'#cfd8e2';
    wc.fillText(s3.label,_lx2,_lyT);
    if(s3.id==='bar'){
      // v7.74, his order, his asterisks.
      wc.font=FS(TYPE.micro);
      wc.fillStyle=on?'#d98aff':'#c3cdd8';
      // v13.03: THE SAME WARNING, SPELLED THE SAME WAY. The hire tab carries this
      // warning in capitals and he has rewritten that one; his wording is matched on
      // the whole string, so this sign being mixed case meant his version reached one
      // of the two features it warns about and not the other. His asterisks, v7.74.
      var _eAsc=Math.max(6,wc.measureText('***EXPERIMENTAL***').actualBoundingBoxAscent||7);   // v18.63: below the name's plate, never into it (it printed across THE LAST POUR)
      // v18.96, seen on the 4K Undercroft screenshot (2026-10-07): his warning is wider than the station name above it, and centred
      // under the name it ran across the room's right wall. It slides inward like the names do (v6.73), measured as he wrote it (TX).
      var _ewd=wc.measureText((typeof TX==='function')?TX('***EXPERIMENTAL***'):'***EXPERIMENTAL***').width, _exx=_lx2;
      // v19.43, seen on the 4K Undercroft screenshot (2026-10-08): his warning is about twice as wide as THE LAST POUR, so even slid
      // in from the wall it reached across under THE STASH and read as that station's line. It shrinks to sit under its own name
      // (never below 70 percent), his words as he wrote them.
      if(_ewd>tw*1.15){ var _ek=Math.max(0.7,tw*1.15/_ewd); wc.font=String(wc.font).replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*_ek).toFixed(1)+'px'; }); _ewd=wc.measureText((typeof TX==='function')?TX('***EXPERIMENTAL***'):'***EXPERIMENTAL***').width; }
      if(_ewd<HUBW-_lm2*2){ if(_exx+_ewd/2>HUBW-_lm2) _exx=HUBW-_lm2-_ewd/2; if(_exx-_ewd/2<_lm2) _exx=_lm2+_ewd/2; }
      wc.fillText('***EXPERIMENTAL***',_exx,Math.max(s3.y-35,_lyT+_lDsc+3+_eAsc+2));
      wc.font=FS(TYPE.label);
    }
    if(s3.season){
      var _sr=seasonReady();
      if(_sr){
        var _sl=_sr+' REWARD'+(_sr===1?'':'S')+' WAITING';
        wc.font=FS(TYPE.label);
        var _sw=wc.measureText(_sl).width;
        var _sp=.55+.45*Math.sin(HB.t*2.4);
        wc.fillStyle='rgba(6,9,13,.9)';
        wc.fillRect(s3.x-_sw/2-5,s3.y-74,_sw+10,13);
        wc.fillStyle='rgba(255,192,74,'+(0.70+0.30*_sp).toFixed(3)+')';
        wc.fillText(_sl,s3.x,s3.y-64);
        wc.font=FS(TYPE.label);
      }
    }
  }
  wc.textAlign='left';
  wc.restore();
}

'@ @'
// v28.xx (cw-cx-hubfloor): screen-sized signage, one raid hero, quiet station names. His v7.74 experimental caption keeps his asterisks and wording.
function hubStationNames(S,ox,oy){
  if(titleOn()||tskOn()) return;
  var R=Math.max(1,(typeof hudRes==='function')?hudRes():1), z=R/S, pad=8*z, margin=34;
  wc.save(); wc.scale(S,S); wc.translate(-ox,-oy); wc.textAlign='center';
  for(var i=0;i<HB.stations.length;i++){
    var s3=HB.stations[i], on=HB.near===s3, hero=s3.id==='lift';
    wc.font=uiFont(hero?'hero':'body',z);
    var tw=wc.measureText(s3.label).width, lx=clamp(s3.x,margin+tw/2+pad,HUBW-margin-tw/2-pad);
    var ly=(s3.labelBelow?s3.y+s3.r+4:s3.y-56)+10;
    var met=wc.measureText(s3.label), asc=Math.max(8*z,met.actualBoundingBoxAscent||((hero?42:15)*z)), dsc=Math.max(2*z,met.actualBoundingBoxDescent||4*z);
    wc.fillStyle=UIC.ui_panel;
    wc.fillRect(lx-tw/2-pad,ly-asc-pad,tw+2*pad,asc+dsc+2*pad);
    wc.fillStyle=hero?UIC.acc:(on?UIC.tx_1:UIC.tx_2);
    wc.fillText(s3.label,lx,ly);
    if(hero||on){
      wc.fillStyle=UIC.acc; wc.fillRect(lx-tw/2-pad,ly+dsc+pad-2*z,tw+2*pad,2*z);
    }
    if(s3.id==='bar'){
      wc.font=uiFont('label',z); wc.fillStyle=UIC.warn;
      var caption='***EXPERIMENTAL***', ew=wc.measureText(typeof TX==='function'?TX(caption):caption).width;
      var ex=clamp(lx,margin+ew/2+pad,HUBW-margin-ew/2-pad), ey=ly+dsc+pad+24*z;
      wc.fillStyle=UIC.ui_panel; wc.fillRect(ex-ew/2-pad,ey-18*z,ew+2*pad,26*z);
      wc.fillStyle=UIC.warn; wc.fillText(caption,ex,ey);
    }
    if(s3.season){
      var ready=seasonReady();
      if(ready){
        var reward=ready+' REWARD'+(ready===1?'':'S')+' WAITING';
        wc.font=uiFont('label',z); var rw=wc.measureText(reward).width;
        var rx=clamp(s3.x,margin+rw/2+pad,HUBW-margin-rw/2-pad), ry=ly-asc-pad-12*z;
        wc.fillStyle=UIC.ui_panel; wc.fillRect(rx-rw/2-pad,ry-18*z,rw+2*pad,26*z);
        wc.fillStyle=UIC.tx_1; wc.fillText(reward,rx,ry);
      }
    }
  }
  wc.restore();
}
// v28.xx (cw-cx-hubfloor): 16px words and 28px key chips; bindings and last-input pad labels stay live.
function hubFloorHints(line){
  var R=Math.max(1,(typeof hudRes==='function')?hudRes():1), rows;
  if(padOn()) rows=[[padB('L STICK'),'WALK'],[padB('LS'),'JOG'],[keyLabel('KeyE','E'),'USE STATION']];
  else rows=[[keyLabel('KeyW','W')+keyLabel('KeyA','A')+keyLabel('KeyS','S')+keyLabel('KeyD','D'),'WALK'],[keyLabel('ShiftLeft','SHIFT'),'JOG'],[keyLabel('KeyE','E'),'USE STATION']];
  if(HB&&HB.drops&&HB.drops.length) rows.push([keyLabel('KeyE','E'),'TAKE THE DROPPED ITEM']);
  if(!padOn()&&typeof line==='string'){
    rows=line.split(/\s+\u00b7\s+/).map(function(s){ var m=/^(.*?) (WALK|JOG|USE STATION|TAKE THE DROPPED ITEM)$/.exec(s); return m?[m[1],m[2]]:null; }).filter(function(s){return !!s;});
  }
  ctx.save(); ctx.font=uiFont('label',R); ctx.textAlign='left';
  var total=32*R, i;
  for(i=0;i<rows.length;i++){
    rows[i].push(Math.max(28*R,ctx.measureText(rows[i][0]).width+16*R),ctx.measureText(rows[i][1]).width);
    total+=rows[i][2]+8*R+rows[i][3]+(i?24*R:0);
  }
  var x=(W-total)/2, y=hubFootY()-36*R;
  uiPanel(ctx,x,y,total,44*R); x+=16*R;
  for(i=0;i<rows.length;i++){
    var row=rows[i];
    ctx.fillStyle=UIC.ui_raised; ctx.fillRect(x,y+8*R,row[2],28*R);
    ctx.strokeStyle=UIC.ui_line_hi; ctx.lineWidth=R; ctx.strokeRect(x+.5*R,y+8.5*R,row[2]-R,27*R);
    ctx.fillStyle=UIC.tx_1; ctx.textAlign='center'; ctx.fillText(row[0],x+row[2]/2,y+27*R);
    x+=row[2]+8*R; ctx.textAlign='left'; ctx.fillStyle=UIC.tx_2; ctx.fillText(row[1],x,y+27*R);
    x+=row[3]+24*R;
  }
  ctx.restore();
}

'@

SubRx @'
  var _hhr=Math.max(1,(typeof hudRes==='function')?hudRes():1);
  ctx.save(); ctx.scale(_hhr,_hhr);
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;
  ctx.font=FS(TYPE.head); ctx.fillStyle='#ffc04a';
  // v20.88, from the whole-game bug hunt of 2026-10-08 (V-A1): THE FLOOR HEADING STAYS OUT OF A STATION WINDOW. A window is a
  // slightly see-through sheet with its frame 14 pixels in from the screen edge, and the floor kept painting this heading in the
  // corner behind it, so on the 4K screenshots the top half of THE UNDERCROFT showed above the frame line of the shop, Fashion and
  // the other windows, cut in half by it. It is not painted while a window is open and is back the frame it closes. The money
  // line under it sits behind the frame and is left as it was.
  if(!hubWinOn()&&!document.getElementById('hub').classList.contains('on')) ctx.fillText('THE UNDERCROFT',16,28); // v28.xx (cw-cx-namefinal): the stash is a window too; keep the floor heading behind it.
  ctx.shadowColor='transparent'; ctx.shadowBlur=0;
  ctx.restore();
  try{ drawHubGiftLine(); }catch(_hg){}   // v18.05: an open trade offer, on the floor
  try{ hubDrawDropPrompt(); }catch(_hdp){}   // v18.28: E TAKE beside a dropped crate
  ctx.save(); ctx.scale(_hhr,_hhr);   // v18.95: the stats line scales with the title
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;   // v18.62: the halo, for the stats line too
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#aeb8c2';
  // vNN.xx (ui5q1b, his #50, the Wirt shot): the money line is the floor's, like its heading (v20.88): not painted while a window is open
  // v27.xx, UI CLEANUP uic9 (his 2026-10-14 note, from the 1080p shot of the Undercroft): THE FLOOR SAYS ITS MONEY ONCE. The line under the heading printed credits and XP in 9 px
  // type, the same two numbers the corner readout shows at 32 px; it keeps the stash and the runs, and the readout keeps the money.
  if(!hubWinOn()&&!document.getElementById('hub').classList.contains('on')) ctx.fillText(( // v28.xx (cw-cx-namefinal): keep the floor counters behind the stash too.

'@ @'
  // v28.xx (cw-cx-hubfloor): 32px cream title, 16px muted counts, five-percent margin. Keep the wall halo and station-window suppression.
  var _hhr=Math.max(1,(typeof hudRes==='function')?hudRes():1), hx=W*.05, hy=H*.05;
  ctx.save(); ctx.scale(_hhr,_hhr);
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;
  ctx.font=uiFont('title'); ctx.fillStyle=UIC.tx_1;
  if(!hubWinOn()&&!document.getElementById('hub').classList.contains('on')) ctx.fillText('THE UNDERCROFT',hx/_hhr,hy/_hhr+24);
  ctx.restore();
  try{ drawHubGiftLine(); }catch(_hg){}
  try{ hubDrawDropPrompt(); }catch(_hdp){}
  ctx.save(); ctx.scale(_hhr,_hhr);
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;
  ctx.font=uiFont('label'); ctx.fillStyle=UIC.tx_2;
  if(!hubWinOn()&&!document.getElementById('hub').classList.contains('on')) ctx.fillText((

'@

SubRx @'
  // v10.93, HIS NOTE: this was rgba(140,152,163,.75).
  ctx.font=FS(TYPE.micro).replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*Math.max(1,(typeof hudRes==='function')?hudRes():1)).toFixed(1)+'px'; }); ctx.fillStyle='#aab6c2';   // v18.95: the floor key footer grows with the screen
  ctx.textAlign='center';
  // v15.60, first run audit finding: ON A CONTROLLER THE UNDERCROFT BOTTOM LINE NAMES THE PAD BUTTONS. The line below is the
  // only place the floor controls are taught (v11.58), and it had no controller branch, so with a pad connected it still said
  // WASD to walk, SHIFT to jog and E to use a station, in the same frame as a station prompt that says [A] (keyLabel reads
  // PADLABEL_HUB on the floor). The pad has no E: on the floor it walks on the left stick (updateHubWorld reads PAD.mx and
  // PAD.my), jogs on the left stick click (padHold ShiftLeft on button 10) and works a station with A (padHold KeyE on button
  // 0). The raid swaps its legends for LEGEND_MINI_PAD and LEGEND_PAD; this line never had a pad version. With a pad on it now
  // draws the pad words in the raid legend's own terms, L STICK and LS, with A from the same keyLabel the prompt uses, and
  // returns. The keyboard line below is untouched word for word. No number and no seeded draw moved.
  // v20.79, from the whole-game bug hunt of 2026-10-08 (H49): the stick words go through padB, so a PlayStation pad reads L3 JOG,
  // the name the raid legend gives the same button, not LS.
  if(padOn()){ ctx.fillText(padB('L STICK WALK  \u00b7  LS JOG  \u00b7  ')+keyLabel('KeyE','E')+' USE STATION'+((HB&&HB.drops&&HB.drops.length)?'  \u00b7  '+keyLabel('KeyE','E')+' TAKE THE DROPPED ITEM':''),W/2,hubFootY()); ctx.textAlign='left'; return; }   // v18.25: and the trade button while a party is on

'@ @'
  // v28.xx (cw-cx-hubfloor): the existing words and bindings feed the 16px control pill.

'@

SubRx @'
    ctx.font=hudFS(TYPE.head); ctx.fillStyle=s.c;
'@ @'
    ctx.font=uiFont('body',_hpR); ctx.fillStyle=UIC.tx_1; // v28.xx (cw-cx-hubfloor): the focused station stays above the control pill.
'@

SubRx @'
    ctx.fillText('['+keyLabel('KeyE','E')+']  '+s.label,W/2,_hpF-42*_hpR);
'@ @'
    ctx.fillText('['+keyLabel('KeyE','E')+']  '+s.label,W/2,_hpF-76*_hpR);
'@

SubRx @'
    ctx.font=hudFS(TYPE.label); ctx.fillStyle='#b7c2cd';
'@ @'
    ctx.font=uiFont('label',_hpR); ctx.fillStyle=UIC.tx_2; // v28.xx (cw-cx-hubfloor): guide size and muted colour.
'@

SubRx @'
    ctx.fillText(typeof s.sub==='function'?s.sub():s.sub,W/2,_hpF-26*_hpR);
'@ @'
    ctx.fillText(typeof s.sub==='function'?s.sub():s.sub,W/2,_hpF-52*_hpR);
'@

SubRx @'
)).replace(/^\s+\S\s+/,''),16,44);
'@ @'
)).replace(/^\s+\S\s+/,''),hx/_hhr,hy/_hhr+48);
'@

SubRx @'
ctx.fillText(hubFootKeys(
'@ @'
hubFloorHints(hubFootKeys(
'@

SubRx @'
var VER='33.98';
'@ @'
var VER='33.99';
'@

$pat = "(?m)^  now:'v33\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.99: A cream title, quiet station names, one lime raid hero and readable control key chips. Check 33.99 fails on v33.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
