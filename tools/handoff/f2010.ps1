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

if ($s.Contains("  {v:'20.10',what:")) { throw "check 20.10 is in the fixture already" }

SubRx @'
  {v:'20.09',what:
'@ @'
  {v:'20.10',what:'the gun arm follows the build: drawn with a gun at rest, the Broad sleeve is thicker than the Lean one and the Curved sleeve slimmer',
   run:function(){
     if(typeof drawOp!=='function'||typeof COSKEY==='undefined') return 'SKIP: no painter here';
     var k=COSKEY.build||'cosBuild', b0=P[k], w0=wc, cv=document.createElement('canvas'), x2, res={}, bad=[], i, b, of=null;
     cv.width=60; cv.height=60; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     var oFR=x2.fillRect, rec=[];
     x2.fillRect=function(x,y,w,h){ if(x2.fillStyle==='#242832') rec.push(h); return oFR.apply(this,arguments); };
     try{
       for(i=0;i<3;i++){ b=['lean','broad','curved'][i]; P[k]=b; rec.length=0; wc=x2; drawOp(0,0,0,0,'#242832',0,0,'',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); wc=w0; res[b]=rec.length?Math.max.apply(null,rec):0; }
     }catch(e){ wc=w0; bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; P[k]=b0; delete x2.fillRect; }
     if(bad.length) return bad.join('; ');
     if(!(res.lean>0)) return 'SKIP: no sleeve was drawn';
     if(!(res.broad>res.lean&&res.curved<res.lean)) bad.push('sleeve heights lean '+res.lean+', broad '+res.broad+', curved '+res.curved);
     return bad.length?bad.join('; '):null; }},
  {v:'20.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
