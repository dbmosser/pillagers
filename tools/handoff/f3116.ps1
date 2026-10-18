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

if ($s.Contains("  {v:'31.16',what:")) { throw "check 31.16 is in the fixture already" }

SubRx @'
  {v:'31.15',what:
'@ @'
  {v:'31.16',what:'the shop grid and detail reach the bottom of the card, the subtitle is gone, and the answer line sits inside the card',
   run:function(){
     if(!(window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], g, d, sub, t, th=window.innerHeight, q, q2;
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       openTrader('buy');
       g=document.getElementById('shopgrid'); d=document.getElementById('shopdetail');
       q=g?g.getBoundingClientRect():null; q2=d?d.getBoundingClientRect():null;
       if(!q||!(q.height>40)) bad.push('the shop grid has no box');
       else if(!(q.bottom>=th*0.95-130)) bad.push('the shop grid ends at '+Math.round(q.bottom)+' of '+th+', short of the card foot');
       if(q2&&q2.height>40&&!(q2.bottom>=th*0.95-130)) bad.push('the shop detail ends at '+Math.round(q2.bottom)+' of '+th);
       sub=document.querySelector('#tpane_buy .msub');
       if(sub&&getComputedStyle(sub).display!=='none') bad.push('the buy subtitle line still shows');
       t=document.getElementById('hubtoast');
       if(t&&!(parseFloat(getComputedStyle(t).bottom)>=th*0.05+6)) bad.push('the answer line sits on the card border ('+getComputedStyle(t).bottom+' up)');
       var b=document.getElementById('closetrader'); if(b) b.click();
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'31.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
