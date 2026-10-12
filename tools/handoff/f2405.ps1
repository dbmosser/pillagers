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

if ($s.Contains("  {v:'24.05',what:")) { throw "check 24.05 is in the fixture already" }

SubRx @'
  {v:'24.04',what:
'@ @'
  {v:'24.05',what:'his order, the hit marker is the inside of the crosshair: a landed round flashes the centre of the reticle white, a weak spot orange and a kill red and bigger, for about 0.15 s, then the centre is the plain dot again, with no separate X; the round marks the weak spot and the kill itself, on the player 2 window too',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__keysRef||typeof drawHUD!=='function'||typeof updateBullets!=='function'||typeof hudRes!=='function'||typeof weakHit!=='function'||typeof lastTs!=='number') return 'SKIP: no raid or HUD here';
     var bad=[], g=null, p=null, en=null, ents0=null, wh0=weakHit, mx0=mouse.x, my0=mouse.y, keepTs=lastTs, own=[], ops=[], path=null, z=1, mx=0, my=0, k, f, sv=null, nv=null, linked=false,
         NM=['beginPath','moveTo','lineTo','arc','rect','fillRect','fill','stroke'],
         WKT={id:'tst',name:'TEST',ang:0,rf:0,rad:99,mult:1,eff:'none',c:'#ff8a3c'};
     function col(s){ s=String(s); var m;
       if(/^#[0-9a-f]{6}$/i.test(s)) return {r:parseInt(s.substr(1,2),16),g:parseInt(s.substr(3,2),16),b:parseInt(s.substr(5,2),16),a:1};
       m=s.match(/[\d.]+/g); if(!m||m.length<3) return null; return {r:+m[0],g:+m[1],b:+m[2],a:m.length>3?+m[3]:1}; }
     function arm(){
       NM.forEach(function(nm){
         var o=ctx[nm]; if(typeof o!=='function'||Object.prototype.hasOwnProperty.call(ctx,nm)) return; own.push(nm);
         ctx[nm]=function(){
           var a=arguments, q;
           if(nm==='beginPath') path={pts:[],segs:[],last:null};
           else if(nm==='moveTo'&&path){ path.last=[+a[0],+a[1]]; path.pts.push(path.last); }
           else if(nm==='lineTo'&&path){ q=[+a[0],+a[1]]; if(path.last) path.segs.push([path.last,q]); path.last=q; path.pts.push(q); }
           else if(nm==='arc'&&path){ path.pts.push([+a[0]-a[2],+a[1]-a[2]],[+a[0]+(+a[2]),+a[1]+(+a[2])]); }
           else if(nm==='rect'&&path){ path.pts.push([+a[0],+a[1]],[+a[0]+(+a[2]),+a[1]+(+a[3])]); }
           else if(nm==='fillRect') ops.push({k:'fill',c:col(ctx.fillStyle),pts:[[+a[0],+a[1]],[+a[0]+(+a[2]),+a[1]+(+a[3])]],segs:[]});
           else if((nm==='fill'||nm==='stroke')&&path) ops.push({k:nm,c:col(nm==='fill'?ctx.fillStyle:ctx.strokeStyle),pts:path.pts.slice(),segs:path.segs.slice()});
           return o.apply(ctx,a);
         };
       });
     }
     function disarm(){ for(var i=0;i<own.length;i++){ try{ delete ctx[own[i]]; }catch(_d){} } own=[]; }
     function draw(hm){ G.hitMark=hm; ops=[]; path=null; arm(); try{ drawHUD(); }catch(_h){ bad.push('the HUD threw: '+(_h&&_h.message||_h)); } finally{ disarm(); } G.hitMark=null; return ops; }
     function box(op){ var x0=1e9,x1=-1e9,y0=1e9,y1=-1e9,j; for(j=0;j<op.pts.length;j++){ x0=Math.min(x0,op.pts[j][0]); x1=Math.max(x1,op.pts[j][0]); y0=Math.min(y0,op.pts[j][1]); y1=Math.max(y1,op.pts[j][1]); } return {cx:(x0+x1)/2,cy:(y0+y1)/2,w:Math.min(x1-x0,y1-y0)}; }
     function centre(o){ var best=null,i,b;
       for(i=0;i<o.length;i++){
         if(o[i].k!=='fill'||!o[i].c||!(o[i].c.a>0.3)||!o[i].pts.length) continue;
         b=box(o[i]); if(Math.abs(b.cx-mx)>1.5*z||Math.abs(b.cy-my)>1.5*z||b.w>16*z) continue;
         if(!best||b.w>best.w) best={w:b.w,c:o[i].c};
       }
       return best; }
     function radial(v){ return Math.abs(v[0])>1.5*z&&Math.abs(Math.abs(v[0])-Math.abs(v[1]))<0.35*Math.abs(v[0]); }
     function xTicks(o){ var n=0,i,j,s,a,b;
       for(i=0;i<o.length;i++){ if(o[i].k!=='stroke') continue;
         for(j=0;j<o[i].segs.length;j++){ s=o[i].segs[j]; a=[s[0][0]-mx,s[0][1]-my]; b=[s[1][0]-mx,s[1][1]-my];
           if(radial(a)&&radial(b)&&Math.max(Math.abs(a[0]),Math.abs(b[0]))<30*z) n++; } }
       return n; }
     function cs(c){ return c?('rgb '+Math.round(c.r)+','+Math.round(c.g)+','+Math.round(c.b)):'nothing'; }
     function shoot(hp,wk){
       var m;
       en.x=p.x; en.y=p.y; en.hp=hp; en.roll=0; en.finished=false; en.downed=false; en.armor=0;
       g.ents.length=0; g.ents.push(en); g.bullets.length=0; G.hitMark=null;
       weakHit=function(){ return wk; };
       try{ g.bullets.push({x:en.x-6,y:en.y,vx:1180,vy:0,dmg:5,life:1,player:true,owner:p,tint:'#ffd48a',thru:0}); updateBullets(0.016); }
       finally{ weakHit=wh0; }
       m=G.hitMark; G.hitMark=null; g.bullets.length=0; return m||null;
     }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; z=hudRes()||1;
       sv={ammo:p.ammo,jam:p.jam,rl:p.reloading,ads:p.ads,iv:p.iv};
       p.jam=0; p.reloading=0; p.ads=false; p.downed=false; if(p.wep&&p.wep.mag>0) p.ammo=p.wep.mag;
       g.bagOpen=false; g.mapOpen=false;
       mouse.x=mx=Math.round(W*0.5); mouse.y=my=Math.round(H*0.4);
       // 1. real rounds from you: a hit, a weak spot, a kill, and a kill on the player 2 window, into one machine set where you stand
       for(k=0;k<g.ents.length;k++){ var e=g.ents[k]; if(e&&e.kind!=='raider'&&e.kind!=='stray'&&e.kind!=='peddler'&&e.kind!=='snitch'&&!e.merc&&e.hp>0&&!e.downed&&e.r>0){ en=e; break; } }
       if(!en) return 'SKIP: staging: no machine on this raid';
       ents0=g.ents.slice(); sv.en={x:en.x,y:en.y,hp:en.hp,armor:en.armor};
       var h1=shoot(500,null), w1=shoot(500,WKT), k1=shoot(0.1,null), k2=null;
       if(!h1) return 'SKIP: staging: the round did not land';
       if(h1.kill||h1.weak) bad.push('a plain hit marks '+(h1.kill?'a kill':'a weak spot'));
       if(!(h1.life>=0.1&&h1.life<=0.22)) bad.push('a hit marker lasts '+h1.life+' s, not about 0.15 s');
       if(!w1||!w1.weak) bad.push('a weak spot hit loses its weak mark (the plain marker writes over it)');
       if(!k1||!k1.kill) bad.push('a killing round does not mark a kill');
       else if(!(k1.life>=0.1&&k1.life<=0.25)) bad.push('a kill marker lasts '+k1.life+' s, not about 0.2 s');
       nv={on:NET.on,role:NET.role,up:NET.upSeed};
       try{ NET.on=true; NET.role='join'; NET.upSeed=(g.seed>>>0); linked=(typeof netEntsPeer==='function'&&!!netEntsPeer()); if(linked) k2=shoot(3,null); }
       finally{ NET.on=nv.on; NET.role=nv.role; NET.upSeed=nv.up; }
       if(linked){ if(!k2||!k2.kill) bad.push('on the player 2 window his killing round does not mark a kill (the host takes the health off later)'); }
       else if(String(updateBullets).indexOf('kill:'+'hitKills(en,edmg)')<0) bad.push('the round does not mark its kill with hitKills, so player 2 never sees his kill mark');
       en.x=sv.en.x; en.y=sv.en.y; en.hp=sv.en.hp; en.armor=sv.en.armor;
       g.ents.length=0; Array.prototype.push.apply(g.ents,ents0);
       // 2. the draw: the inside of the crosshair, in the hit colour
       var c0=centre(draw(null));
       if(!c0) return 'SKIP: staging: the centre of the reticle was not drawn at the aim point'+(bad.length?' ('+bad.join('; ')+')':'');
       var dh=draw({t:0.0225,life:.15,kill:false,weak:false,snd:1}), ch=centre(dh);
       if(!ch||ch.w<4*z) bad.push('a hit does not flash the inside of the crosshair (the centre is '+(ch?ch.w.toFixed(1)+' px':'not drawn')+', '+(c0.w).toFixed(1)+' px at rest)');
       else if(!(ch.c.r>=215&&ch.c.g>=215&&ch.c.b>=215)) bad.push('the hit flash is not white ('+cs(ch.c)+')');
       if(xTicks(dh)) bad.push('a hit still draws a separate X ('+xTicks(dh)+' diagonal ticks around the aim point)');
       var cw=centre(draw({t:0.0225,life:.15,kill:false,weak:true,snd:1}));
       if(!cw||cw.w<4*z||!(cw.c.r>=200&&cw.c.g>=100&&cw.c.g<=180&&cw.c.b<=90)) bad.push('a weak spot hit does not flash the centre orange ('+cs(cw&&cw.c)+')');
       var dk=draw({t:0.03,life:.2,kill:true,weak:false,snd:1}), ck=centre(dk);
       if(!ck||!(ck.c.r>=190&&ck.c.g<=110&&ck.c.b<=90)) bad.push('a kill does not flash the centre red ('+cs(ck&&ck.c)+')');
       else if(ch&&!(ck.w>=ch.w*1.25)) bad.push('the kill flash is not bigger than a hit ('+ck.w.toFixed(1)+' against '+ch.w.toFixed(1)+' px)');
       if(xTicks(dk)) bad.push('a kill still draws a separate X');
       // 3. it goes: the frame tick ages the marker out and the centre is the plain dot again
       g.ents.length=0;
       G.hitMark={t:0,life:h1.life,kill:false,weak:false,snd:1};
       var K=__keysRef();
       for(f=0;f<14;f++){ for(k in K) K[k]=false; g.waveT=-1e9; p.iv=99; __loop(lastTs+16); }
       if(G.hitMark) bad.push('the hit marker is still up '+(+G.hitMark.t||0).toFixed(2)+' s after the hit');
       g.ents.length=0; Array.prototype.push.apply(g.ents,ents0);
       var c1=centre(draw(null));
       if(c1&&c1.w>=3.5*Math.max(1,z)) bad.push('after the marker the centre of the crosshair is still '+c1.w.toFixed(1)+' px, not the plain dot');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       disarm(); try{ weakHit=wh0; }catch(_w){}
       if(nv){ try{ NET.on=nv.on; NET.role=nv.role; NET.upSeed=nv.up; }catch(_n){} }
       mouse.x=mx0; mouse.y=my0;
       try{ lastTs=keepTs; }catch(_t){}
       try{ G.hitMark=null; }catch(_m){}
       try{ if(g&&ents0){ g.ents.length=0; Array.prototype.push.apply(g.ents,ents0); } }catch(_e1){}
       try{ if(p&&sv){ p.ammo=sv.ammo; p.jam=sv.jam; p.reloading=sv.rl; p.ads=sv.ads; p.iv=sv.iv; } }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
