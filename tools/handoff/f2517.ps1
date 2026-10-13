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

if ($s.Contains("  {v:'25.17',what:")) { throw "check 25.17 is in the fixture already" }

SubRx @'
  {v:'25.16',what:
'@ @'
  {v:'25.17',what:'his #50 (UI redesign ui5q2l): every Fashion rack tile is the same height (at least 156px at the menu size) and at least 180px wide',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], q, i, z, h, lo=1e9, w;
     try{
       __topClear(); __hubEnter(); __station('mirror','KeyE');
       q=document.querySelectorAll('#appavatarpicker .costile');
       z=(((typeof menuScale==='function')&&menuScale())||1);
       var n=0;
       for(i=0;i<q.length;i++){ if(!q[i].getClientRects().length) continue; n++; h=q[i].getBoundingClientRect().height/z; if(h<lo) lo=h; }
       if(n<10) return 'SKIP: Fashion drew '+n+' rack tiles';
       if(lo<150) bad.push('the shortest rack tile is '+Math.round(lo)+'px high, so the racks jump in height');
       w=q[0].getBoundingClientRect().width/z;
       if(w<180) bad.push('a rack tile is '+Math.round(w)+'px wide');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'25.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
