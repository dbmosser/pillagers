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

if ($s.Contains("  {v:'19.17',what:")) { throw "check 19.17 is in the fixture already" }

SubRx @'
  {v:'19.16',what:
'@ @'
  {v:'19.17',what:'the FASHION previews are sharp at 4K: with the menu shown at 4K size the outfit and hat previews are painted at least twice as many pixels across, with the figure in the same place',
   run:function(){
     if(typeof outfitPreviewURL!=='function'||typeof cosPreviewURL!=='function'||typeof menuScale!=='function'||typeof OUTFITS==='undefined') return 'SKIP: no previews here';
     var bad=[], ms0=menuScale, ow0=cosOwned, oid=Object.keys(OUTFITS).filter(function(k){ return k!=='outnone'; })[0], hat=COSMETICS.filter(function(c){ return c&&c.kind==='hat'; })[1], r1, r2, w;
     if(!oid||!hat) return 'SKIP: no outfit or hat to preview';
     function rows(cv){ var w=cv.width, h=cv.height, q=w/128, d=cv.getContext('2d').getImageData(0,0,w,h).data, x, y, t=999, b=-1; for(y=0;y<h;y++) for(x=0;x<w;x++) if(d[(y*w+x)*4+3]>40){ if(y<t) t=y; b=y; break; } return {t:t/q,b:b/q}; }
     function pngW(u){ try{ var s=atob(String(u).split(',')[1]||''); return ((s.charCodeAt(16)<<24)|(s.charCodeAt(17)<<16)|(s.charCodeAt(18)<<8)|s.charCodeAt(19))>>>0; }catch(_p){ return 0; } }
     function clear(){ var k; for(k in OUTPREV) delete OUTPREV[k]; for(k in COSPREV) delete COSPREV[k]; }
     try{
       cosOwned=function(c){ return true; };
       menuScale=function(){ return 1; }; clear(); outfitPreviewURL(oid); r1=OUTPREV._cv?rows(OUTPREV._cv):null;
       menuScale=function(){ return 4; }; clear(); outfitPreviewURL(oid); w=OUTPREV._cv?OUTPREV._cv.width:0; r2=OUTPREV._cv?rows(OUTPREV._cv):null;
       if(w<256) bad.push('at 4K menu size the outfit preview is painted only '+w+' pixels across');
       if(r1&&r2&&(Math.abs(r1.t-r2.t)>3||Math.abs(r1.b-r2.b)>3)) bad.push('the sharper outfit figure moved: rows '+Math.round(r1.t)+'-'+Math.round(r1.b)+' became '+Math.round(r2.t)+'-'+Math.round(r2.b));
       clear(); w=pngW(cosPreviewURL('hat',hat.id));
       if(w<256) bad.push('at 4K menu size the hat preview is painted only '+w+' pixels across');
       menuScale=function(){ return 1; }; clear(); w=pngW(cosPreviewURL('hat',hat.id));
       if(w!==128) bad.push('control: at 1080p menu size the hat preview should stay 128 pixels, it is '+w);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ menuScale=ms0; cosOwned=ow0; clear(); if(typeof PREVLOOK!=='undefined') PREVLOOK=null; }
     return bad.length?bad.join('; '):null; }},
  {v:'19.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
