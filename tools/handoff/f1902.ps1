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

if ($s.Contains("  {v:'19.02',what:")) { throw "check 19.02 is in the fixture already" }

SubRx @'
  {v:'19.01',what:
'@ @'
  {v:'19.02',what:'the sector map labels never print over each other: with the map open on a busy sector, no two drawn labels overlap',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, oFT=ctx.fillText, R=[], i, j, a, b, n=0, oMO=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=true;
       oMO=drawMapOverlay; var rec=false; drawMapOverlay=function(){ rec=true; try{ return oMO.apply(this,arguments); } finally { rec=false; } };
       ctx.fillText=function(s,x,y){
         if(!rec) return oFT.apply(this,arguments);
         var t=String(s), m=ctx.getTransform(), fm=(/([\d.]+)px/).exec(String(ctx.font)), fp=fm?parseFloat(fm[1]):12, w=CanvasRenderingContext2D.prototype.measureText.call(ctx,t).width, ta=ctx.textAlign, tb=ctx.textBaseline, l, tp;
         l=(ta==='center')?x-w/2:((ta==='right'||ta==='end')?x-w:x); tp=(tb==='middle')?y-fp*0.46:((tb==='top'||tb==='hanging')?y:y-fp*0.72);
         if(ctx.globalAlpha>0.05&&t.trim()) R.push({s:t,l:l*m.a+m.e,t:tp*m.d+m.f,r:(l+w)*m.a+m.e,b:(tp+fp*0.92)*m.d+m.f});
         return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; drawMapOverlay=oMO; }
       var mapR=R.filter(function(q){ return q.s==='SECTOR MAP'; })[0];
       if(!mapR) return 'SKIP: the sector map was not drawn';
       R=R.filter(function(q){ return q.t>mapR.b; });
       for(i=0;i<R.length;i++) for(j=i+1;j<R.length;j++){ a=R[i]; b=R[j]; if(j===i+1&&Math.abs((a.l+a.r)-(b.l+b.r))<2) continue; if(a.l<b.r-1&&b.l<a.r-1&&a.t<b.b-1&&b.t<a.b-1){ n++; if(n<=3) bad.push(a.s+' prints over '+b.s); } }
       if(n>3) bad.push('and '+(n-3)+' more overlaps');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ if(oMO) drawMapOverlay=oMO; }catch(_o){} try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
