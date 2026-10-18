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

if ($s.Contains("  {v:'30.72',what:")) { throw "check 30.72 is in the fixture already" }

SubRx @'
  {v:'30.71',what:
'@ @'
  {v:'30.72',what:'every word on screen is lower case (his order: change all text shown to player to lowercase only)',
   run:function(){
     if(typeof ncFix!=='function'||typeof TX!=='function'||typeof txRecord!=='function') return 'SKIP: no text door';
     var bad=[], cv=document.createElement('canvas'), x=cv.getContext('2d'), h, up=/[A-Z]/;
     ['Run info','CREATE A NEW SAVE','Location revealed','Ascend. Pillage. Extract.','PRESS A','12 SP','Esc'].forEach(function(s){
       var r=TX(s); if(typeof r==='string'&&up.test(r)) bad.push(s+' reads '+r); });
     h=txRecord(function(){ x.font='20px sans-serif'; x.fillText(['Machine','Alert'].join(' '),0,20); });
     if(!h.length||up.test(h[0].t)) bad.push('a drawn line still has capitals: '+(h[0]&&h[0].t));
     var b=document.getElementById('newgame');
     if(b&&typeof txDom==='function'){ txDom(b.parentNode); if(up.test(b.textContent)) bad.push('the new save button reads '+b.textContent); }
     var pe=null; try{ var d=document.createElement('div'); d.className='__lcx'; document.body.appendChild(d); pe=getComputedStyle(d,'::before').textTransform; d.remove(); }catch(_p){}
     if(pe!=='lowercase') bad.push('stylesheet words are not lowered ('+pe+')');
     return bad.length?bad.join('; '):null;
   }},
  {v:'30.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
