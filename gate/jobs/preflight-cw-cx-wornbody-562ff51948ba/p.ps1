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

# WORN GEAR ON THE PILLAGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawOpBody(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@ @'
// v28.xx (cw-cx-wornbody): answers 76, 77 and 78. Equipment owns its six visible slots; body choices stay saved. Render dice never touch the raid.
var WORN_DRAW=null;
var WORN_BODY_SLOTS=['head','armor','pants','boots','gloves','pack'];
var WORN_BODY_COL=[['#8a7157','#716b53','#775c51'],['#6e8059','#607c7a','#82764f'],['#627b96','#686e99','#537e8c'],['#9b8060','#85729c','#9b6863']];
var WORN_BODY_RAM={};
var WORN_BODY_IDS={head:['cap','tachelm','boonie'],armor:['vestplate','vestutil','vestheavy'],boots:['bootblack','bootgaiter','bootshin'],gloves:['glovetan','glovegrey','gloveblack'],pack:['packroll','packradio','packframe']};
function wornBodyLook(st){
  if(!st||!st.hero||(typeof G!=='undefined'&&G&&G.sim)||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) return null;
  var out={g:{},ids:{hat:'none',outfit:'outnone',fit:'slate',scheme:'schslate',vest:'vestplate',boots:'bootblack',gloves:'barehands',pack:'packbrown',pads:'padsnone',patch:'patchnone'},key:'worn'},s,pc,i,r,v,col;
  for(i=0;i<WORN_BODY_SLOTS.length;i++){
    s=WORN_BODY_SLOTS[i]; pc=P&&P.worn&&P.worn[s];
    if(!pc||pc.k!==s||!(pc.r>=0&&pc.r<=3)||pc.r%1) continue;
    r=pc.r|0; v=Math.abs(pc.pw|0)%3; col=WORN_BODY_COL[r][v];
    out.g[s]={r:r,v:v,col:col,ram:WORN_BODY_RAM[col]||(WORN_BODY_RAM[col]=pixRamp(col))};
    out.key+='|'+s+':'+r+':'+v;
    if(WORN_BODY_IDS[s]) out.ids[s==='head'?'hat':(s==='armor'?'vest':s)]=WORN_BODY_IDS[s][v];
  }
  return out;
}
function wornBodyChoice(kind){ return WORN_DRAW&&Object.prototype.hasOwnProperty.call(WORN_DRAW.ids,kind)?WORN_DRAW.ids[kind]:null; }
function wornBodyAllowed(kind){ return ['build','skin','eyes','face','tattoo','hair','cut','beard'].indexOf(kind)>=0; }
function wornBodyRamp(base){
  if(!WORN_DRAW) return base;
  var c={},k,g=WORN_DRAW.g;
  for(k in base)c[k]=base[k];
  if(g.armor){c.coat=g.armor.ram;c.gear=g.armor.ram;}
  if(g.pants)c.trs=g.pants.ram;
  if(g.pack)c.pack=g.pack.ram;
  return c;
}
function wornPxPack(p){
  var a=WORN_DRAW.g.pack;if(!a)return;
  var v=a.v,R=a.ram;
  p.put(pxRR(pxM(),v===2?1:3,v===0?25:21,10,40,1),R);
  p.put(pxRect(pxM(),4,26,9,28),R);
  if(v===0){p.put(pxRR(pxM(),1,22,11,26,1),R);p.put(pxRect(pxM(),4,32,9,34),R);}
  if(v===1){p.put(pxRect(pxM(),4,13,4,21),R);p.P(4,12,R[0]);p.P(6,31,R[0]);p.P(8,31,R[0]);}
  if(v===2){p.put(pxRect(pxM(),1,19,2,42),R);p.put(pxRect(pxM(),1,40,10,42),R);}
  p.P(6,29,WORN_RARS[a.r].c);
}
function wornPxArmor(p){
  var a=WORN_DRAW.g.armor;if(!a)return;
  var v=a.v,R=a.ram;
  p.put(pxRR(pxM(),11,23,24,34,1),R);
  p.put(pxRect(pxM(),13,24,22,25),R);
  if(v===1){p.put(pxRR(pxM(),10,29,15,34,1),R);p.put(pxRR(pxM(),20,29,25,34,1),R);}
  if(v===2){p.put(pxRR(pxM(),7,21,11,26,1),R);p.put(pxRR(pxM(),24,21,28,26,1),R);}
  if(a.r>0)p.put(pxRect(pxM(),15,21,20,22),R);
  p.P(17,26,WORN_RARS[a.r].c);p.P(18,26,WORN_RARS[a.r].c);
}
function wornPxHead(p){
  var a=WORN_DRAW.g.head;if(!a)return;
  var v=a.v,R=a.ram;
  p.put(pxRR(pxM(),10,2,25,7,2),R);
  if(v===0)p.put(pxRect(pxM(),9,7,27,8),R);
  if(v===1){p.put(pxRR(pxM(),8,4,11,11,1),R);p.put(pxRR(pxM(),24,4,27,11,1),R);}
  if(v===2)p.put(pxRR(pxM(),6,6,29,8,1),R);
  p.P(17,4,WORN_RARS[a.r].c);p.P(18,4,WORN_RARS[a.r].c);
}
function wornPxLeg(p,cx,su,sl,bt,toe){
  var a=WORN_DRAW&&WORN_DRAW.g.pants,b=WORN_DRAW&&WORN_DRAW.g.boots,R,v;
  if(a){R=a.ram;v=a.v;
    if(v===0)p.put(pxRect(pxM(),cx-2+su,41,cx+2+su,43),R);
    if(v===1)p.put(pxRR(pxM(),cx-3+su,41,cx+3+su,44,1),R);
    if(v===2)p.put(pxRR(pxM(),cx-2+su,44,cx+2+su,47,1),R);
    p.P(cx+su,42,WORN_RARS[a.r].c);
  }
  if(b){R=b.ram;v=b.v;
    if(v>0)p.put(pxRR(pxM(),cx-2+sl,bt-(v===1?3:5),cx+2+sl,bt,1),R);
    p.P(cx+sl+(toe>0?2:-2),bt+1,WORN_RARS[b.r].c);
    if(v===2)p.P(cx+sl,bt-3,R[0]);
  }
}
function wornPxRoll(o){
  var s=pixCanvas(64,64),lg=pxBuildLegs({clothes:o.clothes,bot:0,mir:o.mir,kind:'c',fr:0}),up=pxBuildUpper({head:o.head,skin:o.skin,clothes:o.clothes,bot:0,mir:o.mir,pup:0,arms:1,band:o.band||''});
  s.x.imageSmoothingEnabled=false;s.x.translate(32,39);s.x.rotate((o.fr|0)*Math.PI/2);s.x.scale(.55,.55);
  s.x.drawImage(lg.c,-lg.ax,-lg.ay+24);s.x.drawImage(up.c,-up.ax,-up.ay+24);pixHarden(s,128);
  return pixSprite(pixRing(s.c,PIX_INK).c,33,64,PIX_ACT);
}
function drawOpBody(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  var prev=WORN_DRAW;WORN_DRAW=wornBodyLook(st);
  if(WORN_DRAW&&st){var body={};for(var q in st)body[q]=st[q];body.bulk=0;st=body;}
  try{return drawOpBodyWorn(x,y,face,ph,coat,pk,muzzle,mode,iv,st);}finally{WORN_DRAW=prev;}
}
function drawOpBodyWorn(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@

SubRx @'
function cosWorn(kind){
'@ @'
function cosWorn(kind){
  var gearChoice=wornBodyChoice(kind);if(gearChoice!==null)return gearChoice; // v28.xx (cw-cx-wornbody): scoped to this body render only
'@

SubRx @'
  var _SCH=schemeOf(st);
'@ @'
  var _SCH=schemeOf(st);if(WORN_DRAW)_SCH=null; // v28.xx (cw-cx-wornbody)
'@

SubRx @'
  var OUTF=outfitOf(st);   // v10.54: an outfit overrules the racks below
'@ @'
  var OUTF=outfitOf(st);if(WORN_DRAW)OUTF=null; // v28.xx (cw-cx-wornbody): no wardrobe over gear
'@

SubRx @'
  var cc=iv>0?'#2a6a5e':(OUTF?OUTF.coat:(_SCH?_SCH.p:(st.hero?((FITCOL[cosWorn('fit')]||FITCOL.slate)[1]):coat))),cLo=darkHex(cc,.42),cHi=litHex(cc,.20,true);
'@ @'
  var cc=iv>0?'#2a6a5e':(OUTF?OUTF.coat:(_SCH?_SCH.p:(st.hero?((FITCOL[cosWorn('fit')]||FITCOL.slate)[1]):coat))),cLo=darkHex(cc,.42),cHi=litHex(cc,.20,true);
  if(WORN_DRAW&&WORN_DRAW.g.armor&&iv<=0){cc=WORN_DRAW.g.armor.col;cLo=darkHex(cc,.42);cHi=litHex(cc,.20,true);coat=cc;} // v28.xx (cw-cx-wornbody)
'@

SubRx @'
  var _BT=OUTF?OUTF.boots:(BOOTCOL[_BTID]||BOOTCOL.bootblack);   // v10.54
'@ @'
  var _BT=OUTF?OUTF.boots:(BOOTCOL[_BTID]||BOOTCOL.bootblack);   // v10.54
  if(WORN_DRAW&&WORN_DRAW.g.boots)_BT=[WORN_DRAW.g.boots.ram[2],WORN_DRAW.g.boots.col]; // v28.xx (cw-cx-wornbody)
'@

SubRx @'
  var _TRS=OUTF?(OUTF.trs||(OUTF.skin||(st.hero?(SKINCOL[cosWorn('skin')]||SKINCOL.fair):(SKINCOL[st.skin]||'#f2d2a8')))):(_SCH?_SCH.trs:darkHex(cc,.50));
'@ @'
  var _TRS=OUTF?(OUTF.trs||(OUTF.skin||(st.hero?(SKINCOL[cosWorn('skin')]||SKINCOL.fair):(SKINCOL[st.skin]||'#f2d2a8')))):(_SCH?_SCH.trs:darkHex(cc,.50));
  if(WORN_DRAW&&WORN_DRAW.g.pants)_TRS=WORN_DRAW.g.pants.col; // v28.xx (cw-cx-wornbody)
'@

SubRx @'
  if(!(OUTF&&OUTF.nopack)){
'@ @'
  if(!(OUTF&&OUTF.nopack)&&(!WORN_DRAW||WORN_DRAW.g.pack)){ // v28.xx (cw-cx-wornbody): no worn pack, no pack look
'@

SubRx @'
  var _PKC=PACKCOL[_PKID]||PACKCOL.packbrown;   // v10.34
'@ @'
  var _PKC=WORN_DRAW&&WORN_DRAW.g.pack?WORN_DRAW.g.pack.col:(PACKCOL[_PKID]||PACKCOL.packbrown); // v28.xx (cw-cx-wornbody)
'@

SubRx @'
  wc.restore();   // v33.xx (cw-headbody), job 68, his a01 D: the scaled head ends with the hair, face and hats; the suit body paint, caps and pads below draw at body scale (pads at their own FIG_VEST, his a05 B)
'@ @'
  // v28.xx (cw-cx-wornbody): the hat crown carries its piece palette and a small rarity tab, without hiding the eyes.
  if(WORN_DRAW&&WORN_DRAW.g.head){var hg=WORN_DRAW.g.head;wc.fillStyle=hg.col;rrF(hx2-6,ty-39.5,12,2.8,1);wc.fillStyle=WORN_RARS[hg.r].c;wc.fillRect(hx2-1,ty-38.7,2,1);}
  wc.restore();   // v33.xx (cw-headbody), job 68, his a01 D: the scaled head ends with the hair, face and hats; the suit body paint, caps and pads below draw at body scale (pads at their own FIG_VEST, his a05 B)
'@

SubRx @'
function handColour(st){
'@ @'
function handColour(st){
  if(st&&st.hero&&WORN_DRAW&&WORN_DRAW.g.gloves)return WORN_DRAW.g.gloves.col; // v28.xx (cw-cx-wornbody)
'@

SubRx @'
  oid=hero?P.cosOutfit:st.outfit; // v28.xx (cw-cx-pixsets): read saved picks without the old rack ownership filter
'@ @'
  oid=WORN_DRAW?'outnone':(hero?P.cosOutfit:st.outfit); // v28.xx (cw-cx-wornbody)
'@

SubRx @'
  r=pixLook(lk);
'@ @'
  if(WORN_DRAW){lk.hat='none';lk.outfit='outnone';lk.scheme='schsand';lk.fit='slate';} // v28.xx (cw-cx-wornbody)
  r=pixLook(lk);
'@

SubRx @'
function pxUpper(o){
  var fam='u|'+o.head+'|'+o.skin+'|'+o.clothes+'|'+o.bot+'|'+o.mir;
'@ @'
function pxUpper(o){
  var fam='u|'+o.head+'|'+o.skin+'|'+o.clothes+'|'+o.bot+'|'+o.mir;
  if(WORN_DRAW)fam+='|'+WORN_DRAW.key; // v28.xx (cw-cx-wornbody)
'@

SubRx @'
function pxLegs(o){
  var fam='g|'+o.clothes+'|'+o.bot+'|'+o.mir+'|'+o.kind;
'@ @'
function pxLegs(o){
  var fam='g|'+o.clothes+'|'+o.bot+'|'+o.mir+'|'+o.kind;
  if(WORN_DRAW)fam+='|'+WORN_DRAW.key; // v28.xx (cw-cx-wornbody)
'@

SubRx @'
function pxRoll(o){
  var fam='r|'+o.head+'|'+o.skin+'|'+o.clothes+'|'+o.bot+'|'+o.mir+'|'+(o.band||''); // v28.xx (cw-cx-pixsets): separate seat bands
'@ @'
function pxRoll(o){
  var fam='r|'+o.head+'|'+o.skin+'|'+o.clothes+'|'+o.bot+'|'+o.mir+'|'+(o.band||''); // v28.xx (cw-cx-pixsets): separate seat bands
  if(WORN_DRAW)fam+='|'+WORN_DRAW.key; // v28.xx (cw-cx-wornbody)
'@

SubRx @'
function pxBuildRoll(o){
'@ @'
function pxBuildRoll(o){
  if(WORN_DRAW)return wornPxRoll(o); // v28.xx (cw-cx-wornbody): roll the actual worn body
'@

SubRx @'
  var p=pxPaint(o.mir), W=PXB.W, C=o.bot?(o.bot===2?PXB_GOLD:PXB_REDS):(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=(o.bot===2)?PXB_GOLD.skin:(PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair), hr=(o.bot===2)?PXB_GOLD.hair:PXB_HAIR, E=PXB_EYE, bot=!!o.bot, dxp=o.mir?-o.pup:o.pup, cl=o.clothes, m, y, x, skull, op, belt, mk, ml;
'@ @'
  var p=pxPaint(o.mir), W=PXB.W, C=o.bot?(o.bot===2?PXB_GOLD:PXB_REDS):(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=(o.bot===2)?PXB_GOLD.skin:(PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair), hr=(o.bot===2)?PXB_GOLD.hair:PXB_HAIR, E=PXB_EYE, bot=!!o.bot, dxp=o.mir?-o.pup:o.pup, cl=o.clothes, m, y, x, skull, op, belt, mk, ml;
  C=wornBodyRamp(C); // v28.xx (cw-cx-wornbody)
'@

SubRx @'
  if(cl==='recon'){
    p.put(pxRR(pxM(),4,15,10,42,2),C.pack);
'@ @'
  if(WORN_DRAW){wornPxPack(p);} // v28.xx (cw-cx-wornbody)
  else if(cl==='recon'){
    p.put(pxRR(pxM(),4,15,10,42,2),C.pack);
'@

SubRx @'
    p.put(pxRR(pxM(),8,35,10,38,1.2),sk); p.put(pxRR(pxM(),25,35,27,38,1.2),sk);
'@ @'
    var hands=WORN_DRAW&&WORN_DRAW.g.gloves?WORN_DRAW.g.gloves.ram:sk; // v28.xx (cw-cx-wornbody)
    p.put(pxRR(pxM(),8,35,10,38,1.2),hands); p.put(pxRR(pxM(),25,35,27,38,1.2),hands);
'@

SubRx @'
  if(o.bulk>0){   // v33.81 (cw-pixgear) SPEC 9.7: the tier is the silhouette; steel, not the coat colour
'@ @'
  if(WORN_DRAW){wornPxArmor(p);} // v28.xx (cw-cx-wornbody)
  else if(o.bulk>0){   // v33.81 (cw-pixgear) SPEC 9.7: the tier is the silhouette; steel, not the coat colour
'@

SubRx @'
  eye(12); eye(21);
'@ @'
  eye(12); eye(21);
  if(WORN_DRAW)wornPxHead(p); // v28.xx (cw-cx-wornbody): headgear above hair, eyes stay clear
'@

SubRx @'
  var p=pxPaint(o.mir), C=o.bot?(o.bot===2?PXB_GOLD:PXB_REDS):(PXB_RAMP[o.clothes]||PXB_RAMP.scav), B=(o.bot===2)?PXB_GOLD.boot:PXB_BOOT, kind=o.kind, ph, amp=0, sw=0, lA=0, lB=0, k;
'@ @'
  var p=pxPaint(o.mir), C=o.bot?(o.bot===2?PXB_GOLD:PXB_REDS):(PXB_RAMP[o.clothes]||PXB_RAMP.scav), B=(o.bot===2)?PXB_GOLD.boot:PXB_BOOT, kind=o.kind, ph, amp=0, sw=0, lA=0, lB=0, k;
  C=wornBodyRamp(C);if(WORN_DRAW&&WORN_DRAW.g.boots)B=WORN_DRAW.g.boots.ram; // v28.xx (cw-cx-wornbody)
'@

SubRx @'
    p.put(pxRR(pxM(),cx+(toe>0?-2:-4)+sl,bt,cx+(toe>0?4:2)+sl,bt+4,1.6),B);
'@ @'
    p.put(pxRR(pxM(),cx+(toe>0?-2:-4)+sl,bt,cx+(toe>0?4:2)+sl,bt+4,1.6),B);
    if(WORN_DRAW)wornPxLeg(p,cx,su,sl,bt,toe); // v28.xx (cw-cx-wornbody): details follow each leg
'@

SubRx @'
    p.P(14,50,B[0]); p.P(26,50,B[0]);
'@ @'
    p.P(14,50,B[0]); p.P(26,50,B[0]);
    if(WORN_DRAW){wornPxLeg(p,13,0,-1,49,-1);wornPxLeg(p,22,0,1,49,1);} // v28.xx (cw-cx-wornbody)
'@

SubRx @'
gn=pxGun(id,fk,el,rc,step,fl,C.coat[1],sk[1],ext,low?1:0,rq);
'@ @'
gn=pxGun(id,fk,el,rc,step,fl,(WORN_DRAW&&WORN_DRAW.g.armor?WORN_DRAW.g.armor.col:C.coat[1]),(WORN_DRAW&&WORN_DRAW.g.gloves?WORN_DRAW.g.gloves.col:sk[1]),ext,low?1:0,rq);
'@

SubRx @'
  var fam='setmelee|'+lk.clothes+'|'+hand+'|'+(crow?1:0),sp=pixFetch('actors',fam+'|'+step,function(){
'@ @'
  if(WORN_DRAW&&WORN_DRAW.g.gloves)hand=WORN_DRAW.g.gloves.col; // v28.xx (cw-cx-wornbody): gloves stay on during melee
  var fam='setmelee|'+lk.clothes+'|'+hand+'|'+(crow?1:0),sp=pixFetch('actors',fam+'|'+step,function(){
'@

SubRx @'
  PIX_RACKS.forEach(function(rack){
'@ @'
  PIX_RACKS.filter(function(r){return r[0]==='head'||r[0]==='skin';}).forEach(function(rack){ // v28.xx (cw-cx-wornbody): body options only
'@

SubRx @'
      var id=t[0],own=rack[0]!=='set'||id==='off'||pixOwned(id),on=r[rack[0]]===(id==='off'?'none':id),need='';
'@ @'
      var id=t[0],own=rack[0]!=='set'||id==='off'||pixOwned(id),on=r[rack[0]]===(id==='off'?'none':id),need='';
      if(rack[0]==='head'&&id==='hood')return; // v28.xx (cw-cx-wornbody): hats come from worn gear
'@

SubRx @'
function pixWear(kind,id,free){
'@ @'
function pixWear(kind,id,free){
  if(!free&&!(kind==='skin'||(kind==='head'&&id!=='hood')))return false; // v28.xx (cw-cx-wornbody)
'@

SubRx @'
  GROUPS.forEach(function(g){
'@ @'
  GROUPS.filter(function(g){return wornBodyAllowed(g[0]);}).forEach(function(g){ // v28.xx (cw-cx-wornbody): owned body options stay
'@

SubRx @'
      // The buy tiles are the only ones that can be unlocked from here, and
      // only with credits you already have.
      if(!cosOwned(c)){
        var bits=String(c.how).split(':');
        if(bits[0]==='buy'&&P.credits>=+bits[1]){
          P.credits-=+bits[1];
          P.cosBought=P.cosBought||{}; P.cosBought[id]=1;
          try{ sfx('pickRare'); }catch(e){}   // v14.38: a voice that exists
        } else { try{ sfx('clank'); }catch(e){} return; }
      }
      if(kind==='set') setApply(c); else P[COSKEY[kind]||'cosHat']=id;
'@ @'
      // v28.xx (cw-cx-wornbody): the depot is frozen. Only already owned body options may change.
      if(!wornBodyAllowed(kind)||!cosOwned(c))return;
      P[COSKEY[kind]]=id;
'@

SubRx @'
var VER='37.67';
'@ @'
var VER='37.68';
'@

$pat = "(?m)^  now:'v37\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.68: Headgear, armor, pants, boots, gloves and backpacks show the worn pieces. Owned body choices stay. LOCAL: no linked review. Check 37.68 fails on v37.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
