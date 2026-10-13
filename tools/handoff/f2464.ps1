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

if ($s.Contains("  {v:'24.64',what:")) { throw "check 24.64 is in the fixture already" }

SubRx @'
  {v:'24.63',what:
'@ @'
  {v:'24.64',what:'his #50 (UI redesign ui5q1d, from the AAA judge and the lint of the stash shot): on the stash, drawn at 0.92 of the window size (his v9.67 note), no label paints under the 13px floor (font size times the zoom), and the stash tabs are 16px',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], hub, z, q, i, el, f, low=[], tab, n=0;
     function zoomOf(e){ var zz=1; for(var p=e;p&&p.nodeType===1;p=p.parentElement){ zz*=(parseFloat(getComputedStyle(p).zoom)||1); } return zz; }
     try{
       __topClear(); __hubEnter(); __station('term','KeyE');
       hub=document.getElementById('hub');
       if(!hub||getComputedStyle(hub).display==='none') return 'SKIP: the stash did not open';
       // the stash zoom against the window factor (0.92 by his v9.67 note), so the headless window size does not move the measure
       z=(parseFloat(getComputedStyle(hub).zoom)||1)/((typeof menuScale==='function'&&menuScale())||1);
       q=hub.querySelectorAll('.brand,#verlabel,#stashsort,.lohead,.loslab,#invkeybar kbd,#sellhint,#stashtabs .invtab,.cell .cnt');
       for(i=0;i<q.length;i++){
         el=q[i]; if(!el.getClientRects().length) continue;
         n++; f=parseFloat(getComputedStyle(el).fontSize)*z;
         if(f<12.95) low.push((el.id||el.className||el.tagName)+' '+f.toFixed(1)+'px');
       }
       if(n<6) bad.push('only '+n+' stash labels were found to measure');
       if(low.length) bad.push(low.length+' stash labels paint under 13px at zoom '+z.toFixed(2)+': '+low.slice(0,5).join(', '));
       tab=hub.querySelector('#stashtabs .invtab');
       if(tab&&parseFloat(getComputedStyle(tab).fontSize)<16) bad.push('a stash tab is '+getComputedStyle(tab).fontSize);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
