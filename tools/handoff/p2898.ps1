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

# RED BARRELS LEAVE FIRE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function brlTick(dt){
  var i, B;

'@ @'
// v28.xx (cw-barrelfire), HIS ORDER (2026-10-15): "Red barrels: after the first explosion, also leave fire that deals damage over time." A barrel that
// blows leaves a small fire on the spot (BRL_FIRE_R wide, it burns BRL_FIRE_LIFE seconds and glows 1.5 more). Whoever stands in it is burned: the player
// 5 every half second (never a fire a teammate lit, his rule of no team damage), machines and pillagers 22 a second (the host window runs the bodies, and
// whoever the fire kills is credited to the seat that lit the barrel). It never blocks a way, unlike the fuel fires of the raid flow, and it is the window's
// own list (G.bfire), so each window lays it from its own copy of the blast. Cosmetic draws use no seeded stream.
var BRL_FIRE_R=64, BRL_FIRE_LIFE=7, BRL_FIRE_EMB=1.5, BRL_FIRE_PL=5, BRL_FIRE_EN=22;
function brlFireAdd(x,y,by){
  if(!G||G.sim) return null;
  if(!G.bfire) G.bfire=[];
  if(G.bfire.length>=40) G.bfire.shift();
  var f={x:x,y:y,r:BRL_FIRE_R,t:0,life:BRL_FIRE_LIFE,by:by,bt:0};
  G.bfire.push(f); return f;
}
function brlFireTick(dt){
  var F=G.bfire, i, j, f, p=G.player, e, a, rr2, me=brlMe(), peer=netEntsPeer();
  for(i=F.length-1;i>=0;i--){
    f=F[i]; f.t+=dt;
    if(f.t>=f.life+BRL_FIRE_EMB){ F.splice(i,1); continue; }
    if(f.t>=f.life) continue;
    if(fxr()<dt*6){ a=fxn(0,6.2832); rr2=fxn(0,f.r*0.8); spark(f.x+Math.cos(a)*rr2,f.y+Math.sin(a)*rr2*0.6,'#ff9a3c',2,80); }
    if(p&&!p.specOut&&!p.dying&&!p.downed&&(f.by<0||f.by===me)&&Math.hypot(p.x-f.x,p.y-f.y)<f.r+(p.r||11)&&losClear(f.x,f.y,p.x,p.y,G.map.segs)){
      f.bt+=dt;
      if(f.bt>=0.5){ f.bt=0; damagePlayer(BRL_FIRE_PL,'fire','BARREL FIRE',f.x,f.y); }
    }
    if(peer) continue;
    for(j=0;j<G.ents.length;j++){
      e=G.ents[j];
      if(!e||!(e.hp>0)||e.finished||e.kind==='snitch') continue;
      if(f.by>=0&&e.merc&&!e.downed) continue;
      if(Math.hypot(e.x-f.x,e.y-f.y)<f.r+(e.r||12)&&losClear(f.x,f.y,e.x,e.y,G.map.segs)){
        e.hp-=BRL_FIRE_EN*dt; e.hitT=Math.max(e.hitT||0,0.1);
        if(e.hp<=0&&f.by>=0){ e.byPlayer=(f.by===0); e.bySeat=(f.by>0)?f.by:0; }
      }
    }
  }
}
function brlFireDraw(f){
  var t=(G&&G.t)||0, fade=(f.t<f.life)?1:Math.max(0,1-(f.t-f.life)/BRL_FIRE_EMB), R=f.r, x=f.x, y=f.y, j, n=10, ang, bx, by, hh, ww, gr;
  if(fade<=0) return;
  wc.save();
  wc.fillStyle='rgba(22,10,6,'+(0.40*fade).toFixed(3)+')'; wc.beginPath(); wc.ellipse(x,y,R,R*0.6,0,0,6.2832); wc.fill();
  wc.globalCompositeOperation='lighter';
  gr=wc.createRadialGradient(x,y,R*0.15,x,y,R*1.25);
  gr.addColorStop(0,'rgba(255,150,50,'+(0.40*fade).toFixed(3)+')'); gr.addColorStop(0.7,'rgba(255,90,20,'+(0.20*fade).toFixed(3)+')'); gr.addColorStop(1,'rgba(255,60,10,0)');
  wc.fillStyle=gr; wc.beginPath(); wc.ellipse(x,y,R*1.25,R*0.8,0,0,6.2832); wc.fill();
  if(fade>=1){
    for(j=0;j<n;j++){
      ang=j/n*6.2832+0.3*Math.sin(t*1.3+j);
      bx=x+Math.cos(ang)*R*0.62; by=y+Math.sin(ang)*R*0.62*0.6;
      hh=R*(0.55+0.4*Math.abs(Math.sin(t*6.5+j*1.9))); ww=R*0.16;
      wc.fillStyle=(j&1)?'rgba(255,214,120,.55)':'rgba(255,128,36,.5)';
      wc.beginPath(); wc.moveTo(bx-ww,by); wc.quadraticCurveTo(bx-ww*0.3,by-hh*0.6,bx+Math.sin(t*5+j)*R*0.06,by-hh); wc.quadraticCurveTo(bx+ww*0.3,by-hh*0.6,bx+ww,by); wc.closePath(); wc.fill();
    }
  }
  wc.restore();
}
function brlTick(dt){
  var i, B;
  if(G&&G.bfire&&G.bfire.length) brlFireTick(dt);   // v28.xx (cw-barrelfire): the fires the blasts left

'@

SubRx @'
  ping(x,y,600,false,false,'env','fire');

'@ @'
  ping(x,y,600,false,false,'env','fire');
  brlFireAdd(x,y,s);   // v28.xx (cw-barrelfire): HIS ORDER, after the first explosion the barrel also leaves fire that deals damage over time

'@

SubRx @'
    DR.push({k:_bz.y,fn:brlDraw.bind(null,_bz)});
  }

'@ @'
    DR.push({k:_bz.y,fn:brlDraw.bind(null,_bz)});
  }
  for(i=0;i<(G.bfire||[]).length;i++){   // v28.xx (cw-barrelfire): the fire a blast left, sorted with the world
    var _bf=G.bfire[i];
    if(_bf.x<ox-100||_bf.x>ox+VW+100||_bf.y<oy-100||_bf.y>oy+VH+100) continue;
    DR.push({k:_bf.y-30,fn:brlFireDraw.bind(null,_bf)});
  }

'@

SubRx @'
var VER='28.97';
'@ @'
var VER='28.98';
'@

$pat = "(?m)^  now:'v28\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.98: A red barrel that blows up now leaves a fire that burns anyone standing in it for a few seconds. Check 28.98 fails on v28.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
