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

if ($s.Contains("  {v:'33.78',what:")) { throw "check 33.78 is in the fixture already" }

SubRx @'
  {v:'33.77',what:
'@ @'
  {v:'33.78',what:'cw-pixhurt (86g): with the pixel look on a hit is drawn in pixels as a white then red wash over the layer silhouettes only with a 1 px recoil, low health draws the red ink ring layers at a pulse alpha that moves within a second with the shoulders 1 px lower and the stains baked in, and the hit and the low health no longer fall back to the vector body',
   run:function(){
     if(typeof pixDrawOp!=='function'||typeof pxTint!=='function'||typeof pxRingRed!=='function'||typeof pxLayer!=='function') return 'no pixel hurt states (pxTint, pxRingRed, pxLayer)';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], g, saved=false, hp0, hx0, t0, i, M, rs, rw, rr, rlo, ti, info, da, dp, k, ok, al=[], ringN=0, a0, a1, art0, art1, rd, parent, lowRec, st0, o1, o2, df=0, d1, d2;
     function px(c){ return c.getContext('2d').getImageData(0,0,c.width,c.height).data; }
     function maps(){
       var Mp=new Map();
       PIXSTORE.m.actors.forEach(function(en){
         var c;
         Mp.set(en.c,{p:en,k:'art'});
         if(en.tn) for(c in en.tn) Mp.set(en.tn[c].c,{p:en,k:'tint',col:c});
         if(en.rr) Mp.set(en.rr.c,{p:en,k:'ring'});
       });
       return Mp;
     }
     function rec1(fn){
       var d0=wc.drawImage, out=[];
       wc.drawImage=function(src){ out.push({s:src,a:wc.globalAlpha,x:arguments[1],y:arguments[2]}); return d0.apply(wc,arguments); };
       try{ fn(); } finally{ delete wc.drawImage; }
       return out;
     }
     function draw1(s,mode,face){ pixFrame(); drawOp(600,500,face||0,0,'#242832',0,0,mode,0,s); }
     function body(s,mode,face,tr){
       var j, before=PIX.bodies;
       for(j=0;j<(tr||14)&&PIX.bodies===before;j++) draw1(s,mode,face);
       return PIX.bodies>before;
     }
     function arts(r,Mp){ return r.filter(function(q){ var z=Mp.get(q.s); return z&&z.k==='art'; }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; g=__state();
       if(!g||g.over) return 'SKIP: no raid';
       function base(o){ var s={hero:1,own:g.player,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:0,rl:0}, z; for(z in o) s[z]=o[z]; return s; }
       wc.save(); saved=true; wc.setTransform(1,0,0,1,0,0);
       hp0=g.player.hp; hx0=g.player.hitDX; t0=g.t;
       g.player.hitDX=1;
       if(!body(base({}),'',0,16)) bad.push('the still body was not drawn in pixels');
       for(i=0;i<3;i++) draw1(base({}),'',0);
       rs=rec1(function(){ draw1(base({}),'',0); }); M=maps(); art0=arts(rs,M);
       if(art0.length<2) bad.push('the still body drew '+art0.length+' art layers');
       // the first 0.066 s of a hit: white, over the silhouettes only, with a 1 px recoil
       if(!body(base({hurt:0.4}),'',0,16)) bad.push('a hit was not drawn in pixels');
       rw=rec1(function(){ draw1(base({hurt:0.4}),'',0); }); M=maps();
       ti=rw.filter(function(q){ var z=M.get(q.s); return z&&z.k==='tint'; });
       if(ti.length<2) bad.push('the white frame drew '+ti.length+' wash layers, wanted 2 or more');
       ti.forEach(function(q){
         var z=M.get(q.s), Y=0, Z=0, n=0;
         if(z.col!=='#ffffff') bad.push('the first frame of a hit is washed '+z.col+', not white');
         if(!(q.a>0.8&&q.a<0.95)) bad.push('the white wash alpha is '+q.a);
         da=px(q.s); dp=px(z.p.c); ok=1;
         for(k=0;k<da.length;k+=4){
           if((da[k+3]>0)!==(dp[k+3]>0)) ok=0;
           if(da[k+3]>0){ n++; if(da[k]!==255||da[k+1]!==255||da[k+2]!==255||da[k+3]!==255) ok=0; }
         }
         if(!ok||n<20) bad.push('the white wash is not exactly the layer silhouette ('+n+' px)');
       });
       art1=arts(rw,M);
       if(art1.length&&art0.length&&art1[0].x-art0[0].x!==1) bad.push('the recoil moved the body '+(art1[0].x-art0[0].x)+' px, wanted 1');
       // then red, fading
       rr=rec1(function(){ draw1(base({hurt:0.3}),'',0); }); M=maps();
       ti=rr.filter(function(q){ var z=M.get(q.s); return z&&z.k==='tint'; });
       if(ti.length<2) bad.push('the red frame drew '+ti.length+' wash layers');
       ti.forEach(function(q){ var z=M.get(q.s); if(z.col!=='#ff3c30') bad.push('the fade of a hit is '+z.col+', not red'); if(!(q.a>0.1&&q.a<0.5)) bad.push('the red wash alpha is '+q.a); });
       // a hit that is over washes nothing and does not push
       rr=rec1(function(){ draw1(base({hurt:0.1}),'',0); }); M=maps();
       if(rr.filter(function(q){ var z=M.get(q.s); return z&&z.k==='tint'; }).length) bad.push('a hit older than 0.3 s still washes the body');
       art1=arts(rr,M); if(art1.length&&art0.length&&art1[0].x!==art0[0].x) bad.push('a hit older than 0.3 s still pushes the body');
       // low health
       g.player.hitDX=hx0; g.player.hp=20;
       if(!body(base({}),'',0,16)) bad.push('low health was not drawn in pixels');
       for(i=0;i<11;i++){
         g.t=i*0.1; draw1(base({}),'',0);
         lowRec=rec1(function(){ draw1(base({}),'',0); }); M=maps();
         lowRec.forEach(function(q){ var z=M.get(q.s); if(z&&z.k==='ring'){ al.push(q.a); ringN++; if(i===0&&!rd){ rd=q; parent=z.p; } } });
         if(i===0){ art1=arts(lowRec,M); }
       }
       if(ringN<11) bad.push('low health drew '+ringN+' ring layers in 11 frames');
       if(al.length){ a0=Math.min.apply(null,al); a1=Math.max.apply(null,al); if(a1-a0<0.3) bad.push('the ring pulse alpha only moved '+(a1-a0).toFixed(2)+' over 1 s'); }
       if(rd){
         da=px(rd.s); dp=px(parent.c); ok=1; k=0;
         for(i=0;i<da.length;i+=4) if(da[i+3]){ k++; if(!(da[i]>200&&da[i+1]<60&&da[i+2]<60)) ok=0; if(dp[i]!==22||dp[i+1]!==18||dp[i+2]!==28) ok=0; }
         if(!ok||k<30) bad.push('the red ring is not just the ink ring pixels ('+k+' px)');
       }
       if(art1&&art1.length>1&&art0.length>1){
         if(art1[0].y!==art0[0].y) bad.push('low health moved the legs');
         if(art1[1].y!==art0[1].y+1) bad.push('the shoulders dropped '+(art1[1].y-art0[1].y)+' px, wanted 1');
       }
       o1=pxBuildUpper({head:'short',skin:'fair',clothes:'scav',bot:0,mir:0,pup:0,arms:1,lamp:'',band:'',low:0}); o2=pxBuildUpper({head:'short',skin:'fair',clothes:'scav',bot:0,mir:0,pup:0,arms:1,lamp:'',band:'',low:1});
       d1=px(o1.c); d2=px(o2.c); for(i=0;i<d1.length;i++) if(d1[i]!==d2[i]) df++;
       if(df<8) bad.push('the low health upper body has no stains ('+df+' bytes differ)');
       g.t=t0; g.player.hp=hp0;
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel hurt check: '+String(err&&err.message||err);
     } finally {
       try{ delete wc.drawImage; }catch(_d){}
       try{ if(g&&g.player){ g.player.hitDX=hx0; if(hp0!==undefined) g.player.hp=hp0; if(t0!==undefined) g.t=t0; } }catch(_p){}
       if(saved){ try{ wc.restore(); }catch(_r){} }
       CFG.xfPix=0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
