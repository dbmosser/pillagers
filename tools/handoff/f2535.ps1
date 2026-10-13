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

if ($s.Contains("  {v:'25.35',what:")) { throw "check 25.35 is in the fixture already" }

SubRx @'
  {v:'25.34',what:
'@ @'
  {v:'25.35',what:'his #50 (UI redesign ui5q2f): out of reach, GAMBLE (and the offer BUY) carry a chip saying how much more they need, and none when they can be paid',
   run:function(){
     if(typeof renderGamble!=='function') return 'SKIP: no Wirt here';
     var c0=P.credits, bad=[], b, a, lb;
     try{
       P.credits=900; renderGamble();
       b=document.getElementById('gamblebtn'); a=getComputedStyle(b,'::after').content||'';
       if(a.indexOf('NEED')<0) bad.push('GAMBLE out of reach has no reason chip ('+a+')');
       else if(a.indexOf('1,600')<0) bad.push('the GAMBLE chip does not name the 1,600 still needed: '+a);
       lb=document.getElementById('wirtlotbtn');
       if(lb&&lb.disabled&&(getComputedStyle(lb,'::after').content||'').indexOf('NEED')<0) bad.push('the offer BUY out of reach has no reason chip');
       P.credits=9999999; renderGamble();
       a=getComputedStyle(document.getElementById('gamblebtn'),'::after').content||'';
       if(a.indexOf('NEED')>=0) bad.push('GAMBLE that can be paid still shows a chip');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.credits=c0; try{ renderGamble(); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'25.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
