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

if ($s.Contains("  {v:'24.31',what:")) { throw "check 24.31 is in the fixture already" }

SubRx @'
  {v:'24.30',what:
'@ @'
  {v:'24.31',what:'spr18: armour in dark steel, and a helmet shell on armour 3',
   run:function(){
     if(typeof drawOp!=='function'||typeof wc==='undefined') return 'SKIP: no drawOp here';
     var c=document.createElement('canvas'); c.width=240; c.height=300; var x=c.getContext('2d'), w0=wc, bad=[];
     function body(bk){
       x.setTransform(1,0,0,1,0,0); x.clearRect(0,0,240,300); x.setTransform(6,0,0,6,120,280); wc=x;
       try{ drawOp(0,0,Math.PI/2,0,'#4a5b7d',0,0,'none',0,{moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:bk,build:'lean',hair:'dark',cut:'crop',skin:'skinfair',pack:'packbrown',boots:'bootblack'}); }
       finally{ wc=w0; }
       return x.getImageData(0,0,240,300).data;
     }
     function lumBox(d,u0,u1,v0,v1){ var s=0,n=0,px,py,k; for(py=Math.round(280-6*v1);py<=Math.round(280-6*v0);py++) for(px=Math.round(120+6*u0);px<=Math.round(120+6*u1);px++){ k=(py*240+px)*4; if(d[k+3]<200) continue; s+=d[k]*0.3+d[k+1]*0.59+d[k+2]*0.11; n++; } return n?s/n:-1; }
     try{
       var d1=body(1), d3=body(3), d0=body(0);
       var p1=(lumBox(d1,-5,-2.4,15,18)+lumBox(d1,2.4,5,15,18))/2;
       if(p1<0||p1>112) bad.push('the armour 1 plate reads '+Math.round(p1)+' bright (want dark steel, under 112; the old ice blue was about 130)');
       // armour 3 has a helmet over the crown: the rows above the brow differ from the same body with no armour
       var diff=0, px, py, k;
       for(py=Math.round(280-6*39.5);py<=Math.round(280-6*35);py++) for(px=60;px<180;px++){ k=(py*240+px)*4;
         if(Math.abs(d3[k]-d0[k])+Math.abs(d3[k+1]-d0[k+1])+Math.abs(d3[k+2]-d0[k+2])>40) diff++; }
       if(diff<400) bad.push('armour 3 shows no helmet over the crown ('+diff+' changed pixels above the brow)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; }
     return bad.length?bad.join('; '):null; }},
  {v:'24.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
