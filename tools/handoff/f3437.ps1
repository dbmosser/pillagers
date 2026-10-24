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

if ($s.Contains("  {v:'34.37',what:")) { throw "check 34.37 is in the fixture already" }

SubRx @'
  {v:'34.36',what:
'@ @'
  {v:'34.37',what:'Settings: a focused tab has no halo ring, a clicked tab leaves no list row lit, the section line shows no sliver of its label',
   run:function(){
     var bad=[], list, chip, dr, head, cs;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       G=null; __hubEnter(); __topClear(); openSettings();
       list=document.getElementById('setlist'); if(!list) return 'Settings did not open';
       chip=list.querySelector('.setjump button[data-sec="ACCESSIBILITY"]'); if(!chip) return 'no accessibility tab';
       chip.onclick(); chip.focus({preventScroll:true}); padSetFocus(chip); if(window.__setDetailSync) window.__setDetailSync();
       [].forEach.call(list.querySelectorAll('.setjump button, .row.dshow'),function(x){ x.style.setProperty('transition','none','important'); });
       cs=getComputedStyle(chip);
       if(/230, 255, 61/.test(cs.boxShadow)) bad.push('the focused tab still draws the halo ring');
       chip.classList.remove('padfocus'); chip.focus({preventScroll:true});
       dr=list.querySelector('.row.dshow:not(.setjump)');
       if(dr&&/230, 255, 61/.test(getComputedStyle(dr).boxShadow)) bad.push('a clicked tab leaves a list row wearing the focus bar');
       [].forEach.call(list.querySelectorAll('.row'),function(x){ if(!head&&/opacity:\s*0?\.7/.test(x.getAttribute('style')||'')&&x.id&&getComputedStyle(x).display!=='none') head=x; });
       if(!head) return 'SKIP: no section head';
       head.firstElementChild.style.setProperty('transition','none','important');
       if(getComputedStyle(head.firstElementChild).visibility!=='hidden') bad.push('the section line shows a sliver of its hidden label ['+head.id+' '+head.firstElementChild.tagName+' '+getComputedStyle(head.firstElementChild).visibility+' '+getComputedStyle(head).height+' '+(head.getAttribute('style')||'')+']');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ document.querySelectorAll('.padfocus').forEach(function(x){ x.classList.remove('padfocus'); }); if(document.activeElement) document.activeElement.blur(); }catch(e){}
       __topClear();
     } }},
  {v:'34.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
