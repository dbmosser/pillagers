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

if ($s.Contains("  {v:'33.82',what:")) { throw "check 33.82 is in the fixture already" }

SubRx @'
  {v:'33.81',what:
'@ @'
  {v:'33.82',what:'cw-pixlamps (86e) ship 4: lamps and lamp posts, the forge body and the seal slab are cached scene sprites through pixWrap (hard alpha, footprint kept, no clipping, no bake errors); a throw inside pixWrap leaves wc as the world context',
   run:function(){
     if(typeof pixWrap!=='function'||typeof PIXW!=='object') return 'no adapter: pixWrap is not defined';
     if(!(window.__deploy&&window.__frame&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], calls=[], pw0=pixWrap, cfg0=CFG.xfPix, wc0, i, j, L1, e, px, aa, a1, clip0, e0, got={}, t, want, src, tm=[], T0=performance.now(), lamp, post, brk, thrown;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; __frame(0.016);
       post=G.lights.filter(function(q){ return q.post; })[0]; brk=G.lights.filter(function(q){ return !q.post; })[0];
       if(!post&&!brk) return 'SKIP: no lamps on this map';
       wc0=wc;
       pixWrap=function(key,w2,h2,d,paint,x,y,o){ var r=pw0.apply(this,arguments); calls.push({key:key,d:d,e:r}); return r; };
       clip0=PIXW.clip; e0=PIX.errs;
       want=[]; if(post) want.push(['lamp:p',post.x,post.y]); else want.push(['lamp:b',brk.x,brk.y]);
       src=String(render2D);
       if(src.indexOf("pixWrap('forge'")<0) bad.push('the forge body does not go through pixWrap');
       if(src.indexOf("pixWrap('seal:'")<0) bad.push('the seal slab does not go through pixWrap');
       want.forEach(function(w3){
         G.player.x=w3[1]; G.player.y=w3[2]+70;
         for(i=0;i<8;i++){
           calls.length=0; __frame(0.016); tm.push(Math.round(performance.now()-T0)+':'+calls.length+':'+calls.filter(function(c){ return c.e; }).length);
           L1=calls.filter(function(c){ return c.key.indexOf(w3[0])===0; });
           if(L1.length&&L1.every(function(c){ return c.e; })) break;
         }
         if(!L1.length){ bad.push(w3[0]+' was never drawn through the adapter'); return; }
         L1.forEach(function(c){
           if(!c.e){ bad.push(c.key+' fell back to vector'); return; }
           if(c.d!==PIX_ENV) bad.push(c.key+' is not at the scene density');
           e=c.e;
           if(e.c.width*e.d<8||e.c.height*e.d<20) bad.push(c.key+' sprite '+e.c.width*e.d+'x'+e.c.height*e.d+' is too small');
           px=e.c.getContext('2d').getImageData(0,0,e.c.width,e.c.height).data; aa=0; a1=0;
           for(j=3;j<px.length;j+=4){ if(px[j]===255) a1++; else if(px[j]!==0) aa++; }
           if(aa) bad.push(c.key+' sprite has '+aa+' soft alpha pixels');
           if(!a1) bad.push(c.key+' sprite is empty');
         });
       });
       pixWrap=pw0;
       thrown=false;
       try{ pixWrap('px-throw-test',20,20,PIX_ENV,function(){ throw new Error('forced'); },G.player.x,G.player.y,{up:10}); }catch(_t){ thrown=true; }
       if(wc!==wc0) bad.push('a forced throw inside pixWrap left wc pointing at the scratch');
       if(PIXW.clip!==clip0) bad.push(PIXW.clip-clip0+' sprites touched the edge of the scratch');
       if(PIX.errs-e0>1) bad.push((PIX.errs-e0-1)+' unexpected bake errors');
       return bad.length?bad.slice(0,8).join('; '):null;
     } catch(err){
       return 'pixlamps check: '+String(err&&err.message||err);
     } finally {
       pixWrap=pw0;
       CFG.xfPix=cfg0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
