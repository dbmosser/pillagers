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

if ($s.Contains("  {v:'28.85',what:")) { throw "check 28.85 is in the fixture already" }

SubRx @'
  {v:'28.84',what:
'@ @'
  {v:'28.85',what:'the operator ground shadow is cast to the lower right (light top-left): the shadow pixels under the feet lean right and reach past the old 10 px edge',
   run:function(){
     if(typeof drawOp!=='function'||typeof shadowE!=='function') return 'SKIP: no drawOp';
     var bad=[], kw=wc, ks=shadowE;
     function paint(noShadow){
       var cv2=document.createElement('canvas'), x2;
       cv2.width=240; cv2.height=240; x2=cv2.getContext('2d');
       if(noShadow) shadowE=function(){};
       wc=x2;
       try{ x2.translate(120,100); x2.scale(3,3); drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,own:{wep:null}}); }
       finally { wc=kw; shadowE=ks; }
       return x2.getImageData(0,0,240,240).data;
     }
     try{
       var a=paint(false), b=paint(true), px, py, i, w, sw=0, sx=0, mx=-999, mn=999, n=0, wx;
       for(py=109;py<240;py++) for(px=0;px<240;px++){
         i=(py*240+px)*4; w=Math.abs(a[i+3]-b[i+3]);
         if(w>6){ wx=(px+0.5-120)/3; sw+=w; sx+=w*wx; n++; if(wx>mx) mx=wx; if(wx<mn) mn=wx; }
       }
       if(n<200) bad.push('the ground shadow shows only '+n+' pixels under the feet');
       else{
         if(sx/sw<1.0) bad.push('the shadow centre is '+(sx/sw).toFixed(2)+' px from the feet, not cast right (want 1.0 or more)');
         if(mx<11.8) bad.push('the shadow reaches only '+mx.toFixed(1)+' px right (want 11.8 or more)');
         if(mn<-10.6) bad.push('the shadow reaches '+mn.toFixed(1)+' px left (want no further than -10.6)');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=kw; shadowE=ks; }
     return bad.length?bad.join('; '):null; }},
  {v:'28.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
