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

if ($s.Contains("  {v:'31.85',what:")) { throw "check 31.85 is in the fixture already" }

SubRx @'
  {v:'31.84',what:
'@ @'
  {v:'31.85',what:'the boot camera defaults to 1.3, preserves saved zoom, and keeps 1080p/4K projection and pointer agreement (his a36 C)',
   run:function(){
     if(typeof loadZoom!=='function') return 'the boot camera still has no 1.3 default loader';
     if(typeof __setZoom!=='function') return 'missing camera fixture hook';
     var bad=[], had=Object.prototype.hasOwnProperty.call(P,'zoom'), saved=P.zoom,
         oldZT=ZT, oldZC=ZC, oldSaveT=zoomSaveT, oldG=G,
         oldW=W, oldH=H, oldVX=VX, oldVY=VY, mx=mouse.x, my=mouse.y;
     function near(a,b,label){ if(!isFinite(a)||Math.abs(a-b)>0.001) bad.push(label+': '+a+' expected '+b); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       delete P.zoom; loadZoom();
       near(ZT,1.3,'fresh target'); near(ZC,1.3,'fresh eased camera');
       if(Object.prototype.hasOwnProperty.call(P,'zoom')) bad.push('loading the default wrote over the profile');
       [0.85,1,2.15,9].forEach(function(z){
         P.zoom=z; loadZoom();
         near(ZT,z,'saved target'); near(ZC,z,'saved eased camera'); near(P.zoom,z,'saved preference');
       });
       // v28.xx (cw-cx-camera130): exercise the real projection without building or rasterizing a raid in this default-setting check.
       G={sim:true,player:{x:2600,y:2000}};
       [[1920,1080],[3840,2160]].forEach(function(size){
         W=size[0]; H=size[1];
         delete P.zoom; loadZoom();
         var z=ZOOM(), res=hudRes();
         near(z,1.3*res,'default world scale '+W);
         near(W/z,1920/1.3,'world width '+W); near(H/z,1080/1.3,'world height '+W);
         VX=G.camX=G.player.x-W/(2*z); VY=G.camY=G.player.y-H*0.54/z;
         var s=w2s(G.player.x,0,G.player.y);
         near(s.x,W/2,'pillager x '+W); near(s.y,H*0.54,'pillager y '+W);
         mouse.x=W*0.62; mouse.y=H*0.38;
         var mw=mouseWorld(), back=w2s(mw.x,0,mw.y);
         near(back.x,mouse.x,'pointer x '+W); near(back.y,mouse.y,'pointer y '+W);
         near(__setZoom(1.3),z,'survey spec zoom '+W);
       });
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'camera default check: '+String(err&&err.message||err);
     } finally {
       G=oldG; W=oldW; H=oldH; VX=oldVX; VY=oldVY;
       if(had) P.zoom=saved; else delete P.zoom;
       ZT=oldZT; ZC=oldZC; zoomSaveT=oldSaveT;
       mouse.x=mx; mouse.y=my;
       __topClear();
     }
   }},
  {v:'31.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
