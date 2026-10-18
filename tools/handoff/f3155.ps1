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

if ($s.Contains("  {v:'31.55',what:")) { throw "check 31.55 is in the fixture already" }

SubRx @'
  {v:'31.54',what:
'@ @'
  {v:'31.55',what:'cw-mapstyle3: on the sector map card the marker tags sit at their own marks, every contract row has a bar (a rule contract too) and a full list runs to the bottom of the map frame, the hot ground has no explaining line, zone names are at the label size, and the sector name and the muted words sector map sit on one baseline',
   run:function(){
     if(typeof mapCard!=='function'||typeof mapContractRows!=='function') return 'no map card in this build (mapCard or mapContractRows is missing)';
     if(!(window.__state&&window.__endRaid&&window.__deploy&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy a raid';
     var lp=parseFloat((/([\d.]+)px/).exec(FS(TYPE.label))[1]), bad=[], g=null, w0=W, h0=H, us0=P.uiScale, hadUs=Object.prototype.hasOwnProperty.call(P,'uiScale'), oSkip=MAPFIRST.skip, proto=CanvasRenderingContext2D.prototype,
         oFR=proto.fillRect, oMI=mapIcon, oRR=mapRR, cd, i, ent, ic=[], rr=[], trk=[], nrow, tags, far=0, zn, nz=0, zbig=0, tl, pn, mu, tt, nm, hadHot;
     function base(h){ return h.y+((h.bl==='middle')?h.h*0.35:0); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       MAPFIRST.skip=1; keys={}; mouse.down=false;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no raid';
       P.contracts=[
         {type:'kill',tgt:'crawler',n:5,prog:3,reward:450,desc:'x',tier:'std'},{type:'open',ct:'crate',n:4,prog:1,reward:280,desc:'x',tier:'std'},
         {type:'district',d:0,n:3,prog:0,reward:480,desc:'x',tier:'std'},{type:'exItem',item:'core',n:1,prog:0,reward:1450,desc:'x',tier:'std'},
         {type:'haul',v:1200,n:1,prog:0,reward:720,desc:'x',tier:'std'},{type:'conduct',ck:'clean',n:1,prog:0,reward:900,desc:'x',tier:'std'},
         {type:'kill',tgt:'sentry',n:3,prog:3,reward:450,desc:'x',tier:'std'},{type:'conduct',ck:'swift',n:1,prog:0,reward:1000,desc:'x',tier:'std'},
         {type:'kill',tgt:'crawler',n:2,prog:0,reward:300,desc:'x',tier:'std'}];
       if(hadUs) delete P.uiScale;
       W=1920; H=1080; g.mapOpen=true; g.mapFirst=0; cd=mapCard();
       hadHot=!!g.hotZone; if(!hadHot) g.hotZone={x:WORLD_W*0.3,y:WORLD_H*0.5,r:260};
       nrow=mapContractRows().length;
       zn=((g.map&&g.map.zones)||[]).map(function(z){ return String(z.name||''); }).filter(function(s){ return s; });
       mapIcon=function(x,y,r){ var m=ctx.getTransform(); ic.push({l:(x-r)*m.a+m.e,t:(y-r)*m.d+m.f,r:(x+r)*m.a+m.e,b:(y+r)*m.d+m.f}); return oMI.apply(this,arguments); };
       mapRR=function(x,y,w,h,r){ var m=ctx.getTransform(); rr.push({x:x*m.a+m.e,y:y*m.d+m.f,w:w*m.a,h:h*m.d}); return oRR.apply(this,arguments); };
       proto.fillRect=function(x,y,w,h){ var m=this.getTransform(); trk.push({x:x*m.a+m.e,y:y*m.d+m.f,w:w*m.a,h:h*m.d,s:String(this.fillStyle).toLowerCase()}); return oFR.apply(this,arguments); };
       try{ ent=txRecord(function(){ drawMapOverlay(); }); } finally { proto.fillRect=oFR; mapRR=oRR; mapIcon=oMI; }
       // ONE: the hot ground says its name and nothing more
       if(!ent.filter(function(h){ return /^hot ground$/.test(String(h.t)); }).length) bad.push('ONE: no hot ground tag on the map');
       if(ent.filter(function(h){ return /richer/.test(String(h.t)); }).length) bad.push('ONE: the hot ground still carries the explaining line richer, and busier');
       // TWO: the marker tags sit at their marks (at most three may be moved off by a crowd, the packed corner of the locked rooms)
       tags=ent.filter(function(h){ return /^(cache|encampment|peddler|strongbox|the forge)$/.test(String(h.t)); });
       tags.forEach(function(h){ var bx=txBox(h), dmin=1e9, q, dx, dy; for(q=0;q<ic.length;q++){ dx=Math.max(0,ic[q].l-(bx.x+bx.w),bx.x-ic[q].r); dy=Math.max(0,ic[q].t-(bx.y+bx.h),bx.y-ic[q].b); dmin=Math.min(dmin,Math.sqrt(dx*dx+dy*dy)); } if(dmin>12*cd.z) far++; });
       if(tags.length<3) bad.push('TWO: only '+tags.length+' marker tags were drawn (at least 3 expected)');
       else if(far>3) bad.push('TWO: '+far+' of '+tags.length+' marker tags float more than 12 px from their mark');
       // THREE: every contract row has a bar, a rule contract too
       if(nrow<9) bad.push('THREE: only '+nrow+' of 9 contract rows were listed');
       tl=trk.filter(function(r){ return r.s===String(UIC.ui_line_hi).toLowerCase()&&r.h>=2&&r.h<=8*cd.z+1&&r.w>=100*cd.z&&cd.col&&r.x>=cd.col.x-1&&r.y>=cd.col.y&&r.y<=cd.col.y+cd.col.h; });
       if(cd.col&&tl.length!==nrow) bad.push('THREE: '+tl.length+' contract bars for '+nrow+' contract rows (a rule contract has no bar)');
       // FOUR: a full list runs to the bottom of the map frame
       pn=cd.col?rr.filter(function(r){ return Math.abs(r.x-cd.col.x)<=3*cd.z&&Math.abs(r.w-cd.col.w)<=3*cd.z; })[0]:null;
       if(!pn) bad.push('FOUR: no contracts panel was drawn');
       else if(Math.abs(pn.y+pn.h-(cd.col.y+cd.col.h))>3*cd.z) bad.push('FOUR: the contracts panel ends '+Math.round(cd.col.y+cd.col.h-(pn.y+pn.h))+' px off the bottom of the map frame');
       // FIVE: zone names at the label size
       ent.forEach(function(h){ if(zn.indexOf(String(h.o))>=0&&!(h.y<cd.y+cd.hh)){ nz++; if(h.h>lp*1.08*cd.z) zbig++; } });
       if(nz<3) bad.push('FIVE: only '+nz+' zone names were drawn');
       else if(zbig) bad.push('FIVE: '+zbig+' zone names are bigger than the label size ('+lp+' px)');
       // SIX: the sector name and the muted words on one baseline
       nm=String((g.map&&g.map.name)||'').toLowerCase();
       mu=ent.filter(function(h){ return /^sector map$/.test(String(h.t)); })[0];
       tt=ent.filter(function(h){ return h.al==='left'&&String(h.t)===nm&&h.y>=cd.y&&h.y<=cd.y+cd.hh; })[0];
       if(!mu||!tt) bad.push('SIX: the sector name or the words sector map are missing from the header');
       else if(Math.abs(base(tt)-base(mu))>1.5*cd.z) bad.push('SIX: the sector name and sector map are '+Math.abs(base(tt)-base(mu)).toFixed(1)+' px apart on the baseline');
       return bad.length?bad.join('; '):null;
     } finally {
       proto.fillRect=oFR; mapRR=oRR; mapIcon=oMI; W=w0; H=h0;
       if(hadUs) P.uiScale=us0; else delete P.uiScale;
       MAPFIRST.skip=oSkip; keys={}; mouse.down=false;
       try{ if(g&&!hadHot) g.hotZone=null; }catch(_h){}
       try{ if(G&&!G.over){ G.mapOpen=false; G.arcade=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     } }},
  {v:'31.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
