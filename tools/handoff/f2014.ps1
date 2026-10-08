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

if ($s.Contains("  {v:'20.14',what:")) { throw "check 20.14 is in the fixture already" }

SubRx @'
  {v:'20.13',what:
'@ @'
  {v:'20.14',what:'a crouch does not throw the chest: dropping into a crouch and standing up again moves a Curved chest by less than 0.3',
   run:function(){
     if(typeof drawOp!=='function'||typeof bodyJiggle!=='function') return 'SKIP: no jiggle here';
     var bad=[], w0=wc, cv=document.createElement('canvas'), x2, own={wep:null}, k=(typeof COSKEY!=='undefined'&&COSKEY.build)||'cosBuild', b0=P[k], i, mx=0, modes=['','','','crouch','crouch','crouch','crouch','','','',''];
     cv.width=60; cv.height=60; x2=cv.getContext('2d');
     try{
       P[k]='curved'; wc=x2;
       for(i=0;i<modes.length;i++){ if(own._jg) own._jg.t-=17; drawOp(0,300,0,0,'#242832',0,0,modes[i],0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:own}); if(own._jg) mx=Math.max(mx,Math.abs(own._jg.c)); }
       wc=w0;
       if(!own._jg) return 'SKIP: no spring state';
       if(mx>=0.3) bad.push('a crouch threw the chest by '+mx.toFixed(2));
     }catch(e){ wc=w0; bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; P[k]=b0; }
     return bad.length?bad.join('; '):null; }},
  {v:'20.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
