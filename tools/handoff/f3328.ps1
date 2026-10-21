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

if ($s.Contains("  {v:'33.28',what:")) { throw "check 33.28 is in the fixture already" }

SubRx @'
  {v:'33.27',what:
'@ @'
  {v:'33.28',what:'experimental settings use the existing layout without an empty rail, group all 28 switches, keep back outside the toggle rows, and align the focused effect and fixed raid choice below its value',
   run:function(){
     var bad=[], modal=document.getElementById('settingsmodal'), list=document.getElementById('setlist'), detail=document.getElementById('setdetail'), i,b,row,rect,lr,dr,groups,seen={},state,oldCls,oldSub=SETSUB;
     function sync(){ if(window.__setDetailSync) __setDetailSync(); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       oldCls=modal.className; modal.classList.add('on'); SETSUB='exp'; renderSettings(); sync();
       if(!modal.classList.contains('expmode')) return 'experimental page still reserves the absent category rail';
       if(parseFloat(getComputedStyle(list).paddingLeft)>1) bad.push('empty left category gutter remains');
       if(modal.querySelector('h3').textContent!=='settings / experimental') bad.push('missing page breadcrumb');
       b=document.getElementById('exp_back'); if(!b||b.closest('.row')) bad.push('Back is still a toggle row');
       groups=list.querySelectorAll('[data-exp-group]'); if(groups.length!==4) bad.push('expected four feature groups');
       if(list.querySelectorAll('button[id^="go_xf"]').length!==28) bad.push('not all 28 switches were drawn');
       lr=list.getBoundingClientRect();
       for(i=0;i<XF_KEYS.length;i++){
         b=document.getElementById('go_'+XF_KEYS[i]);
         if(!b||seen[b.id]){ bad.push('missing or duplicate '+XF_KEYS[i]); continue; } seen[b.id]=1;
         if(!b.querySelector('.expvalue')||String(b.textContent)!=='on'||b.getAttribute('aria-pressed')!=='true') bad.push('default on state is unclear for '+XF_KEYS[i]);
         row=b.closest('.row'); if(!row.classList.contains('exprow')) bad.push('ungrouped control '+XF_KEYS[i]);
       }
       b=document.getElementById('go_xfGoals'); row=b.closest('.row');
       rect=row.querySelector('b').getBoundingClientRect();
       if(rect.left-lr.left>36) bad.push('row labels still start in an empty left gutter');
       if(parseFloat(getComputedStyle(row.querySelector('b')).fontSize)<19) bad.push('row label below 20px body size');
       if(getComputedStyle(detail).flexDirection!=='column'||getComputedStyle(detail).flexWrap!=='nowrap') bad.push('detail text can still spread across the full pane height');
       if(!detail.querySelector('.sdv')||getComputedStyle(detail.querySelector('.sdv')).display==='none') bad.push('focused state is missing from detail');
       dr=detail.querySelector('.sdh').getBoundingClientRect(); rect=detail.querySelector('.sdk').getBoundingClientRect();
       if(dr.top-rect.bottom>140) bad.push('focused description is detached from its title');
       if(!detail.querySelector('.expnote')) bad.push('next-raid timing missing');
       // Existing click and save path, with clear on/off states. Restore the owner preference before leaving the check.
       b.onclick(); sync(); b=document.getElementById('go_xfGoals');
       if(CFG.xfGoals!==0||!P.gameOpts||P.gameOpts.xfGoals!==1||!b.closest('.expoff')||b.getAttribute('aria-pressed')!=='false'||b.textContent!=='off') bad.push('off value is not saved and visibly distinct');
       b.onclick(); sync(); if(CFG.xfGoals!==1) bad.push('cannot restore on');
       document.getElementById('exp_back').onclick(); sync();
       if(SETSUB!==''||modal.classList.contains('expmode')||!document.getElementById('exp_open')) bad.push('Back did not restore ordinary Settings layout');
     }catch(e){bad.push('threw: '+(e&&e.message||e));}
     finally{
       SETSUB=oldSub; if(P.gameOpts) delete P.gameOpts.xfGoals;
       __topClear(); __resetCfg(); __cleanProfile(); renderSettings(); if(oldCls!==undefined) modal.className=oldCls;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'33.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
