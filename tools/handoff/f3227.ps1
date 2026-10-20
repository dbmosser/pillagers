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

if ($s.Contains("  {v:'32.27',what:")) { throw "check 32.27 is in the fixture already" }

SubRx @'
  {v:'32.26',what:
'@ @'
  {v:'32.27',what:'cw-cx-sectorhold-o03: codex, weather and page notices wait off the map without losing lifetime, replay in order, loot tags do not overlap, and seats use amber/cyan',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__drawHUD&&typeof txRecord==='function')) return 'SKIP: this fixture cannot draw a raid';
     var g, bad=[], os=MAPFIRST.skip, ow=W, oh=H, op=mapPlaceLabels, oi=mapIcon, oseat=seatHere, proto=CanvasRenderingContext2D.prototype, ofill=proto.fill, fills=[], labels=[], markerRects=[], icons=[], i,j, n, msg, ft, saved;
     function tick(n){ for(var k=0;k<n;k++){ g.t+=0.1; msgTick(0.1); } }
     function overlaps(a,b){ return a.l<b.r&&b.l<a.r&&a.t<b.b&&b.t<a.b; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       MAPFIRST.skip=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no raid';
       if(HUBTOAST_T) clearTimeout(HUBTOAST_T); HUBTOAST_T=null; document.getElementById('hubtoast').classList.remove('on');
       keys={}; mouse.down=false; g.paused=false; g.mapFirst=0; g.bagOpen=false; g.mapOpen=true;
       g.fd={t:0,seq:0,lines:[]}; g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.alert=null; g.alertQ=[]; g.mapPop=null;
       feedSay('CODEX ENTRY','info',{sub:'scav pistol'});
       var painted=txRecord(function(){ __drawHUD(); });
       if(painted.some(function(h){ return /codex entry/i.test(String(h.t)); })) return 'codex entry draws over the open map';
       if(typeof mapPopupTick!=='function') return 'map popup hold is missing';
       say('WEATHER TURN','info',{key:'mapwait-weather'}); hubToast('corner notice');
       if(g.mapPop.q.length!==3) bad.push('three notices were not all held');
       tick(200); if(g.fd.t!==0||g.mapPop.q.length!==3) bad.push('held notices used time or vanished');
       g.mapOpen=false; msgTick(0.1);
       if(g.fd.lines.length!==1||String(g.fd.lines[0].txt).toLowerCase().replace(/\s+/g,' ')!=='codex entry \u00b7 scav pistol') bad.push('codex was not first after close: '+JSON.stringify(g.fd.lines.map(function(r){ return r.txt; })));
       if(g.msgT>0) bad.push('weather overwrote the first notice');
       for(i=0;i<70&&g.msg!=='WEATHER TURN';i++) tick(1);
       if(g.msg!=='WEATHER TURN'||g.msgT<3) bad.push('weather did not follow with its full lifetime');
       for(i=0;i<40&&g.mapPop.q.length;i++) tick(1);
       if(document.getElementById('hubtoast').textContent.toLowerCase()!=='corner notice') bad.push('corner notice was not last');
       if(g.mapPop.q.length) bad.push('the notice queue did not drain');
       // v28.xx (cw-cx-sectorhold-o03): an already visible popup also waits when M leaves world time running.
       g.mapPop.wait=0; say('existing notice','info'); msg=g.msgT; ft=g.fd.t; g.mapOpen=true; tick(120);
       if(g.msgT!==msg||g.fd.t!==ft) bad.push('an existing notice aged behind the map');
       g.mapOpen=false; msgTick(0.1); if(Math.abs(g.msgT-(msg-0.1))>0.001) bad.push('existing notice lost its remaining time');
       // v28.xx (cw-cx-sectorhold-o03): closing/opening/closing clears feed layout metadata as well as pixels (32.25).
       g.mapOpen=false; __drawHUD();
       if(!FEEDBOX.on||!FEEDBOX.rows.length) bad.push('feed layout control missing with the map shut');
       g.mapOpen=true; __drawHUD();
       if(FEEDBOX.on||FEEDBOX.rows.length) bad.push('previous feed layout survives over the open map');
       g.mapOpen=false; __drawHUD();
       if(!FEEDBOX.on||!FEEDBOX.rows.length) bad.push('feed layout did not return after map close');
       MAPFIRST.skip=0; g.mapOpen=false; saved=g.timeLeft;
       if(!mapFirstBegin()) bad.push('could not stage the opening map');
       else{ feedSay('opening codex','info'); for(i=0;i<30;i++){ mapFirstStep(0.1); msgTick(0.1); } if(g.timeLeft!==saved) bad.push('opening map consumed raid clock'); }
       mapFirstEnd('test'); g.mapFirst=0; g.mapOpen=true;
       if(mapSeatColor(-1)!==SEATCOL[0]||mapSeatColor(0)!==SEATCOL[0]||mapSeatColor(1)!==SEATCOL[1]) bad.push('seat colours differ from seat rings');
       for(n=0;n<2;n++){
         fills=[]; seatHere=(function(seat){ return function(){ return seat; }; })(n);
         proto.fill=function(){ fills.push(String(this.fillStyle).toLowerCase()); return ofill.apply(this,arguments); };
         try{ drawMapOverlay(); }finally{ proto.fill=ofill; seatHere=oseat; }
         if(fills.indexOf(SEATCOL[n])<0) bad.push('player '+(n+1)+' marker did not paint in its seat colour');
       }
       // v28.xx (cw-cx-sectorhold-o03): exercise the same narrow nine-contract layout as 31.55, rather than only the wider empty-contract map.
       P.contracts=[{type:'kill',tgt:'crawler',n:5,prog:3,reward:450,desc:'x',tier:'std'},{type:'open',ct:'crate',n:4,prog:1,reward:280,desc:'x',tier:'std'},
         {type:'district',d:0,n:3,prog:0,reward:480,desc:'x',tier:'std'},{type:'exItem',item:'core',n:1,prog:0,reward:1450,desc:'x',tier:'std'},
         {type:'haul',v:1200,n:1,prog:0,reward:720,desc:'x',tier:'std'},{type:'conduct',ck:'clean',n:1,prog:0,reward:900,desc:'x',tier:'std'},
         {type:'kill',tgt:'sentry',n:3,prog:3,reward:450,desc:'x',tier:'std'},{type:'conduct',ck:'swift',n:1,prog:0,reward:1000,desc:'x',tier:'std'},
         {type:'kill',tgt:'crawler',n:2,prog:0,reward:300,desc:'x',tier:'std'}];
       delete P.uiScale;
       if(!g.hotZone) g.hotZone={x:WORLD_W*0.3,y:WORLD_H*0.5,r:260};
       mapIcon=function(x,y,r){ var m=ctx.getTransform(); icons.push({l:(x-r)*m.a+m.e,t:(y-r)*m.d+m.f,r:(x+r)*m.a+m.e,b:(y+r)*m.d+m.f}); return oi.apply(this,arguments); };
       mapPlaceLabels=function(Q,hdr,fn){
         return op(Q,hdr,function(s,x,y){
           if(/^(cache|looted|encampment|peddler|strongbox|the forge)$/i.test(String(s))){
             var fm=/([\d.]+)px/.exec(ctx.font), fp=fm?+fm[1]:16, L={x:x,y:y,w:ctx.measureText(typeof TX==='function'?TX(String(s)):String(s)).width,fp:fp,m:ctx.getTransform(),ta:ctx.textAlign,tb:ctx.textBaseline};
             var B=mapLabelRect(L,0,0); markerRects.push({t:String(s),box:B});
             if(/^(cache|looted|strongbox)$/i.test(String(s))) labels.push(B);
           }
           return (fn||proto.fillText).call(ctx,s,x,y);
         });
       };
       for(n=0;n<2;n++){
         W=n?3840:1920; H=n?2160:1080; labels=[]; markerRects=[]; icons=[];
         __drawHUD();
         j=g.containers.filter(function(c){ return !!c.cache; }).length+g.containers.filter(function(c){ return c.strong&&!c.opened; }).length;
         if(labels.length!==j) bad.push('not every cache/strongbox has its own label at '+H+'p ('+labels.length+'/'+j+')');
         for(i=0;i<labels.length;i++) for(j=i+1;j<labels.length;j++) if(overlaps(labels[i],labels[j])) bad.push('loot labels overlap at '+H+'p');
         var cd=mapCard(), distant=[];
         markerRects.forEach(function(rec){ var B=rec.box, best=Infinity, nearest=null; icons.forEach(function(I){ var dx=Math.max(0,I.l-B.r,B.l-I.r), dy=Math.max(0,I.t-B.b,B.t-I.b), d=Math.sqrt(dx*dx+dy*dy); if(d<best){ best=d; nearest=I; } }); if(best>12*cd.z) distant.push({t:rec.t,gap:Math.round(best*10)/10,box:B,nearest:nearest}); });
         if(distant.length>3) bad.push('marker tags too far at '+H+'p: '+JSON.stringify(distant));
       }
       return bad.length?bad.join('; '):null;
     }finally{
       W=ow; H=oh; mapPlaceLabels=op; mapIcon=oi; seatHere=oseat; proto.fill=ofill; MAPFIRST.skip=os; keys={}; mouse.down=false;
       if(HUBTOAST_T) clearTimeout(HUBTOAST_T); HUBTOAST_T=null; document.getElementById('hubtoast').classList.remove('on');
       try{ if(g){ g.mapFirst=0; g.mapOpen=false; g.mapPop=null; } __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'32.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
