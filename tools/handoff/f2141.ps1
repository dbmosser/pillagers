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

if ($s.Contains("  {v:'21.41',what:")) { throw "check 21.41 is in the fixture already" }

SubRx @'
  {v:'21.40',what:
'@ @'
  {v:'21.41',what:'the sector map markers grow with the screen: at 4K the waypoint ring, the encampment diamond and the strongbox ring are drawn at the map zoom, about twice their 1080p size, and at 1080p they are as they were',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__forceSize)) return 'SKIP: this fixture cannot deploy at a forced size';
     if(typeof drawMapOverlay!=='function'||typeof mapProj!=='function'||typeof hudRes!=='function'||typeof WORLD_W!=='number'||typeof WORLD_H!=='number') return 'SKIP: no sector map here';
     var bad=[], g=null, oArc=ctx.arc, oLT=ctx.lineTo, wp0, cp0, staged=false, WP=null, CP=null, SB={x:0,y:0,strong:true,opened:false,loot:[]}, s1, s4, z4;
     function near(a,b){ return Math.abs(a-b)<0.6; }
     function grab(){
       var arcs=[], lines=[], M, o={wp:0,cp:0,sb:0}, i, wx, wy, cx, cy, bx, by;
       ctx.arc=function(x,y,r){ arcs.push([x,y,r]); return oArc.apply(this,arguments); };
       ctx.lineTo=function(x,y){ lines.push([x,y]); return oLT.apply(this,arguments); };
       ctx.save();
       try{ drawMapOverlay(); } finally { ctx.restore(); delete ctx.arc; delete ctx.lineTo; if(ctx.arc!==oArc) ctx.arc=oArc; if(ctx.lineTo!==oLT) ctx.lineTo=oLT; }
       M=mapProj(); wx=M.ox+WP.x*M.sc; wy=M.oy+WP.y*M.sc; cx=M.ox+CP.x*M.sc; cy=M.oy+CP.y*M.sc; bx=M.ox+SB.x*M.sc; by=M.oy+SB.y*M.sc;
       for(i=0;i<arcs.length;i++){
         if(near(arcs[i][0],wx)&&near(arcs[i][1],wy)) o.wp=Math.max(o.wp,arcs[i][2]);
         if(near(arcs[i][0],bx)&&near(arcs[i][1],by)) o.sb=Math.max(o.sb,arcs[i][2]);
       }
       for(i=0;i<lines.length;i++) if(near(lines[i][1],cy)&&lines[i][0]>cx&&lines[i][0]-cx<60) o.cp=Math.max(o.cp,lines[i][0]-cx);
       return o;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       wp0=g.waypoint; cp0=g.camps;
       WP={x:Math.round(WORLD_W*0.31)+0.25,y:Math.round(WORLD_H*0.57)+0.25};
       CP={x:Math.round(WORLD_W*0.69)+0.25,y:Math.round(WORLD_H*0.43)+0.25};
       SB.x=Math.round(WORLD_W*0.47)+0.25; SB.y=Math.round(WORLD_H*0.73)+0.25;
       g.waypoint=WP; g.camps=[CP]; g.containers.push(SB); staged=true;
       s1=grab();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       z4=hudRes(); s4=grab();
       if(!(z4>1.5)) return 'SKIP: the screen factor did not grow at 4K';
       if(!s1.wp||!s1.cp||!s1.sb) return 'SKIP: staging: a staged marker was not drawn at 1080p ('+JSON.stringify(s1)+')';
       if(!near(s1.wp,7)||!near(s1.cp,9)||!near(s1.sb,10)) bad.push('at 1080p the markers changed size: waypoint ring '+s1.wp+', diamond '+s1.cp+', strongbox ring '+s1.sb);
       if(s4.wp<7*z4-0.5) bad.push('at 4K the waypoint ring is '+s4.wp.toFixed(1)+' across its middle, as at 1080p, on a map drawn '+z4.toFixed(2)+' times bigger');
       if(s4.cp<9*z4-0.5) bad.push('at 4K the encampment diamond reaches '+s4.cp.toFixed(1)+' out, its 1080p size');
       if(s4.sb<10*z4-0.5) bad.push('at 4K the strongbox ring is '+s4.sb.toFixed(1)+', its 1080p size');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       delete ctx.arc; delete ctx.lineTo; if(ctx.arc!==oArc) ctx.arc=oArc; if(ctx.lineTo!==oLT) ctx.lineTo=oLT;
       try{ if(g&&staged){ var ix=g.containers.indexOf(SB); if(ix>=0) g.containers.splice(ix,1); g.waypoint=wp0; g.camps=cp0; } }catch(_r){}
       try{ cv.style.width='';cv.style.height='';hcv.style.width='';hcv.style.height=''; resize(); }catch(_f){}
       try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
