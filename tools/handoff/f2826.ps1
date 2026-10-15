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

if ($s.Contains("  {v:'28.26',what:")) { throw "check 28.26 is in the fixture already" }

SubRx @'
  {v:'28.25',what:
'@ @'
  {v:'28.26',what:'the default plate carrier is not painted with the old dark chest band: the lit cloth shows at the left edge of the torso on Lean and Broad, with the default vest, and a vest picked still draws',
   run:function(){
     if(typeof drawOp!=='function'||typeof wc==='undefined'||typeof drawVest!=='function') return 'SKIP: no vest in this build';
     var c=document.createElement('canvas'); c.width=240; c.height=300; var x=c.getContext('2d'), w0=wc, bad=[], B=['lean','broad'], i;
     function body(b,vest){
       x.setTransform(1,0,0,1,0,0); x.clearRect(0,0,240,300); x.setTransform(6,0,0,6,120,270); wc=x;
       try{ drawOp(0,0,Math.PI/2,0,'#4a5b7d',0,0,'none',0,{moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,build:b,hair:'dark',cut:'crop',skin:'skinfair',pack:'packbrown',boots:'bootblack',vest:vest}); }
       finally{ wc=w0; }
       return x.getImageData(0,0,240,300).data;
     }
     function lum(d,px,py){ var k=(py*240+px)*4; return d[k+3]<200?-1:(d[k]*0.3+d[k+1]*0.59+d[k+2]*0.11); }
     function box(d,u0,u1,y0,y1){ var s=0,n=0,v,yy,px; for(yy=y0;yy<=y1;yy++) for(px=Math.round(120+6*u0);px<=Math.round(120+6*u1);px++){ v=lum(d,px,yy); if(v>30){ s+=v; n++; } } return n>=6?s/n:-1; }
     function diff(a,b){ var n=0, j; for(j=0;j<a.length;j+=4) if(a[j]!==b[j]||a[j+1]!==b[j+1]||a[j+2]!==b[j+2]) n++; return n; }
     try{
       for(i=0;i<B.length;i++){
         var hw=(B[i]==='broad')?[6.6,8.6]:[4.6,6.4], y0=Math.round(270-6*17.4), y1=Math.round(270-6*((B[i]==='broad')?16.0:15.4)), d=body(B[i],undefined), d2=body(B[i],'vestplate');
         var L2=box(d,-hw[1],-hw[0],y0,y1), R2=box(d,hw[0],hw[1],y0,y1);
         if(L2<0||R2<0) bad.push(B[i]+': the torso edge columns are empty');
         else if(L2-R2<25) bad.push(B[i]+': the left edge ('+Math.round(L2)+') is not clearly lighter than the right ('+Math.round(R2)+'): the old dark band is back');
         if(diff(d,d2)>24) bad.push(B[i]+': naming the default vest changes '+diff(d,d2)+' pixels');
         if(diff(d,body(B[i],'vestband'))<100) bad.push(B[i]+': a bandolier no longer draws');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; }
     return bad.length?bad.join('; '):null; }},
  {v:'28.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
