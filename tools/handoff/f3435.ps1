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

if ($s.Contains("  {v:'34.35',what:")) { throw "check 34.35 is in the fixture already" }

SubRx @'
  {v:'34.34',what:
'@ @'
  {v:'34.35',what:'Settings: a key or pad step keeps the focused row clear of the list edge and the bottom fade, the rail and the list never both wear the focus look, the clicked tab is the lit tab, restore is not a lime box, no row runs past the card',
   run:function(){
     var bad=[], list, card, rows=[], i, r, lr, cr, zf, fails=0, first='', chip, on, cs, dr, rest, rb, els;
     function inView(row){ var q=row.getBoundingClientRect(); return q.top>=lr.top-0.5 && q.bottom<=lr.bottom-24*zf+0.5; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       G=null; __hubEnter(); __topClear(); openSettings();
       list=document.getElementById('setlist'); card=document.getElementById('settingsmodal');
       if(!list||!card) return 'Settings did not open';
       [].forEach.call(list.querySelectorAll('.row:not(.setjump)'),function(x){ if(x.querySelector('div > b')&&x.querySelector('button')&&!/opacity:\s*\.7/.test(x.getAttribute('style')||'')) rows.push(x); });
       if(rows.length<12) return 'SKIP: staging: only '+rows.length+' settings rows';
       lr=list.getBoundingClientRect(); zf=(list.offsetHeight>0)?lr.height/list.offsetHeight:1;
       list.scrollTop=0;
       for(i=0;i<rows.length;i++){ padSetFocus(rows[i].querySelector('button')); if(!inView(rows[i])){ fails++; if(!first) first='going down '+rows[i].querySelector('b').textContent; } }
       for(i=rows.length-1;i>=0;i--){ padSetFocus(rows[i].querySelector('button')); if(!inView(rows[i])){ fails++; if(!first) first='coming back '+rows[i].querySelector('b').textContent; } }
       if(fails) bad.push(fails+' key steps left the focused row cut or in the bottom fade, first '+first);
       cr=card.getBoundingClientRect(); els=list.querySelectorAll('.row, .row > button');
       for(i=0;i<els.length;i++){ r=els[i].getBoundingClientRect(); if(r.width>0&&(r.right>cr.right+0.5||r.right>lr.right+0.5)){ bad.push('a row runs past the card edge: '+(els[i].textContent||'').slice(0,24)); break; } }
       chip=list.querySelector('.setjump button[data-sec="ACCESSIBILITY"]');
       if(!chip) return 'no accessibility tab';
       chip.onclick();
       on=list.querySelectorAll('.setjump button.on');
       if(on.length!==1||on[0].getAttribute('data-sec')!=='ACCESSIBILITY') bad.push('the clicked tab is not the lit tab: '+[].map.call(on,function(x){return x.getAttribute('data-sec');}).join(','));
       padSetFocus(chip); if(window.__setDetailSync) window.__setDetailSync();
       [].forEach.call(list.querySelectorAll('.setjump button, .row'),function(x){ x.style.setProperty('transition','none','important'); });
       cs=getComputedStyle(chip);
       if(cs.outlineStyle!=='none'&&parseFloat(cs.outlineWidth)>0) bad.push('the focused tab still draws an outline box');
       dr=list.querySelector('.row.dshow:not(.setjump)');
       if(dr&&/230, 255, 61/.test(getComputedStyle(dr).boxShadow)) bad.push('the list row wears the focus bar while the tab has the focus');
       rest=document.getElementById('set_restore');
       if(!rest) bad.push('no restore button'); else { rest.style.setProperty('transition','none','important'); rb=getComputedStyle(rest).backgroundColor; if(rb!=='rgba(0, 0, 0, 0)'&&rb!=='transparent') bad.push('restore is a filled box: '+rb); }
       return bad.length?bad.join('; '):null;
     } finally {
       try{ document.querySelectorAll('.padfocus').forEach(function(x){ x.classList.remove('padfocus'); }); }catch(e){}
       __topClear();
     } }},
  {v:'34.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
