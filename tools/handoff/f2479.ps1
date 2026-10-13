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

if ($s.Contains("  {v:'24.79',what:")) { throw "check 24.79 is in the fixture already" }

SubRx @'
  {v:'24.78',what:
'@ @'
  {v:'24.79',what:'his #50 (UI redesign ui5q1o, from the AAA judge of the Last Pour shot): a drink name is 19px or more in caps, its price 20px or more, and INGEST is at least 46px tall with a 16px label, amber when it can be bought and never in the faint third text colour',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], b, nm, pr, s;
     try{
       __topClear(); __hubEnter(); __station('bar','KeyE');
       b=document.querySelector('#barmodal button[data-bz]');
       if(!b||!b.getClientRects().length) return 'SKIP: the Last Pour did not open here';
       nm=b.parentNode.querySelector('b'); pr=b.parentNode.querySelector('.vl');
       if(nm){ s=getComputedStyle(nm); if(!(parseFloat(s.fontSize)>=19)||s.textTransform!=='uppercase') bad.push('a drink name is '+s.fontSize+' '+s.textTransform); }
       if(pr&&!(parseFloat(getComputedStyle(pr).fontSize)>=20)) bad.push('a drink price is '+getComputedStyle(pr).fontSize);
       s=getComputedStyle(b);
       if(!(parseFloat(s.minHeight)>=46)) bad.push('INGEST is held to '+s.minHeight);
       if(!(parseFloat(s.fontSize)>=16)) bad.push('INGEST is '+s.fontSize);
       if(!b.disabled&&s.backgroundColor!=='rgb(245, 183, 59)') bad.push('INGEST is not amber ('+s.backgroundColor+')');
       if(b.disabled&&s.color==='rgb(122, 118, 110)') bad.push('a greyed INGEST is in the faint third text colour');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
