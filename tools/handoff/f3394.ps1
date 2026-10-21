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

if ($s.Contains("  {v:'33.94',what:")) { throw "check 33.94 is in the fixture already" }

SubRx @'
  {v:'33.93',what:
'@ @'
  {v:'33.94',what:'cw-cx-pixfx: particles are whole art squares, blast/scorch and rings are stepped, half-size medallions blit sharply on the HUD, four districts retain night contrast and steady drawing stays within pixel budgets',
   run:function(){
     if(typeof pixFxPuff!=='function'||typeof pixPwrBake!=='function')return 'effects and medallions are still vector';
     var cfg=CFG.xfPix,cond=P.cond,w0=wc,g,ground=shadowE,blit=pixBlit,pwrCount=0,pwrKinds={},read=CanvasRenderingContext2D.prototype.getImageData,put=CanvasRenderingContext2D.prototype.putImageData,url=HTMLCanvasElement.prototype.toDataURL,fil=Object.getOwnPropertyDescriptor(CanvasRenderingContext2D.prototype,'filter'),orig={},bad=[],reads=0,filters=0,calls=0,arcs=0,rects=0,spy=false,ca=pixCanvas(480,320),c=ca.x;
     function fail(s){if(bad.length<20)bad.push(s);}
     function lum(r,g,b){function l(v){v/=255;return v<=.04045?v/12.92:Math.pow((v+.055)/1.055,2.4);}return .2126*l(r)+.7152*l(g)+.0722*l(b);}
     function hx(h){var n=parseInt(h.slice(1),16);return lum(n>>16,(n>>8)&255,n&255);}
     function count(on){spy=on;if(on)calls=0;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=G;P.cond='night';keys={};mouse.down=false;pixDropAll();wc=c;c.setTransform(1,0,0,1,0,0);
       // v28.xx (cw-cx-pixfx): Observe the actual air-pass helpers: every particle rectangle has integer coordinates and equal integer sides.
       var f=c.fillRect,arc=c.arc;
       c.fillRect=function(x,y,w,h){rects++;if(x!==Math.round(x)||y!==Math.round(y)||w!==Math.round(w)||h!==w)fail('fractional or non-square particle');return f.apply(this,arguments);};
       c.arc=function(){arcs++;return arc.apply(this,arguments);};
       pixFxSpark({x:81.34,y:90.7,z:3.4,c:'#ffa04e',t:.1,life:.5});pixFxSpark({x:121.34,y:90.7,z:2.3,c:BLOOD_SPRAY,t:.1,life:.5});pixFxPuff({x:160.8,y:90.4,c:'#504e4c',t:.23,life:.5,r:31});
       delete c.fillRect;delete c.arc;if(arcs||rects<5)fail('particle path used arcs or drew no squares');
       // v28.xx (cw-cx-pixfx): Pixel ground stamps and ring strokes must stay on their own whole-unit grids too.
       var grid=2,stamps=0;c.fillRect=function(x,y,w,h){stamps++;if(x%grid||y%grid||w%grid||h%grid)fail('stamp escaped its art grid');return f.apply(this,arguments);};
       c.arc=function(){fail('pixel stamp used an arc');};c.ellipse=function(){fail('pixel stamp used an ellipse');};
       ['scorch','crack','debris','brass'].forEach(function(k){pixScarPaint(c,{k:k,x:150.7,y:120.4,r:26.2,a:1,s:123});});
       grid=1;c.fillStyle='#ff4a3a';pixFxOval(c,100.2,110.7,18.4,7.8,2,1);
       delete c.fillRect;delete c.arc;delete c.ellipse;if(stamps<20)fail('pixel ground/ring stamp was empty');
       // v28.xx (cw-cx-pixfx): Blit every kind at whole scale 2 and inspect only the actual resulting edge alpha.
       for(var i=0;i<PWR_KINDS.length;i++){
         var k=PWR_KINDS[i].k;pixFrame();var sp=pixPwrBake(k,3);c.setTransform(1,0,0,1,0,0);c.clearRect(0,0,480,320);pixBlit(sp,160,160,false,c,2);
         var a=read.call(c,0,0,480,320).data,solid=0;
         for(var j=3;j<a.length;j+=4){if(a[j]!==0&&a[j]!==255){fail(k+' medallion has a blended edge');break;}if(a[j])solid++;}
         if(!solid||sp.c.width>PWRI.R*2+4||PWRK!==.5)fail(k+' lost its half-size medallion');
         // v28.xx (cw-cx-pixfx): Warm all four spin frames through the public HUD helper.
         for(j=0;j<4;j++){pixFrame();pixPwrMedallion(c,k,160,160,PWRI.R,.5+j/6);}
       }
       // v28.xx (cw-cx-pixfx): Exercise the real HUD dispatch, so a good bake cannot hide an unwired medallion path.
       // v28.xx (cw-cx-pixfx): pwrDraw culls through w2s/VX/VY. Prime the real world camera before the HUD, as a game frame does.
       mouse.x=W/2;mouse.y=H/2;g.anchX=undefined;g.anchY=undefined;wc=w0;__frame(0);wc=c;
       var arcade=g.arcade,career=g.career;g.arcade=1;g.pwr={items:PWR_KINDS.map(function(d,i){return {k:d.k,x:g.player.x+(i-2)*70,y:g.player.y,t:2,life:16,id:i+1};}),act:{}};
       pixBlit=function(sp,x,y,flip,dest,S){var ok=blit.apply(this,arguments);if(ok&&dest===ctx&&sp.key&&sp.key.indexOf('pwr|')===0){pwrCount++;pwrKinds[sp.key.split('|')[1]]=1;}return ok;};
       ctx.save();try{ctx.setTransform(DPRH,0,0,DPRH,0,0);for(i=0;i<12;i++){pixFrame();pwrDraw(ctx,g.player);}}
       finally{ctx.restore();pixBlit=blit;g.arcade=arcade;g.career=career;g.pwr=null;}
       var missing=PWR_KINDS.filter(function(d){return !pwrKinds[d.k];}).map(function(d){return d.k;});
       if(missing.length){var ps=w2s(g.player.x,0,g.player.y);fail('HUD medallions missing '+missing.join(',')+'; blits '+pwrCount+'; player screen '+Math.round(ps.x)+','+Math.round(ps.y));}
       // v28.xx (cw-cx-pixfx): The lit side is the bright quarter of opaque torso pixels in an actual standing pillager raster, excluding the head and feet.
       var ratios=[];
       for(var cl=0;cl<3;cl++){
         var body=pixBodyCell('short','umber',PXB_CLOTHS[cl],0,0,0),data=read.call(body.getContext('2d'),0,0,body.width,body.height).data,ls=[];
         for(var yy=18;yy<40;yy++)for(var xx=6;xx<24;xx++){var off=(yy*body.width+xx)*4;if(data[off+3]===255)ls.push(lum(data[off],data[off+1],data[off+2]));}
         ls.sort(function(a,b){return b-a;});var nn=Math.max(1,Math.floor(ls.length/4)),L=0;for(j=0;j<nn;j++)L+=ls[j];L/=nn;
         if(!ls.length)fail('empty standing torso measure');
         for(i=0;i<4;i++){var pal=pixGroundPal(g.map,i,false),floor=0;for(j=0;j<4;j++)floor=Math.max(floor,hx(pal.hex[j]));var ratio=(L+.05)/(floor+.05);ratios.push(Math.round(ratio*100)/100);if(ratio<1.8)fail('night contrast '+DISTRICTS[i].name+'/'+PXB_CLOTHS[cl]+' '+ratio.toFixed(2)+':1');}
       }
       // v28.xx (cw-cx-pixfx): Warm fixed poses for three simulated seconds, then measure actual draw calls and cold-bake/readback leakage.
       wc=w0;g.ents=[];g.wild=[];g.containers=[];g.puffs=[];g.sparks=[];g.bullets=[];g.bagOpen=false;g.mapOpen=false;g.paused=false;g.t=4;
       var p=g.player;p.iv=0;p.hitFlash=0;p.roll=0;p.rig=null;p.armor=0;p.face=0;P.cosOutfit='outnone';var st={hero:1,own:p,moving:false,sprint:false,ads:false,bulk:0};
       var machine=pixMachSample('sentry');machine.x=p.x+80;machine.y=p.y;g.ents=[machine];var box={x:p.x-80,y:p.y,type:'crate',r:15,opened:false,loot:[]};g.containers=[box];
       for(i=0;i<180;i++)__frame(0);
       for(i=0;i<20;i++){pixFrame();drawOp(p.x,p.y,0,0,'#aaa',0,0,'none',0,st);drawSentryS(machine);drawContS(box);}
       var proto=CanvasRenderingContext2D.prototype,names=['drawImage','fillRect','strokeRect','fill','stroke','arc','ellipse','beginPath','moveTo','lineTo','bezierCurveTo','quadraticCurveTo','fillText','strokeText'];
       names.forEach(function(n){orig[n]=proto[n];proto[n]=function(){if(spy&&this===wc)calls++;return orig[n].apply(this,arguments);};});
       proto.getImageData=function(){if(spy)reads++;return read.apply(this,arguments);};proto.putImageData=function(){if(spy)reads++;return put.apply(this,arguments);};HTMLCanvasElement.prototype.toDataURL=function(){if(spy)reads++;return url.apply(this,arguments);};
       if(fil&&fil.configurable)Object.defineProperty(proto,'filter',{configurable:true,get:fil.get,set:function(v){if(spy&&v&&v!=='none')filters++;return fil.set.call(this,v);}});
       pixFrame();count(true);drawOp(p.x,p.y,0,0,'#aaa',0,0,'none',0,st);count(false);var pc=calls;if(pc>8)fail('standing pillager '+pc+' drawing calls (cap 8)');
       pixFrame();count(true);drawSentryS(machine);count(false);var mc=calls;if(mc>4)fail('machine '+mc+' drawing calls (cap 4)');
       // v28.xx (cw-cx-pixfx): The prop body cap excludes its live ground shadow; the whole-raid cap below includes every shadow.
       shadowE=function(){var s=spy;spy=false;try{return ground.apply(this,arguments);}finally{spy=s;}};
       pixFrame();count(true);drawContS(box);count(false);shadowE=ground;var bc=calls;if(bc>1)fail('cached prop body '+bc+' drawing calls (cap 1)');
       count(true);for(i=0;i<3;i++){__frame(0);if(PIX.fB>2||PIX.fMs>2)fail('sprite build/time cap exceeded after warm-up');}count(false);var onCalls=calls/3;
       if(reads)fail(reads+' readbacks after warm-up');if(filters)fail(filters+' filters after warm-up');if(onCalls>=4000)fail('raid '+onCalls+' calls (cap 4000)');
       CFG.xfPix=0;count(true);__frame(0);count(false);var offCalls=calls;CFG.xfPix=1;if(onCalls>offCalls)fail('pixel raid '+onCalls+' calls exceeds vector '+offCalls);
       for(var q in PIXSTORE.bytes)if(PIXSTORE.bytes[q]>PIXSTORE.cap[q])fail(q+' cache exceeds its byte cap');
       window.__pixFxMeasure={ratios:ratios,medallions:Object.keys(pwrKinds),pillager:pc,machine:mc,prop:bc,on:onCalls,off:offCalls,reads:reads,filters:filters,bytes:{actors:PIXSTORE.bytes.actors,scene:PIXSTORE.bytes.scene}};
       return bad.length?bad.join('; '):null;
     }catch(e){return 'pixel fx check: '+String(e&&e.stack||e);}
     finally{
       spy=false;wc=w0;pixBlit=blit;shadowE=ground;delete c.fillRect;delete c.arc;delete c.ellipse;var pr=CanvasRenderingContext2D.prototype;for(var n in orig)pr[n]=orig[n];pr.getImageData=read;pr.putImageData=put;HTMLCanvasElement.prototype.toDataURL=url;if(fil&&fil.configurable)Object.defineProperty(pr,'filter',fil);
       P.cond=cond;try{__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();CFG.xfPix=cfg;pixDropAll();pixFrame();
     }
   }},
  {v:'33.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
