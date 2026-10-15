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

if ($s.Contains("  {v:'28.54',what:")) { throw "check 28.54 is in the fixture already" }

SubRx @'
  {v:'28.53',what:
'@ @'
  {v:'28.54',what:'cloud-feel-howler-circle: the Howler landing circle is drawn round, as wide as it is tall, and its full outline is the blast reach',
   run:function(){
     if(!(window.__state&&window.__deploy&&window.__endRaid&&window.__runPrep&&window.__canvases)) return 'SKIP: no raid here';
     if(typeof render2D!=='function'||typeof w2s!=='function'||typeof ZOOM!=='function') return 'SKIP: no world renderer here';
     var bad=[], g=null, p=null, i, CP=CanvasRenderingContext2D.prototype, oEl=CP.ellipse, got=[], kM={x:mouse.x,y:mouse.y,down:mouse.down};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.shells) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; keys={}; mouse.x=W/2; mouse.y=H*0.54; mouse.down=false;
       var sp=null, gx, gy;
       for(gx=600;gx<WORLD_W-600&&!sp;gx+=80) for(gy=600;gy<WORLD_H-600&&!sp;gy+=80){
         if(spotFree(g.map,gx,gy,60)&&spotFree(g.map,gx+120,gy,110)&&!roofAt(gx,gy)&&!roofAt(gx+120,gy)) sp={x:gx,y:gy}; }
       if(!sp) return 'SKIP: no open ground to stage a shell';
       p.x=sp.x; p.y=sp.y; g.anchX=undefined;
       for(i=0;i<20;i++){ g.t+=0.016; __sim(0.016); }
       var ax=p.x+120, ay=p.y, R=(CFG.howlerR===undefined?90:CFG.howlerR);
       var S={mortar:1,x0:ax-400,y0:ay,by:null,tx:ax,ty:ay,t:1.05,air:2.1,dmg:35};
       render2D(0.016);
       var cv=__canvases().world, k=cv.width/W, Z=ZOOM(), c0=w2s(ax,0,ay);
       g.shells.length=0; g.shells.push(S);
       CP.ellipse=function(x,y,rx,ry){
         try{ if(this.canvas===cv){ var m=this.getTransform();
           got.push({sx:(m.a*x+m.c*y+m.e)/k, sy:(m.b*x+m.d*y+m.f)/k,
             rx:rx*Math.sqrt(m.a*m.a+m.b*m.b)/k, ry:ry*Math.sqrt(m.c*m.c+m.d*m.d)/k}); } }catch(_c){}
         return oEl.apply(this,arguments); };
       try{ render2D(0.016); } finally { CP.ellipse=oEl; }
       g.shells.length=0;
       var at=got.filter(function(e){ return Math.abs(e.sx-c0.x)<2&&Math.abs(e.sy-c0.y)<2&&e.rx>10*Z; });
       if(at.length<3) return 'SKIP: the landing circle was not drawn ('+at.length+' ellipses at the aim point)';
       var big=0;
       at.forEach(function(e){ big=Math.max(big,e.rx,e.ry);
         if(Math.abs(e.ry-e.rx)>0.5) bad.push('a landing circle ellipse is '+e.rx.toFixed(1)+' wide but '+e.ry.toFixed(1)+' tall'); });
       if(Math.abs(big-R*Z)>1) bad.push('the full landing circle is '+big.toFixed(1)+' across the radius, the blast reaches '+(R*Z).toFixed(1));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       CP.ellipse=oEl; keys={}; mouse.x=kM.x; mouse.y=kM.y; mouse.down=kM.down;
       try{ var g2=__state(); if(g2&&g2.shells) g2.shells.length=0; if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'28.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
