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

if ($s.Contains("  {v:'20.99',what:")) { throw "check 20.99 is in the fixture already" }

SubRx @'
  {v:'20.98',what:
'@ @'
  {v:'20.99',what:'a name on a stat card sits level with the numbers: on a card holding a name the line under it starts as far down its card as on a card holding a number',
   run:function(){
     if(!(window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot open the Mainframe';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], t, sg, A=null, B=null, oa, ob, va, vb;
     try{
       __topClear(); __runPrep(); __cleanProfile(); if(window.__wnseen) __wnseen(1);
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mf','KeyT');
       sg=document.getElementById('statgrid'); if(!sg||!(sg.getBoundingClientRect().width>0)) return 'SKIP: the stat grid did not open';
       A=document.createElement('div'); A.className='scard'; A.innerHTML='<div class="sk">ZQX ONE</div><div class="sv">7</div><div class="ss">zqx under one</div>';
       B=document.createElement('div'); B.className='scard'; B.innerHTML='<div class="sk">ZQX TWO</div><div class="sv word">ZQXSTORE</div><div class="ss">zqx under two</div>';
       sg.appendChild(A); sg.appendChild(B);
       if(!(A.getBoundingClientRect().width>0&&B.getBoundingClientRect().width>0)) return 'SKIP: the test cards have no layout';
       oa=A.querySelector('.ss').getBoundingClientRect().top-A.getBoundingClientRect().top;
       ob=B.querySelector('.ss').getBoundingClientRect().top-B.getBoundingClientRect().top;
       va=A.querySelector('.sv').getBoundingClientRect().bottom-A.getBoundingClientRect().top;
       vb=B.querySelector('.sv').getBoundingClientRect().bottom-B.getBoundingClientRect().top;
       if(Math.abs(oa-ob)>1.5) bad.push('the line under a name starts '+(oa-ob).toFixed(1)+' px higher on its card than the line under a number');
       if(Math.abs(va-vb)>1.5) bad.push('a name ends '+(va-vb).toFixed(1)+' px higher on its card than a number');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(A&&A.parentNode) A.parentNode.removeChild(A); if(B&&B.parentNode) B.parentNode.removeChild(B); }catch(_r){} try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
