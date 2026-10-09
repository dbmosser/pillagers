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

if ($s.Contains("  {v:'20.96',what:")) { throw "check 20.96 is in the fixture already" }

SubRx @'
  {v:'20.95',what:
'@ @'
  {v:'20.96',what:'the reward marks stand in one column: every box at the end of a REWARDS row is the same width and starts at the same place',
   run:function(){
     if(!(window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot open the Mainframe';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], t, bs, i, r, w0=1e9, w1=0, l0=1e9, l1=0, n=0, wide='', thin='';
     try{
       __topClear(); __runPrep(); __cleanProfile(); if(window.__wnseen) __wnseen(1);
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mf','KeyR');
       bs=[].slice.call(document.querySelectorAll('#seasonlist .row button'));
       for(i=0;i<bs.length;i++){
         r=bs[i].getBoundingClientRect(); if(!(r.width>0)) continue; n++;
         if(r.width<w0){ w0=r.width; thin=String(bs[i].textContent||'').trim(); }
         if(r.width>w1){ w1=r.width; wide=String(bs[i].textContent||'').trim(); }
         l0=Math.min(l0,r.left); l1=Math.max(l1,r.left);
       }
       if(n<6) return 'SKIP: fewer than six reward rows have layout';
       if(w1-w0>1) bad.push('the boxes run from '+w0.toFixed(1)+' px ('+thin+') to '+w1.toFixed(1)+' px ('+wide+') wide');
       if(l1-l0>1) bad.push('their left edges wander over '+(l1-l0).toFixed(1)+' px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
