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

if ($s.Contains("  {v:'31.10',what:")) { throw "check 31.10 is in the fixture already" }

SubRx @'
  {v:'31.09',what:
'@ @'
  {v:'31.10',what:'the shop window is a card with a 5 percent margin on every side (90 x 90 of the screen), and its X sits inside the card',
   run:function(){
     if(!(window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], m, cs, tw=window.innerWidth, th=window.innerHeight, b, q;
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       openTrader('buy');
       m=document.getElementById('tradermodal'); if(!m) return 'no shop window';
       cs=getComputedStyle(m,'::before');
       var t=parseFloat(cs.top), l=parseFloat(cs.left), r=parseFloat(cs.right), bo=parseFloat(cs.bottom);
       if(!(Math.abs(t-th*0.05)<=3)) bad.push('the card top margin is '+Math.round(t)+' px, not 5 percent ('+Math.round(th*0.05)+')');
       if(!(Math.abs(bo-th*0.05)<=3)) bad.push('the card bottom margin is '+Math.round(bo)+' px, not 5 percent');
       if(!(Math.abs(l-tw*0.05)<=3)) bad.push('the card left margin is '+Math.round(l)+' px, not 5 percent ('+Math.round(tw*0.05)+')');
       if(!(Math.abs(r-tw*0.05)<=3)) bad.push('the card right margin is '+Math.round(r)+' px, not 5 percent');
       b=document.getElementById('closetrader'); q=b?b.getBoundingClientRect():null;
       if(!q||!(q.width>8)) bad.push('the shop X has no box');
       else if(!(q.right<=tw*0.95&&q.left>tw*0.8&&q.top>=th*0.05-1)) bad.push('the shop X is not inside the card top right ('+Math.round(q.left)+','+Math.round(q.top)+','+Math.round(q.right)+')');
       if(b) b.click();
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'31.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
