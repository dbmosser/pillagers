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

# TV HUD READABILITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function beltFS(bw,k){ var f=FS(TYPE.micro), m=(/([\d.]+)px/).exec(f), n=m?parseFloat(m[1]):11, want=Math.round(bw*k); if(G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number')want=Math.max(want,20*Math.max(.75,Math.min(2.2,H/1080))); return hudFloor16((want>n)?f.replace((/([\d.]+)px/),want+'px'):f); } // v28.xx (cw-cx-hubbagreadability): key numbers stay readable in the hub card.
'@ @'
function beltFS(bw,k){ var f=FS(TYPE.micro), m=(/([\d.]+)px/).exec(f), n=m?parseFloat(m[1]):11, want=Math.max(Math.round(bw*k),(G&&!G.hubFloor)?Math.round(18*hudRes()):0); if(G&&G.hubFloor&&typeof G.hubBagBeltBottom==='number')want=Math.max(want,20*Math.max(.75,Math.min(2.2,H/1080))); return hudFloor16((want>n)?f.replace((/([\d.]+)px/),want+'px'):f); } // v28.xx (cw-cx-hubbagreadability): key numbers stay readable in the hub card. // v28.xx (cw-cx-hudtvread): raid key numbers and reserves have an 18px floor, grown with the TV and screen scale.
'@

SubRx @'
      hudPlate(hx+_gf*bw+_gx[_gf]-_pp,hy-_pp,(_gl-_gf)*bw+(_gx[_gl]-_gx[_gf])+bw+_pp*2,bw+_lbH+_pp*2,null,HUDC.plate);
'@ @'
      if(G.hubFloor) hudPlate(hx+_gf*bw+_gx[_gf]-_pp,hy-_pp,(_gl-_gf)*bw+(_gx[_gl]-_gx[_gf])+bw+_pp*2,bw+_lbH+_pp*2,null,HUDC.plate); // v28.xx (cw-cx-hudtvread): raid empty slots no longer carry a solid full-width backing plate.
'@

SubRx @'
      var _br=Math.max(3,bw*0.09);
'@ @'
      var _quietBelt=!G.hubFloor, _vacant=!!S.vacant||S.kind==='empty'; // v28.xx (cw-cx-hudtvread): owned slots lead; keep every class key and hit cell.
      var _br=Math.max(3,bw*0.09);
'@

SubRx @'
      var _bg=ctx.createLinearGradient(0,hy,0,hy+bw); _bg.addColorStop(0,on?'rgba(70,56,28,.96)':'rgba(30,34,37,.9)');   /* vNN.xx (ui5q1t, his #35): a belt key is graphite like the HUD plate, not navy */ _bg.addColorStop(1,on?'rgba(38,32,20,.94)':'rgba(6,9,13,.86)');
      ctx.fillStyle=_bg; ctx.fillRect(bx,hy,bw,bw);
'@ @'
      // v28.xx (cw-cx-hudtvread): flat graphite owned tiles; unselected vacant raid slots have no slab.
      if(_quietBelt){
        if(!_vacant||on){ctx.fillStyle=on?UIC.ui_raised:UIC.ui_panel;ctx.fillRect(bx,hy,bw,bw);}
      }else{
        var _bg=ctx.createLinearGradient(0,hy,0,hy+bw);_bg.addColorStop(0,on?'rgba(70,56,28,.96)':'rgba(30,34,37,.9)');_bg.addColorStop(1,on?'rgba(38,32,20,.94)':'rgba(6,9,13,.86)');
        ctx.fillStyle=_bg;ctx.fillRect(bx,hy,bw,bw);
      }
'@

SubRx @'
      if(_hr&&!_bgDim){ var _hf=rfill(_hr); if(_hf){ ctx.fillStyle=_hf; if(_bgHalf) ctx.globalAlpha=.5; ctx.fillRect(bx,hy,bw,bw); ctx.globalAlpha=1; } }   // v24.xx (beltgrey): a reloadable gun keeps half its wash
'@ @'
      // v28.xx (cw-cx-hudtvread): rarity is a 3px rail in the raid, not a second selected fill. Reloadable guns retain their half-grey state.
      if(_hr&&!_bgDim){
        if(_quietBelt){ctx.fillStyle=RCOL[_hr]||UIC.tx_2;ctx.globalAlpha=_bgHalf?.5:1;ctx.fillRect(bx+4,hy+bw-Math.max(3,3*hudRes())-2,bw-8,Math.max(3,3*hudRes()));ctx.globalAlpha=1;}
        else{var _hf=rfill(_hr);if(_hf){ctx.fillStyle=_hf;if(_bgHalf)ctx.globalAlpha=.5;ctx.fillRect(bx,hy,bw,bw);ctx.globalAlpha=1;}}
      }
'@

SubRx @'
      ctx.fillStyle='rgba(255,255,255,.05)'; ctx.fillRect(bx,hy,bw,Math.max(1,bw*0.04));
'@ @'
      if(!_quietBelt){ctx.fillStyle='rgba(255,255,255,.05)'; ctx.fillRect(bx,hy,bw,Math.max(1,bw*0.04));} // v28.xx (cw-cx-hudtvread): flat raid tiles have no gloss.
'@

SubRx @'
      ctx.strokeStyle=dragOver?'#ffc04a':(_selOut?'#ffc04a':((_hr&&RCOL[_hr]&&!_bgDim)?hexA(RCOL[_hr],.55):'rgba(140,152,163,.35)'));
      ctx.lineWidth=(dragOver||_selOut)?2:1;
      _bpath(); ctx.stroke();   // v18.34: the rounded ring
'@ @'
      // v28.xx (cw-cx-hudtvread): his 10-13 order keeps selected guns, heals and throwables gold. Three pixels improves the ring; vacant raid slots lose their outlines.
      ctx.strokeStyle=(dragOver||_selOut)?'#ffc04a':(_quietBelt?UIC.ui_line_hi:((_hr&&RCOL[_hr]&&!_bgDim)?hexA(RCOL[_hr],.55):'rgba(140,152,163,.35)'));
      ctx.lineWidth=(dragOver||_selOut)?(_quietBelt?3:2):1;
      if(!_quietBelt||!_vacant||dragOver||_selOut){_bpath();ctx.stroke();}
'@

SubRx @'
      ctx.font=beltFS(bw,0.13); ctx.fillStyle='rgba(160,172,184,.8)';   // v18.71: grows with the slot
      ctx.fillText(slotKeyName(q),bx+LH(4),hy+Math.max(LH(11),Math.round(bw*0.13)+LH(3)));
'@ @'
      ctx.font=beltFS(bw,0.13); ctx.fillStyle=UIC.tx_2;   // v18.71: grows with the slot
      hudText(slotKeyName(q),bx+LH(4),hy+Math.max(LH(11),Math.round(bw*0.13)+LH(3))); // v28.xx (cw-cx-hudtvread): outlined key digits read on the ground behind vacant slots.
'@

SubRx @'
    oa=ctx.globalAlpha; ctx.globalAlpha=GHOST_A; ctx.drawImage(gh.c,cx-gh.s/2,cy-gh.s/2,gh.s,gh.s); ctx.globalAlpha=oa;
'@ @'
    oa=ctx.globalAlpha; ctx.globalAlpha=GHOST_A*((G&&!G.hubFloor)?.45:1); ctx.drawImage(gh.c,cx-gh.s/2,cy-gh.s/2,gh.s,gh.s); ctx.globalAlpha=oa; // v28.xx (cw-cx-hudtvread): retain class silhouettes at less than half their old opacity in raids.
'@

SubRx @'
      hy=Math.max(LH(16),Math.min(_topB,_topG)-bw-LH(24));
'@ @'
      hy=Math.max(LH(16),Math.min(_topB,_topG)-bw-LH(12)); // v28.xx (cw-cx-hudtvread): half the excess gap, still above both bottom corners.
'@

SubRx @'
  ctx.fillText('HP  '+Math.round(p.hp),24,(_hpx>_hpm)?Math.round(by+HBH/2+_hpm*0.36):by+18);
'@ @'
  hudText('HP  '+Math.round(p.hp),24,(_hpx>_hpm)?Math.round(by+HBH/2+_hpm*0.36):by+18); // v28.xx (cw-cx-hudtvread): ink outline separates the word from its coloured bar; retain the larger hp hierarchy.
'@

SubRx @'
    ctx.fillText('ARMOUR  '+Math.round(p.armor),24,(_apx>_apm)?Math.round(by-50+8+_apm*0.36):by-37);   /* v28.xx (cw-barheight): follows the bar */
'@ @'
    hudText('ARMOUR  '+Math.round(p.armor),24,(_apx>_apm)?Math.round(by-50+8+_apm*0.36):by-37);   /* v28.xx (cw-barheight): follows the bar */ // v28.xx (cw-cx-hudtvread): ink outline separates the word from its coloured bar; retain the larger hp hierarchy.
'@

SubRx @'
  ctx.globalAlpha=_sfa; if(_sfa>0.001) ctx.fillText(p.stamLock?'WINDED':'STAMINA',24,(_spx>_spm)?Math.round(by-29+8+_spm*0.36):by-16);
'@ @'
  ctx.globalAlpha=_sfa; if(_sfa>0.001) hudText(p.stamLock?'WINDED':'STAMINA',24,(_spx>_spm)?Math.round(by-29+8+_spm*0.36):by-16); // v28.xx (cw-cx-hudtvread): ink outline separates the word from its coloured bar; retain the larger hp hierarchy.
'@

SubRx @'
function arcadeScoreHud(y,z){
  if(!G||!(G.arcade||G.career)||!ctx) return;
  var cr=!G.arcade, solo=cr||!!ARCADE.solo;   // v24.xx (feat0h2): a CAREER raid reads its own score, one player to a window
  var cx=Math.round(W/2), mine=Math.max(0,cr?((G.cs&&G.cs.s)|0):(ARCADE.mine|0)), mate=cr?0:Math.max(0,ARCADE.mate|0), nm=arcadeCr(mine+mate);   // v23.56 (arcade31): in credits
  var fb=FSz(TYPE.title,z), fs=FSz(TYPE.micro,z), mh=/([\d.]+)px/.exec(fb), h=mh?+mh[1]:20, w, gx, yL=y+Math.round(10*z), _bot;   // v28.xx (cw-scoretop): the whole block rides 10 pixels lower (the label) and 14 (the number) so the SCORE label is not clipped at the top edge (the critic, 10-19)
  // v25.xx (topmid), HIS NOTE 2026-10-13: "text at top mid iscolliding". The SCORE label sat flush on the number under it (1 pixel of
  // ink over it at 1080p), so the number, the clock under it and everything below go down 4 pixels (times the screen scale) and the
  // label stays at the top edge. The function returns the bottom of its ink, for the compass stack to start under.
  y=y+Math.round(14*z); _bot=Math.round(y+h*0.22);
  ctx.save(); ctx.textAlign='center';
  // v28.xx (cw-scoreplate), the critic (2026-10-19): "the score cluster has no plate". One plate (the HUD plate, 78 percent) hangs from the top edge behind the label, the number and the clock, so the numbers read on any floor; it is as wide as the number plus the streak and the teammate score beside it.
  var _sx0=arcadeStreakLive(), _cl0=raidClockOn(), _fin0=(_cl0&&Math.ceil(Math.max(0,+G.timeLeft||0))<=CLOCK_RED), _pw0, _ph0;
  ctx.font=fb; _pw0=Math.max(Math.round(80*z),Math.round(ctx.measureText(nm).width/2+22*z+(solo?0:100*z)+(_sx0>1?40*z:0))); _ph0=Math.round(y+h*(_cl0?(_fin0?1.42:1.22):0.35));
  hudPlate(cx-_pw0,-Math.round(8*z),_pw0*2,_ph0+Math.round(8*z),null,HUDC.plate); SCOREBOX.g=G; SCOREBOX.x=cx-_pw0; SCOREBOX.y=0; SCOREBOX.w=_pw0*2; SCOREBOX.h=_ph0;   /* v31.xx (cw-trcol2): where the plate is, for the world labels that keep clear of it */
  ctx.font=fs; ctx.fillStyle=UIC.tx_2; hudText(solo?'SCORE':'TEAM SCORE',cx,Math.round(yL-h*0.80));   // v23.54 (arcade30): SCORE in the 1 player arcade; v28.xx (cw-scoretop): the label is quiet grey (amber is for a warning), the number is the hero
  ctx.font=fb; ctx.fillStyle='#e8eef2'; hudText(nm,cx,y); w=ctx.measureText(nm).width;
  if(raidClockOn()){   // v23.6x (feat0e): the DEMO clock under the score, red under 45 s like the raid clock
    var _ct=Math.ceil(Math.max(0,+G.timeLeft||0)), _cm=Math.floor(_ct/60), _cs=_ct%60;
    // v27.xx (clockbig), HIS ANSWER 14 (2026-10-13): "the countdown clock needs to be bigger". The clock under the score was the smallest type on the HUD (13 pixels at
                    // 1080p, 19 in the last minute). It is the head size now (19.5) and the title size, the same as the score, in the last minute (26), and sits a little lower to
                    // make room. DEMO and CAREER draw this one block.
                    var _cfin=(_ct<=CLOCK_RED), _cy=Math.round(y+h*(_cfin?1.14:0.92)), _apo=(_cfin&&_ct>0)?clockPopIn(cx,_cy-h*0.3,G.timeLeft):false;   // v23.xx (his answer 19): the final minute, red, bigger and popping
    ctx.font=_cfin?FSz(TYPE.title,z):FSz(TYPE.head,z); ctx.fillStyle=_cfin?'#ff5a4a':'#cdd6dd'; hudText(_cm+':'+(_cs<10?'0':'')+_cs,cx,_cy); if(_apo) ctx.restore();
    _bot=Math.max(_bot,Math.round(_cy+(+((/([\d.]+)px/.exec(ctx.font)||[0,14])[1]))*0.25));   // v25.xx (topmid): the bottom of the clock row
  }
  gx=Math.round(cx+w/2+10*z);
  ctx.font=fs; ctx.textAlign='left'; ctx.fillStyle='#cdd6dd';
  if(!solo){   // v23.54 (arcade30): no YOU and P2 split in the 1 player arcade
    hudText('YOU '+arcadeCr(mine),gx,Math.round(y-h*0.40));
    hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate),gx,Math.round(y+h*0.15));
  }
  var _sx=arcadeStreakLive();   // v23.38 (arcade15): the live streak multiplier, left of the score
  if(_sx>1){ ctx.font=fb; ctx.textAlign='right'; ctx.fillStyle='#ffc04a'; hudText('x'+_sx,Math.round(cx-w/2-10*z),y); }
  ctx.restore();
  return _bot;   // v25.xx (topmid): where the block ends, for the compass under it
}
'@ @'
function arcadeScoreHud(y,z){
  // v28.xx (cw-cx-hudtvread): readable score labels and a real top inset in both windows. Score, streak and final-minute clock rules stay the same.
  if(!G||!(G.arcade||G.career)||!ctx) return;
  var cr=!G.arcade,solo=cr||!!ARCADE.solo,cx=Math.round(W/2),mine=Math.max(0,cr?((G.cs&&G.cs.s)|0):(ARCADE.mine|0)),mate=cr?0:Math.max(0,ARCADE.mate|0),nm=arcadeCr(mine+mate),
      fb=FSz(TYPE.title,z),fs=FSz(TYPE.label,z),h=parseFloat((/([\d.]+)px/.exec(fb)||[0,20])[1]),lh=parseFloat((/([\d.]+)px/.exec(fs)||[0,16])[1]),
      clock=raidClockOn(),ct=Math.ceil(Math.max(0,+G.timeLeft||0)),fin=ct<=CLOCK_RED,fc=FSz(fin?TYPE.title:TYPE.head,z),ch=parseFloat((/([\d.]+)px/.exec(fc)||[0,20])[1]),
      top=Math.round(16*z),pad=Math.round(12*z),labelY=top+pad+lh,scoreY=labelY+Math.round(8*z)+h,clockY=scoreY+Math.round(8*z)+ch,
      sx=arcadeStreakLive(),w,gx,pw,bot,side=0,sw=0,apo=false;
  ctx.save();ctx.textAlign='center';
  ctx.font=fb;w=ctx.measureText(nm).width;
  if(!solo){ctx.font=fs;side=Math.max(ctx.measureText('YOU '+arcadeCr(mine)).width,ctx.measureText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate)).width)+Math.round(24*z);}
  if(sx>1){ctx.font=fb;sw=ctx.measureText('x'+sx).width+Math.round(10*z);}
  pw=Math.ceil(Math.max(100*z,w/2+pad+Math.max(side,sw)));
  bot=Math.ceil((clock?clockY+ch*.25:scoreY+h*.25)+pad);
  hudPlate(cx-pw,top,pw*2,bot-top,null,HUDC.plate);
  SCOREBOX.g=G;SCOREBOX.x=cx-pw;SCOREBOX.y=top;SCOREBOX.w=pw*2;SCOREBOX.h=bot-top;
  ctx.font=fs;ctx.fillStyle=UIC.tx_2;hudText(solo?'SCORE':'TEAM SCORE',cx,labelY);
  ctx.font=fb;ctx.fillStyle=UIC.tx_1;hudText(nm,cx,scoreY);
  if(clock){apo=(fin&&ct>0)?clockPopIn(cx,clockY-ch*.3,G.timeLeft):false;ctx.font=fc;ctx.fillStyle=fin?'#ff5a4a':'#cdd6dd';hudText(Math.floor(ct/60)+':'+(ct%60<10?'0':'')+(ct%60),cx,clockY);if(apo)ctx.restore();}
  if(!solo){gx=Math.round(cx+w/2+24*z);ctx.font=fs;ctx.textAlign='left';ctx.fillStyle=UIC.tx_2;hudText('YOU '+arcadeCr(mine),gx,Math.round(scoreY-lh*.5));hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate),gx,Math.round(scoreY+lh*.75));}
  if(sx>1){ctx.font=fb;ctx.textAlign='right';ctx.fillStyle='#ffc04a';hudText('x'+sx,Math.round(cx-w/2-10*z),scoreY);}
  ctx.restore();return bot;
}
'@

SubRx @'
  if(G.arcade||G.career){ var _arcB=arcadeScoreHud(_yClk,_tz)||0; try{ if(SCOREBOX&&SCOREBOX.g===G&&SCOREBOX.w>0) wxIconDraw(Math.round(SCOREBOX.x+SCOREBOX.w+LH(16)*_tz),Math.round(SCOREBOX.y+Math.min(SCOREBOX.h/2,LH(28)*_tz)),Math.round(LH(10)*_tz)); }catch(_wxa){}   /* v35.xx (cw-extpill): the sky beside the score block */ if(_arcB>0&&_yCmp<_arcB+Math.round(3*_tz+_hCmp*0.80)){ _yCmp=_arcB+Math.round(3*_tz+_hCmp*0.80); _yArw=Math.round(_yCmp+_hCmp*0.90); _yMk=Math.round(_yArw+_hMk*1.30); } } else {   /* v25.xx (topmid): the compass starts under the score block, not through its clock row */ var _cpo=(!_noClk&&_tSrc<=CLOCK_RED&&_tSrc>0)?clockPopIn(W/2,_yClk-_hClk*0.35,G.timeLeft):false; hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk); if(_cpo) ctx.restore(); try{ ctx.font=_fClk; wxIconDraw(Math.round(W/2+ctx.measureText(mm+':'+(ss<10?'0':'')+ss).width/2+LH(18)*_tz),Math.round(_yClk-_hClk*0.36),Math.round(LH(10)*_tz)); }catch(_wxi){} }   /* v35.xx (cw-extpill): the sky beside the clock */   /* v23.xx (his answer 19): it pops on every second of the final minute */   // v23.29 (arcade8): in the arcade, TEAM SCORE in place of the clock
'@ @'
  if(G.arcade||G.career){ var _arcB=arcadeScoreHud(_yClk,_tz)||0; try{ if(SCOREBOX&&SCOREBOX.g===G&&SCOREBOX.w>0) wxIconDraw(Math.round(SCOREBOX.x+SCOREBOX.w+LH(16)*_tz),Math.round(SCOREBOX.y+Math.min(SCOREBOX.h/2,LH(28)*_tz)),Math.round(LH(10)*_tz)); }catch(_wxa){}   /* v35.xx (cw-extpill): the sky beside the score block */ if(_arcB>0&&_yCmp<_arcB+Math.round(8*_tz+_hCmp*1.05)){ _yCmp=_arcB+Math.round(8*_tz+_hCmp*1.05); _yArw=Math.round(_yCmp+_hCmp*0.90); _yMk=Math.round(_yArw+_hMk*1.30); } } else {   /* v25.xx (topmid): the compass starts under the score block, not through its clock row */ var _cpo=(!_noClk&&_tSrc<=CLOCK_RED&&_tSrc>0)?clockPopIn(W/2,_yClk-_hClk*0.35,G.timeLeft):false; hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk); if(_cpo) ctx.restore(); try{ ctx.font=_fClk; wxIconDraw(Math.round(W/2+ctx.measureText(mm+':'+(ss<10?'0':'')+ss).width/2+LH(18)*_tz),Math.round(_yClk-_hClk*0.36),Math.round(LH(10)*_tz)); }catch(_wxi){} }   /* v35.xx (cw-extpill): the sky beside the clock */   /* v23.xx (his answer 19): it pops on every second of the final minute */   // v23.29 (arcade8): in the arcade, TEAM SCORE in place of the clock // v28.xx (cw-cx-hudtvread): the extraction pill clears the score plate by 8 scaled pixels.
'@

SubRx @'
var VER='35.63';
'@ @'
var VER='35.64';
'@

$pat = "(?m)^  now:'v35\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.64: TV HUD labels read larger; empty belt slots are quieter and the score panel has room. Check 35.64 fails on v35.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
