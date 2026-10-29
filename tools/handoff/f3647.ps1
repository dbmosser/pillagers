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

if ($s.Contains("  {v:'36.47',what:")) { throw "check 36.47 is in the fixture already" }

SubRx @'
  {v:'36.46',what:
'@ @'
  {v:'36.47',what:'cw-hudstack, his 10-29 picture: three combat statuses stand in one column of about 40px rows (were 48) fitted to their words (also in a tight band under a long board), the style medals stand in the reserved medal row under the feed clear of every status, and a run goal row names its task and bonus loot, in a career raid at 1080p and 4K',
   run:function(){
     var g,p,bad=[],sp=statusPill,ft=ctx.fillText,ownFT=Object.prototype.hasOwnProperty.call(ctx,'fillText'),kk=keys,md=mouse.down,ow=W,oh=H,
         us=P.uiScale,ownUS=Object.prototype.hasOwnProperty.call(P,'uiScale'),hud0=P.hud,buzz=P.buzz,sizes=[[1920,1080],[3840,2160]],si,panels,seen,tag,i,a,b,M,R,hr,hd,
         boxes=[HUDBOX,FEEDBOX,MEDALBOX,NETTEAMBOX],sty0,car0,cs0,fl0;
     function need(ok,msg){ if(!ok) bad.push(tag+': '+msg); }
     function ov(a,b){ return a.x<b.x+b.w-0.5&&a.x+a.w>b.x+0.5&&a.y<b.y+b.h-0.5&&a.y+a.h>b.y+0.5; }
     function R4(o){ return Math.round(o.x)+','+Math.round(o.y)+' '+Math.round(o.w)+'x'+Math.round(o.h); }
     function pose(){ p.hp=100; p.healQ=0; p.stimT=0; p.stamLock=0; p.stamRelease=0; p.downed=false; p.arStk=2; p.arBonus=0; p.arGun=p.wep; p.reloading=0; p.shStk=7; p.bmStk=4; p.bmUntil=g.t+4.3; P.buzz=[]; }
     function grabPills(fn){ panels=[]; statusPill=function(x,cy,x1,h){ var m=ctx.getTransform(), d=(typeof DPRH==='number'&&DPRH>0)?DPRH:1; panels.push({x:(m.a*x+m.c*(cy-h/2)+m.e)/d,y:(m.b*x+m.d*(cy-h/2)+m.f)/d,w:(x1-x)*m.a/d,h:h*m.d/d}); return sp.apply(this,arguments); }; try{ fn(); } finally { statusPill=sp; } return panels; }
     function oneColumn(L,what){
       need(L.length===3,what+': '+L.length+' status panels drawn for 3 live statuses');
       for(i=0;i<L.length;i++){
         need(Math.abs(L[i].x-L[0].x)<0.5,what+': panel '+i+' is not in the first column (x '+Math.round(L[i].x)+' vs '+Math.round(L[0].x)+')');
         need(L[i].h/hudRes()>=39.5&&L[i].h/hudRes()<=42.5,what+': panel '+i+' is '+(L[i].h/hudRes()).toFixed(1)+' px tall, not about 40');
         need(Math.abs(L[i].w-L[0].w)<0.5,what+': panel '+i+' width differs');
         need(L[i].x>=0&&L[i].y>=0&&L[i].x+L[i].w<=W+0.1&&L[i].y+L[i].h<=H+0.1,what+': panel '+i+' is off the screen');
         if(i) need(L[i].y>=L[i-1].y+L[i-1].h+0.5,what+': panels '+(i-1)+' and '+i+' touch or overlap');
       }
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); P.uiScale=1;
       __deploy({kit:['gun_carbine','medkit','bandage'],safe:null,mapIx:0,seed:4242}); g=__state(); p=g&&g.player; if(!p||g.over) return 'no live raid';
       car0=g.career; cs0=g.cs; fl0=g.flow; sty0=g.sty;
       g.career=1; g.arcade=0; if(!g.cs) g.cs={s:0,k:0,streak:0}; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.sim=false; keys={}; mouse.down=false;
       P.hud=JSON.parse(JSON.stringify(P.hud||{})); P.hud.cond=P.hud.cond||{}; P.hud.cond.o=1;   // run info held open
       flowS().goals=['pill3','kill10','vault'].map(function(id){ return {id:id,t:GOALS[id].t,n:GOALS[id].n,chip:GOALS[id].chip,v:0,done:0}; });
       for(si=0;si<sizes.length;si++){
         __forceSize(sizes[si][0],sizes[si][1]); tag=sizes[si].join('x'); hr=hudRes(); hd=(typeof DPRH==='number'&&DPRH>0)?DPRH:1;
         pose(); g.sty={pops:[{txt:'UNTOUCHED',pts:100,t:g.t-2.0},{txt:'LONG'+' SHOT',pts:100,t:g.t-0.9}],kt:[],gT:-9,gN:0,calmAt:g.t+30,calmK:0,hp0:-1};
         __frame(0); pose(); __frame(0);   // the boxes the column and the row read come from the frame before
         // ONE: the run goals say what to do and what they pay
         seen=[]; ctx.fillText=function(t){ seen.push(String(t).toLowerCase().replace(/\u00a0/g,' ')); return ft.apply(this,arguments); };
         try{ pose(); __frame(0); } finally { if(ownFT) ctx.fillText=ft; else delete ctx.fillText; }
         a=seen.join(' ');
         need(/kill 3 pillagers/.test(a),'no run goal row says kill 3 pillagers');
         need(/get 10 kills/.test(a),'no run goal row says get 10 kills');
         need(/bonus loot/.test(a),'no run goal row names its bonus loot');
         need(!seen.some(function(t){ return /(pillagers|kills|vault|elite|warden|crates|waves|strike)\b.*\bitem\s*$/.test(t); }),'a run goal row still ends in the bare word item');
         // TWO: the medal row stands in the reserved medal spot
         ctx.save(); try{ ctx.setTransform(hd,0,0,hd,0,0); styMedalDraw(ctx,p); } finally { ctx.restore(); }
         M=MEDALBOX; R={x:STYBOX.x,y:STYBOX.y,w:STYBOX.w,h:STYBOX.h};
         need(M&&M.on&&M.w>0&&M.h>0,'no medal spot reserved under the feed');
         need(STYBOX.n===2,'the row drew '+STYBOX.n+' emblems for 2 medals');
         if(M&&M.on) need(R.x>=M.x-0.5&&R.y>=M.y-0.5&&R.x+R.w<=M.x+M.w+0.5&&R.y+R.h<=M.y+M.h+0.5,'the medal row '+R4(R)+' is not inside the medal spot '+R4(M));
         need(!(FEEDBOX&&FEEDBOX.on&&ov(R,FEEDBOX)),'the medal row '+R4(R)+' is on the feed '+R4(FEEDBOX));
         need(STYBOX.items.length===2&&STYBOX.items[0].s*2>=36*Math.max(1,hr)-0.5,'an emblem is under 36 px across');
         // THREE: the three statuses, one column, 40 px rows, clear of the medals, the feed and the board
         grabPills(function(){ ctx.save(); try{ ctx.setTransform(hd,0,0,hd,0,0); pose(); drawStatusIcons(); } finally { ctx.restore(); } });
         oneColumn(panels,'raid');
         for(i=0;i<panels.length;i++){
           need(!ov(panels[i],R),'status panel '+i+' '+R4(panels[i])+' is on the medal row '+R4(R));
           if(FEEDBOX&&FEEDBOX.on) need(!ov(panels[i],FEEDBOX),'status panel '+i+' is on the feed');
           if(M&&M.on) need(!ov(panels[i],M),'status panel '+i+' is on the medal spot');
           if(HUDBOX.raiders&&HUDBOX.raiders.w>0) need(!ov(panels[i],HUDBOX.raiders),'status panel '+i+' is on the pillager board');
         }
         // FOUR: his screen, a long board and the feed close under it: the band holds three 40 px rows only if they start higher
         b={raiders:{x:Math.round(9*hr),y:Math.round(H*0.12),w:Math.round(380*hr),h:Math.round(H*0.24)},body:{x:0,y:Math.round(H*0.86),w:Math.round(W*0.2),h:Math.round(H*0.14)}};
         a=[HUDBOX,FEEDBOX,MEDALBOX,NETTEAMBOX];
         try{
           HUDBOX=b; NETTEAMBOX={n:0};
           FEEDBOX={on:1,x:Math.round(9*hr),y:Math.round(H*0.40+130*hr),w:Math.round(W*0.28),h:Math.round(88*hr),rows:[]};
           MEDALBOX={on:1,x:FEEDBOX.x,y:FEEDBOX.y+FEEDBOX.h+Math.round(6*hr),w:FEEDBOX.w,h:Math.round(40*hr)};
           grabPills(function(){ ctx.save(); try{ ctx.setTransform(hd,0,0,hd,0,0); pose(); drawStatusIcons(); } finally { ctx.restore(); } });
           oneColumn(panels,'tight band');
           for(i=0;i<panels.length;i++){ need(!ov(panels[i],b.raiders),'tight band: panel '+i+' is on the board'); need(!ov(panels[i],FEEDBOX),'tight band: panel '+i+' is on the feed'); }
         } finally { HUDBOX=a[0]; FEEDBOX=a[1]; MEDALBOX=a[2]; NETTEAMBOX=a[3]; }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       statusPill=sp; if(ownFT) ctx.fillText=ft; else delete ctx.fillText; keys=kk; mouse.down=md;
       HUDBOX=boxes[0]; FEEDBOX=boxes[1]; MEDALBOX=boxes[2]; NETTEAMBOX=boxes[3];
       try{ if(g){ g.career=car0; g.cs=cs0; g.flow=fl0; g.sty=sty0; } if(p){ p.arStk=0; p.arBonus=0; p.shStk=0; p.bmStk=0; } __endRaid('abandon'); }catch(_e){}
       P.hud=hud0; P.buzz=buzz; if(ownUS) P.uiScale=us; else delete P.uiScale; __forceSize(ow,oh); __topClear();
     }
   }},
  {v:'36.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
