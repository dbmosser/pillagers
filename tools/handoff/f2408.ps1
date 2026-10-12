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

if ($s.Contains("  {v:'24.08',what:")) { throw "check 24.08 is in the fixture already" }

SubRx @'
  {v:'24.07',what:
'@ @'
  {v:'24.08',what:'spr15: a plate carrier, not stripes: olive pouches on every build and the cloth lit from the left',
   run:function(){
     if(typeof drawOp!=='function'||typeof wc==='undefined') return 'SKIP: no drawOp here';
     var c=document.createElement('canvas'); c.width=240; c.height=300; var x=c.getContext('2d'), w0=wc, bad=[], B=['lean','broad','curved'], i;
     function body(b){
       x.setTransform(1,0,0,1,0,0); x.clearRect(0,0,240,300); x.setTransform(6,0,0,6,120,270); wc=x;
       try{ drawOp(0,0,Math.PI/2,0,'#4a5b7d',0,0,'none',0,{moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,build:b,hair:'dark',cut:'crop',skin:'skinfair',pack:'packbrown',boots:'bootblack'}); }
       finally{ wc=w0; }
       return x.getImageData(0,0,240,300).data;
     }
     function lum(d,px,py){ var k=(py*240+px)*4; return d[k+3]<200?-1:(d[k]*0.3+d[k+1]*0.59+d[k+2]*0.11); }
     function box(d,u0,u1,y0,y1){ var s=0,n=0,v,yy,px; for(yy=y0;yy<=y1;yy++) for(px=Math.round(120+6*u0);px<=Math.round(120+6*u1);px++){ v=lum(d,px,yy); if(v>30){ s+=v; n++; } } return n>=6?s/n:-1; }   // cloth only: ink and the old dark band are left out
     try{
       for(i=0;i<B.length;i++){
         var d=body(B[i]), ol=0, k, r, g, bl;
         for(k=0;k<d.length;k+=4){ if(d[k+3]<200) continue; r=d[k]; g=d[k+1]; bl=d[k+2];
           if(Math.abs(r-g)<7&&r-bl>16&&r>=50&&r<=120) ol++; }
         if(ol<150) bad.push(B[i]+': '+ol+' olive pouch pixels (want 150+)');
         // the torso edges, below the shoulder caps and above the belt: the left column lit, the right in shade (Curved wears her plate there)
         if(B[i]==='curved') continue;
         var hw=(B[i]==='broad')?[6.6,8.6]:[4.6,6.4], y0=Math.round(270-6*17.4), y1=Math.round(270-6*((B[i]==='broad')?16.0:15.4));
         var L2=box(d,-hw[1],-hw[0],y0,y1), R2=box(d,hw[0],hw[1],y0,y1);
         if(L2<0||R2<0) bad.push(B[i]+': the torso edge columns are empty');
         else if(L2-R2<25) bad.push(B[i]+': the left edge ('+Math.round(L2)+') is not clearly lighter than the right ('+Math.round(R2)+')');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; }
     return bad.length?bad.join('; '):null; }},
  {v:'24.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
