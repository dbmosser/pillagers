$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'31.22',what:")) { throw "check 31.22 is in the fixture already" }

SubRx @'
  {v:'31.21',what:
'@ @'
  {v:'31.22',what:'cw-meleebreak, his note (2026-10-18 11:42): the crowbar breaks what bullets break, through damageWall: one swing breaks a window (debris, glass sound, sight map rebuilt), a swing at a building wall wears it down bar and all and breaks it as a shot wall breaks, the map edge and a locked room are untouched, destruction off protects glass, a body in the way takes the blow instead, and player 2 swing asks the host which breaks it and tells every window',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof meleeStrike!=='function'||typeof damageWall!=='function'||typeof wallHp!=='function'||typeof mkCrawler!=='function'||typeof netOnMsg!=='function'||typeof netEntsInit!=='function') return 'SKIP: this fixture cannot stage a swing at a wall';
     if(typeof NET==='object'&&NET&&NET.on) return 'SKIP: a party is live';
     var bad=[], g=null, p=null, W=null, E0=null, i, k, w, w2, spot, n, c, n0, d0, dw0, bars0, res, sfxLog=[], oSfx=sfx, oS=netSend, oSF=netSendFast, NK={}, sent=[], dest0, pa={state:'in',seat:1}, pb={state:'in',seat:2}, ha={state:'in',seat:0}, used=[];
     for(k in NET) NK[k]=NET[k];
     dest0=CFG.destruct;
     function clr(){ for(var z in keys) keys[z]=false; }
     function free(x,y){ var j, q, cx, cy, dx, dy; for(j=0;j<W.length;j++){ q=W[j]; cx=Math.max(q.x,Math.min(x,q.x+q.w)); cy=Math.max(q.y,Math.min(y,q.y+q.h)); dx=x-cx; dy=y-cy; if(dx*dx+dy*dy<15*15) return false; } return true; }
     function clearTo(x,y,t,fx,fy){ var j, q, s, px, py; for(s=0;s<=1;s+=0.1){ px=x+(fx-x)*s; py=y+(fy-y)*s; for(j=0;j<W.length;j++){ q=W[j]; if(q===t) continue; if(px>q.x-1&&px<q.x+q.w+1&&py>q.y-1&&py<q.y+q.h+1) return false; } } return true; }
     // a free place 30 off the face of the wall, inside the world, with nothing between, looking straight at it
     function spotFor(t){
       var xs=[t.x+t.w/2,t.x+t.w*0.25,t.x+t.w*0.75], ys=[t.y+t.h/2,t.y+t.h*0.25,t.y+t.h*0.75], sd=[[0,-1],[0,1],[-1,0],[1,0]], a, b, x, y, fx, fy;
       for(a=0;a<4;a++) for(b=0;b<3;b++){
         if(sd[a][0]===0){ x=xs[b]; y=(sd[a][1]<0)?t.y-30:t.y+t.h+30; fx=x; fy=(sd[a][1]<0)?t.y:t.y+t.h; }
         else { y=ys[b]; x=(sd[a][0]<0)?t.x-30:t.x+t.w+30; fy=y; fx=(sd[a][0]<0)?t.x:t.x+t.w; }
         if(x<60||y<60||x>WORLD_W-60||y>WORLD_H-60) continue;
         if(free(x,y)&&clearTo(x,y,t,fx,fy)) return {x:x,y:y,face:Math.atan2(-sd[a][1],-sd[a][0])};
       }
       return null;
     }
     function find(pred){ var j, t, s; for(j=0;j<W.length;j++){ t=W[j]; if(used.indexOf(t)>=0||!pred(t)) continue; s=spotFor(t); if(s){ used.push(t); return {w:t,s:s}; } } return null; }
     function stand(s){ p.x=s.x; p.y=s.y; p.face=s.face; g.ents=[]; }
     function swing(){ p.meleeAt=undefined; p.lastShot=undefined; p.cooking=0; p.downed=false; p.dying=false; p.roll=0; g.searching=null; g.trade=null; g.paused=false; g.t+=0.5; clr(); return meleeStrike(); }
     function sound(mat){ return sfxLog.some(function(a){ return a[0]==='clank'&&a[3]===mat; }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.map) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       if(CFG.destruct===0) return 'SKIP: staging: destruction is off';
       W=g.map.walls; E0=g.ents; p.iv=99; clr();
       sfx=function(){ sfxLog.push([].slice.call(arguments)); return oSfx.apply(this,arguments); };
       // A: one swing breaks a window, with its debris and its glass, and the sight map is rebuilt
       res=find(function(t){ return t.win&&wallHp(t)===25; });
       if(!res) return 'SKIP: staging: no window with a free place to stand';
       w=res.w; stand(res.s); n0=g.map.wsegs.length; d0=g.tel.wallsDown||0; g.sparks.length=0; sfxLog.length=0;
       if(!swing()) bad.push('A: the swing was refused');
       if(W.indexOf(w)>=0) bad.push('A: one swing did not break the window (health left '+w.hpLeft+')');
       else {
         if(g.map.wsegs.length!==n0-4) bad.push('A: the window went but the sight map was not rebuilt ('+n0+' to '+g.map.wsegs.length+' glass edges)');
         if((g.tel.wallsDown||0)!==d0+1) bad.push('A: the broken window was not counted as a wall down');
       }
       if(!(g.sparks.length>0)) bad.push('A: no debris flew');
       if(!sound('glass')) bad.push('A: the window gave no glass sound');
       // B: a building wall is worn down, bar and all, and breaks as a shot wall breaks
       res=find(function(t){ return !t.win&&t._bw&&wallHp(t)===320&&(t.w>=60||t.h>=60); });
       if(!res) return 'SKIP: staging: no building wall with a free place to stand';
       w=res.w; stand(res.s); n0=g.map.segs.length; d0=g.tel.wallsDown||0; bars0=(g.dmgWalls||[]).length;
       swing();
       if(W.indexOf(w)<0) bad.push('B: one swing broke a building wall of 320');
       else if(!(w.hpLeft>0&&w.hpLeft<320)) bad.push('B: one swing left a building wall at '+w.hpLeft+' of 320');
       else if((g.dmgWalls||[]).indexOf(w)<0) bad.push('B: the hurt wall wears no bar');
       for(n=1;n<16&&W.indexOf(w)>=0;n++) swing();
       if(W.indexOf(w)>=0) bad.push('B: sixteen swings did not break a building wall of 320');
       else {
         if(n<2||n>10) bad.push('B: a building wall of 320 broke in '+n+' swings');
         k=n0-g.map.segs.length;
         if((g.tel.wallsDown||0)!==d0+1) bad.push('B: the wall went but was not counted as a wall down');
         // the control: the same sort of wall shot down by the one door a bullet uses
         res=find(function(t){ return !t.win&&t._bw&&wallHp(t)===320; });
         if(res){ n0=g.map.segs.length; damageWall(res.w,5000,res.w.x+res.w.w/2,res.w.y+res.w.h/2); if(n0-g.map.segs.length!==k) bad.push('B: a swing-broken wall took '+k+' sight edges with it, a shot-broken one '+(n0-g.map.segs.length)); }
       }
       // C: what a bullet cannot break stays whole: the map edge, a locked room shell, a keyed door, a stronghold
       [function(t){ return t.noDes&&t.sh===undefined; },function(t){ return !!t.lockWall; },function(t){ return !!t.door; },function(t){ return t.noDes&&t.sh!==undefined; }].forEach(function(pred,ix){
         var r2=find(pred), l0, ok0;
         if(!r2) return;
         stand(r2.s); l0=(g.dmgWalls||[]).length; g.sparks.length=0; ok0=W.indexOf(r2.w)>=0;
         swing();
         if(r2.w.hpLeft!==undefined) bad.push('C'+ix+': a swing at a wall that cannot break wore it to '+r2.w.hpLeft);
         if(W.indexOf(r2.w)>=0!==ok0) bad.push('C'+ix+': a swing broke a wall that cannot break');
         if((g.dmgWalls||[]).length!==l0) bad.push('C'+ix+': a swing at a wall that cannot break put it on the hurt list');
       });
       // D: destruction off protects glass too
       res=find(function(t){ return t.win&&wallHp(t)===25; });
       if(res){ stand(res.s); CFG.destruct=0; swing(); CFG.destruct=dest0; if(W.indexOf(res.w)<0||res.w.hpLeft!==undefined) bad.push('D: with destruction off a swing still hurt a window'); }
       // E: a body in the way takes the blow, the window behind it is not struck
       res=find(function(t){ return t.win&&wallHp(t)===25; });
       if(res){
         stand(res.s); c=mkCrawler(p.x,p.y); c.x=p.x+Math.cos(p.face)*22; c.y=p.y+Math.sin(p.face)*22; c.face=p.face+Math.PI; c.downed=false; c.finished=0; c.roll=0; c.merc=0; c.friendlyPC=0; g.ents=[c];
         swing();
         if(!(c.hp<c.maxhp)) bad.push('E: the crawler in front of the window took no blow');
         if(W.indexOf(res.w)<0||res.w.hpLeft!==undefined) bad.push('E: the window behind the crawler was struck as well');
       }
       // F: a shared raid: player 2 swing asks the host and does not break its own copy; the host breaks it and tells every window; the host swing is told to the party
       netSend=function(q,m){ sent.push({q:q,m:m}); return true; }; netSendFast=netSend;
       NET.specG=null; NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[ha]; NET.up=[];
       res=find(function(t){ return t.win&&wallHp(t)===25&&t.wid!==undefined; });
       if(res){
         w=res.w; stand(res.s); sent.length=0; swing();
         k=sent.filter(function(x){ return x.m&&x.m.t==='wdmg'; });
         if(!k.length||k[0].m.id!==w.wid||!(k[0].m.a>=25)) bad.push('F: player 2 swing at a window did not ask the host to break it ('+k.length+' asks)');
         if(W.indexOf(w)<0) bad.push('F: player 2 broke his own copy of the window');
         sent.length=0; NET.role='host'; NET.seat=0; NET.peers=[pa,pb];
         if(k.length){ res=netOnMsg(pa,JSON.stringify({t:'wdmg',sd:g.seed>>>0,id:w.wid,a:k[0].m.a})); if(W.indexOf(w)>=0) bad.push('F: the host did not break the window player 2 swung at ('+res+')'); }
         k=sent.filter(function(x){ return x.m&&x.m.t==='wall'; });
         if(k.length!==2) bad.push('F: the host did not tell both windows the window fell ('+k.length+' words)');
       } else bad.push('F: no window with a build number to stage player 2 on');
       res=find(function(t){ return t.win&&wallHp(t)===25&&t.wid!==undefined; });
       if(res){
         w=res.w; stand(res.s); sent.length=0; NET.role='host'; NET.seat=0; NET.peers=[pa,pb]; swing();
         k=sent.filter(function(x){ return x.m&&x.m.t==='wall'&&x.m.id===w.wid; });
         if(W.indexOf(w)>=0) bad.push('F: the host swing did not break the window');
         else if(k.length!==2) bad.push('F: the party was not told of the window the host broke with a swing ('+k.length+' words)');
       }
       return bad.length?bad.join('; '):null;
     } finally {
       try{ sfx=oSfx; netSend=oS; netSendFast=oSF; for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }catch(_n){}
       try{ CFG.destruct=dest0; if(g){ g.sim=false; g.barT=0; g.punchT=0; g.shake=0; g.sparks.length=0; if(E0) g.ents=E0; } }catch(_g){}
       try{ clr(); }catch(_m){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       try{ __resetCfg(); }catch(_c){}
       __topClear(); __cleanProfile();
     } }},
  {v:'31.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
