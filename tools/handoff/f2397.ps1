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

if ($s.Contains("  {v:'23.97',what:")) { throw "check 23.97 is in the fixture already" }

SubRx @'
  {v:'23.96',what:
'@ @'
  {v:'23.97',what:'graphics program gfx38: trauma shake moves the world only: with G.shake raised to 9 the ground is drawn offset from the steady camera on 12 drawn frames while w2s of the player does not move at all, no frame jumps more than 40 percent of the amplitude from the last, a second hit raises the trauma, and EFFECT INTENSITY OFF draws no offset',
   run:function(){
     if(!(window.__gfxStage&&window.__state&&window.__endRaid)||typeof render2D!=='function'||typeof w2s!=='function'||typeof ZOOM!=='function') return 'SKIP: this fixture cannot draw a raid frame';
     var bad=[], g=null, p=null, OWN=Object.prototype.hasOwnProperty, sv=[], rec=[], fi0=CFG.fxInt, i, f, prev=null, s0=null, big=0, tr1, tr2, nz=0, mx0, my0;
     function spy(){
       var c=wc, own=OWN.call(c,'drawImage'), of=c.drawImage; sv.push({c:c,own:own,f:of});
       c.drawImage=function(img){ if(img===G.ground&&!rec.length){ var T=this.getTransform(); rec.push({x:-T.e/T.a,y:-T.f/T.d}); } return of.apply(this,arguments); };
     }
     function unspy(){ while(sv.length){ var s=sv.pop(); try{ if(s.own) s.c.drawImage=s.f; else delete s.c.drawImage; }catch(_u){} } }
     function frame(){
       var q, z; rec=[]; spy(); try{ render2D(1/60); } finally { unspy(); }
       q=w2s(p.x,0,p.y); z=ZOOM();
       return {s:{x:q.x,y:q.y}, o:rec.length?{x:(rec[0].x-VX)*z,y:(rec[0].y-VY)*z}:null, a:(typeof GFX!=='undefined'&&+GFX.shA)||0};
     }
     try{
       g=__gfxStage({frames:2});
       if(!g) return 'SKIP: __gfxStage built no raid';
       p=g.player; keys={}; g.bagOpen=false; g.mapOpen=false; p.iv=99;
       mx0=mouse.x; my0=mouse.y; mouse.x=W/2; mouse.y=H/2;
       CFG.fxInt=1; G.shake=0;
       for(i=0;i<90;i++) frame();
       f=frame(); if(!f.o) return 'SKIP: staging: the ground was not drawn';
       if(Math.abs(f.o.x)>0.01||Math.abs(f.o.y)>0.01) bad.push('with no shake the ground is drawn '+f.o.x.toFixed(2)+','+f.o.y.toFixed(2)+' px off the camera');
       s0=f.s;
       G.shake=9;
       for(i=0;i<12;i++){
         f=frame();
         if(!f.o){ bad.push('frame '+i+' drew no ground'); break; }
         if(Math.abs(f.s.x-s0.x)>0.01||Math.abs(f.s.y-s0.y)>0.01) bad.push('frame '+i+': w2s of the player moved from '+s0.x.toFixed(1)+','+s0.y.toFixed(1)+' to '+f.s.x.toFixed(1)+','+f.s.y.toFixed(1));
         big=Math.max(big,Math.abs(f.o.x),Math.abs(f.o.y));
         if(Math.abs(f.o.x)>=0.5||Math.abs(f.o.y)>=0.5) nz++;
         if(prev&&prev.o){
           var lim=0.4*Math.max(prev.a,f.a)+1.01, dx=Math.abs(f.o.x-prev.o.x), dy=Math.abs(f.o.y-prev.o.y);
           if(dx>lim||dy>lim) bad.push('frame '+i+' jumped '+dx.toFixed(1)+','+dy.toFixed(1)+' px against an amplitude of '+Math.max(prev.a,f.a).toFixed(1));
         }
         prev=f;
       }
       if(big<1) bad.push('under G.shake 9 the ground was never drawn a whole pixel off the camera (largest '+big.toFixed(2)+')');
       if(nz<3) bad.push('only '+nz+' of 12 shaken frames moved the ground');
       if(bad.length>6) bad.length=6;
       tr1=+GFX.tr||0;
       G.shake=3; frame(); G.shake=9; frame(); tr2=+GFX.tr||0;
       if(!(tr2>tr1)) bad.push('a second hit did not raise the trauma ('+tr1.toFixed(3)+' then '+tr2.toFixed(3)+')');
       CFG.fxInt=0; G.shake=0; frame(); G.shake=12; big=0;
       for(i=0;i<6;i++){ f=frame(); if(f.o) big=Math.max(big,Math.abs(f.o.x),Math.abs(f.o.y)); }
       if(big>0) bad.push('with EFFECT INTENSITY OFF the ground was still drawn '+big.toFixed(1)+' px off the camera');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); keys={}; CFG.fxInt=fi0;
       try{ if(mx0!==undefined){ mouse.x=mx0; mouse.y=my0; } }catch(_m){}
       try{ var g2=__state(); if(g2){ G.shake=0; if(typeof GFX!=='undefined'){ GFX.tr=0; GFX.shL=0; } if(!g2.over){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
