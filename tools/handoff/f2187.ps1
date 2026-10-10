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

if ($s.Contains("  {v:'21.87',what:")) { throw "check 21.87 is in the fixture already" }

SubRx @'
  {v:'21.86',what:
'@ @'
  {v:'21.87',what:'no message line runs off the screen: a 260 character line wraps at a word into at most two lines that lie inside the screen at 1080p and at 4K, and its full text goes into the run report',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof ctx.getTransform!=='function') return 'SKIP: no getTransform here';
     var bad=[], ev=[], g, realSay=say, oFT=ctx.fillText, SZ=[[1920,1080],[3840,2160]], si, forced=false, at, i, ws=[], LONG, pc, j, t;
     for(i=0;i<60;i++) ws.push('zqx'+i);
     LONG=ws.join(' ').slice(0,260).replace(/\s+\S*$/,'');
     if(LONG.length<240) return 'SKIP: the probe line came out short';
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     function spy(){ ev=[]; ctx.fillText=function(s,x,y){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, w=ctx.measureText(String(s)).width, cx=(m.a*x+m.c*y+m.e)/d, al=String(ctx.textAlign), hw=w*Math.abs(m.a)/d, x0=al==='center'?cx-hw/2:(al==='right'||al==='end')?cx-hw:cx; ev.push({t:String(s),x0:x0,x1:x0+hw}); return oFT.apply(this,arguments); }; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       keys={}; g.mapOpen=false; g.bagOpen=false;
       for(si=0;si<SZ.length;si++){
         if(window.__forceSize){ __forceSize(SZ[si][0],SZ[si][1]); forced=true; } else if(si) break;
         at=W+'x'+H;
         g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[];
         say=realSay; say(LONG);
         say=function(){};   // nothing else is said mid-frame
         spy();
         try{ __frame(0.016); } finally { unspy(); }
         pc=[];
         for(j=0;j<ev.length;j++){ t=ev[j].t.replace(/\u2026$/,''); if(t.length>=8&&LONG.indexOf(t)>=0) pc.push(ev[j]); }
         if(!pc.length){ bad.push('at '+at+' the long line was not drawn'); continue; }
         if(pc.length>2) bad.push('at '+at+' the long line was drawn in '+pc.length+' pieces, more than two');
         for(j=0;j<pc.length;j++) if(pc[j].x0<-0.5||pc[j].x1>W+0.5) bad.push('at '+at+' a piece of the long line runs from x '+Math.round(pc[j].x0)+' to '+Math.round(pc[j].x1)+', off a screen '+W+' wide');
         if(!(g.tel&&g.tel.longLines&&g.tel.longLines.indexOf(LONG)>=0)) bad.push('at '+at+' the full long line is not in the run report (G.tel.longLines)');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay; keys={};
       if(forced){ try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_f){} }
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
