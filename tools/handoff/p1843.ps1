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

# THE GUNS ARE DRAWN AS GUNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gunIcon(c,id,cx,cy,S,tint){
'@ @'
// v18.43, HIS ORDER (2026-10-05): THE GUNS ARE DRAWN AS GUNS. v18.10 shaded the old stacked blocks; a gun still read as blocks.
// Each family is now drawn from real outlines: a pistol's slide with its angled front, serrations and port over a frame, a raked
// polymer grip and a ring trigger guard; a revolver's fluted cylinder and wooden grip; a rifle's stock, buffer tube, railed
// receiver, vented handguard, curved magazine and flash hider (a fat can on the Whisper); a pump gun's wood stock, long barrel,
// tube and grooved pump; an LMG's drum and bipod; a marksman's long barrel, scope with lenses and bolt; the lance's coils. The
// receiver keeps the rarity colour (v7.99). Lit from the top, ink outlined. Returns false only if something is missing.
function gunArt(c,fam,id,W,col,S){
  var u=S/110, ink='#0b0d12', OL=Math.max(1,S*0.022), metal='#59616b', poly='#2b2f36', wood='#8a5a32', i;
  function P(pts){ c.beginPath(); c.moveTo(pts[0][0]*u,pts[0][1]*u); for(var k=1;k<pts.length;k++) c.lineTo(pts[k][0]*u,pts[k][1]*u); c.closePath(); }
  function R(x,y,w,h,r){ c.beginPath(); if(c.roundRect) c.roundRect(x*u,y*u,w*u,h*u,(r||1)*u); else c.rect(x*u,y*u,w*u,h*u); }
  function F(base,y0,y1){ var q=c.createLinearGradient(0,y0*u,0,y1*u); q.addColorStop(0,litHex(base,0.28,true)); q.addColorStop(0.5,base); q.addColorStop(1,darkHex(base,0.62)); c.fillStyle=q; c.fill(); c.strokeStyle=ink; c.lineWidth=OL; c.lineJoin='round'; c.stroke(); }
  function line(x0,y0,x1,y1,w,s){ c.beginPath(); c.moveTo(x0*u,y0*u); c.lineTo(x1*u,y1*u); c.lineWidth=(w||1.2)*u; c.strokeStyle=s||'rgba(0,0,0,.45)'; c.lineCap='round'; c.stroke(); }
  function guard(x0,x1,y0,dy){ c.beginPath(); c.moveTo(x0*u,y0*u); c.quadraticCurveTo(x0*u,(y0+dy)*u,(x0+6)*u,(y0+dy)*u); c.lineTo((x1-2)*u,(y0+dy)*u); c.quadraticCurveTo(x1*u,(y0+dy)*u,x1*u,y0*u); c.lineWidth=4*u; c.strokeStyle=ink; c.lineCap='round'; c.stroke(); c.lineWidth=2.2*u; c.strokeStyle=metal; c.stroke(); line(x0+7,y0,x0+9,y0+dy*0.7,2.4,ink); }
  function lens(x,y,r){ c.beginPath(); c.arc(x*u,y*u,r*u,0,6.2832); var q=c.createRadialGradient((x-r*0.3)*u,(y-r*0.3)*u,0,x*u,y*u,r*u); q.addColorStop(0,'#e8f8ff'); q.addColorStop(0.5,'#4fa8d8'); q.addColorStop(1,'#123a55'); c.fillStyle=q; c.fill(); c.strokeStyle=ink; c.lineWidth=OL*0.8; c.stroke(); }
  c.save();
  if(fam==='hand'){
    P([[-32,2],[-10,2],[-14,34],[-34,34],[-37,29]]); F(poly,2,34);
    for(i=0;i<4;i++) line(-31+i*4,8+i*0,-34+i*4,28,1,'rgba(255,255,255,.10)');
    R(-36,31,22,5,1.5); F('#1c1f24',31,36);
    P([[-34,-4],[28,-4],[28,1],[2,1],[-6,4],[-34,4]]); F(metal,-4,4);
    guard(-6,12,2,12);
    P([[-36,-18],[30,-18],[37,-12],[37,-4],[-36,-4]]); F(col,-18,-4);
    for(i=0;i<5;i++) line(-31+i*3,-16,-31+i*3,-7,1.1);
    R(4,-15,13,5,1); c.fillStyle='#14171c'; c.fill();
    R(30,-21,4,3,0.5); c.fillStyle=ink; c.fill(); R(-34,-21,6,3,0.5); c.fill();
    R(34,-11,3,4,0.5); c.fillStyle='#0a0a0a'; c.fill();
  } else if(fam==='revolver'){
    P([[-30,2],[-14,2],[-18,30],[-34,32],[-39,24]]); F(wood,2,32);
    line(-30,8,-34,26,1,'rgba(40,20,8,.45)');
    P([[-32,-18],[-12,-18],[-12,6],[-26,6],[-32,0]]); F(col,-18,6);
    guard(-12,4,4,11);
    R(10,-16,40,8,1.5); F(metal,-16,-8); R(10,-19,40,3,1); F(darkHex(metal,0.8),-19,-16);
    R(-14,-20,24,22,5); F(col,-20,2);
    for(i=0;i<3;i++) line(-9+i*7,-17,-9+i*7,-1,1.6,'rgba(0,0,0,.4)');
    P([[-34,-24],[-28,-26],[-26,-18],[-32,-18]]); F(metal,-26,-18);
    R(46,-21,4,3,0.5); c.fillStyle=ink; c.fill();
  } else if(fam==='smg'){
    R(-46,-11,18,5,1.5); F(metal,-11,-6); R(-46,-11,4,18,1.5); F(metal,-11,7);
    P([[-24,4],[-12,4],[-16,30],[-28,30]]); F(poly,4,30);
    P([[-7,4],[5,4],[8,40],[-4,40]]); F('#24272c',4,40);
    for(i=0;i<3;i++) line(-4,12+i*9,5,12+i*9,1,'rgba(255,255,255,.12)');
    R(12,4,7,15,2); F(poly,4,19);
    R(-30,-16,52,20,3); F(col,-16,4);
    R(-24,-21,38,5,1); F('#1f2228',-21,-16); for(i=0;i<6;i++) line(-21+i*6,-21,-21+i*6,-17,1.1,'rgba(255,255,255,.18)');
    R(-6,-12,12,5,1); c.fillStyle='#14171c'; c.fill();
    R(22,-13,16,11,2); F(metal,-13,-2); for(i=0;i<3;i++){ c.beginPath(); c.arc((26+i*4.5)*u,-7.5*u,1.3*u,0,6.2832); c.fillStyle='#14171c'; c.fill(); }
    R(38,-10,8,6,1); F('#202328',-10,-4);
    guard(-12,6,4,10);
  } else if(fam==='rifle'){
    var can=(id==='whisper');
    P([[-52,-12],[-32,-14],[-32,4],[-52,10]]); F(poly,-14,10);
    R(-34,-11,10,8,1.5); F(metal,-11,-3);
    P([[-20,2],[-10,2],[-14,24],[-25,24]]); F(poly,2,24);
    P([[-4,2],[6,2],[11,26],[0,29]]); F('#26292e',2,29);
    for(i=0;i<3;i++) line(-1+i*0.8,8+i*7,8+i*0.8,8+i*7,1,'rgba(255,255,255,.12)');
    R(-26,-16,40,18,2.5); F(col,-16,2);
    R(-4,-12,10,4,1); c.fillStyle='#14171c'; c.fill();
    R(-24,-21,36,5,1); F('#1f2228',-21,-16); for(i=0;i<6;i++) line(-21+i*6,-21,-21+i*6,-17,1.1,'rgba(255,255,255,.18)');
    R(14,-14,24,12,2); F('#2c3037',-14,-2); for(i=0;i<4;i++){ R(17+i*5,-10,3,4,1); c.fillStyle='#4a525c'; c.fill(); }
    if(can){ R(38,-15,20,12,4); F('#2a2d33',-15,-3); for(i=0;i<3;i++) line(43+i*5,-14,43+i*5,-4,1,'rgba(255,255,255,.15)'); }
    else { R(38,-11,14,4,1); F(metal,-11,-7); R(50,-13,6,8,1.5); F('#202328',-13,-5); R(32,-24,3,10,0.5); F(metal,-24,-14); }
    if(W&&W.optic&&W.optic>1.2){ R(-18,-32,28,10,4); F('#24272c',-32,-22); lens(10,-27,4.5); R(-12,-23,4,3,0.5); c.fillStyle=ink; c.fill(); R(2,-23,4,3,0.5); c.fill(); }
    guard(-10,2,2,10);
  } else if(fam==='shotgun'){
    P([[-54,-6],[-28,-12],[-28,4],[-36,9],[-54,16]]); F(wood,-12,16);
    line(-50,0,-32,-6,1,'rgba(40,20,8,.4)'); line(-50,8,-34,2,1,'rgba(40,20,8,.35)');
    R(-30,-14,26,18,2.5); F(col,-14,4);
    R(-18,-11,10,4,1); c.fillStyle='#14171c'; c.fill();
    R(-4,-14,58,5,1.5); F(metal,-14,-9);
    R(-4,-8,48,5,1.5); F(darkHex(metal,0.8),-8,-3);
    R(8,-11,22,11,3); F(wood,-11,0); for(i=0;i<4;i++) line(11+i*5,-10,11+i*5,-1,1.2,'rgba(40,20,8,.5)');
    c.beginPath(); c.arc(52*u,-15*u,1.6*u,0,6.2832); c.fillStyle='#e8d070'; c.fill();
    guard(-22,-8,4,10);
  } else if(fam==='lmg'){
    P([[-54,-10],[-36,-14],[-36,4],[-54,10]]); F(poly,-14,10);
    P([[-24,4],[-14,4],[-18,24],[-28,24]]); F(poly,4,24);
    R(-38,-18,46,22,3); F(col,-18,4);
    c.beginPath(); c.moveTo(-26*u,-18*u); c.quadraticCurveTo(-14*u,-30*u,-2*u,-18*u); c.lineWidth=4*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=2.2*u; c.strokeStyle=metal; c.stroke();
    R(8,-15,30,11,2); F('#2c3037',-15,-4); for(i=0;i<5;i++){ c.beginPath(); c.arc((12+i*5.5)*u,-9.5*u,1.6*u,0,6.2832); c.fillStyle='#4a525c'; c.fill(); }
    R(38,-12,16,4,1); F(metal,-12,-8); R(52,-14,5,8,1.5); F('#202328',-14,-6);
    c.beginPath(); c.arc(-8*u,16*u,13*u,0,6.2832); F('#2a2d33',3,29); c.beginPath(); c.arc(-8*u,16*u,7*u,0,6.2832); F(col,9,23);
    line(30,-4,22,28,2.6,ink); line(30,-4,40,28,2.6,ink); line(30,-4,22,28,1.4,metal); line(30,-4,40,28,1.4,metal);
    guard(-14,0,4,9);
  } else if(fam==='marksman'){
    var sn=(id==='sniper');
    P([[-54,-10],[-34,-12],[-34,6],[-46,12],[-54,8]]); F(poly,-12,12);
    R(-52,-15,14,5,1.5); F(poly,-15,-10);
    P([[-24,2],[-14,2],[-18,22],[-28,22]]); F(poly,2,22);
    R(-34,-14,30,14,2.5); F(col,-14,0);
    R(-16,0,10,12,1.5); F('#26292e',0,12);
    R(-4,-11,56,4,1); F(metal,-11,-7);
    if(sn){ R(48,-14,9,10,2); F('#202328',-14,-4); for(i=0;i<2;i++) line(51+i*3,-13,51+i*3,-5,1,'rgba(255,255,255,.2)'); line(36,-7,28,26,2.6,ink); line(36,-7,44,26,2.6,ink); line(36,-7,28,26,1.4,metal); line(36,-7,44,26,1.4,metal); }
    R(-30,-30,36,10,4); F('#24272c',-30,-20); P([[6,-32],[16,-34],[16,-16],[6,-18]]); F('#24272c',-34,-16); lens(16,-25,5.5); R(-32,-28,4,6,1); F('#1c1f24',-28,-22);
    R(-24,-21,4,3,0.5); c.fillStyle=ink; c.fill(); R(-2,-21,4,3,0.5); c.fill();
    line(-8,-6,-4,6,2.4,ink); c.beginPath(); c.arc(-4*u,7*u,2.4*u,0,6.2832); c.fillStyle=metal; c.fill(); c.strokeStyle=ink; c.lineWidth=OL*0.7; c.stroke();
    guard(-14,-2,0,10);
  } else {
    P([[-24,2],[-14,2],[-18,22],[-28,22]]); F(poly,2,22);
    R(-44,-14,52,20,5); F(darkHex(col,0.75),-14,6);
    R(-38,-10,30,4,2); c.fillStyle=col; c.fill();
    R(8,-9,36,8,2); F('#2c3037',-9,-1);
    for(i=0;i<4;i++){ c.beginPath(); c.ellipse((13+i*8)*u,-5*u,2.2*u,6*u,0,0,6.2832); c.fillStyle='#e6c8ff'; c.fill(); c.strokeStyle=ink; c.lineWidth=OL*0.6; c.stroke(); }
    var tg=c.createRadialGradient(48*u,-5*u,0,48*u,-5*u,9*u); tg.addColorStop(0,'#ffffff'); tg.addColorStop(0.4,'#e6c8ff'); tg.addColorStop(1,'rgba(200,150,255,0)'); c.fillStyle=tg; c.beginPath(); c.arc(48*u,-5*u,9*u,0,6.2832); c.fill();
    R(-30,-22,26,8,3); F('#24272c',-22,-14); lens(-4,-18,3.5);
    guard(-14,0,2,10);
  }
  c.restore();
  return true;
}
function gunIcon(c,id,cx,cy,S,tint){
'@

SubRx @'
  var W=WEAPONS[id]||WEAPONS.pistol, fam=GUN_FAMILY[id]||'rifle';
  var col=RCOL[gunRarity(W.id)]||tint||W.tint||'#ffd48a';
'@ @'
  var W=WEAPONS[id]||WEAPONS.pistol, fam=GUN_FAMILY[id]||'rifle';
  var col=RCOL[gunRarity(W.id)]||tint||W.tint||'#ffd48a';
  // v18.43, his order of 2026-10-05: the guns are drawn as guns (gunArt), with the ground shadow and rarity glow below
  if(typeof gunArt==='function'&&S>0){
    var _gu=S/40;
    c.save(); c.translate(cx,cy);
    c.fillStyle='rgba(0,0,0,.26)'; c.beginPath(); c.ellipse(0,14*_gu,19*_gu,3*_gu,0,0,6.2832); c.fill();
    if(_gu>=0.9){ try{ var _gl=c.createRadialGradient(0,0,2*_gu,0,0,25*_gu); _gl.addColorStop(0,hexA(col,.18)); _gl.addColorStop(1,hexA(col,0)); c.fillStyle=_gl; c.fillRect(-27*_gu,-27*_gu,54*_gu,54*_gu); }catch(_gg){} }
    var _ok=false; try{ _ok=gunArt(c,fam,id,W,col,S); }catch(_ga){ _ok=false; }
    c.restore();
    if(_ok) return;
  }
'@

SubRx @'
var VER='18.42';
'@ @'
var VER='18.43';
'@

$pat = "(?m)^  now:'v18\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.43: Every gun has a new detailed icon drawn as the real thing: slides, grips, scopes, stocks and magazines. Check 18.43 fails on v18.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
