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

if ($s.Contains("  {v:'32.30',what:")) { throw "check 32.30 is in the fixture already" }

SubRx @'
  {v:'32.29',what:
'@ @'
  {v:'32.30',what:'cw-cx-mapspace-o03: every cache and strongbox retains an individual tag with 12px label clearance and its own leader, while contract tracks align',
   run:function(){
     var bad=[], g, ow=W, oh=H, os=MAPFIRST.skip, op=mapPlaceLabels, oi=mapIcon, PR=CanvasRenderingContext2D.prototype, of=PR.fillText, ofr=PR.fillRect, ost=PR.stroke, om=PR.moveTo, ol=PR.lineTo,
         tags=[], all=[], icons=[], strokes=[], points=[], tracks=[], col=null, z=1, i, j, pass, oldC=P.contracts, oldUS=P.uiScale, hadUS=Object.prototype.hasOwnProperty.call(P,'uiScale');
     function rect(s,x,y){ var m=ctx.getTransform(), fp=+((/([\d.]+)px/.exec(ctx.font)||[0,16])[1]); return mapLabelRect({s:s,x:x,y:y,w:ctx.measureText(typeof TX==='function'?TX(String(s)):String(s)).width,fp:fp,m:m,ta:ctx.textAlign,tb:ctx.textBaseline},0,0); }
     function gap(a,b){ return Math.sqrt(Math.pow(Math.max(0,a.l-b.r,b.l-a.r),2)+Math.pow(Math.max(0,a.t-b.b,b.t-a.b),2)); }
     function hasPoint(p){ return strokes.some(function(path){ return path.some(function(v){ return Math.abs(v.x-p.x)<10*z&&Math.abs(v.y-p.y)<10*z; }); }); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); MAPFIRST.skip=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||!g.player||g.over) return 'SKIP: no raid';
       g.mapOpen=true; g.mapFirst=0; g.bagOpen=false; g.paused=false; keys={}; mouse.down=false; delete P.uiScale;
       P.contracts=[{type:'conduct',ck:'clean',n:1,prog:0,reward:450,desc:'x',tier:'std'},{type:'kill',tgt:'crawler',n:5,prog:3,reward:450,desc:'x',tier:'std'},
         {type:'open',ct:'crate',n:4,prog:1,reward:280,desc:'x',tier:'std'},{type:'district',d:0,n:3,prog:0,reward:480,desc:'x',tier:'std'},
         {type:'exItem',item:'core',n:1,prog:0,reward:1450,desc:'x',tier:'std'},{type:'haul',v:1200,n:1,prog:0,reward:720,desc:'x',tier:'std'},
         {type:'kill',tgt:'sentry',n:3,prog:3,reward:450,desc:'x',tier:'std'},{type:'conduct',ck:'swift',n:1,prog:0,reward:1000,desc:'x',tier:'std'},
         {type:'kill',tgt:'crawler',n:2,prog:0,reward:300,desc:'x',tier:'std'}];
       mapIcon=function(x,y,r){ var m=ctx.getTransform(); icons.push({l:(x-r)*m.a+m.e,t:(y-r)*m.d+m.f,r:(x+r)*m.a+m.e,b:(y+r)*m.d+m.f}); return oi.apply(this,arguments); };
       PR.moveTo=function(x,y){ var m=this.getTransform(); points=[{x:x*m.a+m.e,y:y*m.d+m.f}]; return om.apply(this,arguments); };
       PR.lineTo=function(x,y){ var m=this.getTransform(); points.push({x:x*m.a+m.e,y:y*m.d+m.f}); return ol.apply(this,arguments); };
       PR.stroke=function(){ if(points.length>1) strokes.push(points.slice()); return ost.apply(this,arguments); };
       mapPlaceLabels=function(Q,hdr,fn){
         return op(Q,hdr,function(s,x,y){
           var B=rect(s,x,y), source=Q.filter(function(L){ return L.s===s&&!L._probeUsed; })[0];
           all.push(B);
           if(/^(cache|looted|strongbox)$/i.test(String(s))){ if(source) source._probeUsed=1; tags.push({box:B,source:source,text:String(s)}); }
           return (fn||of).call(ctx,s,x,y);
         });
       };
       PR.fillRect=function(x,y,w,h){ if(col&&String(this.fillStyle).toLowerCase()===String(UIC.ui_line_hi).toLowerCase()&&h>=2*z&&h<=8*z&&x>=col.x-1&&x<col.x+col.w&&y>=col.y&&y<col.y+col.h) tracks.push({x:x,w:w}); return ofr.apply(this,arguments); };
       for(pass=0;pass<2;pass++){
         W=pass?3840:1920; H=pass?2160:1080; var cd=mapCard(); z=cd.z; col=cd.col; tags=[]; all=[]; icons=[]; strokes=[]; tracks=[];
         __drawHUD();
         var expected=g.containers.filter(function(c){ return !!c.cache; }).length+g.containers.filter(function(c){ return c.strong&&!c.opened; }).length;
         if(tags.length!==expected) bad.push('lost loot tags at '+H+'p: '+tags.length+'/'+expected);
         tags.forEach(function(T){
           all.forEach(function(B){ if(B===T.box) return; if(T.box.l<B.r+11.5*z&&B.l<T.box.r+11.5*z&&T.box.t<B.b+11.5*z&&B.t<T.box.b+11.5*z) bad.push('less than 12px label clearance at '+H+'p: '+T.text); });
           var L=T.source; if(!L||!L.mark){ bad.push('loot tag has no own anchor'); return; }
           var M=L.mark, p={x:M.x*M.m.a+M.m.e,y:M.y*M.m.d+M.m.f}, I={l:p.x-8*z,r:p.x+8*z,t:p.y-8*z,b:p.y+8*z};
           if(gap(T.box,I)>100*z) bad.push('loot tag more than 100px from its own icon at '+H+'p');
           var original=mapLabelRect(L,0,0); if((Math.abs(original.l-T.box.l)>z||Math.abs(original.t-T.box.t)>z)&&gap(T.box,I)>2*z&&!hasPoint(p)) bad.push('displaced loot tag lacks a leader at its own icon');
         });
         if(tracks.length!==mapContractRows().length) bad.push('not every contract has a track');
         if(tracks.length&&tracks.some(function(t){ return Math.abs(t.x-tracks[0].x)>z||Math.abs(t.w-tracks[0].w)>z; })) bad.push('contract tracks have ragged edges');
       }
       return bad.length?bad.join('; '):null;
     }finally{
       mapPlaceLabels=op; mapIcon=oi; PR.fillText=of; PR.fillRect=ofr; PR.stroke=ost; PR.moveTo=om; PR.lineTo=ol; W=ow; H=oh; MAPFIRST.skip=os;
       P.contracts=oldC; if(hadUS) P.uiScale=oldUS; else delete P.uiScale; keys={}; mouse.down=false;
       try{ if(g){ g.mapOpen=false; g.mapFirst=0; } __endRaid('abandon'); }catch(e){} __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'32.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
