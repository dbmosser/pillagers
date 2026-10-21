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

if ($s.Contains("  {v:'33.68',what:")) { throw "check 33.68 is in the fixture already" }

SubRx @'
  {v:'33.67',what:
'@ @'
  {v:'33.68',what:'cw-pixprops (86e) ship 1: the pixel adapter pixWrap and the containers, bodies, carcass and the 9 wrecks through it. After a warm-up each kind is ONE cached sprite drawImage (closed and opened both cached), the sprite holds only alpha 0 and 255, footprints are unchanged (crate 16, locker 12, cache 26), a forced throw leaves wc as the world context, no readback over 60 frames, the wreck smoke still moves and no wc.fillText',
   run:function(){
     if(typeof pixWrap!=='function'||typeof PIXW!=='object') return 'no adapter: pixWrap is not defined';
     if(!(window.__deploy&&window.__frame&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], list=[], pr=CanvasRenderingContext2D.prototype, gi0=pr.getImageData, td0=HTMLCanvasElement.prototype.toDataURL, ro=0, cfg0=CFG.xfPix, t0=null, i, j, r, ee, w0, s0, B0, k0, e0, names, px, aa, a0, a1, lim, fw, wn=['drawImage','fill','fillRect','stroke','fillText','arc'], clip0;
     function mkc(x,type,fn){ var q=mkContainer(x,700,type,0); q.loot=[]; if(fn) fn(q); return q; }
     function add(n,w,type,fn){ list.push({n:n+' closed',w:w,op:0,c:mkc(300+list.length*97,type,fn)}); list.push({n:n+' opened',w:w,op:1,c:mkc(300+list.length*97,type,function(q){ if(fn) fn(q); q.opened=true; })}); }
     function cached(){ var s=new Set(); ['actors','scene'].forEach(function(kd){ PIXSTORE.m[kd].forEach(function(en){ s.add(en.c); if(en.pre) for(var q in en.pre) s.add(en.pre[q]); }); }); return s; }
     function probe(ct){
       var cn={img:0,spr:0,fill:0,txt:0,arcs:[]}, ss=cached(), cc=wc;
       wn.forEach(function(nm){ var orig=pr[nm]; cc[nm]=function(){
         if(nm==='drawImage'){ cn.img++; if(ss.has(arguments[0])) cn.spr++; }
         else if(nm==='fillText') cn.txt++;
         else if(nm==='arc') cn.arcs.push(arguments[0].toFixed(2)+','+arguments[1].toFixed(2));
         else cn.fill++;
         return orig.apply(this,arguments); }; });
       try{ pixFrame(); PIXW.last=null; drawContS(ct); } finally { wn.forEach(function(nm){ delete cc[nm]; }); }
       cn.e=PIXW.last; return cn;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; __frame(0.016);
       add('crate',16,'crate'); add('locker',12,'locker'); add('safe',16,'safe'); add('camp safe',22,'safe',function(q){ q.camp=1; });
       add('cache',26,'cache'); add('jackpot',24,'jackpot'); add('generic box',20,'crate',function(q){ q.type='bin'; });
       add('body',0,'body'); add('botwreck',0,'botwreck'); add('deer',0,'crate',function(q){ q.carcass='deer'; });
       names=Object.keys(WRECKDRAW);
       if(names.length<9) bad.push('only '+names.length+' wreck painters registered');
       names.forEach(function(nm){ add('wreck '+nm,0,'cache',function(q){ q.bot=nm; q.cache=1; }); });
       add('wreck warden big',0,'cache',function(q){ q.bot='warden'; q.cache=1; q.ov=1; });
       clip0=PIXW.clip; e0=PIX.errs;
       for(j=0;j<3;j++) for(i=0;i<list.length;i++){ pixFrame(); drawContS(list[i].c); }
       B0=PIX.builds;
       for(i=0;i<list.length;i++){
         r=probe(list[i].c); ee=r.e; list[i].e=ee;
         if(r.spr!==1) bad.push(list[i].n+' draws '+r.spr+' cached sprites, wanted 1');
         lim=(list[i].c.bot&&!list[i].op)?3:0;
         if(r.fill>lim) bad.push(list[i].n+' makes '+r.fill+' live fills');
         if(r.txt) bad.push(list[i].n+' calls fillText '+r.txt);
         if(ee){
           fw=ee.c.width*ee.d;
           if(list[i].w&&!list[i].op&&(fw<list[i].w||fw>list[i].w+3)) bad.push(list[i].n+' footprint is '+fw+' wide, wanted '+list[i].w+' plus the ink ring');
           if(list[i].w&&list[i].op&&(fw<list[i].w||fw>list[i].w+6)) bad.push(list[i].n+' footprint is '+fw+' wide, wanted '+list[i].w+' plus lid');
           px=ee.c.getContext('2d').getImageData(0,0,ee.c.width,ee.c.height).data; a0=0; a1=0; aa=0;
           for(j=3;j<px.length;j+=4){ if(px[j]===0) a0++; else if(px[j]===255) a1++; else aa++; }
           if(aa) bad.push(list[i].n+' sprite has '+aa+' soft alpha pixels');
           if(!a1) bad.push(list[i].n+' sprite is empty');
         } else bad.push(list[i].n+' drew no sprite');
       }
       if(PIX.builds!==B0) bad.push('a warmed kind rebuilt ('+(PIX.builds-B0)+' builds)');
       for(i=0;i+1<list.length;i+=2) if(list[i].e&&list[i].e===list[i+1].e) bad.push(list[i].n+' and opened share one sprite');
       if(PIXW.clip!==clip0) bad.push(PIXW.clip-clip0+' sprites touched the edge of the scratch');
       if(PIX.errs!==e0) bad.push((PIX.errs-e0)+' bake errors');
       // wreck smoke still moves
       t0=G.t; for(i=0;i<list.length&&!(list[i].c.bot&&!list[i].op);i++){}
       if(i<list.length){ G.t=2.0; a0=probe(list[i].c); G.t=2.9; a1=probe(list[i].c);
         if(!a0.arcs.length) bad.push('no smoke over an unsearched wreck'); else if(a0.arcs.join('|')===a1.arcs.join('|')) bad.push('wreck smoke does not move'); }
       // a throw inside pixWrap
       w0=wc; s0=shadowE; k0=PIX.errs; pixFrame();
       r=pixWrap('t:forced',160,124,1,function(){ wc.fillRect(0,0,3,3); throw new Error('forced'); },0,0,{up:90});
       if(r) bad.push('a forced throw still returned a sprite');
       if(wc!==w0||shadowE!==s0||PIXW.on) bad.push('a forced throw left wc or shadowE or PIXW.on changed');
       PIX.errs=k0;
       // no readback over 60 frames
       pr.getImageData=function(){ ro++; return gi0.apply(this,arguments); };
       HTMLCanvasElement.prototype.toDataURL=function(){ ro++; return td0.apply(this,arguments); };
       for(i=0;i<60;i++){ pixFrame(); for(j=0;j<list.length;j++) drawContS(list[j].c); }
       pr.getImageData=gi0; HTMLCanvasElement.prototype.toDataURL=td0;
       if(ro) bad.push(ro+' readbacks over 60 frames');
       return bad.length?bad.slice(0,8).join('; '):null;
     } catch(err){
       return 'pixprops check: '+String(err&&err.message||err);
     } finally {
       pr.getImageData=gi0; HTMLCanvasElement.prototype.toDataURL=td0;
       if(t0!==null) G.t=t0;
       CFG.xfPix=cfg0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
