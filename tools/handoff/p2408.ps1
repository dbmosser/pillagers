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

# A PLATE CARRIER, NOT STRIPES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawBuildTorso(b,cx,ty,cc,cHi,cLo,trs,jc,jh,lx,lA,lB,legc){   // v20.06: trs fills the hips, legc the legs below them
  var P=(b==='broad')?BUILD_BROAD:BUILD_CURVED, by, sh, bl;
  if(b==='curved'&&jh){ BUILD_CPT[4][1]=BUILD_CURVED[4][1]+jh*.6; BUILD_CPT[5][1]=BUILD_CURVED[5][1]+jh*.4; P=BUILD_CPT; }   // v20.02: the hips ride the spring
  buildPath(cx,ty,P,1); wc.fillStyle=INK; wc.fill();
  buildPath(cx,ty,P,0); wc.save(); wc.clip();
  wc.fillStyle=cc; wc.fillRect(cx-11,ty-25,22,17);
  wc.fillStyle=cHi; wc.fillRect(cx-11,ty-24,22,(b==='broad')?3.4:2.6);
  if(b==='broad'){
    wc.fillStyle=cLo; wc.fillRect(cx-11,ty-13.2,22,3.4);
  } else {
    wc.fillStyle=trs; wc.fillRect(cx-11,ty-14.4,22,7);                       // trousers from the waist down
    by=ty-18.0+(jc||0); sh=darkHex(cc,.40); bl=litHex(cc,.28,true);
    wc.fillStyle=sh;                                                         // the shadow under the chest
    wc.beginPath(); wc.ellipse(cx-2.8,by+1.0,2.95,2.4,0,0,6.2832); wc.ellipse(cx+2.8,by+1.0,2.95,2.4,0,0,6.2832); wc.fill();
    wc.fillStyle=bl;                                                         // and the chest, lit from above
    wc.beginPath(); wc.ellipse(cx-2.8,by,2.8,2.25,0,0,6.2832); wc.ellipse(cx+2.8,by,2.8,2.25,0,0,6.2832); wc.fill();
    wc.fillStyle=cHi; wc.fillRect(cx-4.3,by-1.6,1.5,.9); wc.fillRect(cx+1.4,by-1.6,1.5,.9);
    wc.fillStyle=cLo; wc.fillRect(cx-11,ty-15.2,22,1.0);                    // a belt at the waist
'@ @'
function drawBuildTorso(b,cx,ty,cc,cHi,cLo,trs,jc,jh,lx,lA,lB,legc,pc){   // v20.06: trs fills the hips, legc the legs below them
  var P=(b==='broad')?BUILD_BROAD:BUILD_CURVED, by, sh, bl;
  if(b==='curved'&&jh){ BUILD_CPT[4][1]=BUILD_CURVED[4][1]+jh*.6; BUILD_CPT[5][1]=BUILD_CURVED[5][1]+jh*.4; P=BUILD_CPT; }   // v20.02: the hips ride the spring
  buildPath(cx,ty,P,1); wc.fillStyle=INK; wc.fill();
  buildPath(cx,ty,P,0); wc.save(); wc.clip();
  wc.fillStyle=cc; wc.fillRect(cx-11,ty-25,22,17);
  if(!pc){ wc.fillStyle=cHi; wc.fillRect(cx-11,ty-24,22,(b==='broad')?3.4:2.6); }   // v23.xx (spr15): a plate carrier body is lit by drawRigPC
  if(b==='broad'){
    if(!pc){ wc.fillStyle=cLo; wc.fillRect(cx-11,ty-13.2,22,3.4); }
  } else {
    wc.fillStyle=trs; wc.fillRect(cx-11,ty-14.4,22,7);                       // trousers from the waist down
    by=ty-18.0+(jc||0); sh=darkHex(cc,.40); bl=litHex(cc,.28,true);
    wc.fillStyle=sh;                                                         // the shadow under the chest
    wc.beginPath(); wc.ellipse(cx-2.8,by+1.0,2.95,2.4,0,0,6.2832); wc.ellipse(cx+2.8,by+1.0,2.95,2.4,0,0,6.2832); wc.fill();
    wc.fillStyle=bl;                                                         // and the chest, lit from above
    wc.beginPath(); wc.ellipse(cx-2.8,by,2.8,2.25,0,0,6.2832); wc.ellipse(cx+2.8,by,2.8,2.25,0,0,6.2832); wc.fill();
    wc.fillStyle=cHi; wc.fillRect(cx-4.3,by-1.6,1.5,.9); wc.fillRect(cx+1.4,by-1.6,1.5,.9);
    if(!pc){ wc.fillStyle=cLo; wc.fillRect(cx-11,ty-15.2,22,1.0); }                    // a belt at the waist
'@

SubRx @'
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@ @'
// v23.xx (spr15), HIS ORDER (2026-10-12): "improve the sprites of all characters, bots, etc -- spend time on that -- make them all
// look better", answer 20 "a" (gritty and grounded like ARC Raiders). THE PLATE CARRIER, NOT STRIPES. A body wore its rig as two
// horizontal dark bands across the coat, a lit band over the shoulders and a dark one at the waist, so every coat read as a striped
// jersey (and the Peddler's amber as a bumblebee). Now the coat is cloth lit from the top left (the light every sprite shares): the
// tops of the shoulders and the left side catch it, the right side is in shade. Over it sits a plate carrier: a chest plate in a
// darker cut of the coat, two shoulder straps, three magazine pouches in olive webbing, and a belt with a buckle. Curved wears it cut
// to her outline: the plate is moulded over her chest (riding the same spring, v20.02) and her pouches ride on the hips. Suits
// (OUTFITS) and the number 23 jersey keep their own paint exactly as before. Cosmetic only: no random numbers, nothing a fight reads.
var RIG_OLIVE=['#33331f','#4a4a32','#6e6e4e'], RIG_BELT='#24201a', RIG_BUCKLE='#a8996a';
function torsoPathPC(b,cx,ty,jh){
  if(b==='broad') buildPath(cx,ty,BUILD_BROAD,0);
  else if(b==='curved') buildPath(cx,ty,jh?BUILD_CPT:BUILD_CURVED,0);
  else { wc.beginPath(); if(HAS_RR) wc.roundRect(cx-6.5,ty-22,13,11,3); else wc.rect(cx-6.5,ty-22,13,11); }
}
function rigPouch(px,py,pw,ph){
  wc.fillStyle=RIG_OLIVE[0]; wc.fillRect(px,py,pw,ph);
  wc.fillStyle=RIG_OLIVE[1]; wc.fillRect(px,py,pw-0.5,ph-0.5);
  wc.fillStyle=RIG_OLIVE[2]; wc.fillRect(px,py,pw-0.5,0.7);
}
function drawRigPC(b,cx,ty,cc,jc,jh){
  var cHi=litHex(cc,.24,true), cLo=darkHex(cc,.40), rg=darkHex(cc,.30), rgHi=litHex(rg,.14), rgLo=darkHex(cc,.56),
      top=(b==='broad')?-23.8:(b==='curved'?-23.4:-22), low=(b==='curved')?-14.6:-12, i, x0, R;
  wc.save(); torsoPathPC(b,cx,ty,jh); wc.clip();
  // the cloth: lit across the tops of the shoulders and down the left side, in shade down the right
  wc.fillStyle=cHi; wc.fillRect(cx-12,ty+top-2,24,3.3);
  wc.save(); wc.beginPath(); wc.rect(cx-14,ty-28,13.6,28+low); wc.clip(); torsoPathPC(b,cx,ty,jh); wc.lineWidth=3; wc.strokeStyle=cHi; wc.stroke(); wc.restore();
  wc.save(); wc.beginPath(); wc.rect(cx+0.6,ty+top+1.4,14,low-top-1.4); wc.clip(); torsoPathPC(b,cx,ty,jh); wc.lineWidth=4; wc.strokeStyle=cLo; wc.stroke(); wc.restore();
  if(b==='curved'){
    var by=ty-18.0+(jc||0);
    wc.fillStyle=rg; wc.fillRect(cx-4.9,ty-26,1.5,6); wc.fillRect(cx+3.4,ty-26,1.5,6);   // the straps
    wc.fillStyle=rgLo; wc.fillRect(cx-6.5,ty-21.1,13,6.0);                               // the plate, moulded over her chest
    wc.fillStyle=rg; wc.fillRect(cx-6.0,ty-20.6,11.4,4.9);
    wc.fillStyle=rgLo; wc.beginPath(); wc.ellipse(cx-2.8,by+1.0,2.95,2.4,0,0,6.2832); wc.ellipse(cx+2.8,by+1.0,2.95,2.4,0,0,6.2832); wc.fill();
    wc.fillStyle=litHex(rg,.22); wc.beginPath(); wc.ellipse(cx-2.8,by,2.8,2.25,0,0,6.2832); wc.ellipse(cx+2.8,by,2.8,2.25,0,0,6.2832); wc.fill();
    wc.fillStyle=litHex(rg,.42); wc.fillRect(cx-4.3,by-1.6,1.5,.9); wc.fillRect(cx+1.4,by-1.6,1.5,.9);
    wc.fillStyle=RIG_BELT; wc.fillRect(cx-12,ty-15.5,24,1.3);                            // the belt at her waist
    wc.fillStyle=RIG_BUCKLE; wc.fillRect(cx-0.8,ty-15.5,1.6,1.3);
    rigPouch(cx-6.0,ty-14.2,2.6,2.8); rigPouch(cx+3.4,ty-14.2,2.6,2.8);                 // and the pouches on her hips
  } else {
    R=(b==='broad')?{w:12.4,y:-20.6,h:7.4,sx:-5.6,sx2:3.6,sw:2,pw:3.2,py:-16.8,ph:3.2,by:-12.6,bh:1.6}
                   :{w:9.4,y:-20.2,h:6.8,sx:-4.4,sx2:2.8,sw:1.6,pw:2.6,py:-16.6,ph:3,by:-13.0,bh:1.4};
    wc.fillStyle=rg; wc.fillRect(cx+R.sx,ty-26,R.sw,26+R.y); wc.fillRect(cx+R.sx2,ty-26,R.sw,26+R.y);   // the straps
    wc.fillStyle=rgLo; wc.fillRect(cx-R.w/2-0.5,ty+R.y-0.5,R.w+1,R.h+1);                                          // the plate
    wc.fillStyle=rg; wc.fillRect(cx-R.w/2,ty+R.y,R.w-0.6,R.h-0.6);
    wc.fillStyle=rgHi; wc.fillRect(cx-R.w/2,ty+R.y,R.w-0.6,0.7); wc.fillRect(cx-R.w/2,ty+R.y,0.6,R.h-0.6);
    x0=cx-(3*R.pw+0.8)/2;
    for(i=0;i<3;i++) rigPouch(x0+i*(R.pw+0.4),ty+R.py,R.pw,R.ph);                                    // three magazine pouches
    wc.fillStyle=RIG_BELT; wc.fillRect(cx-12,ty+R.by,24,R.bh);                                         // the belt
    wc.fillStyle=RIG_BUCKLE; wc.fillRect(cx-0.8,ty+R.by,1.6,R.bh);
  }
  wc.restore();
}
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@

SubRx @'
  wc.fillStyle=_TRS;
  rrF(x-6.3+swing2*.5,ty-11,4.6,7.5-liftB*.5,1);
  rrF(x+1.7+swing*.5,ty-11,4.6,7.5-liftA*.5,1);
'@ @'
  wc.fillStyle=_TRS;
  rrF(x-6.3+swing2*.5,ty-11,4.6,7.5-liftB*.5,1);
  rrF(x+1.7+swing*.5,ty-11,4.6,7.5-liftA*.5,1);
  var _PC=!OUTF&&!(st.hero&&cosWorn('fit')==='jersey');   // v23.xx (spr15): the plate carrier and the lit cloth; suits and the jersey keep their own paint
  if(_PC&&/^#[0-9a-fA-F]{6}$/.test(_TRS)){
    wc.fillStyle=litHex(_TRS,.16); wc.fillRect(x-6.3+swing2*.5,ty-10.6,0.9,4.4-liftB*.5); wc.fillRect(x+1.7+swing*.5,ty-10.6,0.9,4.4-liftA*.5);
    wc.fillStyle=darkHex(_TRS,.32); wc.fillRect(x-2.7+swing2*.5,ty-10.6,1.0,4.4-liftB*.5); wc.fillRect(x+5.3+swing*.5,ty-10.6,1.0,4.4-liftA*.5);
  }
'@

SubRx @'
    rrF(x-6.7+swing2,ty-1.7-liftB,5.8,1.7,.6); rrF(x+.9+swing,ty-1.7-liftA,5.8,1.7,.6);
  }
'@ @'
    rrF(x-6.7+swing2,ty-1.7-liftB,5.8,1.7,.6); rrF(x+.9+swing,ty-1.7-liftA,5.8,1.7,.6);
  }
  else if(_PC){   // v23.xx (spr15): a lit toe cap on each boot, toward the facing
    var _toe=(fl>0)?3.0:0.2;
    wc.fillStyle=litHex(_BT[0],.30); wc.fillRect(x-6.5+swing2+_toe,ty-4.2-liftB,2.2,1.0);
    wc.fillStyle=litHex(_BT[1],.30); wc.fillRect(x+1.1+swing+_toe,ty-4.2-liftA,2.2,1.0);
  }
'@

SubRx @'
  if(!_BLD){
  wc.fillStyle=INK; rrF(x-7.5+leanX,ty-23,15,13,4);
  wc.fillStyle=cc; rrF(x-6.5+leanX,ty-22,13,11,3);
  wc.fillStyle=cHi; wc.fillRect(x-5.7+leanX,ty-22,11.4,3);
  wc.fillStyle=cLo; wc.fillRect(x-5.7+leanX,ty-13.4,11.4,2.4);
  } else drawBuildTorso(_BLD,x+leanX,ty,cc,cHi,cLo,(OUTF&&!OUTF.trs)?darkHex(cc,.62):_TRS,_JG.c,_JG.h,x,swing*.5,swing2*.5,_TRS);   /* v20.06: a bare-legged suit wears shorts on the hips */   // v20.01: Broad and Curved draw their own body
  // v11.06, HIS NOTE 20: the jersey used to be painted HERE, before the chest
  // rig, so the rig's near-black band was laid across the lower half of the
  // numeral. It goes on after the rig now, a dozen lines down.
  // chest rig, and a hit shimmer when recently hurt
  wc.fillStyle='rgba(16,21,27,.85)';
  if(_BLD==='broad') wc.fillRect(x-8.2+leanX,ty-18,16.4,2.4); else if(!_BLD) wc.fillRect(x-6.5+leanX,ty-18,13,2.4);   // v20.01: wider on Broad; Curved wears a belt instead
'@ @'
  if(!_BLD){
  wc.fillStyle=INK; rrF(x-7.5+leanX,ty-23,15,13,4);
  wc.fillStyle=cc; rrF(x-6.5+leanX,ty-22,13,11,3);
  if(!_PC){   // v23.xx (spr15): a plate carrier body is lit by drawRigPC instead of these bands
  wc.fillStyle=cHi; wc.fillRect(x-5.7+leanX,ty-22,11.4,3);
  wc.fillStyle=cLo; wc.fillRect(x-5.7+leanX,ty-13.4,11.4,2.4);
  }
  } else drawBuildTorso(_BLD,x+leanX,ty,cc,cHi,cLo,(OUTF&&!OUTF.trs)?darkHex(cc,.62):_TRS,_JG.c,_JG.h,x,swing*.5,swing2*.5,_TRS,_PC);   /* v20.06: a bare-legged suit wears shorts on the hips */   // v20.01: Broad and Curved draw their own body
  // v11.06, HIS NOTE 20: the jersey used to be painted HERE, before the chest
  // rig, so the rig's near-black band was laid across the lower half of the
  // numeral. It goes on after the rig now, a dozen lines down.
  // chest rig, and a hit shimmer when recently hurt
  if(_PC) drawRigPC(_BLD||'lean',x+leanX,ty,cc,_JG.c,_JG.h);   // v23.xx (spr15): the plate carrier, not stripes
  else {
  wc.fillStyle='rgba(16,21,27,.85)';
  if(_BLD==='broad') wc.fillRect(x-8.2+leanX,ty-18,16.4,2.4); else if(!_BLD) wc.fillRect(x-6.5+leanX,ty-18,13,2.4);   // v20.01: wider on Broad; Curved wears a belt instead
  }
'@

SubRx @'
  wc.fillStyle=coat; if(_BLD==='broad') wc.fillRect(1+ext,-2.9,6,5.8); else if(_BLD==='curved') wc.fillRect(1+ext,-2.0,6,4.0); else wc.fillRect(1+ext,-2.4,6,4.8);   // v20.10: a thicker arm on Broad, a slimmer one on Curved
'@ @'
  wc.fillStyle=coat; if(_BLD==='broad') wc.fillRect(1+ext,-2.9,6,5.8); else if(_BLD==='curved') wc.fillRect(1+ext,-2.0,6,4.0); else wc.fillRect(1+ext,-2.4,6,4.8);   // v20.10: a thicker arm on Broad, a slimmer one on Curved
  if(_PC&&/^#[0-9a-fA-F]{6}$/.test(coat)){ var _ah=(_BLD==='broad')?2.9:(_BLD==='curved'?2.0:2.4); wc.fillStyle=litHex(coat,.22,true); wc.fillRect(1+ext,(Math.cos(face)>=0)?-_ah:_ah-0.9,6,0.9); }   // v23.xx (spr15): the sleeve, lit on its upper edge
'@

SubRx @'
var VER='24.07';
'@ @'
var VER='24.08';
'@

$pat = "(?m)^  now:'v24\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.08: Every pillager, hire, teammate and you now wear a plate carrier with pouches and a belt, and the cloth is lit from one side. Check 24.08 fails on v24.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
