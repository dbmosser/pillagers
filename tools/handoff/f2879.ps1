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

if ($s.Contains("  {v:'28.79',what:")) { throw "check 28.79 is in the fixture already" }

SubRx @'
  {v:'28.78',what:
'@ @'
  {v:'28.79',what:'the Heavy Helmet has no tall neon bar: on Toxic its scheme accent is a small lens, no taller than 4.5 px in any column, and the lens is still there',
   run:function(){
     if(typeof drawOp!=='function'||typeof cosFind!=='function') return 'SKIP: no drawOp';
     var keepOut=P.cosOutfit, bad=[];
     function paint(st){
       var cv2=document.createElement('canvas'), x2, kw=wc;
       cv2.width=240; cv2.height=240; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(120,200); x2.scale(3,3); drawOp(0,0,0,0,'#242832',0,0,'none',0,st); } finally { wc=kw; }
       return x2.getImageData(0,0,240,240).data;
     }
     function acc(d,hex,tol){
       var r0=parseInt(hex.slice(1,3),16), g0=parseInt(hex.slice(3,5),16), b0=parseInt(hex.slice(5,7),16), run=[], best=0, n=0, x, y, j, cur;
       for(x=0;x<240;x++){ cur=0; for(y=0;y<132;y++){ j=(y*240+x)*4;
         if(d[j+3]>200&&Math.abs(d[j]-r0)<=tol&&Math.abs(d[j+1]-g0)<=tol&&Math.abs(d[j+2]-b0)<=tol){ n++; cur++; if(cur>best) best=cur; } else cur=0; } }
       return {n:n,tall:best/3};
     }
     try{
       P.cosOutfit='outnone';
       var st={hero:0,build:'lean',pack:'packbrown',boots:'bootblack',hair:'dark',cut:'crop',skin:'fair',fit:'slate',eyes:'eyebrown',hat:'heavyhelm',scheme:'schtoxic'};
       var a=acc(paint(st),'#8dff2e',24);
       if(a.tall>4.5) bad.push('the Heavy Helmet shows an accent bar '+a.tall.toFixed(1)+' px tall');
       if(a.n<20) bad.push('the Heavy Helmet shows only '+a.n+' accent pixels, the lens is gone');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(keepOut===undefined) delete P.cosOutfit; else P.cosOutfit=keepOut; }
     return bad.length?bad.join('; '):null; }},
  {v:'28.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
