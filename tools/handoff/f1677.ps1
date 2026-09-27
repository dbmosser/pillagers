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

if ($s.Contains("  {v:'16.77',what:")) { throw "check 16.77 is in the fixture already" }

SubRx @'
  {v:'16.76',what:
'@ @'
  {v:'16.77',what:'with a controller the crosshair is always on screen: with the sticks idle it stays a reach out from the player and follows the aim distance, aiming past the edge of the map keeps it on the canvas along the same aim, and a sweep leaves a short fading trail the frame draws',
   run:function(){
     if(typeof pollPad!=='function'||typeof drawHUD!=='function'||typeof ZOOM!=='function'||typeof PAD==='undefined'||!window.__deploy||!window.__endRaid||!window.__frame||!window.__runPrep) return 'SKIP: this build has no controller raid path';
     if(typeof NET!=='undefined'&&NET&&NET.same) return 'SKIP: a same machine party is on, and its controller comes from the hand-over';
     if(!(W>=700&&H>=500)) return 'SKIP: the pane is too small to aim a reach out and off the edge';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, ax=[0,0,0,0], oMove=null, reach0=PAD.reach, own0=PAD.curOwn, ang0=PAD.aimA, trail0=PAD.trail, mx0=mouse.x, my0=mouse.y, zc0=ZC, zt0=ZT;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function pad(){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:false,value:0,touched:false}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:ax.slice()}]; }
     function stick(rx,ry){ ax=[0,0,rx,ry]; pollPad(); }
     function psx(){ var p=G.player,z=ZOOM(); return (p.x-(G.camX===undefined?p.x-W/(2*z):G.camX))*z; }
     function psy(){ var p=G.player,z=ZOOM(); return (p.y-(G.camY===undefined?p.y-H/z*0.54:G.camY))*z; }
     function park(x,y){ G.player.x=x; G.player.y=y; G.anchX=x; G.anchY=y; G.leanSX=0; G.leanSY=0; __frame(0.016); __frame(0.016); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       navigator.getGamepads=pad;
       ZT=ZC=1; PAD.trail=[]; PAD.reach=200; G.mapOpen=false; G.bagOpen=false;
       park(WORLD_W/2,WORLD_H/2);
       var z=ZOOM();
       stick(1,0);
       var dx1=mouse.x-psx();
       if(Math.abs(dx1-200*z)>2) bad.push('control: the right stick did not place the crosshair a reach out ('+dx1.toFixed(1)+' for '+(200*z).toFixed(1)+')');
       stick(0,0); stick(0,0);
       var dx2=mouse.x-psx();
       if(Math.abs(dx2-200*z)>2) bad.push('with the sticks idle the crosshair left its aim point ('+dx2.toFixed(1)+')');
       PAD.reach=100; stick(0,0);
       var dx3=mouse.x-psx();
       if(Math.abs(dx3-100*z)>2) bad.push('the aim distance changed with the sticks idle and the crosshair did not follow ('+dx3.toFixed(1)+' for '+(100*z).toFixed(1)+')');
       PAD.reach=200; stick(1,0); stick(0.7,0.7); stick(0,1); stick(-0.7,0.7);
       var T=PAD.trail;
       if(!T||T.length<3) bad.push('a sweep left no trail ('+(T?T.length:'none')+')');
       else {
         var old=T[0], hits=0, near=40*hudRes();
         oMove=ctx.moveTo;
         ctx.moveTo=function(x,y){ if(Math.abs(x-old.x)<0.5&&Math.abs(y-old.y)<near) hits++; return oMove.apply(ctx,arguments); };
         __frame(0.016);
         if(!hits) bad.push('the frame drew nothing at the oldest place of the trail');
       }
       park(WORLD_W/2,WORLD_H-60);
       stick(0,1);
       if(!(mouse.y>=0&&mouse.y<=H&&mouse.x>=0&&mouse.x<=W)) bad.push('aiming at the bottom edge of the map put the crosshair off the canvas (y '+mouse.y.toFixed(0)+' of '+H+')');
       else if(!(mouse.y>psy())) bad.push('drawn in to the edge, the crosshair no longer points down the aim (y '+mouse.y.toFixed(0)+' against the player at '+psy().toFixed(0)+')');
       stick(0,0);
       if(!(mouse.y>=0&&mouse.y<=H)) bad.push('with the sticks idle at the edge the crosshair went off the canvas again (y '+mouse.y.toFixed(0)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(oMove){ delete ctx.moveTo; if(ctx.moveTo!==oMove) ctx.moveTo=oMove; } }catch(_a){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ ZC=zc0; ZT=zt0; PAD.reach=reach0; PAD.curOwn=own0; PAD.aimA=ang0; PAD.trail=trail0; mouse.x=mx0; mouse.y=my0; }catch(_k){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
