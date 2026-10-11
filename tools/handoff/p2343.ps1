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

# ARCADE: HALLOWEEN DRESSING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// The bubble on a shielded player (own: this window, which also gets the tag under him). Drawn on the world canvas.
'@ @'
// v23.43, HIS ORDER (2026-10-11), build 20 of 20 (arcade20): HALLOWEEN DRESSING. The party mode is for a Halloween night, so an arcade
// raid dresses the street: every lamp burns orange and a little brighter (only the darkness cut, which is colourless, and the lamp
// colour pool change, so the sight rules are the same), carved pumpkins sit by lamps and doors (most of them lit, with a warm glow
// at night), and a slow violet haze drifts over the screen after the fog sheets. Purely cosmetic: arcadeHallow draws only from the
// cosmetic stream (fxr), never from the raid stream, so the seeded raid is the same. It runs from arcadePostBuild, so only an arcade
// raid is ever dressed and a normal raid is unchanged. Calling it again redresses from the stored base intensity (L.i0).
var ARCADE_HALLOW={lamps:['#ff7a1a','#ff8a2e','#ff9a3c','#ffae55'],lampI:1.12,lampMax:0.62,pumps:80,lampP:0.5,doorP:0.3,haze:1};
function arcadeHallow(g){
  if(!g||g.sim||!g.arcade||!g.map) return false;
  var H2=ARCADE_HALLOW, m=g.map, i, j, L, D, src=[], list=[], a, r, x, y, k, tmp;
  for(i=0;i<(g.lights||[]).length;i++){
    L=g.lights[i]; if(!L) continue;
    if(L.i0===undefined) L.i0=L.i;
    L.c=H2.lamps[Math.floor(fxr()*H2.lamps.length)];
    L.i=Math.min(H2.lampMax,Math.max(L.i0,L.i0*H2.lampI));
    if(fxr()<H2.lampP) src.push({x:L.x,y:L.y});
  }
  for(i=0;i<(m.doors||[]).length;i++){ D=m.doors[i]; if(D&&fxr()<H2.doorP) src.push({x:D.x+D.w/2,y:D.y+D.h/2}); }
  for(i=src.length-1;i>0;i--){ k=Math.floor(fxr()*(i+1)); tmp=src[i]; src[i]=src[k]; src[k]=tmp; }
  for(i=0;i<src.length&&list.length<H2.pumps;i++){
    for(j=0;j<6;j++){
      a=fxr()*6.2832; r=fxn(20,42); x=src[i].x+Math.cos(a)*r; y=src[i].y+Math.sin(a)*r;
      if(!spotFree(m,x,y,9)) continue;
      if(typeof inWaterMap==='function'&&inWaterMap(m,x,y)) continue;
      list.push({x:x,y:y,s:fxn(0.8,1.25),f:fxr()*9,lit:(fxr()<0.7)?1:0}); break;
    }
  }
  g.arcPumps=list;
  return true;
}
// the pumpkins, on the ground in world space right after the decals
function arcadePumpDraw(ox,oy,vw,vh){
  var pl=G&&G.arcPumps, i, q, s, gl, night=!isDay(), t=+(G&&G.t)||0;
  if(!pl||!pl.length||!wc) return;
  wc.save();
  for(i=0;i<pl.length;i++){
    q=pl[i];
    if(q.x<ox-30||q.x>ox+vw+30||q.y<oy-30||q.y>oy+vh+30) continue;
    s=q.s||1;
    wc.globalAlpha=0.32; wc.fillStyle='#000000';
    wc.beginPath(); wc.ellipse(q.x,q.y+5*s,9*s,3*s,0,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.fillStyle='#c4561a';
    wc.beginPath(); wc.ellipse(q.x,q.y,9*s,7*s,0,0,6.2832); wc.fill();
    wc.fillStyle='#e8762a';
    wc.beginPath(); wc.ellipse(q.x,q.y,5*s,7*s,0,0,6.2832); wc.fill();
    wc.strokeStyle='rgba(90,34,8,.7)'; wc.lineWidth=1;
    wc.beginPath(); wc.ellipse(q.x,q.y,2.6*s,6.6*s,0,0,6.2832); wc.stroke();
    wc.fillStyle='#4a5a24'; wc.fillRect(q.x-1.2*s,q.y-9.5*s,2.4*s,3.5*s);
    if(q.lit){
      gl=0.75+0.25*Math.sin(t*7+q.f)*Math.sin(t*2.3+q.f);
      wc.globalAlpha=gl; wc.fillStyle='#ffd25a';
      wc.beginPath();
      wc.moveTo(q.x-4.2*s,q.y-0.8*s); wc.lineTo(q.x-1.4*s,q.y-0.8*s); wc.lineTo(q.x-2.8*s,q.y-3.6*s); wc.closePath();
      wc.moveTo(q.x+1.4*s,q.y-0.8*s); wc.lineTo(q.x+4.2*s,q.y-0.8*s); wc.lineTo(q.x+2.8*s,q.y-3.6*s); wc.closePath();
      wc.fill();
      wc.fillRect(q.x-4*s,q.y+1.6*s,8*s,1.6*s);
      if(night){
        wc.globalCompositeOperation='lighter'; wc.globalAlpha=0.22*gl; wc.fillStyle='#ff8a2e';
        wc.beginPath(); wc.arc(q.x,q.y,16*s,0,6.2832); wc.fill();
        wc.globalCompositeOperation='source-over';
      }
    }
  }
  wc.restore();
}
// the slow violet haze, in screen space after the fog sheets; a wash, it hides nothing
function arcadeHazeDraw(){
  if(!ARCADE_HALLOW.haze||!wc||!(W>0)||!(H>0)) return;
  var t=(+(G&&G.t)||0)*0.04, i, x, y, r, gd;
  wc.save();
  wc.fillStyle='rgba(70,30,110,'+(0.045+0.015*Math.sin(t*3)).toFixed(3)+')';
  wc.fillRect(0,0,W,H);
  for(i=0;i<3;i++){
    x=((Math.sin(i*2.9+t*(0.5+i*0.13))*0.5+0.5)*(W+600))-300;
    y=((Math.sin(i*7.3+1.1+t*(0.4+i*0.09))*0.5+0.5)*(H+400))-200;
    r=420+i*90;
    gd=wc.createRadialGradient(x,y,r*0.1,x,y,r);
    gd.addColorStop(0,'rgba(120,50,170,0.07)'); gd.addColorStop(1,'rgba(120,50,170,0)');
    wc.fillStyle=gd; wc.fillRect(x-r,y-r,r*2,r*2);
  }
  wc.restore();
}
// The bubble on a shielded player (own: this window, which also gets the tag under him). Drawn on the world canvas.
'@

SubRx @'
  g.player.arcSh=1;   // v23.30 (arcade9): the spawn shield
'@ @'
  g.player.arcSh=1;   // v23.30 (arcade9): the spawn shield
  try{ arcadeHallow(g); }catch(_ah){}   // v23.43 (arcade20): the Halloween dressing, cosmetic stream only
'@

SubRx @'
  wc.fillStyle='#b08c3c';
  for(i=0;i<G.shells.length;i++){
'@ @'
  if(G.arcade&&G.arcPumps) arcadePumpDraw(ox,oy,VW,VH);   // v23.43 (arcade20): the pumpkins
  wc.fillStyle='#b08c3c';
  for(i=0;i<G.shells.length;i++){
'@

SubRx @'
  // THE SITE GOING UP. A hard white-out that ramps rather than snapping, so the
'@ @'
  if(G.arcade&&G.arcPumps) arcadeHazeDraw();   // v23.43 (arcade20): the violet haze
  // THE SITE GOING UP. A hard white-out that ramps rather than snapping, so the
'@

SubRx @'
var VER='23.42';
'@ @'
var VER='23.43';
'@

$pat = "(?m)^  now:'v23\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.43: In the arcade the lamps burn orange, carved pumpkins sit by lamps and doors, and a slow violet haze drifts over the screen, all purely decoration. Check 23.43 fails on v23.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
