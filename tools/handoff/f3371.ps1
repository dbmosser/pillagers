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

if ($s.Contains("  {v:'33.71',what:")) { throw "check 33.71 is in the fixture already" }

SubRx @'
  {v:'33.70',what:
'@ @'
  {v:'33.71',what:'cw-pixbarrels (86e) ship 2: the red, shock, acid and cryo barrel bodies are one cached sprite per blink state (lit or not), hard edged, footprint 24 wide, no readback over 60 frames, and the idle pulse still moves',
   run:function(){
     if(typeof pixWrap!=='function'||typeof PIXW!=='object') return 'no adapter: pixWrap is not defined';
     if(!(window.__deploy&&window.__frame&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], list=[], pr=CanvasRenderingContext2D.prototype, gi0=pr.getImageData, td0=HTMLCanvasElement.prototype.toDataURL, ro=0, cfg0=CFG.xfPix, t0=null, i, j, r, ee, B0, e0, clip0, px, aa, a1, fw, a, b, wn=['drawImage','ellipse'];
     function cached(){ var s=new Set(); ['actors','scene'].forEach(function(kd){ PIXSTORE.m[kd].forEach(function(en){ s.add(en.c); if(en.pre) for(var q in en.pre) s.add(en.pre[q]); }); }); return s; }
     function probe(B,t){
       var cn={spr:0,ell:[]}, ss=cached(), cc=wc;
       wn.forEach(function(nm){ var orig=pr[nm]; cc[nm]=function(){
         if(nm==='drawImage'){ if(ss.has(arguments[0])) cn.spr++; } else cn.ell.push(arguments[2].toFixed(2));
         return orig.apply(this,arguments); }; });
       try{ G.t=t; pixFrame(); PIXW.last=null; brlDraw(B); } finally { wn.forEach(function(nm){ delete cc[nm]; }); }
       cn.e=PIXW.last; return cn;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; __frame(0.016);
       t0=G.t;
       ['red','shock','acid','cryo'].forEach(function(k,n){
         list.push({n:k+' idle',B:{x:300+n*60,y:700,id:3+n,k:k,fuse:-1},t:0.5});
         list.push({n:k+' lit on',B:{x:300+n*60,y:760,id:3+n,k:k,fuse:1},t:0});
         list.push({n:k+' lit off',B:{x:300+n*60,y:820,id:3+n,k:k,fuse:1},t:1/24+0.004});
       });
       clip0=PIXW.clip; e0=PIX.errs;
       for(j=0;j<3;j++) for(i=0;i<list.length;i++){ G.t=list[i].t; pixFrame(); brlDraw(list[i].B); }
       B0=PIX.builds;
       for(i=0;i<list.length;i++){
         r=probe(list[i].B,list[i].t); ee=r.e; list[i].e=ee;
         if(r.spr!==1) bad.push(list[i].n+' draws '+r.spr+' cached sprites, wanted 1');
         if(ee){
           fw=ee.c.width*ee.d;
           if(fw<22||fw>28) bad.push(list[i].n+' footprint is '+fw+' wide, wanted about 24');
           px=ee.c.getContext('2d').getImageData(0,0,ee.c.width,ee.c.height).data; aa=0; a1=0;
           for(j=3;j<px.length;j+=4){ if(px[j]===255) a1++; else if(px[j]!==0) aa++; }
           if(aa) bad.push(list[i].n+' sprite has '+aa+' soft alpha pixels');
           if(!a1) bad.push(list[i].n+' sprite is empty');
         } else bad.push(list[i].n+' drew no sprite');
       }
       if(PIX.builds!==B0) bad.push('a warmed barrel rebuilt ('+(PIX.builds-B0)+' builds)');
       if(list[1].e&&list[2].e&&list[1].e===list[2].e) bad.push('the lit blink states share one sprite');
       if(PIXW.clip!==clip0) bad.push(PIXW.clip-clip0+' sprites touched the edge of the scratch');
       if(PIX.errs!==e0) bad.push((PIX.errs-e0)+' bake errors');
       a=probe(list[0].B,0.4).ell.join('|'); b=probe(list[0].B,1.1).ell.join('|');
       if(!a) bad.push('the red barrel idle pulse draws nothing'); else if(a===b) bad.push('the red barrel idle pulse does not move');
       pr.getImageData=function(){ ro++; return gi0.apply(this,arguments); };
       HTMLCanvasElement.prototype.toDataURL=function(){ ro++; return td0.apply(this,arguments); };
       for(i=0;i<60;i++){ pixFrame(); for(j=0;j<list.length;j++){ G.t=list[j].t; brlDraw(list[j].B); } }
       pr.getImageData=gi0; HTMLCanvasElement.prototype.toDataURL=td0;
       if(ro) bad.push(ro+' readbacks over 60 frames');
       return bad.length?bad.slice(0,8).join('; '):null;
     } catch(err){
       return 'pixbarrels check: '+String(err&&err.message||err);
     } finally {
       pr.getImageData=gi0; HTMLCanvasElement.prototype.toDataURL=td0;
       if(t0!==null) G.t=t0;
       CFG.xfPix=cfg0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
