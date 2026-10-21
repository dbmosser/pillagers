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

# THE PIXEL HURT STATES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pxBob(ph,moving){
'@ @'
// v33.78 (cw-pixhurt), HIS PICKS a12 B and a13 D (art survey 2026-10-19), job 86g ship 1: THE HURT STATES IN PIXELS. A hit is the layer silhouettes (baked once per layer, pxTint) drawn white for the first
// v33.78 (cw-pixhurt):  0.066 s and then red as it fades, a 1 px recoil away from the shot; low health is a red copy of the ink ring (pxRingRed, the ring pixels and nothing else) breathing over the same ring
// v33.78 (cw-pixhurt):  at the vector pulse rate, the shoulders 1 px lower, two dark red stains on the chest and the arm, the walk 30 percent slower and the blood drops. Cosmetic: no random draw, nothing the sim reads.
function pxTint(spr,col){   // the silhouette of one baked layer in one colour, cached on the layer: nothing is read back
  var k=spr.tn||(spr.tn={}), t, s;
  if(k[col]) return k[col];
  t=pixSilhouette(spr.c,col); s=pixSprite(t.c,spr.ax,spr.ay,spr.d); s.mx=spr.mx; s.my=spr.my;
  k[col]=s; spr.bytes+=s.bytes; if(spr.kind&&PIXSTORE.bytes[spr.kind]!==undefined) PIXSTORE.bytes[spr.kind]+=s.bytes;
  return s;
}
function pxRingRed(spr){   // the ink ring of a layer in red, on its own: drawn at the pulse alpha over the layer. Bake time reads pixels; a busy frame waits one frame for it.
  var s, d, p, k, n=0, r;
  if(spr.rr!==undefined) return spr.rr;
  if(PIX.fB>=PIXSTORE.maxBuilds) return null;
  s=pixCanvas(spr.c.width,spr.c.height); s.x.drawImage(spr.c,0,0);
  d=s.x.getImageData(0,0,s.w,s.h); p=d.data;
  for(k=0;k<p.length;k+=4){
    if(p[k+3]&&p[k]===22&&p[k+1]===18&&p[k+2]===28){ p[k]=224; p[k+1]=36; p[k+2]=26; p[k+3]=255; n++; } else p[k+3]=0;
  }
  s.x.putImageData(d,0,0); PIX.fB++; PIX.builds++;
  r=n?pixSprite(s.c,spr.ax,spr.ay,spr.d):0;
  if(r){ spr.bytes+=r.bytes; if(spr.kind&&PIXSTORE.bytes[spr.kind]!==undefined) PIXSTORE.bytes[spr.kind]+=r.bytes; }
  spr.rr=r; return r;
}
function pxLayer(spr,wx,wy,m,fx){   // one layer, then the wash over its own silhouette and the red ring over its own ring
  var a0, t;
  pxBlit(spr,wx,wy,m);
  if(!fx) return;
  a0=wc.globalAlpha;
  if(fx.wa>0){ wc.globalAlpha=a0*fx.wa; pxBlit(pxTint(spr,fx.wc),wx,wy,m); }
  if(fx.ra>0&&(t=pxRingRed(spr))){ wc.globalAlpha=a0*fx.ra; pxBlit(t,wx,wy,m); }
  wc.globalAlpha=a0;
}
function pxBob(ph,moving){
'@

SubRx @'
  if(!st||iv>0||OPX.inScr||st.bulk>0||st.low) return false;
'@ @'
  if(!st||iv>0||OPX.inScr||st.bulk>0) return false;   // v33.78 (cw-pixhurt): low health is drawn in pixels now
'@

SubRx @'
  if(opHitAge(st)<0.3) return false;
'@ @'
  // v33.78 (cw-pixhurt): a hit is drawn in pixels now (the wash and the recoil are worked out below)
'@

SubRx @'
  var m, lk, fl, mir, moving, sprint, crouch, ads, rl, hold, back, kind, fr, bob, lean, dyUp,
'@ @'
  var age, hurt, lw, rx=0, fx=null, m, lk, fl, mir, moving, sprint, crouch, ads, rl, hold, back, kind, fr, bob, lean, dyUp,
'@

SubRx @'
  hold=gunHeldOn(st,mode); back=hold&&Math.sin(face)<-0.3;
'@ @'
  age=opHitAge(st); hurt=age<0.3; lw=opLow(st);   // v33.78 (cw-pixhurt): a12 B and a13 D
  if(lw) ph*=0.7;
  if(hurt||lw){
    fx={wc:'',wa:0,ra:0};
    if(hurt){
      if(age<0.066){ fx.wc='#ffffff'; fx.wa=0.9; } else { fx.wc='#ff3c30'; fx.wa=0.55*Math.max(0,1-(age-0.066)/0.234); }
      if(st.own&&st.own.hitDX&&age<0.22) rx=st.own.hitDX>0?1:-1;   // 1 art px away from the shot
    }
    if(lw) fx.ra=0.5+0.5*Math.sin(((G&&G.t)||0)*hpFlashRate());
  }
  hold=gunHeldOn(st,mode); back=hold&&Math.sin(face)<-0.3;
'@

SubRx @'
  dyUp=(crouch?5:0)-bob;
'@ @'
  dyUp=(crouch?5:0)-bob+(lw?1:0);   // a13 D: the shoulders drop
'@

SubRx @'
band:sm>=0?SEATCOL[sm&3]:''};
'@ @'
band:sm>=0?SEATCOL[sm&3]:'',low:lw?1:0};
'@

SubRx @'
  ty=y+dyUp; pxd=x+lean; px=pxd; py=ty-PXB.PV+(ads?-1:0);
'@ @'
  ty=y+dyUp; pxd=x+lean+rx; px=pxd; py=ty-PXB.PV+(ads?-1:0);
'@

SubRx @'
  pxBlit(lg,x,y,m);
'@ @'
  pxLayer(lg,x+rx,y,m,fx);
'@

SubRx @'
  if(back){ if(gv){ wc.imageSmoothingEnabled=true; gunHeld(pxd,ty,face,fl,st,C.coat[1],null,true,ads,sprint,rl,muzzle); } else if(gn) pxBlit(gn,px,py,m); }
'@ @'
  if(back){ if(gv){ wc.imageSmoothingEnabled=true; gunHeld(pxd,ty,face,fl,st,C.coat[1],null,true,ads,sprint,rl,muzzle); } else if(gn) pxLayer(gn,px,py,m,fx); }
'@

SubRx @'
  pxBlit(up,pxd,ty,m);
'@ @'
  pxLayer(up,pxd,ty,m,fx);
'@

SubRx @'
  if(hold&&!back){ if(gv){ wc.imageSmoothingEnabled=true; gunHeld(pxd,ty,face,fl,st,C.coat[1],null,true,ads,sprint,rl,muzzle); } else if(gn) pxBlit(gn,px,py,m); }
'@ @'
  if(hold&&!back){ if(gv){ wc.imageSmoothingEnabled=true; gunHeld(pxd,ty,face,fl,st,C.coat[1],null,true,ads,sprint,rl,muzzle); } else if(gn) pxLayer(gn,px,py,m,fx); }
'@

SubRx @'
  if(gn&&muzzle>0){
'@ @'
  if(lw) opLowDrops(x,y,fl);
  if(gn&&muzzle>0){
'@

SubRx @'
  return pixFetch('actors',fam+'|'+o.pup+'|'+o.arms+'|'+(o.lamp||'')+'|'+(o.band||''),function(){ return pxBuildUpper(o); },fam,0);
'@ @'
  return pixFetch('actors',fam+'|'+o.pup+'|'+o.arms+'|'+(o.lamp||'')+'|'+(o.band||'')+'|'+(o.low?1:0),function(){ return pxBuildUpper(o); },fam,0);
'@

SubRx @'
  if(o.lamp){ p.Pl(11,22,o.lamp); p.Pl(12,22,o.lamp); p.Pl(11,23,o.lamp); p.Pl(12,23,o.lamp); }
'@ @'
  if(o.low){ p.Pl(14,27,'#8a1c14'); p.Pl(15,27,'#b02a1e'); p.Pl(14,28,'#b02a1e'); p.Pl(15,28,'#8a1c14'); p.Pl(16,28,'#8a1c14'); p.Pl(22,30,'#8a1c14'); p.Pl(23,30,'#b02a1e'); p.Pl(22,31,'#b02a1e'); p.Pl(23,31,'#8a1c14'); p.Pl(24,31,'#8a1c14'); }   // v33.78 (cw-pixhurt) a13 D: two dark red stains, chest and arm
  if(o.lamp){ p.Pl(11,22,o.lamp); p.Pl(12,22,o.lamp); p.Pl(11,23,o.lamp); p.Pl(12,23,o.lamp); }
'@

SubRx @'
var VER='33.77';
'@ @'
var VER='33.78';
'@

$pat = "(?m)^  now:'v33\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.78: A hit washes the pixel pillager white then red inside its own shape with a one pixel push; low health pulses the outline red and drops the shoulders one pixel with two stains. Check 33.78 fails on v33.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
