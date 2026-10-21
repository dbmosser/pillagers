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

# PIXEL PILLAGER STANDING HEIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var PXB={W:36,H:50,AX:19,AY:51,PV:20,TARGET:50};
'@ @'
var PXB={W:36,H:54,AX:19,AY:55,PV:20,TARGET:54}; /* v28.xx (cw-cx-pixheight): 79a measured about 58 px at zoom 1.05; at zoom 1 that is 55 px, with 2 px tolerance. Redraw the torso and legs, never scale a sprite. */
'@

SubRx @'
function pxBuildUpper(o){
  var p=pxPaint(o.mir), W=PXB.W, C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair, hr=PXB_HAIR, E=PXB_EYE, bot=!!o.bot, dxp=o.mir?-o.pup:o.pup, cl=o.clothes, m, y, x, skull, op, belt, mk, ml;
  // pack, on the side away from the facing (the left of the unflipped sprite)
  if(cl==='recon'){
    p.put(pxRR(pxM(),4,15,10,40,2),C.pack); p.put(pxRR(pxM(),2,11,11,15,2.2),C.gear);
    for(y=17;y<=38;y++) p.P(5,y,C.pack[3]);
  } else if(cl==='heavy'){
    p.put(pxRR(pxM(),2,21,10,40,1.2),C.pack); p.put(pxRect(pxM(),4,24,8,29),C.gear);
    p.P(5,31,C.acc); p.P(7,31,C.acc); p.P(5,33,C.gear[0]); p.P(6,33,C.gear[0]);
    for(y=5;y<=20;y++) p.P(4,y,C.gear[2]);
    p.P(4,4,C.acc); p.P(3,4,C.gear[1]);
  } else {
    p.put(pxRR(pxM(),3,26,10,38,2),C.pack); p.put(pxRect(pxM(),4,27,9,29),C.gear); p.P(6,30,C.acc);
  }
  // torso, then what each clothes pick wears on it
  p.put(pxRR(pxM(),10,22,25,35,2.5),C.coat);
  if(cl==='recon'){
    p.put(pxSeg(pxM(),12,22.6,23.5,33.5,0.9),C.gear); p.put(pxSeg(pxM(),23.5,22.6,12,33.5,0.9),C.gear); p.put(pxRR(pxM(),15,29,20,32,1),C.pack);
  } else if(cl==='heavy'){
    p.put(pxRR(pxM(),12,23,23,31,1.5),C.gear); p.put(pxRR(pxM(),8,21,12,26,1.5),C.gear); p.put(pxRR(pxM(),23,21,27,26,1.5),C.gear);
    p.Pl(13,24,C.gear[0]); p.Pl(9,22,C.gear[0]);
  } else {
    p.put(pxSeg(pxM(),12.5,23,22.5,33.5,1.1),C.gear); p.put(pxRR(pxM(),11,28,14,31,1),C.gear); p.put(pxRR(pxM(),21,28,24,31,1),C.gear);
  }
  belt=o.band?pixRamp(o.band):[C.gear[1],C.gear[2],C.gear[3],C.gear[3]];
  p.put(pxRect(pxM(),10,34,25,35),belt,{line:false}); p.P(17,34,C.acc); p.P(18,34,C.acc);
  if(o.arms){
    p.put(pxRR(pxM(),8,23,10,33,1.2),C.coat); p.put(pxRR(pxM(),25,23,27,33,1.2),C.coat);
    p.put(pxRR(pxM(),8,33,10,36,1.2),sk); p.put(pxRR(pxM(),25,33,27,36,1.2),sk);
  }
  if(o.lamp){ p.Pl(11,22,o.lamp); p.Pl(12,22,o.lamp); p.Pl(11,23,o.lamp); p.Pl(12,23,o.lamp); }
  p.put(pxRect(pxM(),16,19,19,21),sk,{line:false});
  // the head: hair behind first, then the skull, then what covers it
  if(o.head==='long'){
    p.put(pxEll(pxM(),6,2,29,22),hr); p.put(pxSeg(pxM(),10,15,6.5,29,2.3),hr);
    p.P(8,19,C.acc); p.P(9,19,C.acc); p.P(8,20,C.acc);
  }
  skull=pxEll(pxM(),9,3,26,18); p.put(skull,sk);
  if(o.head==='hood'){
    ml=pxEll(pxM(),6,0,29,21); op=pxRR(pxM(),11,8,24,19,3.2);
    for(y=0;y<PXB.H*W;y++) if(op[y]) ml[y]=0;
    p.put(pxRR(pxM(),7,19,28,24,2),C.coat);
    p.put(ml,C.coat,{lx:-0.75,ly:-0.66,b1:0.24,b2:0.56,b3:0.82});
    mk=pxRR(pxM(),11,15,24,19,2); p.put(mk,[C.coat[0],C.coat[0],C.coat[1],C.coat[2]],{line:false});
    p.Pl(12,3,C.coat[0]); p.Pl(13,3,C.coat[0]); p.Pl(11,4,C.coat[0]);
  } else {
    ml=pxM(); for(y=3;y<=8;y++) for(x=9;x<=26;x++) if(skull[y*W+x]) ml[y*W+x]=1;
    pxRect(ml,9,9,10,o.head==='long'?18:11); pxRect(ml,25,9,26,o.head==='long'?18:11); pxRect(ml,10,9,o.head==='long'?24:20,9);
    p.put(ml,hr,{line:false});
    p.P(17,16,sk[3]); p.P(18,16,sk[3]);
  }
  // the face: two 3 by 3 eyes, the pupils a pixel toward the aim; a bot has red eyes and angry brows
  function eye(ex){
    var px=ex+1+dxp, yy, xx;
    for(yy=11;yy<=13;yy++) for(xx=ex;xx<=ex+2;xx++) p.P(xx,yy,yy===11?E.lid:E.white);
    if(bot){ p.P(px,12,E.red); p.P(px,13,E.redDeep); } else { p.P(px,12,E.iris); p.P(px,13,E.ink); }
  }
  eye(12); eye(21);
  if(bot){ p.P(11,10,E.brow); p.P(12,10,E.brow); p.P(13,11,E.brow); p.P(14,11,E.brow); p.P(24,10,E.brow); p.P(23,10,E.brow); p.P(22,11,E.brow); p.P(21,11,E.brow); p.P(13,10,E.brow); p.P(22,10,E.brow); }
  return p.sprite();
}
'@ @'
// v28.xx (cw-cx-pixheight): add two art rows to the torso, extend the packs and sleeves with it, and keep the original face grid.
function pxBuildUpper(o){
  var p=pxPaint(o.mir), W=PXB.W, C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair, hr=PXB_HAIR, E=PXB_EYE, bot=!!o.bot, dxp=o.mir?-o.pup:o.pup, cl=o.clothes, m, y, x, skull, op, belt, mk, ml;
  // pack, on the side away from the facing (the left of the unflipped sprite)
  if(cl==='recon'){
    p.put(pxRR(pxM(),4,15,10,42,2),C.pack); p.put(pxRR(pxM(),2,11,11,15,2.2),C.gear);
    for(y=17;y<=40;y++) p.P(5,y,C.pack[3]);
  } else if(cl==='heavy'){
    p.put(pxRR(pxM(),2,21,10,42,1.2),C.pack); p.put(pxRect(pxM(),4,24,8,29),C.gear);
    p.P(5,31,C.acc); p.P(7,31,C.acc); p.P(5,33,C.gear[0]); p.P(6,33,C.gear[0]);
    for(y=5;y<=20;y++) p.P(4,y,C.gear[2]);
    p.P(4,4,C.acc); p.P(3,4,C.gear[1]);
  } else {
    p.put(pxRR(pxM(),3,26,10,40,2),C.pack); p.put(pxRect(pxM(),4,27,9,29),C.gear); p.P(6,30,C.acc);
  }
  // torso, then what each clothes pick wears on it
  p.put(pxRR(pxM(),10,22,25,37,2.5),C.coat);
  if(cl==='recon'){
    p.put(pxSeg(pxM(),12,22.6,23.5,35.5,0.9),C.gear); p.put(pxSeg(pxM(),23.5,22.6,12,35.5,0.9),C.gear); p.put(pxRR(pxM(),15,31,20,34,1),C.pack);
  } else if(cl==='heavy'){
    p.put(pxRR(pxM(),12,23,23,33,1.5),C.gear); p.put(pxRR(pxM(),8,21,12,26,1.5),C.gear); p.put(pxRR(pxM(),23,21,27,26,1.5),C.gear);
    p.Pl(13,24,C.gear[0]); p.Pl(9,22,C.gear[0]);
  } else {
    p.put(pxSeg(pxM(),12.5,23,22.5,35.5,1.1),C.gear); p.put(pxRR(pxM(),11,30,14,33,1),C.gear); p.put(pxRR(pxM(),21,30,24,33,1),C.gear);
  }
  belt=o.band?pixRamp(o.band):[C.gear[1],C.gear[2],C.gear[3],C.gear[3]];
  p.put(pxRect(pxM(),10,36,25,37),belt,{line:false}); p.P(17,36,C.acc); p.P(18,36,C.acc);
  if(o.arms){
    p.put(pxRR(pxM(),8,23,10,35,1.2),C.coat); p.put(pxRR(pxM(),25,23,27,35,1.2),C.coat);
    p.put(pxRR(pxM(),8,35,10,38,1.2),sk); p.put(pxRR(pxM(),25,35,27,38,1.2),sk);
  }
  if(o.lamp){ p.Pl(11,22,o.lamp); p.Pl(12,22,o.lamp); p.Pl(11,23,o.lamp); p.Pl(12,23,o.lamp); }
  p.put(pxRect(pxM(),16,19,19,21),sk,{line:false});
  // the head: hair behind first, then the skull, then what covers it
  if(o.head==='long'){
    p.put(pxEll(pxM(),6,2,29,22),hr); p.put(pxSeg(pxM(),10,15,6.5,29,2.3),hr);
    p.P(8,19,C.acc); p.P(9,19,C.acc); p.P(8,20,C.acc);
  }
  skull=pxEll(pxM(),9,3,26,18); p.put(skull,sk);
  if(o.head==='hood'){
    ml=pxEll(pxM(),6,0,29,21); op=pxRR(pxM(),11,8,24,19,3.2);
    for(y=0;y<PXB.H*W;y++) if(op[y]) ml[y]=0;
    p.put(pxRR(pxM(),7,19,28,24,2),C.coat);
    p.put(ml,C.coat,{lx:-0.75,ly:-0.66,b1:0.24,b2:0.56,b3:0.82});
    mk=pxRR(pxM(),11,15,24,19,2); p.put(mk,[C.coat[0],C.coat[0],C.coat[1],C.coat[2]],{line:false});
    p.Pl(12,3,C.coat[0]); p.Pl(13,3,C.coat[0]); p.Pl(11,4,C.coat[0]);
  } else {
    ml=pxM(); for(y=3;y<=8;y++) for(x=9;x<=26;x++) if(skull[y*W+x]) ml[y*W+x]=1;
    pxRect(ml,9,9,10,o.head==='long'?18:11); pxRect(ml,25,9,26,o.head==='long'?18:11); pxRect(ml,10,9,o.head==='long'?24:20,9);
    p.put(ml,hr,{line:false});
    p.P(17,16,sk[3]); p.P(18,16,sk[3]);
  }
  // the face: two 3 by 3 eyes, the pupils a pixel toward the aim; a bot has red eyes and angry brows
  function eye(ex){
    var px=ex+1+dxp, yy, xx;
    for(yy=11;yy<=13;yy++) for(xx=ex;xx<=ex+2;xx++) p.P(xx,yy,yy===11?E.lid:E.white);
    if(bot){ p.P(px,12,E.red); p.P(px,13,E.redDeep); } else { p.P(px,12,E.iris); p.P(px,13,E.ink); }
  }
  eye(12); eye(21);
  if(bot){ p.P(11,10,E.brow); p.P(12,10,E.brow); p.P(13,11,E.brow); p.P(14,11,E.brow); p.P(24,10,E.brow); p.P(23,10,E.brow); p.P(22,11,E.brow); p.P(21,11,E.brow); p.P(13,10,E.brow); p.P(22,10,E.brow); }
  return p.sprite();
}
'@

SubRx @'
function pxBuildLegs(o){
  var p=pxPaint(o.mir), C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), B=PXB_BOOT, kind=o.kind, ph, amp=0, sw=0, lA=0, lB=0, k;
  if(kind==='w'||kind==='r'){
    ph=((o.fr|0)+0.5)/6*6.28318; amp=(kind==='r')?5:3.4; k=(kind==='r')?3.4:2.2;
    sw=Math.sin(ph)*amp; lA=Math.max(0,Math.sin(ph))*k; lB=Math.max(0,-Math.sin(ph))*k;
  }
  function leg(cx,su,sl,lift,toe){
    var bt=45-lift;
    p.put(pxRR(pxM(),cx-2+su,37,cx+2+su,bt,1),C.trs);
    p.put(pxRR(pxM(),cx+(toe>0?-2:-4)+sl,bt,cx+(toe>0?4:2)+sl,bt+4,1.6),B);
  }
  if(kind==='c'){
    p.put(pxRR(pxM(),10,39,25,44,2),C.trs,{line:false});
    p.put(pxRR(pxM(),11,42,16,46,1),C.trs); p.put(pxRR(pxM(),19,42,24,46,1),C.trs);
    p.put(pxRR(pxM(),8,45,15,49,1.6),B); p.put(pxRR(pxM(),20,45,27,49,1.6),B);
    p.P(14,46,B[0]); p.P(26,46,B[0]);
  } else {
    p.put(pxRR(pxM(),11,33,24,40,2),C.trs,{line:false});
    leg(14,Math.round(-sw*0.45),Math.round(-sw*0.9),Math.round(lB),-1); leg(21,Math.round(sw*0.45),Math.round(sw*0.9),Math.round(lA),1);
  }
  return p.sprite();
}
'@ @'
// v28.xx (cw-cx-pixheight): hips follow the longer torso; add two rows to the lower legs and keep every sole on the entity anchor.
function pxBuildLegs(o){
  var p=pxPaint(o.mir), C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), B=PXB_BOOT, kind=o.kind, ph, amp=0, sw=0, lA=0, lB=0, k;
  if(kind==='w'||kind==='r'){
    ph=((o.fr|0)+0.5)/6*6.28318; amp=(kind==='r')?5:3.4; k=(kind==='r')?3.4:2.2;
    sw=Math.sin(ph)*amp; lA=Math.max(0,Math.sin(ph))*k; lB=Math.max(0,-Math.sin(ph))*k;
  }
  function leg(cx,su,sl,lift,toe){
    var bt=49-lift;
    p.put(pxRR(pxM(),cx-2+su,39,cx+2+su,bt,1),C.trs);
    p.put(pxRR(pxM(),cx+(toe>0?-2:-4)+sl,bt,cx+(toe>0?4:2)+sl,bt+4,1.6),B);
  }
  if(kind==='c'){
    p.put(pxRR(pxM(),10,43,25,48,2),C.trs,{line:false});
    p.put(pxRR(pxM(),11,46,16,50,1),C.trs); p.put(pxRR(pxM(),19,46,24,50,1),C.trs);
    p.put(pxRR(pxM(),8,49,15,53,1.6),B); p.put(pxRR(pxM(),20,49,27,53,1.6),B);
    p.P(14,50,B[0]); p.P(26,50,B[0]);
  } else {
    p.put(pxRR(pxM(),11,35,24,42,2),C.trs,{line:false});
    leg(14,Math.round(-sw*0.45),Math.round(-sw*0.9),Math.round(lB),-1); leg(21,Math.round(sw*0.45),Math.round(sw*0.9),Math.round(lA),1);
  }
  return p.sprite();
}
'@

SubRx @'
function pxBuildRoll(o){
  var p=pxPaint(o.mir), C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair, a=(o.fr|0)*1.5708+0.7854, c=Math.cos(a), s=Math.sin(a), t, hx, hy, bx, by, kx, ky;
  p.put(pxEll(pxM(),10,34,25,49),C.coat);
  for(t=a+0.9;t<=a+2.6;t+=0.1) p.P(Math.round(17.5+Math.cos(t)*6.4),Math.round(41.5+Math.sin(t)*6.4),C.gear[1]);
  kx=Math.cos(a+1.5708); ky=Math.sin(a+1.5708); p.put(pxRR(pxM(),Math.round(17.5+kx*5)-2,Math.round(41.5+ky*5)-2,Math.round(17.5+kx*5)+1,Math.round(41.5+ky*5)+1,1),C.pack);
  hx=Math.round(17.5+c*5.2); hy=Math.round(41.5+s*5.2); p.put(pxEll(pxM(),hx-2,hy-2,hx+2,hy+2),sk);
  bx=Math.round(17.5-c*5.8); by=Math.round(41.5-s*5.8); p.put(pxRR(pxM(),bx-1,by-1,bx+1,by+1,0.8),PXB_BOOT);
  return p.sprite();
}
'@ @'
// v28.xx (cw-cx-pixheight): the roll follows the four-row foot-anchor change, with the same four poses and timing.
function pxBuildRoll(o){
  var p=pxPaint(o.mir), C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair, a=(o.fr|0)*1.5708+0.7854, c=Math.cos(a), s=Math.sin(a), t, hx, hy, bx, by, kx, ky;
  p.put(pxEll(pxM(),10,38,25,53),C.coat);
  for(t=a+0.9;t<=a+2.6;t+=0.1) p.P(Math.round(17.5+Math.cos(t)*6.4),Math.round(45.5+Math.sin(t)*6.4),C.gear[1]);
  kx=Math.cos(a+1.5708); ky=Math.sin(a+1.5708); p.put(pxRR(pxM(),Math.round(17.5+kx*5)-2,Math.round(45.5+ky*5)-2,Math.round(17.5+kx*5)+1,Math.round(45.5+ky*5)+1,1),C.pack);
  hx=Math.round(17.5+c*5.2); hy=Math.round(45.5+s*5.2); p.put(pxEll(pxM(),hx-2,hy-2,hx+2,hy+2),sk);
  bx=Math.round(17.5-c*5.8); by=Math.round(45.5-s*5.8); p.put(pxRR(pxM(),bx-1,by-1,bx+1,by+1,0.8),PXB_BOOT);
  return p.sprite();
}
'@

SubRx @'
var VER='33.73';
'@ @'
var VER='33.74';
'@

$pat = "(?m)^  now:'v33\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.74: Plain pillagers stand 53 to 57 art pixels tall through their two breath frames. The torso and legs are redrawn four rows taller, with packs, sleeves, crouch and roll following the planted foot point. Check 33.74 fails on v33.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
