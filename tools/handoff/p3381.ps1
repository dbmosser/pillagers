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

# THE PIXEL ARMOUR AND GOLD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pxBob(ph,moving){
'@ @'
// v33.81 (cw-pixgear), HIS PICKS a20 A, a21 B and a22 (art survey 2026-10-19) and SPEC 9.7, job 86g ship 3: ARMOUR, GOLD, ELITE AND THE TELL IN PIXELS. The armour tier is a silhouette on the upper body (1 a chest plate, 2 a wider
// v33.81 (cw-pixgear):  plate with pauldrons, 3 wider again with a collar, a ridge and a helmet shell), the golden pillager bot is a baked solid gold palette with a pixel shine band (no scratch canvas, no ctx.filter), the elite
// v33.81 (cw-pixgear):  purple ground ring is a baked pixel ring at the vector pulse, and the 0.45 s chase tell flares the eyes with a red halo and tightens the brows. Cosmetic: no random draw, nothing the sim reads.
var PXB_ARM=['#9aa6b0','#75818c','#55606b','#3a434c'];
var PXB_GOLD={coat:['#fff0a0','#f0c840','#b48a1c','#6e4c10'],trs:['#e0b83a','#b48a1c','#8a640e','#5a400a'],gear:['#fff4b0','#f4d050','#c49a24','#7c5810'],pack:['#e8c440','#c49a24','#8a640e','#5a400a'],acc:'#ffffff',
  skin:['#fff0a0','#f0c840','#b48a1c','#6e4c10'],hair:['#d8b030','#b48a1c','#8a640e','#5a400a'],boot:['#c49a24','#8a640e','#5a400a','#3a2806']};
function pxEliteRing(e){
  var rx=Math.max(4,Math.round(e.r*1.2)), ry=Math.max(3,Math.round(e.r*0.5)), m, spr, ep, a0=wc.globalAlpha;
  try{
    if(!(e.r>0)||!wc.getTransform) return false;
    m=wc.getTransform(); if(Math.abs(m.b)>1e-9||Math.abs(m.c)>1e-9||!(m.a>0)||Math.abs(m.a-m.d)>1e-6) return false;
    spr=pixFetch('actors','e|'+rx+'|'+ry,function(){
      var s=pixCanvas(rx*2+6,ry*2+6), q;
      s.x.imageSmoothingEnabled=true; s.x.strokeStyle='#d08ce8'; s.x.lineWidth=2; s.x.beginPath(); s.x.ellipse(rx+3,ry+3,rx,ry,0,0,6.2832); s.x.stroke();
      pixHarden(s,100); q=pixSprite(s.c,rx+3,ry+3,PIX_ACT); q.elite=1; return q;
    },'e|'+rx+'|'+ry,0);
    if(!spr) return false;
    ep=0.55+0.45*Math.sin(((G&&G.t)||0)*3.1+e.x*0.02);
    wc.save(); wc.globalCompositeOperation='lighter'; wc.globalAlpha=a0*(0.28+0.24*ep); pxBlit(spr,e.x,e.y+2,m); wc.restore();
    return true;
  }catch(_pe){ PIX.errs++; PIX.fall++; try{ wc.globalAlpha=a0; }catch(_q){} return false; }
}
function pxBob(ph,moving){
'@

SubRx @'
  if(!st||iv>0||OPX.inScr||st.bulk>0) return false;   // v33.78 (cw-pixhurt): low health is drawn in pixels now
'@ @'
  if(!st||iv>0||OPX.inScr) return false;   // v33.78 (cw-pixhurt): low health is drawn in pixels now; v33.81 (cw-pixgear): armour too
'@

SubRx @'
bot:1};
'@ @'
bot:(o&&o.golden)?2:1};   // v33.81 (cw-pixgear) a21 B: the golden pillager bot is the gold palette
'@

SubRx @'
C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair, hr=PXB_HAIR,
'@ @'
C=o.bot?(o.bot===2?PXB_GOLD:PXB_REDS):(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=(o.bot===2)?PXB_GOLD.skin:(PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair), hr=(o.bot===2)?PXB_GOLD.hair:PXB_HAIR,
'@

SubRx @'
C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), B=PXB_BOOT,
'@ @'
C=o.bot?(o.bot===2?PXB_GOLD:PXB_REDS):(PXB_RAMP[o.clothes]||PXB_RAMP.scav), B=(o.bot===2)?PXB_GOLD.boot:PXB_BOOT,
'@

SubRx @'
C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair, a=(o.fr|0)
'@ @'
C=o.bot?(o.bot===2?PXB_GOLD:PXB_REDS):(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=(o.bot===2)?PXB_GOLD.skin:(PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair), a=(o.fr|0)
'@

SubRx @'
C=lk.bot?PXB_REDS:(PXB_RAMP[lk.clothes]||PXB_RAMP.scav); sk=PIXRAMPS.skins[lk.skin]||PIXRAMPS.skins.fair;
'@ @'
C=lk.bot?(lk.bot===2?PXB_GOLD:PXB_REDS):(PXB_RAMP[lk.clothes]||PXB_RAMP.scav); sk=(lk.bot===2)?PXB_GOLD.skin:(PIXRAMPS.skins[lk.skin]||PIXRAMPS.skins.fair);
'@

SubRx @'
  if(o.low){ p.Pl(14,27,'#8a1c14');
'@ @'
  if(o.bulk>0){   // v33.81 (cw-pixgear) SPEC 9.7: the tier is the silhouette; steel, not the coat colour
    var A=PXB_ARM, bt=o.bulk;
    if(bt===1){ p.put(pxRR(pxM(),11,23,24,32,1.5),A); }
    else if(bt===2){ p.put(pxRR(pxM(),9,22,26,34,1.8),A); p.put(pxRR(pxM(),6,20,11,26,2),A); p.put(pxRR(pxM(),24,20,29,26,2),A); }
    else { p.put(pxRR(pxM(),8,21,27,35,2),A); p.put(pxRR(pxM(),5,18,11,26,2.2),A); p.put(pxRR(pxM(),24,18,30,26,2.2),A); p.put(pxRR(pxM(),12,19,23,22,1.5),A); p.put(pxRect(pxM(),17,23,18,33),[A[0],A[0],A[1],A[1]],{line:false}); }
  }
  if(o.low){ p.Pl(14,27,'#8a1c14');
'@

SubRx @'
  // the face: two 3 by 3 eyes, the pupils a pixel toward the aim; a bot has red eyes and angry brows
'@ @'
  if(o.bulk>=3&&o.head!=='hood'){ p.put(pxRR(pxM(),8,0,27,9,4),PXB_ARM); p.put(pxRect(pxM(),9,9,26,9),[PXB_ARM[2],PXB_ARM[2],PXB_ARM[3],PXB_ARM[3]],{line:false}); p.P(8,10,'#5c5c3c'); p.P(8,11,'#5c5c3c'); p.P(27,10,'#5c5c3c'); p.P(27,11,'#5c5c3c'); }   // v33.81 (cw-pixgear): the armour 3 helmet shell
  // the face: two 3 by 3 eyes, the pupils a pixel toward the aim; a bot has red eyes and angry brows
'@

SubRx @'
  eye(12); eye(21);
'@ @'
  if(o.tell){ [12,21].forEach(function(ex){ var xx, yy; for(yy=10;yy<=14;yy++) for(xx=ex-1;xx<=ex+3;xx++) if(xx<ex||xx>ex+2||yy<11||yy>13) p.P(xx,yy,'#c4302a'); }); }   // v33.81 (cw-pixgear) a22: the eyes flare
  eye(12); eye(21);
  if(o.tell&&bot){ p.P(11,11,E.brow); p.P(12,11,E.brow); p.P(24,11,E.brow); p.P(23,11,E.brow); }   // and the brows go a pixel thicker
'@

SubRx @'
+'|'+(o.band||'')+'|'+(o.low?1:0),function(){ return pxBuildUpper(o); }
'@ @'
+'|'+(o.band||'')+'|'+(o.low?1:0)+'|'+(o.bulk|0)+'|'+(o.tell?1:0),function(){ return pxBuildUpper(o); }
'@

SubRx @'
band:sm>=0?SEATCOL[sm&3]:'',low:lw?1:0};
'@ @'
band:sm>=0?SEATCOL[sm&3]:'',low:lw?1:0,bulk:Math.min(3,Math.max(0,Math.round(st.bulk||0))),tell:(st.tell>0)?1:0};
'@

SubRx @'
wc.globalAlpha=a0*fx.ra; pxBlit(t,wx,wy,m); }
'@ @'
wc.globalAlpha=a0*fx.ra; pxBlit(t,wx,wy,m); }
  if(fx.sh!==undefined){ wc.save(); wc.beginPath(); wc.rect(fx.sh,wy-70,5,80); wc.clip(); wc.globalAlpha=a0*0.45; pxBlit(pxTint(spr,'#fff6d0'),wx,wy,m); wc.restore(); }   // v33.81 (cw-pixgear) a21 B: a 5 px shine band crosses the gold body for 0.4 s of every 2 s
'@

SubRx @'
  var age, hurt, lw, rx=0, fx=null, dn=0, m,
'@ @'
  var age, hurt, lw, rx=0, fx=null, dn=0, sf, m,
'@

SubRx @'
  hold=gunHeldOn(st,mode); back=hold&&Math.sin(face)<-0.3;
'@ @'
  if(lk.bot===2){ sf=(((G&&G.t)||0)%2)/0.4; if(sf<1){ if(!fx) fx={wc:'',wa:0,ra:0}; fx.sh=Math.round(x+(sf*2-1)*18); } }   // v33.81 (cw-pixgear): the gold shine
  hold=gunHeldOn(st,mode); back=hold&&Math.sin(face)<-0.3;
'@

SubRx @'
var fam='t|'+lk.head+'|'+lk.skin+'|'+lk.clothes+'|'+lk.bot+'|'+mir+'|'+sg+'|'+A;
'@ @'
var fam='t|'+lk.head+'|'+lk.skin+'|'+lk.clothes+'|'+lk.bot+'|'+mir+'|'+sg+'|'+A+'|'+(lk.bulk|0);
'@

SubRx @'
arms:1,lamp:'',band:'',low:0}), R=62
'@ @'
arms:1,lamp:'',band:'',low:0,bulk:lk.bulk|0}), R=62
'@

SubRx @'
  spr=pxToppleSpr(lk,fl<0?1:0,sg,Math.round(k*k*7),1.5708); if(!spr) return false;
'@ @'
  lk.bulk=Math.min(3,Math.max(0,Math.round(st.bulk||0)));
  spr=pxToppleSpr(lk,fl<0?1:0,sg,Math.round(k*k*7),1.5708); if(!spr) return false;
'@

SubRx @'
    spr=pxToppleSpr(lk,fl<0?1:0,sg<0?-1:1,Math.round((1-(1-k)*(1-k))*7),1.4835); if(!spr) return false;
'@ @'
    lk.bulk=Math.min(3,Math.max(0,Math.round(st.bulk||0)));
    spr=pxToppleSpr(lk,fl<0?1:0,sg<0?-1:1,Math.round((1-(1-k)*(1-k))*7),1.4835); if(!spr) return false;
'@

SubRx @'
if(!e||!e.golden||typeof wc==='undefined'
'@ @'
if(!e||!e.golden||(pixOn()&&e.kind==='raider')||typeof wc==='undefined'
'@

SubRx @'
      else if(e2.elite){
'@ @'
      else if(e2.elite&&!(pixOn()&&e2.kind==='raider'&&pxEliteRing(e2))){   // v33.81 (cw-pixgear) a20 A: a pillager bot elite ring is a baked pixel ring
'@

SubRx @'
var VER='33.80';
'@ @'
var VER='33.81';
'@

$pat = "(?m)^  now:'v33\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.81: Armoured pillagers wear pixel plates (a chest plate, then pauldrons, then a collar and a helmet), the golden pillager bot is solid gold with a pixel shine, the elite ring is a pixel ring, and the chase tell flares the eyes. Check 33.81 fails on v33.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
