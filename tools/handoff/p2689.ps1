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

# MAGNET, SHIELD BUBBLE AND SCREEN CLEAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // PWR-KINDS (the next party builds add their rows above this line)
'@ @'
  {k:'mag',n:'MAGNET',sec:20,w:12,hex:'#4aa8ff',rgb:'74,168,255'},
  {k:'shield',n:'SHIELD BUBBLE',sec:10,w:16,hex:'#4ff0e0',rgb:'79,240,224'},
  {k:'pulse',n:'SCREEN CLEAR',sec:0,w:10,hex:'#c88bff',rgb:'200,139,255'},
  // PWR-KINDS (the next party builds add their rows above this line)
'@

SubRx @'
  // PWR-SND (the next party builds add their notes above this line)
'@ @'
  mag:[[0,1200,300,0.35,'sine',0.06],[0.1,300,900,0.3,'sine',0.04]],
  shield:[[0,1047,1047,0.5,'sine',0.05],[0,1568,1568,0.5,'sine',0.03],[0.08,2093,2093,0.4,'sine',0.02]],
  pulse:[[0,140,35,0.7,'sine',0.12],[0,420,70,0.5,'square',0.05],[0.05,1800,200,0.4,'sawtooth',0.03]],
  shhit:[[0,1900,1200,0.08,'triangle',0.04]],
  // PWR-SND (the next party builds add their notes above this line)
'@

SubRx @'
  // PWR-GLYPHS (the next party builds add their glyphs above this line)
'@ @'
  else if(k==='mag'){
    c.beginPath(); c.arc(x,y+s*0.15,s*0.6,0,3.1416); c.stroke();
    c.beginPath(); c.moveTo(x-s*0.6,y+s*0.15); c.lineTo(x-s*0.6,y-s*0.6); c.moveTo(x+s*0.6,y+s*0.15); c.lineTo(x+s*0.6,y-s*0.6); c.stroke();
    c.fillStyle='rgba(255,255,255,1)'; c.fillRect(x-s*0.85,y-s*0.9,s*0.5,s*0.32); c.fillRect(x+s*0.35,y-s*0.9,s*0.5,s*0.32);
  }
  else if(k==='shield'){
    c.beginPath(); c.moveTo(x,y-s); c.lineTo(x+s*0.8,y-s*0.55); c.lineTo(x+s*0.8,y+s*0.15); c.lineTo(x,y+s); c.lineTo(x-s*0.8,y+s*0.15); c.lineTo(x-s*0.8,y-s*0.55); c.closePath(); c.stroke();
  }
  else if(k==='pulse'){
    c.beginPath(); c.arc(x,y,s*0.28,0,6.2832); c.fill();
    c.beginPath(); c.arc(x,y,s*0.65,0,6.2832); c.stroke();
    c.beginPath(); c.arc(x,y,s*1.0,-0.8,0.8); c.stroke(); c.beginPath(); c.arc(x,y,s*1.0,2.34,3.94); c.stroke();
  }
  // PWR-GLYPHS (the next party builds add their glyphs above this line)
'@

SubRx @'
try{ say(D.n,'ext',{sub:D.sec+' S'}); }catch(_s){}
'@ @'
try{ say(D.n,'ext',D.sec>0?{sub:D.sec+' S'}:undefined); }catch(_s){}
'@

SubRx @'
  try{ styTone(PWR_SND[it.k]); }catch(_t){}
'@ @'
  try{ styTone(PWR_SND[it.k]); }catch(_t){}
  if(it.k==='pulse'){ try{ pwrPulse(p); }catch(_pp){} }   // v26.xx (party3): the screen clear goes off at once
'@

SubRx @'
  if(S.act.clip>0&&p.wep&&p.wep.mag>0){ p.ammo=p.wep.mag; p.reloading=0; p.jam=0; }
'@ @'
  if(S.act.clip>0&&p.wep&&p.wep.mag>0){ p.ammo=p.wep.mag; p.reloading=0; p.jam=0; }
  pwrTick2(p,dt,S);   // v26.xx (party3): the magnet, the pulse clock and the bubble flash
'@

SubRx @'
  try{ pwrDraw(ctx,p); }catch(_pwd){}   // v26.xx (party2): the power-ups on the floor, the aura and the timer chips
'@ @'
  try{ pwrDraw(ctx,p); }catch(_pwd){}   // v26.xx (party2): the power-ups on the floor, the aura and the timer chips
  try{ pwrDraw2(ctx,p); }catch(_pwd2){}   // v26.xx (party3): the shield bubble and the screen clear wave
'@

SubRx @'
  // v23.30 (arcade9): the arcade spawn shield takes the hit, above every stamp, and sparks teal on the bubble
'@ @'
  if(G&&!G.sim&&G.player&&pwrOn('shield')){ try{ pwrShieldHit(sx,sy); }catch(_psh){} return; }   // v26.xx (party3): the shield bubble takes the hit
  // v23.30 (arcade9): the arcade spawn shield takes the hit, above every stamp, and sparks teal on the bubble
'@

SubRx @'
// PARTY-MODULE-END (the next party builds add their code above this line)
'@ @'
// v26.xx (party3), HIS YES (2026-10-14) to suggestion 40, the other three power-ups. They join the drops of party2 (the same rolls, three more kinds on the
// table). MAGNET (20 s): loose wrecks and bodies that still hold something, and the pickups on the floor, slide toward you from PWRX.magR (52 m) and stop
// at your feet; a wreck never slides through a wall or out of a shut room, and not while you search it. SHIELD BUBBLE (10 s): a bubble round you takes every
// hit, from a round to a blast to a fire, with a flash and a ping (above the arcade spawn shield). SCREEN CLEAR (at once): a pulse leaves you, and every
// ordinary machine on the screen dies (crawler, snitch, sentry, listener, howler, bulwark); bosses, elites, wardens, the pillbox and pillagers are not
// touched. Those machines are credited to nobody (no streak, no kill count): the pulse pays a flat PWRX.pulsePer (30) for each, up to PWRX.pulseMax (400),
// as a medal. In a linked window the machines are the host's, so the pulse is sent as a killing blow of the player's own. Live play only.
var PWRX={magR:520,magSp:340,magPick:520,magStop:56,pulsePer:30,pulseMax:400,pulseT:0.8,flash:0.3};
function pwrMagnet(p,dt,S){
  var i, c, it, d, st, nx, ny, mt={body:1,botwreck:1,cache:1};
  for(i=0;i<S.items.length;i++){
    it=S.items[i]; d=Math.hypot(p.x-it.x,p.y-it.y);
    if(d<PWRX.magR*1.3&&d>PWR.pick*0.5){ st=Math.min(d,PWRX.magPick*dt); it.x+=(p.x-it.x)/d*st; it.y+=(p.y-it.y)/d*st; }
  }
  for(i=0;G.containers&&i<G.containers.length;i++){
    c=G.containers[i];
    if(!c||!mt[c.type]||!c.loot||!c.loot.length||G.searching===c) continue;
    d=Math.hypot(p.x-c.x,p.y-c.y); if(d>PWRX.magR||d<=PWRX.magStop) continue;
    st=Math.min(d-PWRX.magStop,PWRX.magSp*dt); nx=c.x+(p.x-c.x)/d*st; ny=c.y+(p.y-c.y)/d*st;
    if(spotFree(G.map,nx,ny,12)&&!shutRoomAt(G.map,nx,ny)&&!shutRoomAt(G.map,c.x,c.y)){ c.x=nx; c.y=ny; if(fxr()<dt*4) spark(c.x,c.y,'#7fc4ff',2,60); }
  }
}
function pwrTick2(p,dt,S){
  if(S.act.mag>0) pwrMagnet(p,dt,S);
  if(S.pulse){ S.pulse.t+=dt; if(S.pulse.t>=PWRX.pulseT) S.pulse=null; }
  if(S.shFlash>0) S.shFlash-=dt;
}
function pwrShieldHit(sx,sy){
  var S=pwrS(), p=G.player, a, t=+G.t||0;
  S.shFlash=PWRX.flash;
  a=(sx!==undefined&&isFinite(sx)&&isFinite(sy))?Math.atan2(sy-p.y,sx-p.x):-1.5708;
  try{ spark(p.x+Math.cos(a)*24,p.y-14+Math.sin(a)*26,'#7ffcf0',8,170); }catch(_a){}
  if(t-(S.shSnd===undefined?-9:S.shSnd)>0.15){ S.shSnd=t; try{ styTone(PWR_SND.shhit); }catch(_b){} }
  return true;
}
// the screen clear: every ordinary machine on the screen dies. Returns how many.
function pwrPulse(p){
  var S=pwrS(), D=pwrDef('pulse'), K={crawler:1,snitch:1,sentry:1,listener:1,howler:1,bulwark:1}, i, e, s, n=0, net=!!(NET.on&&netEntsPeer());
  S.pulse={t:0,x:p.x,y:p.y};
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!e||!K[e.kind]||!(e.hp>0)||e.boss||e.elite||e.downed||e.finished||e.neutral) continue;
    s=w2s(e.x,0,e.y); if(s.x<-40||s.y<-40||s.x>W+40||s.y>H+40) continue;
    if(net) netShotSend(e,9999,Math.atan2(e.y-p.y,e.x-p.x),null);
    else { e.hp=0; e.byPlayer=false; e.bySeat=0; }
    e.hitT=0.2; n++;
    try{ spark(e.x,e.y,D.hex,10,260); }catch(_s){}
  }
  G.shake=Math.max(G.shake||0,10);
  if(!net&&n>0) styMedal('SCREEN CLEAR',Math.min(PWRX.pulseMax,PWRX.pulsePer*n),p.x,p.y-30);
  return n;
}
// the shield bubble round the player, and the wave and flash of a screen clear
function pwrDraw2(c,p){
  var S=G&&G.pwr, q, z, t, sc, R, a, fl, gr, k, ang, f, o, cy;
  if(!S||G.sim||!(G.arcade||G.career)||!p) return;
  q=ZOOM(); z=Math.max(1,hudRes()); t=+G.t||0;
  c.save();
  if(S.act.shield>0){
    sc=w2s(p.x,0,p.y); R=34*q; cy=sc.y-14*q; fl=Math.max(0,(S.shFlash||0)/PWRX.flash);
    a=(S.act.shield<=PWR.warn&&(Math.floor(S.act.shield*5)%2))?0.4:1;
    c.globalAlpha=a; c.globalCompositeOperation='lighter';
    gr=c.createRadialGradient(sc.x,cy,R*0.5,sc.x,cy,R);
    gr.addColorStop(0,'rgba(79,240,224,0)'); gr.addColorStop(1,'rgba(79,240,224,'+(0.22+0.5*fl).toFixed(3)+')');
    c.fillStyle=gr; c.beginPath(); c.arc(sc.x,cy,R,0,6.2832); c.fill();
    c.strokeStyle='rgba(150,255,245,'+(0.55+0.4*fl).toFixed(3)+')'; c.lineWidth=2*z; c.beginPath(); c.arc(sc.x,cy,R,0,6.2832); c.stroke();
    c.lineWidth=1.2*z; c.strokeStyle='rgba(120,250,236,.38)';
    for(k=0;k<6;k++){ ang=t*0.6+k*1.0472; c.beginPath(); c.arc(sc.x,cy,R*0.82,ang,ang+0.55); c.stroke(); }
  }
  if(S.pulse){
    f=Math.max(0,Math.min(1,S.pulse.t/PWRX.pulseT)); o=w2s(S.pulse.x,0,S.pulse.y);
    c.globalAlpha=1; c.globalCompositeOperation='lighter';
    c.strokeStyle='rgba(214,170,255,'+(0.85*(1-f)).toFixed(3)+')'; c.lineWidth=(14*(1-f)+2)*z;
    c.beginPath(); c.arc(o.x,o.y,Math.max(4,f*Math.hypot(W,H)*0.9),0,6.2832); c.stroke();
    c.fillStyle='rgba(235,220,255,'+(0.22*(1-f)*(1-f)).toFixed(3)+')'; c.fillRect(0,0,W,H);
  }
  c.restore();
}
// PARTY-MODULE-END (the next party builds add their code above this line)
'@

SubRx @'
var VER='26.88';
'@ @'
var VER='26.89';
'@

$pat = "(?m)^  now:'v26\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.89: Three more power-ups drop: a magnet, a shield bubble and a screen clear. Check 26.89 fails on v26.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
