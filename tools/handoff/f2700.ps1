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

if ($s.Contains("  {v:'27.00',what:")) { throw "check 27.00 is in the fixture already" }

SubRx @'
  {v:'26.99',what:
'@ @'
  {v:'27.00',what:'career3, his yes to the needed-item glow (31): what an unfinished contract still needs is worked out (the lift kit does not count, a finished card needs nothing, the arcade has none), a shut box that holds it glows in the world and stops when it is empty or opened, and the item glows in the backpack and the pickup stack',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__w2s&&window.__drawBagWith&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof needItems!=='function') return 'there is no needed-item glow in this build';
     if(typeof mkContainer!=='function'||typeof setLoot!=='function'||typeof drawPickups!=='function'||typeof spotFree!=='function') return 'SKIP: no raid pieces here';
     var bad=[], snap=null, g=null, p=null, q, o, ct, ct2, sp, k, aa, x, y, a, b, c, n1, n2, rec=[], oSR=null, r2, cv, c2, ar0, bo0, pk0, srcs, c0=(typeof CAREER_ON==='number')?CAREER_ON:0;
     function diffNear(s,t,sx,sy){
       var W=cv.width,H=cv.height,d=0,x0=Math.max(0,Math.round(sx-200)),x1=Math.min(W,Math.round(sx+200)),y0=Math.max(0,Math.round(sy-200)),y1=Math.min(H,Math.round(sy+200)),yy,xx,i;
       for(yy=y0;yy<y1;yy++){ for(xx=x0;xx<x1;xx++){ i=(yy*W+xx)*4; if(Math.abs(s[i]-t[i])+Math.abs(s[i+1]-t[i+1])+Math.abs(s[i+2]-t[i+2])>8) d++; } }
       return d;
     }
     function shot(){ __frame(0); return c2.getImageData(0,0,cv.width,cv.height).data; }
     function strokes(fn){
       var out=[];
       oSR=ctx.strokeRect;
       ctx.strokeRect=function(){ out.push(String(this.strokeStyle)); return oSR.apply(this,arguments); };
       try{ fn(); } finally { delete ctx.strokeRect; if(ctx.strokeRect!==oSR) ctx.strokeRect=oSR; }
       return out;
     }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); var CONS=[{type:'exItem',item:'board',n:2,prog:0,reward:100,desc:'Extract carrying 2x Circuit Board'},{type:'kill',tgt:'sentry',n:3,prog:0,reward:10,desc:'Destroy 3 sentries'}];
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false; g.ents.length=0;
       cv=document.getElementById('cv'); if(!cv) return 'SKIP: no canvas to read';
       c2=cv.getContext('2d');
       q=__P(); q.contracts=CONS;
       // ONE: what is needed
       g.bag=[]; g.carriedKit=[];
       o=needItems();
       if(o.board!==2||Object.keys(o).length!==1) bad.push('ONE: the needed items are '+JSON.stringify(o)+', not just 2 boards');
       g.bag.push('board'); o=needItems();
       if(o.board!==1) bad.push('ONE: after one board in the bag the need is '+o.board+', not 1');
       g.carriedKit=['board']; o=needItems();
       if(o.board!==2) bad.push('ONE: a board the lift carried up counted ('+o.board+')');
       g.carriedKit=[]; q.contracts[0].prog=2; o=needItems();
       if(Object.keys(o).length) bad.push('ONE: a finished card still needs '+JSON.stringify(o));
       q.contracts[0].prog=0; g.bag=[];
       // TWO: the arcade has no contracts
       ar0=g.arcade; g.arcade=1; o=needItems(); g.arcade=ar0;
       if(Object.keys(o).length) bad.push('TWO: the arcade needs '+JSON.stringify(o));
       // THREE: which boxes hold it
       needRefresh();
       ct=mkContainer(p.x+100,p.y,'crate'); setLoot(ct,['scrap','board']);
       ct2=mkContainer(p.x-100,p.y,'crate'); setLoot(ct2,['scrap','wire']);
       if(!needHolds(ct)) bad.push('THREE: the box with the board does not hold it');
       if(needHolds(ct2)) bad.push('THREE: the box without it holds it');
       ct.loot=['scrap']; if(needHolds(ct)) bad.push('THREE: a box with the board pulled out still holds it');
       ct.loot=['scrap','board']; ct.opened=true; if(needHolds(ct)) bad.push('THREE: an opened box still holds it');
       ct.opened=false;
       // FOUR: the once-a-second tick works it out
       g.need=null; g.cxT=0; careerTick(0.016);
       if(!g.need||g.need.board!==2) bad.push('FOUR: the tick did not work out the need ('+JSON.stringify(g.need)+')');
       // FIVE: the box glows in the world, and only when it should
       sp=null;
       for(k=0;k<24&&!sp;k++){ aa=k/24*6.2832; x=p.x+Math.cos(aa)*110; y=p.y+Math.sin(aa)*110; if(x>120&&y>120&&x<WORLD_W-120&&y<WORLD_H-120&&spotFree(g.map,x,y,50)) sp={x:x,y:y}; }
       if(!sp) return 'SKIP: no open ground for the box';
       g.containers.push(ct); ct.x=sp.x; ct.y=sp.y; ct.loot=['scrap','board']; ct.opened=false;
       g.need={}; g.needN=0; a=shot();
       r2=__w2s(ct.x,ct.y);
       g.need={board:2}; g.needN=1; b=shot();
       n1=diffNear(a,b,r2.x,r2.y);
       if(n1<200) bad.push('FIVE: the glow changed only '+n1+' pixels around the box');
       ct.loot=['scrap']; c=shot(); n2=diffNear(a,c,r2.x,r2.y);
       if(n2!==0) bad.push('FIVE: a box without the item glowed ('+n2+' pixels)');
       ct.loot=['scrap','board']; ct.opened=true; g.need={}; g.needN=0; c=shot(); g.need={board:2}; g.needN=1; b=shot(); n2=diffNear(c,b,r2.x,r2.y);
       if(n2!==0) bad.push('FIVE: an opened box glowed ('+n2+' pixels)');
       ct.opened=false;
       // SIX: the item in the backpack
       g.bag=['board','scrap']; g.need={board:2}; g.needN=1;
       rec=strokes(function(){ var r=__drawBagWith(g); if(r.threw) bad.push('SIX: the backpack threw: '+r.threw); });
       if(rec.indexOf('#ffd452')<0) bad.push('SIX: no gold edge on the board in the backpack');
       g.need={}; g.needN=0;
       rec=strokes(function(){ __drawBagWith(g); });
       if(rec.indexOf('#ffd452')>=0) bad.push('SIX: a gold edge with nothing needed');
       // SEVEN: the item in the pickup stack
       bo0=g.bagOpen; pk0=g.pick; g.bagOpen=false; g.mapOpen=false;
       g.pick=[{m:'Circuit Board',item:'board',n:1,tag:'',c:'',T:4,at:(+g.t||0)-1,key:'',sub:''}];
       g.need={board:2}; g.needN=1;
       rec=strokes(function(){ drawPickups(); });
       if(rec.indexOf('#ffd452')<0) bad.push('SEVEN: no gold edge on the board in the pickup stack');
       g.need={}; g.needN=0;
       rec=strokes(function(){ drawPickups(); });
       if(rec.indexOf('#ffd452')>=0) bad.push('SEVEN: a gold edge on the stack with nothing needed');
       g.bagOpen=bo0; g.pick=pk0;
       // EIGHT: the world pass calls it
       srcs=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       if(srcs.indexOf('needHolds'+'(ct)) needGlow')<0) bad.push('EIGHT: the container draw never calls the glow');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ if(oSR){ delete ctx.strokeRect; if(ctx.strokeRect!==oSR) ctx.strokeRect=oSR; } }catch(_sr){}
       try{ CAREER_ON=c0; }catch(_c0){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
