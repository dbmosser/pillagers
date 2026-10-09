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

if ($s.Contains("  {v:'20.98',what:")) { throw "check 20.98 is in the fixture already" }

SubRx @'
  {v:'20.97',what:
'@ @'
  {v:'20.98',what:'the line under each drink at the bar starts under the drink name, not a step to the right of it',
   run:function(){
     if(!(window.__hubEnter&&window.__station)||typeof renderBar!=='function') return 'SKIP: no bar here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], t, rows, i, b, h, xb, xh, n=0;
     function tx(el){ var g=document.createRange(), r; g.selectNodeContents(el); r=g.getBoundingClientRect(); return (r&&r.width>0)?r.left:null; }
     try{
       __topClear(); __runPrep(); __cleanProfile(); if(window.__wnseen) __wnseen(1);
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('bar','KeyE');
       rows=[].slice.call(document.querySelectorAll('.modal.on .row')).filter(function(r){ return !!r.querySelector('[data-bz]'); });
       if(!rows.length) return 'SKIP: no drink rows';
       for(i=0;i<rows.length;i++){
         b=rows[i].querySelector('b'); h=rows[i].querySelector('.hint'); if(!b||!h) continue;
         xb=tx(b); xh=tx(h); if(xb===null||xh===null) continue; n++;
         if(Math.abs(xh-xb)>1.5) bad.push('the line under '+String(b.textContent||'').trim()+' starts '+(xh-xb).toFixed(1)+' px to the right of the name');
       }
       if(!n) return 'SKIP: no drink row has both a name and a line under it';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
