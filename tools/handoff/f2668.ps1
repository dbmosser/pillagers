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

if ($s.Contains("  {v:'26.68',what:")) { throw "check 26.68 is in the fixture already" }

SubRx @'
  {v:'26.67',what:
'@ @'
  {v:'26.68',what:'his words (suggestion 23): pillagers and machines fight each other without a decoy: a pillager running for the ring shoots a Sentry he meets, and a plain Warden that cannot see the player shoots at a pillager in sight',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof mkRaider!=='function'||typeof mkSentry!=='function'||typeof mkWarden!=='function'||typeof updateBullets!=='function'||typeof spotFree!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, A=null, B=null, S=null, R=null, W=null, j, i, shots=0, b, dm, minD=1e9, hitSeen=0, diag="", bb=null, trail=[], strail=[];
     function inW(x,y){ return x>60&&y>60&&x<WORLD_W-60&&y<WORLD_H-60; }
     function shotClear(sx,sy,rx,ry){
       var s0=mkSentry(sx,sy), o={kind:'raider',x:rx,y:ry,name:'probe'}, a=Math.atan2(sy-ry,sx-rx), q, ok, keep=g.ents;
       s0.elite=0; s0.hp=150; s0.maxhp=150; g.ents=[s0]; g.bullets.length=0;
       g.bullets.push({x:rx+Math.cos(a)*17,y:ry+Math.sin(a)*17,vx:Math.cos(a)*1180,vy:Math.sin(a)*1180,dmg:5,life:0.3,player:false,owner:o,tint:'#ffffff',el:'',thru:0});
       for(q=0;q<14;q++) updateBullets(1/60);
       ok=s0.hp<150; g.bullets.length=0; g.ents=keep;
       return ok;
     }
     function pairNear(){
       var k, m, a, c, sx, sy, rx, ry;
       for(k=0;k<24;k++){
         a=k/24*6.2832; sx=p.x+Math.cos(a)*320; sy=p.y+Math.sin(a)*320;
         if(!inW(sx,sy)||!spotFree(g.map,sx,sy,26)) continue;
         for(m=0;m<16;m++){
           c=m/16*6.2832; rx=sx+Math.cos(c)*130; ry=sy+Math.sin(c)*130;
           if(!inW(rx,ry)||!spotFree(g.map,rx,ry,16)) continue;
           if(Math.hypot(rx-p.x,ry-p.y)>520) continue;
           if(losClear(sx,sy,rx,ry,G.vseg)&&shotClear(sx,sy,rx,ry)) return {sx:sx,sy:sy,rx:rx,ry:ry};
         }
       }
       return null;
     }
     function pairFar(){
       var t, f, m, c, rx, ry;
       for(t=0;t<120;t++){
         f=freeSpot(g.map,40); if(Math.hypot(f.x-p.x,f.y-p.y)<950) continue;
         for(m=0;m<16;m++){
           c=m/16*6.2832; rx=f.x+Math.cos(c)*160; ry=f.y+Math.sin(c)*160;
           if(!inW(rx,ry)||!spotFree(g.map,rx,ry,16)) continue;
           if(losClear(f.x,f.y,rx,ry,G.vseg)&&shotClear(f.x,f.y,rx,ry)) return {sx:f.x,sy:f.y,rx:rx,ry:ry};
         }
       }
       return null;
     }
     function mkR(x,y,st){
       var q=mkRaider(x,y,undefined,true);
       q.elite=0; q.hostile=true; q.state=st; q.hp=100000; q.maxhp=100000; q.bag=[]; q.cd=0; q.goal=null; q.windup=null; q.wep=WEAPONS.smg; q.dmg=WEAPONS.smg.dmg; q.rng=WEAPONS.smg.rng*.72;
       return q;
     }
     try{
       if(typeof machFoe!=='function') return 'a machine is not a foe to a pillager';
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100000; p.downed=false; all=g.ents.slice();
       A=pairNear();
       if(A){
         S=mkSentry(A.sx,A.sy); S.elite=0; S.state='patrol'; S.face=Math.atan2(A.ry-A.sy,A.rx-A.sx); S.cd=9; S.hp=S.maxhp;
         R=mkR(A.rx,A.ry,"extract"); R.face=Math.atan2(A.sy-A.ry,A.sx-A.rx); S.spd=0;
         g.ents=[S,R]; g.bullets.length=0; for(j in keys) keys[j]=false;
         for(i=0;i<180;i++){ R.cd=Math.min(R.cd,0.2); __sim(1/60); for(j=0;j<g.bullets.length;j++){ if(g.bullets[j]&&g.bullets[j].owner===R){ shots++; if(shots===1){ bb=g.bullets[j]; } if(shots===1) diag='bullet '+Math.round(Math.atan2(g.bullets[j].vy,g.bullets[j].vx)*100)/100+' to S '+Math.round(Math.atan2(S.y-R.y,S.x-R.x)*100)/100+' to player '+Math.round(Math.atan2(p.y-R.y,p.x-R.x)*100)/100+' (player '+Math.round(dist(p,R))+' from R, '+Math.round(dist(p,S))+' from S) bullet at '+Math.round(g.bullets[j].x)+','+Math.round(g.bullets[j].y); break; } } updateBullets(1/60); for(j=0;j<g.bullets.length;j++){ if(g.bullets[j]&&g.bullets[j].owner===R){ dm=Math.hypot(g.bullets[j].x-S.x,g.bullets[j].y-S.y); if(dm<minD) minD=dm; } } if(S.hitT>0) hitSeen++; if(i<14){ strail.push(Math.round(S.x)+','+Math.round(S.y)+'|'+Math.round(R.x)+','+Math.round(R.y)); } if(bb&&trail.length<14){ trail.push(g.bullets.indexOf(bb)<0?'gone':(Math.round(bb.x)+','+Math.round(bb.y))); } }
         if(!(S.hp<S.maxhp)) bad.push("a pillager running for the ring, with a Sentry 130 units away in plain sight, did not hurt it (it fired on "+shots+" frames, its rounds came within "+Math.round(minD)+")");
       }
       g.ents=all.slice(); g.bullets.length=0;
       B=pairFar();
       if(B){
         shots=0; W=mkWarden(B.sx,B.sy); W.state='patrol'; W.face=Math.atan2(B.ry-B.sy,B.rx-B.sx); W.cd=0; W.seenYou=false;
         R=mkR(B.rx,B.ry,'extract'); R.face=Math.atan2(B.sy-B.ry,B.sx-B.rx);
         g.ents=[W,R]; for(j in keys) keys[j]=false;
         for(i=0;i<180;i++){
           __sim(1/60); updateBullets(1/60);
           for(j=0;j<g.bullets.length;j++){ b=g.bullets[j]; if(b&&b.owner===W){ shots++; break; } }
         }
         if(!shots) bad.push('a plain Warden that cannot see the player never fired at a pillager 160 units away in plain sight');
         W.boss=1; W.state='patrol'; shots=0; W.cd=0; g.bullets.length=0;
         for(i=0;i<180;i++){
           __sim(1/60); updateBullets(1/60);
           for(j=0;j<g.bullets.length;j++){ b=g.bullets[j]; if(b&&b.owner===W){ shots++; break; } }
         }
         if(shots) bad.push('THE OVERSEER (a boss Warden) hunted a pillager; it should keep its lair');
       }
       if(!A&&!B) return 'SKIP: no open ground for the pairs';
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(g&&all){ g.ents=all; g.bullets.length=0; } var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
