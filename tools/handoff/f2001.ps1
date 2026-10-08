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

if ($s.Contains("  {v:'20.01',what:")) { throw "check 20.01 is in the fixture already" }

SubRx @'
  {v:'20.00',what:
'@ @'
  {v:'20.01',what:'the BUILD changes the body: drawn the same way, Curved flares wider than Lean at the hips with a narrower waist and a rose mouth, and Broad is wider than Lean at the shoulders',
   run:function(){
     if(typeof drawOp!=='function'||typeof COSKEY==='undefined') return 'SKIP: no painter here';
     var k=COSKEY.build||'cosBuild', b0=P[k], w0=wc, cv=document.createElement('canvas'), x2, res={}, bad=[], i, b;
     cv.width=240; cv.height=220; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function rightExtent(ly){ var row=x2.getImageData(120,Math.round(190+ly*4),120,1).data, j, r=0; for(j=0;j<120;j++) if(row[j*4+3]>40) r=j; return r; }
     function opaque(ly){ var row=x2.getImageData(0,Math.round(190+ly*4),240,1).data, j, n=0; for(j=0;j<240;j++) if(row[j*4+3]>40) n++; return n; }
     function mouthRose(){ var d=x2.getImageData(108,Math.round(190-25.0*4)-2,24,6).data, j, n=0; for(j=0;j<d.length;j+=4) if(d[j+3]>200&&d[j]>170&&d[j+1]<120&&d[j+2]>80) n++; return n; }
     try{
       for(i=0;i<3;i++){
         b=['lean','broad','curved'][i]; P[k]=b;
         x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,240,220); x2.setTransform(4,0,0,4,120,190);
         wc=x2; drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); wc=w0;
         x2.setTransform(1,0,0,1,0,0);
         res[b]={hip:rightExtent(-11.6),waist:rightExtent(-14.9),sh:rightExtent(-21.0),rose:mouthRose()};
       }
     }catch(e){ wc=w0; bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; P[k]=b0; }
     if(bad.length) return bad.join('; ');
     if(!(res.curved.hip>=res.lean.hip+4)) bad.push('Curved is not wider at the hips ('+res.curved.hip+' against Lean '+res.lean.hip+')');
     if(!(res.curved.waist<res.curved.hip-6)) bad.push('Curved has no waist ('+res.curved.waist+' at the waist, '+res.curved.hip+' at the hips)');
     if(!(res.broad.sh>=res.lean.sh+4)) bad.push('Broad is not wider at the shoulders ('+res.broad.sh+' against Lean '+res.lean.sh+')');
     if(!(res.curved.rose>3&&res.lean.rose===0)) bad.push('the rose mouth is missing on Curved or showing on Lean ('+res.curved.rose+'/'+res.lean.rose+')');
     return bad.length?bad.join('; '):null; }},
  {v:'20.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
