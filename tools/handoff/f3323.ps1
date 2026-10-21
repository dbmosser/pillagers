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

if ($s.Contains("  {v:'33.23',what:")) { throw "check 33.23 is in the fixture already" }

SubRx @'
  {v:'33.22',what:
'@ @'
  {v:'33.23',what:'a fresh profile boots at the 1.05 default camera (his picture), in career and in the demo, for both windows, and a saved zoom stays his',
   run:function(){
     if(typeof loadZoom!=='function'||typeof ZDEFAULT==='undefined') return 'the boot camera has no default loader';
     var bad=[], had=Object.prototype.hasOwnProperty.call(P,'zoom'), saved=P.zoom,
         oldZT=ZT, oldZC=ZC, oldSaveT=zoomSaveT, oldG=G,
         oldW=W, oldH=H, oldVX=VX, oldVY=VY, mx=mouse.x, my=mouse.y;
     function near(a,b,label){ if(!isFinite(a)||Math.abs(a-b)>0.001) bad.push(label+': '+a+' expected '+b); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       near(ZDEFAULT,1.05,'the default dial');
       // both modes and both windows load the same shared default: a fresh profile has no zoom field
       ['career','demo'].forEach(function(mode){
         [1,2].forEach(function(win){
           delete P.zoom; ZT=ZC=7; loadZoom();
           near(ZT,1.05,mode+' window '+win+' target'); near(ZC,1.05,mode+' window '+win+' eased camera');
         });
       });
       if(Object.prototype.hasOwnProperty.call(P,'zoom')) bad.push('loading the default wrote over the profile');
       [0.85,1.3,2.15].forEach(function(z){
         P.zoom=z; loadZoom();
         near(ZT,z,'saved target'); near(ZC,z,'saved eased camera');
       });
       G={sim:true,player:{x:2600,y:2000}};
       [[1920,1080],[3840,2160]].forEach(function(size){
         W=size[0]; H=size[1];
         delete P.zoom; loadZoom();
         var z=ZOOM(), res=hudRes();
         near(z,1.05*res,'default world scale '+W);
         near(W/z,1920/1.05,'world width '+W); near(H/z,1080/1.05,'world height '+W);
         VX=G.camX=G.player.x-W/(2*z); VY=G.camY=G.player.y-H*0.54/z;
         var s=w2s(G.player.x,0,G.player.y);
         near(s.x,W/2,'pillager x '+W); near(s.y,H*0.54,'pillager y '+W);
         mouse.x=W*0.62; mouse.y=H*0.38;
         var mw=mouseWorld(), back=w2s(mw.x,0,mw.y);
         near(back.x,mouse.x,'pointer x '+W); near(back.y,mouse.y,'pointer y '+W);
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
  {v:'33.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
