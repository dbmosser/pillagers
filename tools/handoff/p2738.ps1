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

# THE STYLE MEDALS ARE EMBLEMS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var STY={long:100,longM:45,melee:120,gren:200,grenT:0.5,multi:150,multiN:3,multiT:1.5,calm:100,calmT:30,pop:1.7,max:3,fresh:1.5};
'@ @'
var STY={long:100,longM:45,melee:120,gren:200,grenT:0.5,multi:150,multiN:3,multiT:1.5,calm:100,calmT:30,pop:4.2,max:3,fresh:1.5};   // v27.38 (partyp1): a medal stays up 4.2 s, not 1.7
'@

SubRx @'
// the ring and the medal plates, at the cursor (rx, ry are the cursor on the HUD canvas)
function styleDraw(c,p,rx,ry){
'@ @'
// v27.38 (partyp1), HIS ORDER (2026-10-14, after the party playtest, his words): "all the new features neeed to be integrated and polished up to a AAA
// level" and on the style medals "keep all of them ... need ui overhaul though -- halo does a great job with these sorts of metals". THE MEDAL ROW. A medal
// was a line of text on a small plate that rose over the cursor and was gone in under two seconds. Now each medal is an EMBLEM of its own, drawn on the
// canvas in the game's metal and amber: a chamfered badge with a rim of beaten metal (copper for the plain medals, amber for the skilled ones, bright gold
// for the rare ones), a dark field and one picture that is its alone (LONG SHOT a scope, MELEE KILL a blade, GRENADE DOUBLE two grenades, MULTI-KILL a skull,
// UNTOUCHED a shield with a tick, SCREEN CLEAR a burst, TEAM COMBO two figures in the team cyan). The newest pops in large and settles with a ring flash and a
// sweep of light across the metal; the older ones slide along the row to make room; each stays up 4.2 s (STY.pop) and fades. The row sits at the LEFT edge, in
// the clear stretch between the pillager board, the controls list and the feed (the same panel boxes the ring badge reads), and the NAME and figure of the
// newest sit on a plate under it for 2.4 s. The text of the medal also goes to the feed as one line (feedMedal, from styMedal). The old text plates at the
// cursor are gone. Cosmetic only: nothing here draws from a seeded stream, nothing runs under G.sim.
var STYM={size:25,gap:9,slide:12,pop:0.34,shine:0.8,nameT:2.4,fade:0.6,max:5};
var STY_TIER={'MELEE KILL':1,'LONG SHOT':2,'UNTOUCHED':2,'MULTI-KILL':2,'TEAM COMBO':2,'GRENADE DOUBLE':3,'SCREEN CLEAR':3};
var STY_TIERC=[null,
  {hi:'#efc08e',mid:'#b87c4a',lo:'#5e3a20',glow:'226,160,98'},
  {hi:'#ffe69a',mid:'#f5b73b',lo:'#8a5a10',glow:'255,196,74'},
  {hi:'#fffdf0',mid:'#ffd24a',lo:'#b46c0c',glow:'255,226,130'}];
var STY_ICON={
  'LONG SHOT':'M12 4a8 8 0 1 0 0 16a8 8 0 1 0 0-16zM12 1v6M12 17v6M1 12h6M17 12h6M12 11.2a.8.8 0 1 0 0 1.6a.8.8 0 1 0 0-1.6z',
  'MELEE KILL':'M20 3.5L10.5 13M5.5 12l6.5 6.5M9 15L3.5 20.5M14 21a9 9 0 0 0 7.5-8',
  'GRENADE DOUBLE':'M12 8.5a5.2 6.3 0 1 0 0 12.6a5.2 6.3 0 1 0 0-12.6zM10 8.5V5.5h4v3M14 6l4.6-1.9M7.2 14.8h9.6M19.6 3a1.4 1.4 0 1 0 0 2.8a1.4 1.4 0 1 0 0-2.8z',
  'MULTI-KILL':'M12 3a8 8 0 0 0-8 8c0 3 1.5 4.8 3 5.8V20h10v-3.2c1.5-1 3-2.8 3-5.8a8 8 0 0 0-8-8zM9 11h1M14 11h1M10 20v-2M14 20v-2M8 22.6h2M11 22.6h2M14 22.6h2',
  'UNTOUCHED':'M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6zM8.5 12l2.5 2.5L16 9.5',
  'SCREEN CLEAR':'M12 9.5a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1',
  'TEAM COMBO':'M9 8a3 3 0 1 0 0 6a3 3 0 1 0 0-6zM17 9a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM3 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4'
};
var STYBOX={n:0,x:0,y:0,w:0,h:0,s:0,free:1,items:[]};
var _styP={};
function styKey(txt){ return String(txt).replace(/\s+x\d+$/i,''); }
function styTierOf(txt){ return STY_TIER[styKey(txt)]||2; }
function styPath(key){
  if(_styP[key]===undefined){ try{ _styP[key]=new Path2D(STY_ICON[key]||UIICON.xp); }catch(_e){ _styP[key]=null; } }
  return _styP[key];
}
function styOct(c,r,u){
  c.beginPath(); c.moveTo(-r+u,-r); c.lineTo(r-u,-r); c.lineTo(r,-r+u); c.lineTo(r,r-u); c.lineTo(r-u,r); c.lineTo(-r+u,r); c.lineTo(-r,r-u); c.lineTo(-r,-r+u); c.closePath();
}
// one emblem at the middle of the current transform (s the half size, age the seconds since it popped)
function styEmblem(c,key,tier,s,age){
  var T=STY_TIERC[tier]||STY_TIERC[2], P=styPath(key), teal=(key==='TEAM COMBO'), ac=teal?'95,245,228':T.glow, u=s*0.4, k=s*0.56/12, gr, sh, i;
  c.save(); c.translate(0,s*0.08); c.fillStyle='rgba(0,0,0,.5)'; styOct(c,s,u); c.fill(); c.restore();
  gr=c.createLinearGradient(-s,-s,s,s); gr.addColorStop(0,T.hi); gr.addColorStop(0.45,T.mid); gr.addColorStop(1,T.lo);
  c.fillStyle=gr; styOct(c,s,u); c.fill();
  c.lineWidth=Math.max(1,s*0.05); c.strokeStyle='rgba(0,0,0,.45)'; styOct(c,s*0.9,u*0.9); c.stroke();
  gr=c.createRadialGradient(0,-s*0.15,s*0.1,0,0,s*0.8); gr.addColorStop(0,'#2b3137'); gr.addColorStop(1,'#0f1215');
  c.fillStyle=gr; styOct(c,s*0.78,u*0.78); c.fill();
  c.lineWidth=Math.max(1,s*0.045); c.strokeStyle='rgba('+ac+',.6)'; c.stroke();
  if(P){
    c.save(); c.scale(k,k); c.translate(-12,-12.4); c.lineCap='round'; c.lineJoin='round';
    c.lineWidth=4.6; c.strokeStyle='rgba('+ac+',.22)'; c.stroke(P);
    c.lineWidth=2.5; c.strokeStyle='rgb('+ac+')'; c.stroke(P);
    c.restore();
  }
  c.fillStyle='rgba('+ac+',.95)';
  for(i=0;i<tier;i++){ c.beginPath(); c.arc((i-(tier-1)/2)*s*0.2,s*0.7,Math.max(1,s*0.055),0,6.2832); c.fill(); }
  sh=(age-0.12)/STYM.shine;
  if(sh>0&&sh<1){
    c.save(); styOct(c,s,u); c.clip(); c.rotate(-0.55);
    gr=c.createLinearGradient(-s*0.4+(sh-0.5)*s*4.8,0,s*0.4+(sh-0.5)*s*4.8,0);
    gr.addColorStop(0,'rgba(255,255,255,0)'); gr.addColorStop(0.5,'rgba(255,255,255,.66)'); gr.addColorStop(1,'rgba(255,255,255,0)');
    c.fillStyle=gr; c.fillRect(-s*3,-s*3,s*6,s*6); c.restore();
  }
}
// where the row goes: the left edge, its middle on the middle of the screen, slid up or down to the nearest stretch clear of every panel (the pillager
// board, the controls list, the vitals, the feed, the teammate rows) that its emblems and the name plate under them need
function styMedalSpot(z,n){
  var s=Math.round(STYM.size*z), g=Math.round(STYM.gap*z), x0=Math.round(LH(9)*z), rw=n*(2*s+g)-g, up=s, dn=s+Math.round(34*z), m=Math.round(6*z), bx=[], k, B, i, c, cy=Math.round(H*0.5), best=-1, bd=1e9, free=1, cand=[];
  for(k in HUDBOX){ B=HUDBOX[k]; if(B&&B.w>0&&B.h>0) bx.push(B); }
  if(typeof EDGEBOX==='object') for(k in EDGEBOX){ B=EDGEBOX[k]; if(B&&B.w>0&&B.h>0) bx.push(B); }
  if(typeof FEEDBOX==='object'&&FEEDBOX&&FEEDBOX.on&&FEEDBOX.w>0) bx.push(FEEDBOX);
  if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.w>0) bx.push(NETTEAMBOX);
  function hit(yy){ for(var j=0;j<bx.length;j++){ var b=bx[j]; if(x0+rw>b.x&&x0<b.x+b.w&&yy+dn+m>b.y&&yy-up-m<b.y+b.h) return true; } return false; }
  if(hit(cy)){
    for(i=0;i<bx.length;i++){ B=bx[i]; if(x0+rw>B.x&&x0<B.x+B.w) cand.push(B.y-m-dn-1,B.y+B.h+m+up+1); }
    cand.push(Math.round(H*0.25),Math.round(H*0.75));
    for(i=0;i<cand.length;i++){ c=cand[i]; if(c-up<4||c+dn>H-4||hit(c)) continue; if(Math.abs(c-cy)<bd){ bd=Math.abs(c-cy); best=c; } }
    if(best>=0) cy=best; else free=0;
  }
  return {x:x0,y:cy,s:s,g:g,free:free,dn:dn};
}
// the row: the newest first at the left edge, the older ones further along. Returns how many emblems it drew.
function styMedalDraw(c,p){
  var S=G&&G.sty, z, t, i, j, live=[], pp, age, sp, s, tx, ty, sc, u, a, key, tier, dt, f, v, T, teal, rgb, nm, fg, w, hh, x, y, o;
  STYBOX.n=0; STYBOX.items.length=0;
  if(!G||G.sim||G.mapOpen||!S||!S.pops||!S.pops.length||!(G.arcade||G.career)||!p) return 0;
  t=+G.t||0; z=Math.max(1,hudRes());
  for(i=S.pops.length-1;i>=0&&live.length<STYM.max;i--){ pp=S.pops[i]; age=t-pp.t; if(age>=0&&age<=STY.pop) live.push(pp); }
  if(!live.length) return 0;
  sp=styMedalSpot(z,live.length); s=sp.s; STYBOX.s=s; STYBOX.free=sp.free;
  c.save();
  try{
    for(j=live.length-1;j>=0;j--){
      pp=live[j]; age=t-pp.t; key=styKey(pp.txt); tier=styTierOf(pp.txt); T=STY_TIERC[tier]||STY_TIERC[2]; teal=(key==='TEAM COMBO'); rgb=teal?'95,245,228':T.glow;
      tx=sp.x+s+j*(2*s+sp.g); ty=sp.y;
      if(typeof pp.sx!=='number'){ pp.sx=tx; pp.lt=t; }
      dt=Math.max(0,Math.min(0.1,t-pp.lt)); pp.lt=t; f=1-Math.exp(-dt*STYM.slide); pp.sx+=(tx-pp.sx)*f; if(Math.abs(tx-pp.sx)<0.3) pp.sx=tx;
      u=Math.min(1,age/STYM.pop); sc=1+0.8*(1-u)*(1-u);
      v=Math.min(1,(STY.pop-age)/STYM.fade); a=Math.min(1,age/0.07)*v; ty+=(1-v)*s*0.3;
      c.globalAlpha=a;
      if(tier>=3){ c.globalCompositeOperation='lighter'; c.fillStyle='rgba('+rgb+','+(0.16+0.06*Math.sin(t*5)).toFixed(3)+')'; c.beginPath(); c.arc(pp.sx,ty,s*1.9,0,6.2832); c.fill(); c.globalCompositeOperation='source-over'; }
      if(age<0.5){
        o=age/0.5; c.globalCompositeOperation='lighter'; c.globalAlpha=a*(1-o)*0.9; c.strokeStyle='rgb('+rgb+')'; c.lineWidth=Math.max(2,s*0.14*(1-o));
        c.beginPath(); c.arc(pp.sx,ty,s*(1.05+o*1.4),0,6.2832); c.stroke();
        c.fillStyle='rgba('+rgb+','+(0.35*(1-o)).toFixed(3)+')'; c.beginPath(); c.arc(pp.sx,ty,s*(1+o*0.8),0,6.2832); c.fill();
        c.globalCompositeOperation='source-over'; c.globalAlpha=a;
      }
      c.save(); c.translate(pp.sx,ty); c.scale(sc,sc); styEmblem(c,key,tier,s,age); c.restore();
      STYBOX.items.push({txt:pp.txt,key:key,tier:tier,x:pp.sx,y:ty,s:s,sc:sc,a:a});
    }
    STYBOX.items.reverse();
    pp=live[0]; age=t-pp.t;
    if(age<STYM.nameT){
      key=styKey(pp.txt); T=STY_TIERC[styTierOf(pp.txt)]||STY_TIERC[2]; teal=(key==='TEAM COMBO');
      a=Math.min(1,age/0.14)*Math.min(1,(STYM.nameT-age)/0.5);
      c.globalAlpha=a; c.font=hudFS(TYPE.label); c.textAlign='left'; c.textBaseline='alphabetic';
      nm=String(pp.txt); fg='+'+arcadeCr(pp.pts); hh=Math.round(26*z); w=Math.round(c.measureText(nm).width+c.measureText(fg).width+34*z);
      x=sp.x; y=sp.y+s+Math.round(7*z);
      hudPlate(x,y,w,hh,teal?'rgb(95,245,228)':T.mid,'rgba(8,10,13,.88)');
      c.fillStyle='rgba(255,246,222,1)'; hudText(nm,x+Math.round(13*z),y+Math.round(hh*0.5+5*z));
      c.fillStyle=teal?'rgb(95,245,228)':T.hi; c.textAlign='right'; hudText(fg,x+w-Math.round(9*z),y+Math.round(hh*0.5+5*z)); c.textAlign='left';
    }
    STYBOX.n=live.length; STYBOX.x=sp.x; STYBOX.y=sp.y-s; STYBOX.w=live.length*(2*s+sp.g)-sp.g; STYBOX.h=sp.dn+s;
  } finally { c.restore(); }
  return live.length;
}
// the ring at the cursor (the medals are the row at the left edge now, styMedalDraw)
function styleDraw(c,p,rx,ry){
'@

SubRx @'
  if(S&&S.pops&&S.pops.length){
    c.font=hudFS(TYPE.label); c.textAlign='center'; n=0;
    for(i=S.pops.length-1;i>=0&&n<STY.max;i--){
      pp=S.pops[i]; age=t-pp.t; if(age<0||age>STY.pop) continue;
      a=Math.min(1,age/0.12)*Math.min(1,(STY.pop-age)/0.4);
      y=ry-r-(14+n*24)*z-Math.min(age,0.5)*22*z;
      str=pp.txt+'  +'+arcadeCr(pp.pts); tw=c.measureText(str).width; hh=20*z;
      c.globalAlpha=0.78*a; c.fillStyle='rgba(12,14,18,1)'; c.fillRect(Math.round(rx-tw/2-9*z),Math.round(y-hh*0.72),Math.round(tw+18*z),Math.round(hh));
      c.globalAlpha=a; c.fillStyle='rgba(255,192,74,1)'; c.fillRect(Math.round(rx-tw/2-9*z),Math.round(y-hh*0.72),Math.round(3*z),Math.round(hh));
      c.fillStyle='rgba(255,236,196,1)'; hudText(str,Math.round(rx),Math.round(y));
      n++;
    }
  }
'@ @'
  // v27.38 (partyp1): the medal plates that rose over the ring are gone; the medals are the emblem row at the left edge (styMedalDraw)
'@

SubRx @'
  try{ pwrDraw2(ctx,p); }catch(_pwd2){}   // v26.xx (party3): the shield bubble and the screen clear wave
'@ @'
  try{ pwrDraw2(ctx,p); }catch(_pwd2){}   // v26.xx (party3): the shield bubble and the screen clear wave
  try{ styMedalDraw(ctx,p); }catch(_smd){}   // v27.38 (partyp1): the medal row at the left edge
'@

SubRx @'
var VER='27.37';
'@ @'
var VER='27.38';
'@

$pat = "(?m)^  now:'v27\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.38: Each style medal is a metal emblem in a row at the left, the newest popping in with its name under it. Check 27.38 fails on v27.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
