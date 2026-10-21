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

if ($s.Contains("  {v:'33.74',what:")) { throw "check 33.74 is in the fixture already" }

SubRx @'
  {v:'33.73',what:
'@ @'
  {v:'33.74',what:'cw-cx-pixheight: all 27 plain looks and both baked facings match the 79a standing measure within two world pixels, through both breath frames, and their soles stay on the entity anchor',
   run:function(){
     var oldPix=CFG.xfPix, bad=[], measured79a=58, camera79a=1.05, target=Math.round(measured79a/camera79a), h,k,c,mir,bob,s,lg,up,dd,x,y,top,bot,height,foot;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); CFG.xfPix=1;
       // Independent reference from the 79a notes, adjusted for the later camera 1.05 -> 1.0 change, not PXB.TARGET.
       for(h=0;h<3;h++) for(k=0;k<3;k++) for(c=0;c<3;c++) for(mir=0;mir<2;mir++){
         lg=pxBuildLegs({clothes:PXB_CLOTHS[c],bot:0,mir:mir,kind:'s',fr:0});
         up=pxBuildUpper({head:PXB_HEADS[h],skin:PXB_SKINS[k],clothes:PXB_CLOTHS[c],bot:0,mir:mir,pup:0,arms:1,lamp:'',band:''});
         for(bob=0;bob<=1;bob++){
           s=pixCanvas(PXB.W+2,PXB.H+10); s.x.drawImage(lg.c,0,4); s.x.drawImage(up.c,0,4-bob); foot=4+lg.ay;
           dd=s.x.getImageData(0,0,s.w,s.h).data; top=s.h; bot=-1;
           for(y=0;y<s.h;y++) for(x=0;x<s.w;x++) if(dd[(y*s.w+x)*4+3]){ if(y<top) top=y; if(y>bot) bot=y; }
           height=bot-top+1;
           if(Math.abs(height-target)>2) bad.push(PXB_HEADS[h]+'/'+PXB_CLOTHS[c]+' height '+height+', wanted '+target+' +/-2');
           if(bot!==foot) bad.push('the sole missed the entity point by '+(bot-foot));
         }
       }
       return bad.length?bad.slice(0,8).join('; '):null;
     } finally {
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile(); CFG.xfPix=oldPix;
     } }},
  {v:'33.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
