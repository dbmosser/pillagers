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

if ($s.Contains("  {v:'32.69',what:")) { throw "check 32.69 is in the fixture already" }

SubRx @'
  {v:'32.68',what:
'@ @'
  {v:'32.69',what:'named stash heading, neutral freebie action, no idle keyboard sentence or toast over the open stash (J4 critic)',
   run:function(){
     if(!window.__hubEnter||!window.__station)return 'SKIP: this fixture cannot open the stash';
     var bad=[],oldName=P.pname,oldText=document.getElementById('hubtoast').textContent,oldClass=document.getElementById('hubtoast').className;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();__wnseen(1);
       __hubEnter();P.pname='nilo';__station('term','KeyE');renderHub();
       var name=document.getElementById('stashname'),brand=name.closest('.brand'),detail=document.getElementById('stashdetail'),fk=document.querySelector('#hubfreekit .fkbox'),btn=fk&&fk.querySelector('button');
       if(name.textContent!=='nilo'||!/^stash\s*\//i.test(brand.textContent))bad.push('stash heading does not identify the screen and save');
       if(!/Barlow Condensed|Bahnschrift SemiCondensed|Arial Narrow/.test(getComputedStyle(name).fontFamily))bad.push('save name uses a different font');
       if(detail.textContent.trim()||getComputedStyle(detail).display!=='none')bad.push('idle help sentence or empty detail strip remains');
       if(!fk||getComputedStyle(fk.querySelector('span')).display!=='none')bad.push('freebie description still competes with the action');
       // v28.xx (cw-cx-namestashview): the stash has menu zoom too; calibrate the required 3px border at that same scale.
       if(fk){var borderProbe=document.createElement('i');borderProbe.style.cssText='position:absolute;visibility:hidden;pointer-events:none;border-left:3px solid var(--acc)';fk.appendChild(borderProbe);var want=getComputedStyle(borderProbe),actual=getComputedStyle(fk);
         if(Math.abs(parseFloat(actual.borderLeftWidth)-parseFloat(want.borderLeftWidth))>0.01||actual.borderLeftStyle!=='solid'||actual.borderLeftColor!==want.borderLeftColor||actual.backgroundColor!=='rgb(22, 25, 27)')bad.push('freebie bar is not neutral with an accent tab: '+actual.borderLeftWidth+' expected '+want.borderLeftWidth);
         borderProbe.remove();}
       if(!btn||parseFloat(getComputedStyle(btn).minHeight)<48||getComputedStyle(btn).backgroundColor!=='rgb(230, 255, 61)')bad.push('freebie action is not a filled 48px button');
       var toast=document.getElementById('hubtoast');toast.textContent='welcome pack';toast.classList.add('on');
       if(getComputedStyle(toast).visibility!=='hidden')bad.push('toast competes with the open stash');
       var cell=document.querySelector('#stashgrid .cell');
       if(cell&&typeof cell.onmouseenter==='function'){cell.onmouseenter();if(!detail.textContent.trim()||getComputedStyle(detail).display==='none')bad.push('focused item details were lost');}
       return bad.length?bad.join('; '):null;
     }finally{
       try{__endRaid('abandon');}catch(e){}__topClear();document.getElementById('hub').classList.remove('on');
       P.pname=oldName;document.getElementById('hubtoast').textContent=oldText;document.getElementById('hubtoast').className=oldClass;
     }
   }},
  {v:'32.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
