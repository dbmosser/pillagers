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

if ($s.Contains("  {v:'35.14',what:")) { throw "check 35.14 is in the fixture already" }

SubRx @'
  {v:'35.13',what:
'@ @'
  {v:'35.14',what:'FOG OF WAR: unexplored ground is grey, and tracers and sparks out of sight stay hidden with fog of war on',
   run:function(){
     var bad=[], p, im, d, keep=CFG.fogWar, far=null, i, a, rr, x, y, pts=[], rects=[];
     function hitL(){ for(var q=0;q<pts.length;q++) if(Math.abs(pts[q][0]-far.x)<1&&Math.abs(pts[q][1]-(far.y-12))<1) return true; return false; }
     function hitR(){ for(var q=0;q<rects.length;q++) if(Math.abs(rects[q][0]-(far.x-1.7))<1.5&&Math.abs(rects[q][1]-(far.y-7.8-1.7))<1.5) return true; return false; }
     function stage(){
       G.fxBullets=[{x:far.x,y:far.y,vx:600,vy:0,life:2,tint:'#ffd48a',owner:1,sx:far.x-60,sy:far.y}];
       G.sparks.push({x:far.x,y:far.y,t:0,life:1,c:'#ffaa00',z:3.4,nc:1});
       pts.length=0; rects.length=0; G._fwlT=-1;
     }
     try{
       __topClear(); __runPrep(); __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.fogWar=1;
       __deploy({kit:['gun_carbine'],mapIx:0,seed:4242});
       if(state!=='raid'||!G||!G.player) return 'no raid';
       G.mapFirst=false; G.mapOpen=false; p=G.player; G.ents.length=0; G.sparks.length=0; if(!G.vseg) G.vseg=G.map.segs;
       // (1) unexplored ground is grey
       fowEnsure(); for(i=0;i<G.fow.length;i++) G.fow[i]=0; G._fowDirty=1;
       im=fowMask();
       if(!im) bad.push('no fog of war mask');
       else { d=im.getContext('2d').getImageData(0,0,1,1).data; if(!(d[3]===255&&d[0]>=30&&d[1]>=30&&d[2]>=30&&Math.abs(d[0]-d[2])<=16)) bad.push('unexplored ground is rgba('+[d[0],d[1],d[2],d[3]].join(',')+'), not grey'); }
       // (2) a spot behind him that he cannot see
       for(a=0;a<17&&!far;a++){ for(rr=Math.max(280,AMBR()+80);rr<=760&&!far;rr+=60){ x=p.x+Math.cos(p.face+Math.PI+(a-8)*0.1)*rr; y=p.y+Math.sin(p.face+Math.PI+(a-8)*0.1)*rr;
         if(x>30&&y>30&&x<WORLD_W-30&&y<WORLD_H-30&&!canSee(p.x,p.y,p.face,x,y,G.vseg)) far={x:x,y:y}; } }
       if(!far) bad.push('staging: no spot out of his sight');
       else {
         if(typeof fowLive!=='function') bad.push('no live action test for fog of war');
         else {
           G._fwlT=-1;
           if(fowLive(far.x,far.y)) bad.push('a spot he cannot see counts as in sight');
           if(!fowLive(p.x+20,p.y)) bad.push('the spot beside him counts as out of sight');
         }
         // (3) a tracer and a spark out of sight are not drawn with fog of war on, and are with it off
         wc.lineTo=function(){ pts.push([arguments[0],arguments[1]]); return CanvasRenderingContext2D.prototype.lineTo.apply(this,arguments); };
         wc.fillRect=function(){ rects.push([arguments[0],arguments[1]]); return CanvasRenderingContext2D.prototype.fillRect.apply(this,arguments); };
         stage(); __frame(0);
         if(hitL()) bad.push('a tracer out of sight was drawn with fog of war on');
         if(hitR()) bad.push('a spark out of sight was drawn with fog of war on');
         CFG.fogWar=0; G.sparks.length=0; stage(); __frame(0);
         if(!hitL()) bad.push('control: the tracer was not drawn with fog of war off either');
         if(!hitR()) bad.push('control: the spark was not drawn with fog of war off either');
         CFG.fogWar=1;
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ delete wc.lineTo; delete wc.fillRect; }catch(_w){}
       try{ CFG.fogWar=keep; }catch(_f){}
       try{ if(G){ G.fxBullets=[]; if(G.sparks) G.sparks.length=0; } }catch(_b){}
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_s){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
