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

if ($s.Contains("  {v:'20.95',what:")) { throw "check 20.95 is in the fixture already" }

SubRx @'
  {v:'20.94',what:
'@ @'
  {v:'20.95',what:'the sector maps on the lift page are drawn at the screen resolution: with the menus at twice size each map holds twice its page size in pixels, keeps its 420 page width, and is drawn out to its far corner',
   run:function(){
     if(typeof sectorPreviewDraw!=='function'||typeof renderSector!=='function'||typeof menuScale!=='function') return 'SKIP: this build has no sector maps';
     if(!document.getElementById('sectorlist')||typeof FIXED_MAPS==='undefined') return 'SKIP: no sector page in this fixture';
     var bad=[], oMS=menuScale, cvs, i, cv, cw, ch, k, px;
     try{
       __topClear(); __runPrep();
       menuScale=function(){ return 2; };
       renderSector();
       cvs=document.querySelectorAll('#sectorlist canvas.secprev');
       if(!cvs.length) return 'SKIP: staging: no sector maps drawn';
       for(i=0;i<cvs.length;i++){
         cv=cvs[i];
         cw=parseFloat(cv.style.width)||cv.width; ch=parseFloat(cv.style.height)||cv.height;
         if(!(cw>0&&ch>0)) { bad.push('sector '+i+' map has no size'); continue; }
         k=cv.width/cw;
         if(!(k>=1.9)) bad.push('sector '+i+' map is '+cv.width+' pixels across for '+Math.round(cw)+' on the page, so a menu at twice size stretches it '+(2/k).toFixed(1)+' times');
         if(Math.abs(cw-420)>1) bad.push('sector '+i+' map is '+Math.round(cw)+' wide on the page, not 420');
         if(Math.abs(cv.height/ch-k)>0.05) bad.push('sector '+i+' map is stretched more one way than the other');
         px=cv.getContext('2d').getImageData(cv.width-3,cv.height-3,1,1).data;
         if(!(px[3]>0)) bad.push('sector '+i+' map stops short of its far corner');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ menuScale=oMS; try{ renderSector(); }catch(_r){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
