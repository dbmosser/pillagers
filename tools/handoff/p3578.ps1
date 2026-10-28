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

# A JAGGED WHITE BOLT FROM THE SKY TO EACH LIGHTNING STRIKE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    G.strikes.splice(i,1);

'@ @'
    G.strikes.splice(i,1);
    try{ boltMark(S); }catch(_bm){}   // v35.xx (cw-skybolt): the sky bolt picture only; nothing in the sim reads it and it draws no random number

'@

SubRx @'
function lightningVisual(){ return CFG.flashRed===1&&!G._flashBolt?0:(G.lightning||0); }

'@ @'
function lightningVisual(){ return CFG.flashRed===1&&!G._flashBolt?0:(G.lightning||0); }
// v35.xx (cw-skybolt), HIS ORDER (2026-10-28): "when the lightning hits, along with the flash, it would be cool to have a white jagged line lightning
// grahpic extend from the top of the screen down to the hit location, so it looks like sky-to-ground lightning". RENDER ONLY: boltMark keeps where a strike
// landed (never in the sim), drawBolts draws it in screen space from the top edge of the view down to the strike point for BOLT_LIFE seconds, with the
// flash, so it works at any zoom. The jagged shape and its forks come from a hash of the strike number and spot (boltShape), never from a game random
// stream, so the seed fingerprint and replays do not move and both party windows draw the same bolt. Effects reduced or a flash the reduced flashing
// limiter held back: no bolt. A strike off screen: no bolt.
var BOLT_LIFE=0.32;
function boltSeed(S){ var h=(((S.id||S.rid||0)|0)*2654435761)^(Math.round(+S.x||0)*40503)^(Math.round(+S.y||0)*9973); return (h>>>0)||1; }
function boltMark(S){
  if(typeof G==='undefined'||!G||G.sim||!S||!isFinite(+S.x)||!isFinite(+S.y)) return;
  var Lb=G.bolts||(G.bolts=[]);
  Lb.push({x:+S.x,y:+S.y,t:0,s:boltSeed(S)});
  if(Lb.length>4) Lb.shift();
}
function boltRand(seed){ var s=(seed>>>0)||1; return function(){ s=(s+0x6D2B79F5)>>>0; var t=s; t=Math.imul(t^(t>>>15),t|1); t^=t+Math.imul(t^(t>>>7),t|61); return ((t^(t>>>14))>>>0)/4294967296; }; }
// The bolt as fractions: f runs from 0 at the top edge to 1 at the strike, d is the sideways kick in bolt lengths. The main line is a random walk pinned at
// both ends (a bridge), so it always leaves the top and always lands on the strike; two or three forks branch off it going down and out.
function boltShape(seed){
  var r=boltRand(seed), n=16, w=[0], m=[], fk=[], i, j, d=0, f;
  for(i=1;i<=n;i++){ d+=(r()-0.5)*0.13; w.push(d); }
  for(i=0;i<=n;i++){ f=(i===0||i===n)?i/n:(i+(r()-0.5)*0.55)/n; m.push({f:f,d:w[i]-w[n]*i/n}); }
  var nf=2+((r()*2)|0);
  for(j=0;j<nf;j++){
    var at=2+((r()*(n-6))|0), side=r()<0.5?-1:1, q=m[at], pts=[{f:q.f,d:q.d}], ff=q.f, fd=q.d, segs=3+((r()*2)|0);
    for(i=0;i<segs;i++){ ff+=0.022+r()*0.03; fd+=side*(0.02+r()*0.04)+(r()-0.5)*0.025; pts.push({f:Math.min(0.97,ff),d:fd}); }
    fk.push(pts);
  }
  return {lean:(r()-0.5)*0.5, m:m, fk:fk};
}
// Brightness over the bolt life: full, a quick dip, full again (the double flicker), then out.
function boltEnv(t){ if(!(t>=0)||t>=BOLT_LIFE) return 0; if(t<0.06) return 1; if(t<0.10) return 0.3; if(t<0.15) return 0.95; return 0.95*Math.max(0,1-(t-0.15)/(BOLT_LIFE-0.15)); }
function drawBolts(c,dt,Z,ox,oy,VWp,VHp){
  var Lb=(typeof G!=='undefined'&&G)?G.bolts:null, i, j, b, n=0;
  if(!Lb||!Lb.length) return 0;
  var step=Math.max(0,Math.min(0.1,+dt||0));
  for(i=Lb.length-1;i>=0;i--){ Lb[i].t+=step; if(!(Lb[i].t<BOLT_LIFE)) Lb.splice(i,1); }
  if(!Lb.length||CFG.fxLevel===0||(CFG.flashRed===1&&!G._flashBolt)) return 0;
  var k=Math.max(1,VHp/1080), fK=flashK();
  c.save();
  try{
    c.lineJoin='miter'; c.miterLimit=3; c.lineCap='round';
    for(i=0;i<Lb.length;i++){
      b=Lb[i]; var a=boltEnv(b.t)*fK; if(a<0.02) continue;
      var sx=(b.x-ox)*Z, sy=(b.y-oy)*Z;
      if(sx<-40||sx>VWp+40||sy<12||sy>VHp+40) continue;
      var sh=b.sh||(b.sh=boltShape(b.s)), x0=sx+sh.lean*sy, y0=-4*k, len=Math.sqrt((sx-x0)*(sx-x0)+(sy-y0)*(sy-y0));
      var line=function(list){ var u, q=list[0]; c.moveTo(x0+(sx-x0)*q.f+q.d*len,y0+(sy-y0)*q.f); for(u=1;u<list.length;u++){ q=list[u]; c.lineTo(x0+(sx-x0)*q.f+q.d*len,y0+(sy-y0)*q.f); } };
      c.globalCompositeOperation='lighter';
      c.beginPath(); line(sh.m); for(j=0;j<sh.fk.length;j++) line(sh.fk[j]);
      c.strokeStyle='rgba(185,205,255,'+(0.45*a).toFixed(3)+')'; c.lineWidth=12*k; c.stroke();
      var rg=c.createRadialGradient(sx,sy,0,sx,sy,50*k);
      rg.addColorStop(0,'rgba(255,255,255,'+(0.95*a).toFixed(3)+')'); rg.addColorStop(1,'rgba(190,210,255,0)');
      c.fillStyle=rg; c.beginPath(); c.arc(sx,sy,50*k,0,6.2832); c.fill();
      c.globalCompositeOperation='source-over';
      c.beginPath(); for(j=0;j<sh.fk.length;j++) line(sh.fk[j]);
      c.strokeStyle='rgba(240,246,255,'+(0.9*a).toFixed(3)+')'; c.lineWidth=2*k; c.stroke();
      var lg=c.createLinearGradient(x0,y0,sx,sy);
      lg.addColorStop(0,'rgba(255,255,255,'+(0.8*a).toFixed(3)+')'); lg.addColorStop(1,'rgba(255,255,255,'+a.toFixed(3)+')');
      c.beginPath(); line(sh.m); c.strokeStyle=lg; c.lineWidth=3.6*k; c.stroke();
      n++;
    }
  } finally { c.globalCompositeOperation='source-over'; c.restore(); }
  return n;
}

'@

SubRx @'
  try{ gfxScreen(dt); }catch(_gsc){}
'@ @'
  try{ drawBolts(wc,dt,Z,ox,oy,W,H); }catch(_bk){}   // v35.xx (cw-skybolt): the sky bolt, top edge to the strike, over the flash and under the HUD
  try{ gfxScreen(dt); }catch(_gsc){}
'@

SubRx @'
var VER='35.77';
'@ @'
var VER='35.78';
'@

$pat = "(?m)^  now:'v35\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.78: Each lightning strike that lands on screen draws a white jagged bolt with two or three side forks from the top edge of the view down to the strike point, brightest at the ground, with a quick double flicker, gone in about a third of a second with the flash. Render only: where strikes land and what they hit are unchanged, and the shape uses no game random number. Effects reduced: no bolt. Check 35.78 fails on v35.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
