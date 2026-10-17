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

if ($s.Contains("  {v:'28.82',what:")) { throw "check 28.82 is in the fixture already" }

SubRx @'
  {v:'28.81',what:
'@ @'
  {v:'28.82',what:'the held gun casts a soft shadow: painting the gun with its shadow strip held back changes pixels under the gun (the drawing, not a stand-in)',
   run:function(){
     if(typeof gunHeld!=='function') return 'SKIP: no gunHeld';
     var bad=[], skipped=0;
     function paint(skip){
       var cv2=document.createElement('canvas'), x2, kw=wc, fr, d;
       cv2.width=240; cv2.height=240; x2=cv2.getContext('2d'); fr=x2.fillRect;
       x2.fillRect=function(a,b,c,e){ if(skip&&/^rgba\(0,\s*0,\s*0,/.test(String(x2.fillStyle))){ skipped++; return; } return fr.call(x2,a,b,c,e); };
       wc=x2;
       try{ x2.translate(20,50); x2.scale(3,3); gunHeld(0,20,0,1,{hero:0},'#555a66',null,false,false,false,0,0); } finally { wc=kw; }
       return x2.getImageData(0,0,240,240).data;
     }
     try{
       var a=paint(false), b=paint(true), i, diff=0, n=0;
       for(i=3;i<a.length;i+=4){ if(a[i]!==b[i]){ diff+=Math.abs(a[i]-b[i]); n++; } }
       if(skipped<1) bad.push('the gun paints no black translucent shadow fill');
       if(n<150) bad.push('the gun shadow touches only '+n+' pixels (want 150 or more)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'28.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
