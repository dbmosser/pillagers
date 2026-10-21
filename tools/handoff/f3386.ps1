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

if ($s.Contains("  {v:'33.86',what:")) { throw "check 33.86 is in the fixture already" }

SubRx @'
  {v:'33.85',what:
'@ @'
  {v:'33.86',what:'cw-cx-propsfinish: real landmark and wildlife painters cache at the required densities; 60 cached draws use one blit and no readback; strongbox, seal and forge labels use GFXWT',
   run:function(){
     if(typeof pixWrap!=='function') return 'no pixel adapter';
     var cfg=CFG.xfPix, pw=pixWrap, see=canSee, oldRead=CanvasRenderingContext2D.prototype.getImageData, bad=[], seen={}, worldText=[], hudText=[], wc0, wf, hf, g, saved={}, t0, labels0, moved=/meridian strongbox|the seal|seal broken|the forge/i;
     function checkSprite(key,d,e){
       if(!e){ bad.push(key+' did not cache'); return; }
       if(d!==(/^(cd:|bd:|dr:)/.test(key)?PIX_ACT:PIX_ENV)) bad.push(key+' has wrong art density');
       var a=oldRead.call(e.c.getContext('2d'),0,0,e.c.width,e.c.height).data, n=0;
       for(var j=3;j<a.length;j+=4){ if(a[j]&&a[j]!==255){ bad.push(key+' has soft alpha'); break; } if(a[j]) n++; }
       if(!n) bad.push(key+' is empty');
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; __frame(0.016);
       g=G; wc0=wc; wf=Object.getOwnPropertyDescriptor(wc,'fillText'); hf=Object.getOwnPropertyDescriptor(ctx,'fillText');
       var worldFill=wc.fillText, hudFill=ctx.fillText, p=G.player;
       wc.fillText=function(t){ if(moved.test(String(t))) worldText.push(String(t)); return worldFill.apply(this,arguments); };
       ctx.fillText=function(t){ if(moved.test(String(t))) hudText.push(String(t)); return hudFill.apply(this,arguments); };
       ['wild','forge','seal','nearForge','ents','containers','t'].forEach(function(k){ saved[k]=G[k]; });
       saved.story=G.map.story; labels0=CACHETAGS; CACHETAGS=[];
       G.ents=[]; G.containers=[]; G.nearForge=false;
       G.forge={x:p.x-70,y:p.y+50,name:'the forge'};
       G.seal={x:p.x+70,y:p.y+50,done:false,gained:0};
       G.map.story={x:p.x+110,y:p.y+50};
       G.wild=[{k:'deer',x:p.x-40,y:p.y+10,z:0,face:1,st:'graze',f:0.31,ant:1},
         {k:'bird',x:p.x+40,y:p.y+10,z:0,face:1,st:'flee',f:0.31},
         {k:'deer',x:p.x-20,y:p.y+30,z:0,face:1,dead:1},
         {k:'bird',x:p.x+20,y:p.y+30,z:0,face:1,dead:1}];
       canSee=function(){ return true; };
       pixWrap=function(key,w,h,d,paint,x,y,o){
         if(!/^(cd:|bd:|dr:|forge$|seal:|xz:|story$)/.test(key)||seen[key]) return pw.apply(this,arguments);
         seen[key]=1;
         pixFrame(); var e=pw.apply(this,arguments); checkSprite(key,d,e);
         if(!e) return e;
         var args=arguments, blits=0, reads=0, own=Object.getOwnPropertyDescriptor(wc,'drawImage'), draw=wc.drawImage, clock=G.t;
         wc.drawImage=function(){ blits++; return draw.apply(this,arguments); };
         CanvasRenderingContext2D.prototype.getImageData=function(){ reads++; return oldRead.apply(this,arguments); };
         try{
           for(var f=0;f<60;f++){ G.t=clock+f/60; pixFrame(); if(pw.apply(this,args)!==e) bad.push(key+' lost its cached frame'); }
         } finally {
           G.t=clock; CanvasRenderingContext2D.prototype.getImageData=oldRead;
           if(own) Object.defineProperty(wc,'drawImage',own); else delete wc.drawImage;
         }
         if(blits!==60) bad.push(key+' used '+blits+' blits in 60 frames');
         if(reads) bad.push(key+' read back '+reads+' times after warm-up');
         return e;
       };
       drawContS({x:p.x,y:p.y+20,r:15,type:'safe',camp:1,strong:1,cache:1,opened:false,loot:[],best:'common',time:9,prog:0});
       render2D(0);
       if(worldText.length) bad.push('labels still on world canvas: '+worldText.join(','));
       ['meridian strongbox','the seal','the forge'].forEach(function(t){ if(!hudText.some(function(v){ return v.toLowerCase().indexOf(t)>=0; })) bad.push(t+' missing from HUD hand-off'); });
       ['dr:','bd:','cd:deer','cd:bird','forge','seal:','xz:','story'].forEach(function(k){ if(!Object.keys(seen).some(function(s){ return s.indexOf(k)===0; })) bad.push(k+' painter was not exercised'); });
       if(wc!==wc0) bad.push('wc was not restored');
       return bad.length?bad.slice(0,10).join('; '):null;
     } catch(err){ return 'props finish check: '+String(err&&err.message||err); }
     finally{
       pixWrap=pw; canSee=see; CanvasRenderingContext2D.prototype.getImageData=oldRead;
       if(wc0){ wc=wc0; if(wf) Object.defineProperty(wc,'fillText',wf); else delete wc.fillText; if(hf) Object.defineProperty(ctx,'fillText',hf); else delete ctx.fillText; }
       if(g){ ['wild','forge','seal','nearForge','ents','containers','t'].forEach(function(k){ g[k]=saved[k]; }); g.map.story=saved.story; }
       if(labels0) CACHETAGS=labels0; GFXWT=null;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile(); CFG.xfPix=cfg;
     }
   }},
  {v:'33.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
