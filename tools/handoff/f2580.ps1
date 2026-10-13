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

if ($s.Contains("  {v:'25.80',what:")) { throw "check 25.80 is in the fixture already" }

SubRx @'
  {v:'25.79',what:
'@ @'
  {v:'25.80',what:'his note (looted item names fade faster, they impede vision): a loot name popup lives about four seconds instead of six, peaks at 0.85, is clearly fainter at half life (under 0.7, it was 0.91), is at alpha 0 by the end of its life, and stacks plate on plate with no gap, while a combat callout keeps its 1.9 s life, its full peak and its fade',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof label!=='function'||typeof render2D!=='function'||typeof labelPlateH!=='function') return 'SKIP: this fixture cannot stage a loot label';
     var bad=[], g=null, p=null, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, rec=[], lb=null, nl=null, a0, aQ, aH, aE, i, ys, lph, sp, aN, N1='ZQX LOOT ONE', N2='ZQX CALLOUT';
     function alphaOf(l,t){
       var j; l.t=t; rec=[];
       proto.fillText=function(s){ rec.push([String(s),this.globalAlpha]); return oFT.apply(this,arguments); };
       try{ render2D(0); } finally { proto.fillText=oFT; }
       for(j=0;j<rec.length;j++) if(rec[j][0]===l.txt) return rec[j][1];
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||g.sim) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.labels.length=0;
       label(p.x,p.y-30,N1,'#5fbf6a',0,true,'bandage');
       lb=g.labels[g.labels.length-1];
       if(!lb||lb.txt!==N1) return 'SKIP: staging: the loot label was not pushed';
       a0=alphaOf(lb,0);
       if(a0===null) return 'SKIP: staging: the loot label was not drawn';
       aQ=alphaOf(lb,lb.life*0.3); aH=alphaOf(lb,lb.life/2); aE=alphaOf(lb,lb.life);
       if(!(lb.life<=4.3)) bad.push('a loot name lives '+lb.life+' s, not about four');
       if(!(a0<=0.9)) bad.push('a loot name opens at alpha '+a0+', not about 0.85');
       if(!(aQ<0.8)) bad.push('at 30 percent of its life a loot name is still at alpha '+aQ);
       if(!(aH<0.7)) bad.push('at half life a loot name is at alpha '+aH+' (it was 0.91)');
       if(aE!==0) bad.push('at the end of its life a loot name is at alpha '+aE+', not 0');
       // stacked on one spot: plate on plate, no gap
       g.labels.length=0;
       for(i=0;i<4;i++) label(p.x,p.y-30,'ZQX LOOT '+i,'#5fbf6a',0,false,'bandage');
       ys=g.labels.map(function(l){ return l.y; }).sort(function(a,b){ return b-a; });
       lph=labelPlateH(msgPx(FS(TYPE.micro)));
       sp=ys.length>1?(ys[0]-ys[1]):0;
       if(ys.length<4) bad.push('four loot names made '+ys.length+' labels');
       else if(Math.abs(sp-lph)>0.6) bad.push('stacked loot names are '+sp.toFixed(1)+' units apart, not one plate ('+lph+')');
       // a combat callout is untouched
       g.labels.length=0;
       label(p.x+300,p.y-30,N2,'#ff5a4a',0,true);
       nl=g.labels[g.labels.length-1];
       if(!nl||nl.txt!==N2) bad.push('control: the callout was not pushed');
       else {
         if(nl.life!==1.9) bad.push('a callout lives '+nl.life+' s, not 1.9');
         aN=alphaOf(nl,0);
         if(aN!==1) bad.push('a callout opens at alpha '+aN+', not 1');
         aN=alphaOf(nl,0.95);
         if(aN===null||Math.abs(aN-0.909)>0.02) bad.push('a callout at 0.95 s is at alpha '+aN+', not 0.91');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; }catch(_f){}
       try{ var g2=__state(); if(g2){ g2.labels.length=0; if(!g2.over){ g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
