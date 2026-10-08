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

if ($s.Contains("  {v:'20.11',what:")) { throw "check 20.11 is in the fixture already" }

SubRx @'
  {v:'20.10',what:
'@ @'
  {v:'20.11',what:'armour fits a Curved body: the chest plate on a Curved body stays inside her waist, and is still there in the middle',
   run:function(){
     if(typeof drawOp!=='function'||typeof COSKEY==='undefined') return 'SKIP: no painter here';
     var k=COSKEY.build||'cosBuild', b0=P[k], w0=wc, cv=document.createElement('canvas'), x2, bad=[], out, mid;
     cv.width=240; cv.height=220; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function at(lx,ly){ var d=x2.getImageData(Math.round(120+lx*4),Math.round(190+ly*4),1,1).data; return d; }
     try{
       P[k]='curved';
       x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,240,220); x2.setTransform(4,0,0,4,120,190); wc=x2;
       drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,bulk:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); wc=w0; x2.setTransform(1,0,0,1,0,0);
       out=at(7.2,-14.9); mid=at(0,-12.4);
       if(out[3]>40) bad.push('the plate shows outside the Curved waist');
       if(!(mid[3]>200&&mid[2]>mid[0])) bad.push('no steel plate in the middle ('+mid[0]+','+mid[1]+','+mid[2]+')');
     }catch(e){ wc=w0; bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; P[k]=b0; }
     return bad.length?bad.join('; '):null; }},
  {v:'20.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
