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

if ($s.Contains("  {v:'20.97',what:")) { throw "check 20.97 is in the fixture already" }

SubRx @'
  {v:'20.96',what:
'@ @'
  {v:'20.97',what:'the RACKS page lines up on one left edge: the rack row, BUILD A RACK and the rack cost line start where the line at the top starts',
   run:function(){
     if(!(window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot open the Mainframe';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], t, pane, ms, st, bt, hn, x0, xs, i;
     function tx(el){ var g=document.createRange(), r; g.selectNodeContents(el); r=g.getBoundingClientRect(); return (r&&r.width>0)?r.left:null; }
     try{
       __topClear(); __runPrep(); __cleanProfile(); if(window.__wnseen) __wnseen(1);
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mf','KeyF');
       pane=document.getElementById('opane_mf'); if(!pane||!(pane.getBoundingClientRect().width>0)) return 'SKIP: the RACKS page did not open';
       ms=pane.querySelector('.msub'); st=document.getElementById('mfstatus'); bt=document.getElementById('mfbuild'); hn=document.getElementById('mfhint');
       if(!ms||!st||!bt||!hn) return 'SKIP: the RACKS page is not built as expected';
       x0=tx(ms); if(x0===null) return 'SKIP: the line at the top of the page is empty';
       xs=[['the row of rack boxes',st.firstElementChild?st.firstElementChild.getBoundingClientRect().left:tx(st)],['BUILD A RACK',bt.getBoundingClientRect().left],['the rack cost line',tx(hn)]];
       for(i=0;i<xs.length;i++){ if(xs[i][1]===null) continue; if(Math.abs(xs[i][1]-x0)>1.5) bad.push(xs[i][0]+' starts '+(xs[i][1]-x0).toFixed(1)+' px to the right of the line at the top'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
