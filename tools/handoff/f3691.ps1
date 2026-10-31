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

if ($s.Contains("  {v:'36.91',what:")) { throw "check 36.91 is in the fixture already" }

SubRx @'
  {v:'36.90',what:
'@ @'
  {v:'36.91',what:'cw-mappolish: on the seed 4242 Cold Storage map at 1080p and 4K no two map labels touch, the strongbox word sits beside its icon (4 to 16 px clear), zone names are brighter, the contract reward is main text and the progress track is thicker',
   run:function(){
     var g, bad=[], os=MAPFIRST.skip, ow=W, oh=H, oi=mapIcon, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, oFR=proto.fillRect, icons, n, f, z, ent, cd, sb, zn, zfs, rews, tracks, i, j;
     function a(s){ var m=/^rgba?\(([\d.]+),\s*([\d.]+),\s*([\d.]+)(?:,\s*([\d.]+))?\)$/.exec(String(s)); return m?(m[4]===undefined?1:+m[4]):1; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); MAPFIRST.skip=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||g.over) return 'SKIP: no raid';
       P.contracts=[{type:'kill',tgt:'crawler',n:5,prog:3,reward:4321,desc:'Destroy 5 crawlers',tier:'std'},{type:'open',ct:'crate',n:4,prog:4,reward:777,desc:'Search 4 crates',tier:'std'},{type:'conduct',ck:'clean',n:1,prog:0,reward:1234,desc:'Extract without using a single heal',tier:'std'},{type:'kill',tgt:'crawler',n:3,prog:0,reward:500,desc:'Destroy 3 crawlers',tier:'std'},{type:'open',ct:'crate',n:5,prog:0,reward:350,desc:'Search 5 crates',tier:'std'},{type:'kill',tgt:'raider',n:2,prog:0,reward:520,desc:'Eliminate 2 pillagers',tier:'std'}];
       g.mapOpen=true; g.bagOpen=false; g.paused=false; keys={}; mouse.down=false;
       sb=g.containers.filter(function(v){ return v.strong&&!v.opened; })[0];
       zn=((g.map&&g.map.zones)||[]).map(function(q){ return String(q.name||'').toLowerCase(); }).filter(function(s){ return s; });
       if(!sb) return 'staging: no strongbox';
       for(n=0;n<2;n++){
         W=n?3840:1920; H=n?2160:1080; z=Math.max(1,hudRes());
         for(f=0;f<2;f++){
           g.mapFirst=f; g.intel=1; zfs=[]; rews=[]; tracks=[];
           proto.fillText=function(s){ var k=String(s).toLowerCase(); if(zn.indexOf(k)>=0) zfs.push(this.fillStyle); if(/^\$4,321$/.test(k)) rews.push(this.fillStyle); return oFT.apply(this,arguments); };
           proto.fillRect=function(x,y,w,h){ tracks.push([x,y,w,h]); return oFR.apply(this,arguments); };
           icons=[]; mapIcon=function(x,y,r){ icons.push([x,y,r]); return oi.apply(this,arguments); };
           try{ ent=txRecord(function(){ drawMapOverlay(); }); } finally { proto.fillText=oFT; proto.fillRect=oFR; mapIcon=oi; }
           cd=mapCard();
           var m=mapProj(), tag='z'+z+(f?' start':' map');
           var bx=ent.filter(function(h){ var b=txBox(h), cx=b.x+b.w/2, cy=b.y+b.h/2; return cx>m.ox&&cx<m.ox+WORLD_W*m.sc&&cy>m.oy&&cy<m.oy+WORLD_H*m.sc; }).map(function(h){ var b=txBox(h); return {t:String(h.t),l:b.x,r:b.x+b.w,tp:b.y,bt:b.y+b.h}; });
           var mg=1e9, ov=[], c, gx, gy, d;
           for(i=0;i<bx.length;i++) for(j=i+1;j<bx.length;j++){ c=bx[i]; d=bx[j]; gx=Math.max(c.l-d.r,d.l-c.r); gy=Math.max(c.tp-d.bt,d.tp-c.bt); if(gx<0&&gy<0) ov.push(c.t+'|'+d.t); else mg=Math.min(mg,Math.max(gx,gy)); }
           if(ov.length) bad.push(tag+': labels overlap '+ov.join(', '));
           if(mg<6*z-0.5) bad.push(tag+': two labels are only '+mg.toFixed(1)+' px apart');
           if(bx.length<20) bad.push(tag+': only '+bx.length+' labels drawn');
           if(!f){
             var sw=bx.filter(function(b){ return /^strongbox$/i.test(b.t); })[0], ix=m.ox+sb.x*m.sc, iy=m.oy+sb.y*m.sc, r=15*z, sg;
             if(!sw) bad.push(tag+': the strongbox word is missing');
             else{ sg=Math.max(sw.l-(ix+r),(ix-r)-sw.r,sw.tp-(iy+r),(iy-r)-sw.bt); if(sg<4) bad.push(tag+': the strongbox word is only '+sg.toFixed(1)+' px from its icon'); if(sg>16*z) bad.push(tag+': the strongbox word floats '+sg.toFixed(1)+' px off its icon (over '+(16*z)+') DIAG icons='+icons.filter(function(c){ return Math.abs(c[0]-ix)<300&&Math.abs(c[1]-iy)<300; }).map(function(c){ return Math.round(c[0])+','+Math.round(c[1])+'r'+Math.round(c[2]); }).join(' ')+' box='+Math.round(m.ox)+'-'+Math.round(m.ox+WORLD_W*m.sc)); }
             if(!zfs.length||Math.min.apply(null,zfs.map(a))<0.74) bad.push(tag+': zone names are drawn under 74 percent');
             if(!rews.length||rews.some(function(s){ return String(s).toLowerCase()!==String(UIC.tx_1).toLowerCase(); })) bad.push(tag+': the contract reward is not the main text colour');
             var q=Math.round(20*cd.u), tk=tracks.filter(function(t){ return cd.col&&Math.abs(t[0]-(cd.col.x+q))<1.1&&Math.abs(t[2]-(cd.col.w-2*q))<1.1; });
             if(!tk.length||Math.min.apply(null,tk.map(function(t){ return t[3]; }))<5*z-0.6) bad.push(tag+': the progress tracks are under '+(5*z)+' px thick ('+(tk[0]?tk[0][3]:'none')+')');
           }
         }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       proto.fillText=oFT; proto.fillRect=oFR; mapIcon=oi; W=ow; H=oh; MAPFIRST.skip=os;
       try{ if(g){ g.mapFirst=0; g.mapOpen=false; } __endRaid('abandon'); }catch(e){} __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'36.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
