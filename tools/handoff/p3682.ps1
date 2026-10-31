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

# ONE THIN OUTLINE IN A FIXED ORDER: PARTNER, GOLDEN, CREWS, THE BOX IN REACH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function rimOpen(e,col){

'@ @'
function rimOpen(e,col,sp){   // v36.80 (cw-outlineorder): sp (an OUTLN row) asks for the one thin outline instead of the elite two-layer rim

'@

SubRx @'
col:col,sx:sx,sy:sy,w:w,h:h,u:T.a,e:e};
'@ @'
col:col,sp:sp,sx:sx,sy:sy,w:w,h:h,u:T.a,e:e};
'@

SubRx @'
function rimClose(h){
  var k, d, dx, dy, m, pu, xa=RIM.xa, xb=RIM.xb;
  if(!h) return;
  wc=h.w0; shadowE=h.sh0; RIM.on=0; RIM.h=null;

'@ @'
// v36.80 (cw-outlineorder), HIS PICK 81 (2026-10-14, outline hierarchy), priorities page r-outlines: ONE thin outline for everything that has to stand out in a busy
// fight, in a fixed order of strength: the partner first, then the golden enemy, then the pillager crews, then the one box in reach. Plain machines get none.
// w is in world units (never under 1 device pixel), a is the alpha; the order of a is the order of the rows. Cosmetic: no random draw, nothing the sim reads.
var OUTLN={partner:{w:1.0,a:1.0},golden:{w:0.7,a:0.9,c:'#ffd452'},crew:{w:0.55,a:0.7},use:{w:0.55,a:0.5,c:'#e6ff3d'}};
var OUTLN_CREW=['#c8452f','#4a90c2','#c2a54a','#7a4ac2'];
function outlineFor(e){   // the outline row and colour a machine or pillager wears, or null (a plain machine, a hired pillager)
  if(!e||!(e.hp>0)) return null;
  if(e.golden) return {c:OUTLN.golden.c,sp:OUTLN.golden};
  if(e.kind==='raider'&&!e.merc&&!e.friendlyPC&&CFG.raiderFeud!==0&&e.crew!==undefined) return {c:OUTLN_CREW[e.crew%4],sp:OUTLN.crew};
  return null;
}
function outlinePartnerOpen(g){   // the partner in a co-op raid wears his seat colour; an opponent in pvp wears nothing
  if(!g||(typeof NET!=='undefined'&&NET.mode==='pvp')) return null;
  return rimOpen({x:g.x,y:g.y,r:12,kind:'raider'},SEATCOL[(+g.seat||0)&3],OUTLN.partner);
}
function drawUseOutline(ct,w,lift,d2){   // the box in reach (the one E searches): a thin lime rectangle, no glow
  var sp=OUTLN.use;
  if(!ct||ct.opened||ct.type==='body'||!G||G.sim||G.nearContainer!==ct||G.searching===ct) return;
  wc.save();
  try{ wc.strokeStyle=hexA(sp.c,sp.a); wc.lineWidth=sp.w; wc.lineJoin='round'; wc.strokeRect(ct.x-w/2-0.5,ct.y-lift-d2-0.5,w+1,lift+d2+1); }
  finally{ wc.restore(); }
}
function rimStamp(h){   // the thin outline: the body grown one step in eight directions in the row colour, then the body over it
  var sp=h.sp, xb=RIM.xb, d=Math.max(1,Math.round(h.u*sp.w)), k, dx, dy;
  try{
    xb.setTransform(1,0,0,1,0,0); xb.globalCompositeOperation='source-over'; xb.clearRect(0,0,h.w,h.h);
    for(k=0;k<8;k++){ dx=Math.round(Math.cos(k*0.7854)*d); dy=Math.round(Math.sin(k*0.7854)*d); xb.drawImage(RIM.ca,0,0,h.w,h.h,dx,dy,h.w,h.h); }
    xb.globalCompositeOperation='source-in'; xb.fillStyle=hexA(h.col,sp.a); xb.fillRect(0,0,h.w,h.h); xb.globalCompositeOperation='source-over';
    wc.save(); wc.setTransform(1,0,0,1,0,0);
    wc.drawImage(RIM.cb,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h);
    wc.drawImage(RIM.ca,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h);
    wc.restore();
    RIM.n++;
  }catch(_rs){ try{ wc.restore(); }catch(_r2){} }
}
function rimClose(h){
  var k, d, dx, dy, m, pu, xa=RIM.xa, xb=RIM.xb;
  if(!h) return;
  wc=h.w0; shadowE=h.sh0; RIM.on=0; RIM.h=null;
  if(h.sp){ rimStamp(h); return; }   // v36.80 (cw-outlineorder)

'@

SubRx @'
      if(!_pm&&e2.elite&&e2.affix&&AFFIX[e2.affix]) _rm=rimOpen(e2,AFFIX[e2.affix].c);   // v26.xx (aip1): the elite outline

'@ @'
      if(!_pm&&e2.elite&&e2.affix&&AFFIX[e2.affix]) _rm=rimOpen(e2,AFFIX[e2.affix].c);   // v26.xx (aip1): the elite outline
      else if(!_pm){ var _ol=outlineFor(e2); if(_ol) _rm=rimOpen(e2,_ol.c,_ol.sp); }   // v36.80 (cw-outlineorder): the golden enemy and the pillager crews wear the one thin outline

'@

SubRx @'
    drawOp(g.x,g.y,g.f,(g.roll>0)?(1-g.roll/0.38)*12.6:g.bob,fit[1],0,0,mode,0,

'@ @'
    _pr=outlinePartnerOpen(g);   // v36.80 (cw-outlineorder): the partner is the strongest outline, in his seat colour
    drawOp(g.x,g.y,g.f,(g.roll>0)?(1-g.roll/0.38)*12.6:g.bob,fit[1],0,0,mode,0,

'@

SubRx @'
pads:lk.pads});
    if(g.sh&&G&&G.arcade) arcadeShieldRing(g.x,g.y,0);
'@ @'
pads:lk.pads});
    rimClose(_pr); _pr=null;   // v36.80 (cw-outlineorder)
    if(g.sh&&G&&G.arcade) arcadeShieldRing(g.x,g.y,0);
'@

SubRx @'
  var lk, fit, lift=0, mode, wp=null;

'@ @'
  var lk, fit, lift=0, mode, wp=null, _pr=null;

'@

SubRx @'
}catch(e){}
  if(lift>0){ try{ wc.restore(); }catch(e2){} }
'@ @'
}catch(e){ if(_pr) rimAbort(); }   // v36.80 (cw-outlineorder): a throw inside the partner body puts the world canvas back
  if(lift>0){ try{ wc.restore(); }catch(e2){} }
'@

SubRx @'
  if(ct.dropped&&!ct.opened&&!G.sim&&ct.best){ try{ lootShaft(ct,lift); }catch(_ls){} }   // v28.xx (cw-ascent), his pick 75

'@ @'
  if(ct.dropped&&!ct.opened&&!G.sim&&ct.best){ try{ lootShaft(ct,lift); }catch(_ls){} }   // v28.xx (cw-ascent), his pick 75
  drawUseOutline(ct,w,lift,d2);   // v36.80 (cw-outlineorder): the box in reach wears the thin use outline

'@

SubRx @'
var VER='36.81';
'@ @'
var VER='36.82';
'@

$pat = "(?m)^  now:'v36\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.82: The partner, the golden enemy, pillager crews and the box in reach wear one thin outline, strongest to faintest in that order. Check 36.82 fails on v36.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
