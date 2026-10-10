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

if ($s.Contains("  {v:'21.82',what:")) { throw "check 21.82 is in the fixture already" }

SubRx @'
  {v:'21.81',what:
'@ @'
  {v:'21.82',what:'the raid text look: the message line is outlined in ink and sits on a rounded plate sized from its font',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var proto=CanvasRenderingContext2D.prototype;
     if(!proto.roundRect) return 'SKIP: this browser has no roundRect';
     var bad=[], ev=[], g, j, q, pl=null, st=null, px, realSay=say, MSG=['zq','look','line'].join(' '),
         oST=ctx.strokeText, oFT=ctx.fillText, oRR=ctx.roundRect, oFR=ctx.fillRect;
     function unspy(){
       delete ctx.strokeText; if(ctx.strokeText!==oST) ctx.strokeText=oST;
       delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT;
       delete ctx.roundRect; if(ctx.roundRect!==oRR) ctx.roundRect=oRR;
       delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       keys={}; g.mapOpen=false; g.bagOpen=false;
       if(typeof HUDC!=='object'||!HUDC||HUDC.danger!=='#ff5a4a'||HUDC.extract!=='#4de3d0') bad.push('there is no HUDC palette with danger and extract');
       say=function(){};   // nothing replaces the probe line mid-frame
       g.msg=MSG; g.msgT=3;
       ctx.strokeText=function(t){ ev.push({k:'st',t:String(t),lw:+ctx.lineWidth,ss:String(ctx.strokeStyle).toLowerCase(),lj:String(ctx.lineJoin)}); return oST.apply(this,arguments); };
       ctx.fillText=function(t){ ev.push({k:'ft',t:String(t),font:String(ctx.font)}); return oFT.apply(this,arguments); };
       ctx.roundRect=function(x,y,w,h){ ev.push({k:'rr',h:+h,w:+w}); return oRR.apply(this,arguments); };
       ctx.fillRect=function(x,y,w,h){ ev.push({k:'fr',h:+h,w:+w}); return oFR.apply(this,arguments); };
       try{ __frame(0.016); } finally { unspy(); }
       for(j=ev.length-1;j>=0;j--) if(ev[j].k==='ft'&&ev[j].t===MSG) break;
       if(j<0) return 'SKIP: the message line was not drawn this frame';
       for(q=j-1;q>=0;q--){ if(!st&&ev[q].k==='st'&&ev[q].t===MSG) st=ev[q]; if(ev[q].k==='rr'||ev[q].k==='fr'){ pl=ev[q]; break; } }
       px=parseFloat(((/([\d.]+)px/).exec(ev[j].font)||[0,0])[1])||0;
       if(!st) bad.push('the message line is not outlined (no strokeText of it before its fill)');
       else {
         if(!(st.lw>0)) bad.push('the outline has no width');
         if(st.ss!==String(INK).toLowerCase()) bad.push('the outline is '+st.ss+', not the ink '+INK);
         if(st.lj!=='round') bad.push('the outline joins are '+st.lj+', not round');
       }
       if(!pl) bad.push('the message line has no plate under it');
       else {
         if(pl.k!=='rr') bad.push('the message plate is a flat rectangle, not a rounded plate');
         if(!(px>0&&pl.h>=px*1.25)) bad.push('the plate is '+Math.round(pl.h)+' tall for '+px+'px words; it must be at least 1.25 times the font');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ unspy(); say=realSay; try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
