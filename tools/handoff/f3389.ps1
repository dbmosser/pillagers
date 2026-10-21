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

if ($s.Contains("  {v:'33.89',what:")) { throw "check 33.89 is in the fixture already" }

SubRx @'
  {v:'33.88',what:
'@ @'
  {v:'33.89',what:'cw-cx-pixmachines: nine machine bodies cache at job 80 size, masks fit hits, gold has no filter, live lights and alarm HUD, two builds per frame and zero steady readbacks, including the title sentry',
   run:function(){
     if(typeof pixMachDraw!=='function'||typeof pixMachPose!=='function')return 'machines still use vector painters every frame';
     var cfg=CFG.xfPix,cond=P.cond,w0=wc,sh0=shadowE,read=CanvasRenderingContext2D.prototype.getImageData,filter=Object.getOwnPropertyDescriptor(CanvasRenderingContext2D.prototype,'filter'),bad=[],g=null,labels=CACHETAGS,see=canSee,worldOwn,hudOwn,worldFill,hudFill,oldPixWrap=pixWrap;
     var names=['sentry','crawler','snitch','bulwark','howler','listener','choir','warden','overseer'],canvas=document.createElement('canvas'),cx,reads=0,filters=0,worldAlarms=0,hudAlarms=0;
     canvas.width=440;canvas.height=400;cx=canvas.getContext('2d');
     function fail(s){if(bad.length<32)bad.push(s);}
     function bounds(data,w,ox,oy){
       var x0=w,y0=data.length/(w*4),x1=-1,y1=-1,n=0;
       for(var j=3;j<data.length;j+=4)if(data[j]>=128){var i=(j-3)/4,x=i%w,y=(i-x)/w;x0=Math.min(x0,x);x1=Math.max(x1,x);y0=Math.min(y0,y);y1=Math.max(y1,y);n++;}
       return {a:[x0-ox,y0-oy,x1-ox,y1-oy],n:n};
     }
     function rawBounds(e){
       var p=pixMachPose(e),f=e.kind==='warden'?drawWardenS:pixMachPainter(p.k),time=PIXM.time;
       cx.setTransform(1,0,0,1,0,0);cx.clearRect(0,0,440,400);cx.setTransform(p.m,0,0,p.m,220,220);wc=cx;
       PIXM.paint=1;PIXM.baking=1;PIXM.time=p.time;shadowE=function(){};
       try{f(p.q);}finally{PIXM.paint=0;PIXM.baking=0;PIXM.time=time;shadowE=sh0;}
       return bounds(read.call(cx,0,0,440,400).data,440,220,220);
     }
     function draw(e){cx.setTransform(1,0,0,1,220,220);wc=cx;pixMachPainter(pixMachKind(e))(e);return PIXM.last;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});keys={};mouse.down=false;g=G;G.t=0;P.cond='day';pixDropAll();
       for(var i=0;i<names.length;i++){
         var e=pixMachSample(names[i]),b0=rawBounds(e);pixFrame();PIXM.last=null;var sp=draw(e),p0=PIXM.paints,h0=PIX.hits;
         if(!sp||sp.mp.k!==names[i]){fail(names[i]+' did not build');continue;}
         pixFrame();if(draw(e)!==sp||PIXM.paints!==p0||PIX.hits<=h0)fail(names[i]+' second frame was not a cache hit');
         if(sp.d!==PIX_ACT)fail(names[i]+' has the wrong density');
         if(sp.ax!==Math.round(sp.ax)||sp.ay!==Math.round(sp.ay))fail(names[i]+' has a fractional art anchor');
         var a=read.call(sp.c.getContext('2d'),0,0,sp.c.width,sp.c.height).data,b1=bounds(a,sp.c.width,sp.ax,sp.ay),f=read.call(sp.flash.c.getContext('2d'),0,0,sp.flash.c.width,sp.flash.c.height).data;
         if(!b0.n||!b1.n)fail(names[i]+' body is empty');
         for(var j=0;j<4;j++)if(Math.abs(b0.a[j]-b1.a[j])>1.01)fail(names[i]+' bounds '+j+' differ from job 80 by '+Math.abs(b0.a[j]-b1.a[j])+' art px ('+b0.a.join(',')+' vs '+b1.a.join(',')+')');
         for(j=3;j<a.length;j+=4){if(a[j]!==0&&a[j]!==255){fail(names[i]+' body has soft alpha');break;}if(f[j]!==a[j]){fail(names[i]+' hit flash escaped the opaque mask');break;}}
       }
       // Exercise four gait poses for twelve visible machines for three seconds; after that they must only blit.
       var group=[];
       for(i=0;i<12;i++){e=pixMachSample(names[i%9]);e.moving=true;e.face=(i%4)*Math.PI/4;e.x=(i%4)*80-120;e.y=Math.floor(i/4)*100-60;group.push(e);}
       CanvasRenderingContext2D.prototype.getImageData=function(){reads++;return read.apply(this,arguments);};
       for(var frame=0;frame<240;frame++){
         G.t=frame/60;pixFrame();
         for(i=0;i<group.length;i++){e=group[i];e.step=frame/15;e.legs=frame/15;draw(e);}
         if(PIX.fB>2)fail('twelve machines exceeded two builds in frame '+frame);
         if(frame===179)reads=0;
       }
       if(reads)fail(reads+' readbacks after the three second warm-up');
       CanvasRenderingContext2D.prototype.getImageData=read;
       // A real budget miss must choose a cached pose of the same appearance, without invoking a vector painter.
       e=pixMachSample('sentry');G.t=0;pixFrame();draw(e);e.face=Math.PI/8;var n0=PIXM.near; p0=PIXM.paints;PIX.fB=2;draw(e);
       if(PIXM.near<=n0||PIXM.paints!==p0)fail('a pose miss did not use the nearest cached body');
       // Gold and elite masks are built with the body; never use a finished-sprite filter.
       if(filter&&filter.configurable)Object.defineProperty(CanvasRenderingContext2D.prototype,'filter',{configurable:true,get:filter.get,set:function(v){if(v&&v!=='none'&&(this===w0||this===cx||GOLDB.h))filters++;return filter.set.call(this,v);}});
       e=pixMachSample('sentry');e.golden=1;e.elite=1;e.affix='';pixFrame();sp=draw(e);
       if(!sp||!sp.edge)fail('the elite outline ring is missing');
       else{
         a=read.call(sp.c.getContext('2d'),0,0,sp.c.width,sp.c.height).data;var gold=0,opaque=0;
         for(j=0;j<a.length;j+=4)if(a[j+3]&&a[j]+a[j+1]+a[j+2]>80){opaque++;if(a[j]>a[j+1]&&a[j+1]>a[j+2]*1.3)gold++;}
         if(gold<opaque*.95)fail('gold is not baked into the machine palette');
         var edge=read.call(sp.edge.c.getContext('2d'),0,0,sp.edge.c.width,sp.edge.c.height).data;
         for(j=3;j<a.length;j+=4)if(a[j]){var ix=(j-3)/4,xx=ix%sp.c.width,yy=(ix-xx)/sp.c.width;if(edge[((yy+1)*sp.edge.c.width+xx+1)*4+3]){fail('elite outline paints inside the body');break;}}
       }
       // The actual render dispatcher must keep gold off the old filter and alarm text off the world canvas.
       wc=w0;worldOwn=Object.getOwnPropertyDescriptor(wc,'fillText');hudOwn=Object.getOwnPropertyDescriptor(ctx,'fillText');worldFill=wc.fillText;hudFill=ctx.fillText;
       wc.fillText=function(t){if(String(t).toLowerCase()==='alarm')worldAlarms++;return worldFill.apply(this,arguments);};
       ctx.fillText=function(t){if(String(t).toLowerCase()==='alarm')hudAlarms++;return hudFill.apply(this,arguments);};
       var player=G.player;G.ents=[];G.containers=[];G.wild=[];G.forge=null;G.seal=null;G.map.story=null;G.bagOpen=false;G.mapOpen=false;G.paused=false;G.t=0;canSee=function(){return true;};
       var alarm=pixMachSample('snitch');alarm.x=player.x+70;alarm.y=player.y+70;alarm.state='alarm';alarm.wind=2;G.ents.push(alarm);
       e=pixMachSample('sentry');e.x=player.x-70;e.y=player.y+70;e.golden=1;G.ents.push(e);
       for(i=0;i<8;i++){pixFrame();render2D(0);}
       if(worldAlarms)fail('alarm text still draws on wc');if(!hudAlarms)fail('alarm did not reach the HUD hand-off');if(filters)fail('golden machine drawing set a canvas filter');if(G.drawErr)fail('real machine rendering logged '+G.drawErr);
       // The title skit uses its real dispatcher, rather than a look-alike sentry test.
       var tsk0=TSK,seen=0,wrap0=pixWrap;
       try{
         pixWrap=function(key){if(String(key).indexOf('mach|sentry|')===0)seen++;return wrap0.apply(this,arguments);};
         wc=cx;cx.setTransform(1,0,0,1,220,220);TSK={};e=pixMachSample('sentry');e.dead=0;e.fade=1;pixFrame();tskDraw(e);
       }finally{TSK=tsk0;pixWrap=wrap0;}
       if(!seen)fail('title skit did not draw a pixel sentry');
       return bad.length?bad.join('; '):null;
     }catch(err){return 'machine art check: '+String(err&&err.stack||err);}
     finally{
       wc=w0;shadowE=sh0;PIXM.paint=0;PIXM.baking=0;pixWrap=oldPixWrap;canSee=see;CanvasRenderingContext2D.prototype.getImageData=read;
       if(filter&&filter.configurable)Object.defineProperty(CanvasRenderingContext2D.prototype,'filter',filter);
       if(worldFill){if(worldOwn)Object.defineProperty(w0,'fillText',worldOwn);else delete w0.fillText;if(hudOwn)Object.defineProperty(ctx,'fillText',hudOwn);else delete ctx.fillText;}
       CACHETAGS=labels;GFXWT=null;P.cond=cond;try{if(__state()&&!__state().over)__endRaid('abandon');}catch(_end){}
       __topClear();__resetCfg();__cleanProfile();CFG.xfPix=cfg;pixDropAll();pixFrame();
     }
   }},
  {v:'33.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
