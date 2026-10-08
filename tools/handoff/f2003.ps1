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

if ($s.Contains("  {v:'20.03',what:")) { throw "check 20.03 is in the fixture already" }

SubRx @'
  {v:'20.02',what:
'@ @'
  {v:'20.03',what:'your teammate sees your build: the look you send carries the build, a bad build id is dropped, and the teammate is drawn in the build sent on the floor and in a raid',
   run:function(){
     if(typeof netLook!=='function'||typeof netLookClean!=='function'||typeof netDrawPeer!=='function'||typeof netUpDrawOne!=='function') return 'SKIP: no co-op look here';
     var bad=[], k=(typeof COSKEY!=='undefined'&&COSKEY.build)||'cosBuild', b0=P[k], od=drawOp, seen=[], lk, c1, c2;
     try{
       P[k]='curved'; lk=netLook();
       if(!lk||lk.build!=='curved') bad.push('the look sent does not carry the build ('+(lk&&lk.build)+')');
       c1=netLookClean({build:'curved'}); c2=netLookClean({build:'zqbadbuild'});
       if(!c1||c1.build!=='curved') bad.push('a received Curved build was dropped');
       if(c2&&c2.build) bad.push('a bad build id was kept');
       drawOp=function(x,y,f,ph,co,pk,mu,mode,iv,st){ seen.push(st&&st.build); };
       netDrawPeer({x:0,y:0,f:0,bob:0,roll:0,lk:{build:'curved'}});
       netUpDrawOne({x:0,y:0,f:0,bob:0,roll:0,lk:{build:'curved'}});
       drawOp=od;
       if(seen.length<2) bad.push('the teammate was not drawn ('+seen.length+' draws)');
       else if(seen[0]!=='curved'||seen[1]!=='curved') bad.push('the teammate is drawn without the build (floor '+seen[0]+', raid '+seen[1]+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ drawOp=od; P[k]=b0; }
     return bad.length?bad.join('; '):null; }},
  {v:'20.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
