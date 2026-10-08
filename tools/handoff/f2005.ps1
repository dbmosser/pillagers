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

if ($s.Contains("  {v:'20.05',what:")) { throw "check 20.05 is in the fixture already" }

SubRx @'
  {v:'20.04',what:
'@ @'
  {v:'20.05',what:'outfits fit a Curved body: the Baller jersey panels stay inside a Curved waist, and the Trooper helmet shows no rose mouth',
   run:function(){
     if(typeof drawOp!=='function'||typeof COSKEY==='undefined'||typeof OUTFITS==='undefined') return 'SKIP: no painter or outfits here';
     var kb=COSKEY.build||'cosBuild', ko=COSKEY.outfit||'cosOutfit', b0=P[kb], o0=P[ko], a0=P.cosAll, w0=wc, cv=document.createElement('canvas'), x2, bad=[];
     cv.width=240; cv.height=220; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function paint(){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,240,220); x2.setTransform(4,0,0,4,120,190); wc=x2; drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); wc=w0; x2.setTransform(1,0,0,1,0,0); }
     function darkAt(lx,ly){ var d=x2.getImageData(Math.round(120+lx*4),Math.round(190+ly*4),1,1).data; return d[3]>40&&d[0]<40&&d[1]<40&&d[2]<45; }
     function rose(){ var d=x2.getImageData(108,88,24,6).data, j, n=0; for(j=0;j<d.length;j+=4) if(d[j+3]>200&&d[j]>170&&d[j+1]<120&&d[j+2]>80) n++; return n; }
     try{
       P.cosAll=true; P[kb]='curved';
       P[ko]='outballer'; paint();
       if(darkAt(6.4,-14.9)) bad.push('the Baller jersey panel shows outside the Curved waist');
       P[ko]='outtrooper'; paint();
       if(rose()>3) bad.push('the Trooper helmet shows a rose mouth');
     }catch(e){ wc=w0; bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; P[kb]=b0; P[ko]=o0; P.cosAll=a0; }
     return bad.length?bad.join('; '):null; }},
  {v:'20.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
