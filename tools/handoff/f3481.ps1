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

if ($s.Contains("  {v:'34.81',what:")) { throw "check 34.81 is in the fixture already" }

SubRx @'
  {v:'34.80',what:
'@ @'
  {v:'34.81',what:'cw-smoothlook, his notes of 2026-10-25 ("I want the graphics smooth", "Pillager still too big", "Bulwark still too small"): the smooth look is the default and a save that holds the pixel look moves to it once while a later pick survives; the pillager is drawn at 0.8; the bulwark is drawn and hit at 1.5 times the other machines',
   run:function(){
     if(typeof DEF==='undefined'||typeof GAMEOPTS==='undefined'||typeof applyGameOpts!=='function') return 'SKIP: no settings rows in this build';
     if(typeof __deploy!=='function'||typeof __runPrep!=='function') return 'SKIP: no raid helpers';
     var bad=[], row=null, i, go=null, had=false, mark, kw=wc, g, cvs, ctx;
     for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k==='xfPix') row=GAMEOPTS[i];
     if(DEF.xfPix!==0) bad.push('the pixel look default is '+DEF.xfPix+', not off');
     if(!row) bad.push('no pixel look row in Settings'); else if(!row.opts[row.def]||row.opts[row.def].cfg.xfPix!==0) bad.push('the pixel look row defaults to '+(row.opts[row.def]?row.opts[row.def].n:'?')+', not off');
     if(typeof FIG_SCALE==='undefined'||Math.abs(FIG_SCALE-0.8)>1e-9) bad.push('the pillager is drawn at FIG_SCALE '+(typeof FIG_SCALE==='undefined'?'(none)':FIG_SCALE)+', not 0.8');
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       go=P.gameOpts?JSON.stringify(P.gameOpts):null; had=('pixOff1' in P); mark=P.pixOff1;
       if(!P.gameOpts) P.gameOpts={};
       delete P.pixOff1; P.gameOpts.xfPix=0; applyGameOpts();
       if(CFG.xfPix!==0) bad.push('a save that holds the pixel look loads with xfPix '+CFG.xfPix+', not the smooth look');
       P.gameOpts.xfPix=0; applyGameOpts();
       if(CFG.xfPix!==1) bad.push('the pixel look picked after the move loads with xfPix '+CFG.xfPix+' (a later pick must survive)');
       delete P.gameOpts.xfPix; applyGameOpts();
       if(CFG.xfPix!==0) bad.push('a save with no pick loads with xfPix '+CFG.xfPix+', not the smooth look');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ if(go===null) delete P.gameOpts; else P.gameOpts=JSON.parse(go); if(had) P.pixOff1=mark; else delete P.pixOff1; applyGameOpts(); }catch(_r){} try{ __resetCfg(); }catch(_c){} }
     if(typeof mkBulwark!=='function'||typeof drawBulwarkS!=='function'||typeof machMul!=='function'||typeof machScaleBegin!=='function'||typeof mkSentry!=='function'){ bad.push('no bulwark maker, painter or machine size helpers to measure'); return bad.join('; '); }
     function box(e,scaled){
       ctx.setTransform(1,0,0,1,0,0); ctx.clearRect(0,0,900,900);
       wc=ctx; var n=0;
       try{ if(scaled) n=machScaleBegin(e); drawBulwarkS(e); }finally{ machScaleEnd(n); wc=kw; }
       var d=ctx.getImageData(0,0,900,900).data, x0=1e9,y0=1e9,x1=-1,y1=-1, x, y;
       for(y=0;y<900;y++) for(x=0;x<900;x++) if(d[(y*900+x)*4+3]>12){ if(x<x0)x0=x; if(x>x1)x1=x; if(y<y0)y0=y; if(y>y1)y1=y; }
       return x1<0?null:{w:x1-x0+1,h:y1-y0+1};
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       cvs=document.createElement('canvas'); cvs.width=900; cvs.height=900; ctx=cvs.getContext('2d');
       var b=mkBulwark(450,600), s=mkSentry(450,600), b0, b1; b.face=0; b.hitT=0;
       if(Math.abs(machMul(b)-1.33*1.5)>1e-6) bad.push('the bulwark size factor is '+machMul(b)+', not 1.33 x 1.5');
       if(machMul(s)!==1.33) bad.push('control: a sentry size factor moved to '+machMul(s));
       b0=box(b,false); b1=box(b,true);
       if(!b0||!b1) bad.push('the bulwark drew nothing on the test canvas');
       else if(Math.abs(b1.h/b0.h-1.995)>0.06||Math.abs(b1.w/b0.w-1.995)>0.06) bad.push('the bulwark is drawn x'+(b1.w/b0.w).toFixed(3)+' wide by x'+(b1.h/b0.h).toFixed(3)+' tall, not about x2 of its art');
     }catch(err2){ bad.push('bulwark threw: '+(err2&&err2.message||err2)); }
     finally{ wc=kw; try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
