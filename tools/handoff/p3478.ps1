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

# THE CAREER CONTROLS LIST IS A CLEAN PANEL AND THE FOLDED CHIP MATCHES THE STANDING TAG (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
['B / I','backpack'],['LMB','use item in hand'],
'@ @'
['B / I','backpack'],['LMB','use item'],
'@

SubRx @'
    if(!padOn()&&!(typeof arcadeCardOn==='function'&&arcadeCardOn()>0)) { var _f1t=legendKeys('F1')+'  controls', _f1w=Math.round(ctx.measureText(_f1t).width+LH(16)); /* v28.xx (cw-f1plate), the critic (2026-10-19): the f1 controls hint is dim grey over a busy map with no plate. It sits on the HUD plate in the quiet grey text colour. */ hudPlate(_hx,Math.round(_hy-LH(14)),_f1w,LH(22),null,HUDC.plate); ctx.fillStyle=UIC.tx_2; ctx.fillText(_f1t,_hx+8,_hy); LEGHINT={x:_hx,y:Math.round(_hy-LH(14)),w:_f1w,h:LH(22)}; }   // v25.xx (keyswap): F1; v30.xx (cw-partyhud2): not while the arcade controls card is up (it showed through the card)

'@ @'
    if(!padOn()&&!(typeof arcadeCardOn==='function'&&arcadeCardOn()>0)) {   // v25.xx (keyswap): F1; v30.xx (cw-partyhud2): not while the arcade controls card is up (it showed through the card)
      // v34.xx (cw-ctrlchip), the critic (job 121) on screen 79: 'the f1 controls chip uses a different chip style from the standing tag'. It is the same chip now: the same HUD panel (88 percent, 1px line, 4px radius), the same label face and the same quiet grey text as the posture tag, standing on the same spot as before (bottom just over the vitals).
      var _f1t=legendKeys('F1')+'  controls'; ctx.font=FS(TYPE.label);
      var _cp=parseFloat((/([\d.]+)px/.exec(ctx.font)||[0,16])[1])||16, _ch=Math.round(_cp*1.45), _cw=Math.round(ctx.measureText(_f1t).width+_cp*0.9), _ct=Math.round(_hy+LH(8))-_ch;
      hudPanel(_hx,_ct,_cw,_ch,0.88,1); ctx.fillStyle='#a5b1bc'; ctx.fillText(_f1t,_hx+Math.round(_cp*0.45),_ct+Math.round(_ch*0.72)); LEGHINT={x:_hx,y:_ct,w:_cw,h:_ch};
    }

'@

SubRx @'
  if(G.legendOn===1){
    ctx.save();   // v28.xx (cw-h103hero)
    var MN=(padOn()?LEGEND_MINI_PAD:LEGEND_MINI).slice(),mi;
    // v20.76, from the whole-game bug hunt of 2026-10-08 (H46): ON A CONTROLLER THE PARTY ROWS ADD NO SECOND PING. The pad list
    // above already says D-UP ping, and the row added here named both bumpers, which never ping. On keys N still pings.
    if(typeof NET==='object'&&NET&&NET.on){ if(padOn()) MN.push(['Y','drop to trade']); else MN.push(['Z','drop to trade'],['N','ping']); }   // v18.27: his order, trading is dropping
    var _mr=Math.ceil(MN.length/2);
    if(!padOn()) for(mi=0;mi<MN.length;mi++) MN[mi]=[legendKeys(MN[mi][0]),MN[mi][1]];   // v18.60: the keys as set
    var _kw=0, _lw=0; ctx.font=FS(TYPE.micro); for(mi=0;mi<MN.length;mi++) _kw=Math.max(_kw,ctx.measureText(padB(MN[mi][0])).width);
    ctx.font=MONO; for(mi=0;mi<MN.length;mi++) _lw=Math.max(_lw,ctx.measureText(MN[mi][1]).width);
    var KOFF=Math.max(LH(44),Math.ceil(_kw)+LH(6));   // v18.60: the word clears the widest key
    var COLW=Math.max(LH(112),KOFF+Math.ceil(_lw)+LH(8)),MROW=LH(10),MW=COLW*2+LH(24),MH=MROW*_mr+(padOn()?LH(6):LH(16));   // v17.76: wide enough for TACTICAL BELT beside its key; v18.17: as many rows as the list has; v18.60: and for the widest key and word
    // 118, not 96: the health panel below is about 100 tall and 96 left the
    // legend sitting 12 pixels inside it. Measured, not guessed.
    var mx=14,my=H-Math.max(LH(64),Math.round(104*(HUDZ.body||1))+14)-MH;
    // v9.83: no offset here either. dx was added in this unscaled space and then
    // multiplied by the panel zoom, and dy was cancelled by the bottom anchor a
    // frame later. Both now ride outside the zoom with the anchor.
    mx=clamp(mx,4,Math.max(4,W-MW-4));
    my=clamp(my,LH(14),Math.max(LH(14),H-MH-4));
    hudPanel(mx-8,my-6,MW,MH+10,undefined,1);   // v18.13: the one HUD panel
    HUDBOX.legend={x:mx-8,y:my-6,w:MW,h:MH+10,tg:{x:mx-8+MW-LH(20),y:my-6,w:LH(20),h:LH(14)}};
    ctx.textAlign='right'; ctx.fillStyle='#8a96a1'; ctx.font=MONO;
    ctx.globalAlpha*=0.8; hudChev(mx-8+MW-4,my+LH(4),true);   // v28.xx (cw-h103hero), the critic on screens 21 and 19 ('the keys cheat sheet is big and always on'): the words of the compact list are drawn at 80 percent (the panel keeps the one shared fill), so it reads as a reference and not as a second hero   // vNN.xx (ui5q2p): a drawn chevron, not [-]
    ctx.textAlign='left';
    for(mi=0;mi<MN.length;mi++){
      var cx0=mx+(mi%2)*COLW, cy0=my+LH(7)+Math.floor(mi/2)*MROW;
      ctx.font=FS(TYPE.micro); ctx.fillStyle='#cdd6dd';
      ctx.fillText(padB(MN[mi][0]),cx0,cy0);
      ctx.font=MONO; ctx.fillStyle='#8a96a1';
      ctx.fillText(MN[mi][1],cx0+KOFF,cy0);
    }
    ctx.font=MONO; ctx.fillStyle='rgba(140,152,163,.6)';
    // v19.68, seen on the 4K controller screenshot (2026-10-08): on a controller (player 2 in co-op) no button opens the full list, so
    // H  full list named a keyboard key the pad player cannot press. On a pad the line and its row are left out.
    if(!padOn()) ctx.fillText(legendKeys('F1')+'  full list',mx,my+LH(7)+MROW*_mr+LH(3));
    ctx.restore();   // v28.xx (cw-h103hero)
    return;
  }

'@ @'
  if(G.legendOn===1){
    ctx.save();   // v28.xx (cw-h103hero)
    // v34.xx (cw-ctrlchip), the critic (job 121) on screen 80: 'a dense, tiny, dim, ragged four-column block'. One opaque panel (style guide Panel), rows at the label size (16px at 1080, scaled with the screen like every HUD size), a key cap plus a word on every row (the guide's Chip), the words in the text colour not dimmed, four short sections (move, fight, gear, raid) in two columns, ONE footer line (f1 full list, left out on a pad as before). The panel is drawn in the list's own zoom, so every size here is divided by that zoom (Q) and lands on the screen at its real size.
    var MN=(padOn()?LEGEND_MINI_PAD:LEGEND_MINI).slice(),mi,ci,ri,it;
    // v20.76, from the whole-game bug hunt of 2026-10-08 (H46): ON A CONTROLLER THE PARTY ROWS ADD NO SECOND PING. The pad list
    // above already says D-UP ping, and the row added here named both bumpers, which never ping. On keys N still pings.
    if(typeof NET==='object'&&NET&&NET.on){ if(padOn()) MN.push(['Y','drop to trade']); else MN.push(['Z','drop to trade'],['N','ping']); }   // v18.27: his order, trading is dropping
    if(!padOn()) for(mi=0;mi<MN.length;mi++) MN[mi]=[legendKeys(MN[mi][0]),MN[mi][1]];   // v18.60: the keys as set
    var _q=1/(HUDZ.legend||1), Q=function(n){ return n*_q; }, _lf=uiFont('label',_q), _pd=Q(12), _rh=Q(22), _chH=Q(20), _cpd=Q(8), _cg=Q(8), _gap=Q(24);
    var _secs=padOn()?[['move',0,4],['fight',4,9],['gear',9,99]]:[['move',0,4],['fight',4,8],['gear',8,14],['raid',14,99]], _cols=[[],[]], _si, _sk;
    for(_si=0;_si<_secs.length;_si++){ ci=_si<2?0:1; _cols[ci].push({h:_secs[_si][0]}); for(_sk=_secs[_si][1];_sk<Math.min(_secs[_si][2],MN.length);_sk++) _cols[ci].push({k:padB(MN[_sk][0]),w:MN[_sk][1]}); }
    ctx.font=_lf;
    var _cw=[0,0], _ww=[0,0], _rows=0;
    for(ci=0;ci<2;ci++){
      _rows=Math.max(_rows,_cols[ci].length);
      for(ri=0;ri<_cols[ci].length;ri++){ it=_cols[ci][ri]; if(it.h) continue; _cw[ci]=Math.max(_cw[ci],ctx.measureText(it.k).width+_cpd*2); _ww[ci]=Math.max(_ww[ci],ctx.measureText(it.w).width); }
      _cw[ci]=Math.max(_cw[ci],Q(28));
    }
    var _c0=_cw[0]+_cg+_ww[0], _c1=_cw[1]+_cg+_ww[1], _foot=padOn()?0:_rh, _f1k=legendKeys('F1');
    var MW=Math.ceil(_pd*2+_c0+_gap+_c1), MH=Math.ceil(_pd*2+_rows*_rh+_foot)-10;   // the panel is MH+10 high, as before
    var mx=14,my=H-Math.max(LH(64),Math.round(104*(HUDZ.body||1))+14)-MH;
    // v9.83: no offset here either. dx was added in this unscaled space and then
    // multiplied by the panel zoom, and dy was cancelled by the bottom anchor a
    // frame later. Both now ride outside the zoom with the anchor.
    mx=clamp(mx,4,Math.max(4,W-MW-4));
    my=clamp(my,LH(14),Math.max(LH(14),H-MH-4));
    var _px=mx-8, _py=my-6, _pw=MW, _ph=MH+10, _fx, _ry, _by, _cy;
    // v18.13: the one HUD panel. Opaque now (the critic: the map showed through it): a solid graphite underlay in the panel colour, then the shared HUD panel (same fill and line as every raid panel, check 34.24) on top.
    ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(_px,_py,_pw,_ph,LH(HUDPS.rad)); else ctx.rect(_px,_py,_pw,_ph);
    ctx.fillStyle='#111315'; ctx.fill();
    hudPanel(_px,_py,_pw,_ph,undefined,1);
    HUDBOX.legend={x:_px,y:_py,w:_pw,h:_ph,tg:{x:_px+_pw-LH(20),y:_py,w:LH(20),h:LH(14)}};
    ctx.textAlign='left'; ctx.lineWidth=Q(1);
    ctx.globalAlpha*=0.8;   // v28.xx (cw-h103hero, check 34.29): the rows are drawn at 80 percent so the list reads as a reference, not a second hero; the panel under them is solid
    function _cap(x,ry,w,k,wd,wdc){   // one row: the key cap, then its word
      var by=Math.round(ry+_rh/2+Q(5.5)), cy=ry+(_rh-_chH)/2;
      ctx.fillStyle=UIC.ui_raised; ctx.fillRect(x,cy,w,_chH); ctx.strokeStyle=UIC.ui_line_hi; ctx.strokeRect(x+Q(.5),cy+Q(.5),w-Q(1),_chH-Q(1));
      ctx.fillStyle=UIC.tx_1; ctx.textAlign='center'; ctx.fillText(k,x+w/2,by);
      ctx.fillStyle=wdc; ctx.textAlign='left'; ctx.fillText(wd,x+w+_cg,by);
    }
    for(ci=0;ci<2;ci++){
      _fx=_px+_pd+(ci?_c0+_gap:0);
      for(ri=0;ri<_cols[ci].length;ri++){
        it=_cols[ci][ri]; _ry=_py+_pd+ri*_rh;
        if(it.h){ ctx.fillStyle=UIC.tx_2; ctx.textAlign='left'; ctx.fillText(it.h,_fx,Math.round(_ry+_rh/2+Q(5.5))); continue; }
        _cap(_fx,_ry,_cw[ci],it.k,it.w,UIC.tx_1);
      }
    }
    if(!padOn()){   // v19.68, seen on the 4K controller screenshot (2026-10-08): on a pad no button opens the full list, so the line and its row are left out
      ctx.font=_lf; _cap(_px+_pd,_py+_pd+_rows*_rh,Math.max(Q(28),ctx.measureText(_f1k).width+_cpd*2),_f1k,'full list',UIC.tx_2);
    }
    ctx.restore();   // v28.xx (cw-h103hero)
    return;
  }

'@

SubRx @'
var VER='34.77';
'@ @'
var VER='34.78';
'@

$pat = "(?m)^  now:'v34\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.78: The controls list opened with F1 reads clearly: key caps, grouped, bigger. The folded f1 controls chip looks like the standing tag. Check 34.78 fails on v34.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
