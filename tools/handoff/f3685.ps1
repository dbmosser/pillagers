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

if ($s.Contains("  {v:'36.85',what:")) { throw "check 36.85 is in the fixture already" }

SubRx @'
  {v:'36.84',what:
'@ @'
  {v:'36.85',what:'the racks page reads at a glance: a disabled button and an empty slot differ from an enabled one and a built one in fill, the rack counter is a style guide colour (not teal), and the cost parts are at least 16px',
   run:function(){
     if(!(window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot open the Mainframe';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], t, sl, ar, d0, d1, cn, hp, nt, allowed=['rgb(239, 233, 220)','rgb(230, 255, 61)','rgb(118, 185, 124)','rgb(245, 183, 59)','rgb(229, 72, 47)','rgb(170, 164, 152)'];
     function cs(el){ return getComputedStyle(el); }
     try{
       __topClear(); __runPrep(); __cleanProfile(); if(window.__wnseen) __wnseen(1);
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mf','KeyF');
       if(!(document.getElementById('opane_mf').getBoundingClientRect().width>0)) return 'SKIP: the RACKS page did not open';
       nt=document.createElement('style'); nt.textContent='#opane_mf *{transition:none !important}'; document.head.appendChild(nt);   // a button that just turned disabled is mid-transition, so its computed fill is still the old one
       P.racks=3; renderMainframe();
       sl=[].slice.call(document.querySelectorAll('#mfstatus > span'));
       if(sl.length<10) bad.push('only '+sl.length+' rack slots');
       else if(cs(sl[0]).backgroundColor===cs(sl[5]).backgroundColor) bad.push('a built slot and an empty slot have the same fill '+cs(sl[0]).backgroundColor);
       ar=document.getElementById('mfarray'); d0=cs(ar).backgroundColor+'|'+cs(ar).opacity; d1=cs(document.getElementById('mfghost')).backgroundColor+'|'+cs(document.getElementById('mfghost')).opacity;
       cn=document.querySelector('#mfstatus b');
       if(!cn) bad.push('no rack counter');
       else if(allowed.indexOf(cs(cn).color)<0) bad.push('the rack counter is '+cs(cn).color+', not a style guide colour');
       hp=document.querySelector('#mfhint .rkp');
       if(!hp) bad.push('the cost line has no part spans'); else if(!(parseFloat(cs(hp).fontSize)>=16)) bad.push('the cost parts are '+cs(hp).fontSize);
       if(!ar.disabled||document.getElementById('mfghost').disabled) bad.push('expected the fold button disabled and the import button enabled');
       else if(d0===d1) bad.push('a disabled button looks the same as an enabled one: '+d0+' / '+d1);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(nt&&nt.parentNode) nt.parentNode.removeChild(nt); }catch(_n){} try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'36.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
