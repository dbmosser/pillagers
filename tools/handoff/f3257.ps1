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

if ($s.Contains("  {v:'32.57',what:")) { throw "check 32.57 is in the fixture already" }

SubRx @'
  {v:'32.56',what:
'@ @'
  {v:'32.57',what:'the pre-raid page sixth pass: map labels sit on a dark pill, the window title is 32 px and bigger than the sector name, the footer lists ascend once, and the no armour row is 16 px with a warn bar',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded)||typeof renderSector!=='function') return 'SKIP: no pre-raid page';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), h3, nm, wb, h, st;
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.freeKit=0; q.kitPick='mine'; q.stash=['medkit']; q.kit=[]; q.equipped='fists';
       __hubEnter(); shut(); renderSector(); openModal('sectormodal');
       h3=sm.querySelector('h3'); nm=sm.querySelector('.srmh b'); wb=sm.querySelector('#sectorkit .wn b'); h=document.getElementById('srhints'); st=sm.querySelector('.srprow .st button');
       if(!h3||!nm||!wb||!h||!st) return 'the pre-raid page is not drawn';
       if(!(parseFloat(getComputedStyle(h3).fontSize)>parseFloat(getComputedStyle(nm).fontSize))) bad.push('the window title ('+getComputedStyle(h3).fontSize+') is not bigger than the sector name ('+getComputedStyle(nm).fontSize+')');
       if(parseFloat(getComputedStyle(wb).fontSize)>17) bad.push('the no armour words are '+getComputedStyle(wb).fontSize);
       if(/ascend/i.test(h.querySelector('.srk').textContent)) bad.push('the key footer still lists ascend, which the plate already shows');
       if(parseFloat(getComputedStyle(st).height)<43) bad.push('a stepper is '+getComputedStyle(st).height+' high, not 44');
       if(String(sectorPreviewDraw).indexOf('rgba(11,12,13,.78)')<0) bad.push('map labels have no dark pill');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ shut(); }catch(_s){} try{ if(snap) __applyLoaded(snap); }catch(_a){} try{ __cleanProfile(); }catch(_c){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
